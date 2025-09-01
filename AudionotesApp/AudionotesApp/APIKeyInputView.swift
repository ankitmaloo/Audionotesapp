import SwiftUI

struct APIKeyInputView: View {
    @AppStorage("geminiAPIKey") private var geminiAPIKey: String = ""
    @Environment(\.dismiss) private var dismiss
    
    @State private var apiKey = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                VStack(spacing: 10) {
                    Image(systemName: "key.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.blue)
                    
                    Text("Gemini API Key")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("Enter your Gemini API key to enable transcription features")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("API Key")
                        .font(.headline)
                    
                    SecureField("Enter your Gemini API key", text: $apiKey)
                        .textFieldStyle(.roundedBorder)
                    
                    Text("You can get your API key from the Google AI Studio")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Link(destination: URL(string: "https://makersuite.google.com/app/apikey")!) {
                    HStack {
                        Image(systemName: "link")
                        Text("Get API Key from Google AI Studio")
                    }
                }
                .buttonStyle(.bordered)
                
                Spacer()
                
                Text("You can skip this step and add the API key later in Settings")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding()
            .navigationTitle("Setup")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Skip") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        geminiAPIKey = apiKey.trimmingCharacters(in: .whitespacesAndNewlines)
                        dismiss()
                    }
                    .disabled(apiKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
        .frame(width: 500, height: 400)
        .onAppear {
            apiKey = geminiAPIKey
        }
    }
}