import SwiftUI

struct OpenAISettingsView: View {
    @Environment(\.dismiss) private var dismiss

    @AppStorage("openAIBaseURL") private var openAIBaseURL: String = "https://api.openai.com/v1"
    @AppStorage("openAITranscriptionModel") private var openAITranscriptionModel: String = "whisper-1"
    @AppStorage("openAITextModel") private var openAITextModel: String = "gpt-5"
    @AppStorage("openAIAPIKey") private var openAIAPIKey: String = ""

    @State private var baseURL: String = "https://api.openai.com/v1"
    @State private var transcriptionModel: String = "whisper-1"
    @State private var textModel: String = "gpt-5"
    @State private var apiKey: String = ""

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("API Configuration")) {
                    TextField("Base URL", text: $baseURL)
                        .textFieldStyle(.roundedBorder)
                        .font(.system(.body, design: .monospaced))

                    TextField("Transcription model (e.g., whisper-1)", text: $transcriptionModel)
                        .textFieldStyle(.roundedBorder)

                    TextField("Text model (e.g., gpt-5)", text: $textModel)
                        .textFieldStyle(.roundedBorder)

                    SecureField("API Key", text: $apiKey)
                        .textFieldStyle(.roundedBorder)
                }

                Section(footer: Text("Manage keys at platform.openai.com")) {
                    Link(destination: URL(string: "https://platform.openai.com/api-keys")!) {
                        Label("Open OpenAI API Keys", systemImage: "link")
                    }
                }
            }
            .navigationTitle("OpenAI Settings")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        openAIBaseURL = baseURL.trimmingCharacters(in: .whitespacesAndNewlines)
                        openAITranscriptionModel = transcriptionModel.trimmingCharacters(in: .whitespacesAndNewlines)
                        openAITextModel = textModel.trimmingCharacters(in: .whitespacesAndNewlines)
                        openAIAPIKey = apiKey.trimmingCharacters(in: .whitespacesAndNewlines)
                        dismiss()
                    }
                }
            }
        }
        .frame(width: 520, height: 360)
        .onAppear {
            baseURL = openAIBaseURL
            transcriptionModel = openAITranscriptionModel
            textModel = openAITextModel
            apiKey = openAIAPIKey
        }
    }
}
