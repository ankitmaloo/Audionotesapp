import Foundation
import AudioToolbox
import OSLog

@MainActor
final class MicrophoneActivityMonitor: ObservableObject {

    @Published private(set) var isActive = false

    private let logger = Logger(subsystem: kAppSubsystem, category: String(describing: MicrophoneActivityMonitor.self))
    private let callbackQueue = DispatchQueue(label: "MicrophoneActivityMonitor")

    private var defaultInputListener: AudioObjectPropertyListenerBlock?
    private var deviceRunningListener: AudioObjectPropertyListenerBlock?

    private var defaultInputDevice: AudioDeviceID = .unknown
    private var monitoring = false

    func start() throws {
        guard !monitoring else { return }
        monitoring = true
        logger.debug("Starting microphone monitor")

        try observeDefaultInputChanges()
        try refreshDefaultInputDevice()
        updateActiveState()
    }

    func stop() {
        guard monitoring else { return }
        monitoring = false

        logger.debug("Stopping microphone monitor")

        removeDeviceListener()
        removeDefaultInputListener()
        defaultInputDevice = .unknown
        isActive = false
    }

    private func observeDefaultInputChanges() throws {
        removeDefaultInputListener()

        var address = AudioObjectPropertyAddress(
            mSelector: kAudioHardwarePropertyDefaultInputDevice,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )

        let listener: AudioObjectPropertyListenerBlock = { [weak self] _, _ in
            Task { @MainActor [weak self] in
                try? self?.refreshDefaultInputDevice()
            }
        }

        let status = AudioObjectAddPropertyListenerBlock(.system, &address, callbackQueue, listener)
        guard status == noErr else { throw "Unable to observe default input changes: \(status)" }

        defaultInputListener = listener
    }

    private func refreshDefaultInputDevice() throws {
        let newDevice = try AudioObjectID.system.readDefaultInputDevice()
        if newDevice != defaultInputDevice {
            removeDeviceListener()
            defaultInputDevice = newDevice
            try attachDeviceListener()
        }
        updateActiveState()
    }

    private func attachDeviceListener() throws {
        guard defaultInputDevice.isValid else { return }

        var address = AudioObjectPropertyAddress(
            mSelector: kAudioDevicePropertyDeviceIsRunningSomewhere,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )

        let listener: AudioObjectPropertyListenerBlock = { [weak self] _, _ in
            Task { @MainActor [weak self] in
                self?.updateActiveState()
            }
        }

        var deviceID = defaultInputDevice
        let status = AudioObjectAddPropertyListenerBlock(deviceID, &address, callbackQueue, listener)
        guard status == noErr else { throw "Unable to observe microphone device state: \(status)" }

        deviceRunningListener = listener
    }

    private func removeDeviceListener() {
        guard let listener = deviceRunningListener, defaultInputDevice.isValid else { return }

        var deviceID = defaultInputDevice
        var address = AudioObjectPropertyAddress(
            mSelector: kAudioDevicePropertyDeviceIsRunningSomewhere,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )

        AudioObjectRemovePropertyListenerBlock(deviceID, &address, callbackQueue, listener)
        deviceRunningListener = nil
    }

    private func removeDefaultInputListener() {
        guard let listener = defaultInputListener else { return }

        var address = AudioObjectPropertyAddress(
            mSelector: kAudioHardwarePropertyDefaultInputDevice,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )

        AudioObjectRemovePropertyListenerBlock(.system, &address, callbackQueue, listener)
        defaultInputListener = nil
    }

    private func updateActiveState() {
        guard monitoring else { return }

        let active = defaultInputDevice.readDeviceIsRunningSomewhere()
        if isActive != active {
            isActive = active
            logger.debug("Microphone active state changed: \(active)")
        }
    }
}
