import Foundation
import AVFoundation
import AppKit

@MainActor
final class AudioRecordingPermission: ObservableObject {
    enum Status {
        case unknown
        case authorized
        case denied
    }
    
    @Published private(set) var status: Status = .unknown
    
    init() {
        checkCurrentPermission()
        
        // Check permission when app becomes active
        NotificationCenter.default.addObserver(
            forName: NSApplication.didBecomeActiveNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                self?.checkCurrentPermission()
            }
        }
    }
    
    func request() {
        AVCaptureDevice.requestAccess(for: .audio) { [weak self] granted in
            Task { @MainActor in
                self?.status = granted ? .authorized : .denied
            }
        }
    }
    
    private func checkCurrentPermission() {
        let authStatus = AVCaptureDevice.authorizationStatus(for: .audio)
        switch authStatus {
        case .authorized:
            status = .authorized
        case .denied, .restricted:
            status = .denied
        case .notDetermined:
            status = .unknown
        @unknown default:
            status = .unknown
        }
    }
}