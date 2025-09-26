import SwiftUI

struct OpenAISettingsPanelView: View {
    // Persisted settings
    @AppStorage("openAIBaseURL") private var openAIBaseURL: String = "https://api.openai.com/v1"
    @AppStorage("openAITranscriptionModel") private var openAITranscriptionModel: String = "whisper-1"
    @AppStorage("openAITextModel") private var openAITextModel: String = "gpt-5"
    @AppStorage("openAIAPIKey") private var openAIAPIKey: String = ""

    // Working copies for editing
    @State private var baseURL: String = "https://api.openai.com/v1"
    @State private var transcriptionModel: String = "whisper-1"
    @State private var textModel: String = "gpt-5"
    @State private var apiKey: String = ""
    @State private var isTesting = false
    @State private var testMessage: String = ""
    @State private var testIsError = false

    var onDone: (() -> Void)?

    private let defaultBaseURL = "https://api.openai.com/v1"
    private let defaultTranscriptionModel = "whisper-1"
    private let defaultTextModel = "gpt-5"

    var body: some View {
        VStack(spacing: 16) {
            header
            form
            footer
        }
        .padding(16)
        .frame(minWidth: 460)
        .onAppear {
            baseURL = openAIBaseURL
            transcriptionModel = openAITranscriptionModel
            textModel = openAITextModel
            apiKey = openAIAPIKey
        }
    }

    @ViewBuilder
    private var header: some View {
        HStack(spacing: 12) {
            Image(systemName: "gearshape.fill")
                .font(.system(size: 28))
                .foregroundColor(.blue)
                .frame(width: 36, height: 36)
            VStack(alignment: .leading, spacing: 4) {
                Text("OpenAI Settings")
                    .font(.title2).fontWeight(.bold)
                Text("Configure base URL, models, and your API key for transcription and summaries.")
                    .font(.subheadline).foregroundColor(.secondary)
            }
            Spacer()
        }
    }

    @ViewBuilder
    private var form: some View {
        VStack(alignment: .leading, spacing: 12) {
            GroupBox(label: Label("API", systemImage: "network")) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Base URL").font(.headline)
                    TextField("https://api.openai.com/v1", text: $baseURL)
                        .textFieldStyle(.roundedBorder)
                        .font(.system(.body, design: .monospaced))
                }
                .padding(8)
            }

            GroupBox(label: Label("Models", systemImage: "cpu")) {
                VStack(alignment: .leading, spacing: 8) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Transcription Model").font(.headline)
                        TextField("whisper-1", text: $transcriptionModel)
                            .textFieldStyle(.roundedBorder)
                    }
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Text (Summaries & Actions)").font(.headline)
                        TextField("gpt-5", text: $textModel)
                            .textFieldStyle(.roundedBorder)
                    }
                }
                .padding(8)
            }

            GroupBox(label: Label("Credentials", systemImage: "key.fill")) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("API Key").font(.headline)
                    SecureField("OpenAI API key", text: $apiKey)
                        .textFieldStyle(.roundedBorder)
                    HStack(spacing: 12) {
                        Button {
                            testConnection()
                        } label: {
                            if isTesting {
                                ProgressView().scaleEffect(0.8)
                            }
                            Text(isTesting ? "Testing…" : "Test Connection")
                        }
                        .disabled(apiKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isTesting)
                        .buttonStyle(.bordered)

                        if !testMessage.isEmpty {
                            Label(testMessage, systemImage: testIsError ? "xmark.octagon.fill" : "checkmark.seal.fill")
                                .foregroundColor(testIsError ? .red : .green)
                        }
                    }
                    HStack {
                        Spacer()
                        Link(destination: URL(string: "https://platform.openai.com/api-keys")!) {
                            Label("Get an API key", systemImage: "link")
                        }
                        .buttonStyle(.bordered)
                    }
                }
                .padding(8)
            }
        }
    }

    @ViewBuilder
    private var footer: some View {
        HStack {
            Button(role: .none) {
                baseURL = defaultBaseURL
                transcriptionModel = defaultTranscriptionModel
                textModel = defaultTextModel
            } label: {
                Label("Reset Defaults", systemImage: "arrow.counterclockwise")
            }
            .buttonStyle(.bordered)

            Spacer()

            Button("Cancel") { onDone?() }
            Button("Save") { saveAndClose() }
                .buttonStyle(.borderedProminent)
        }
    }

    private func saveAndClose() {
        openAIBaseURL = baseURL.trimmingCharacters(in: .whitespacesAndNewlines)
        openAITranscriptionModel = transcriptionModel.trimmingCharacters(in: .whitespacesAndNewlines)
        openAITextModel = textModel.trimmingCharacters(in: .whitespacesAndNewlines)
        openAIAPIKey = apiKey.trimmingCharacters(in: .whitespacesAndNewlines)
        onDone?()
    }

    private func testConnection() {
        testMessage = ""
        testIsError = false
        isTesting = true
        let cfg = OpenAIConfig(
            baseURL: baseURL,
            apiKey: apiKey,
            transcriptionModel: transcriptionModel,
            textModel: textModel
        )
        Task { @MainActor in
            defer { isTesting = false }
            do {
                let text = try await OpenAIService().testConnection(config: cfg)
                let snippet = text.prefix(32)
                testMessage = "Connected (\(snippet)…)"
                testIsError = false
            } catch {
                testMessage = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
                testIsError = true
            }
        }
    }
}
