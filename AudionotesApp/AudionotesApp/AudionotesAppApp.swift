import SwiftUI

@main
struct AudionotesAppApp: App {
    @AppStorage("geminiAPIKey") private var geminiAPIKey: String = ""
    @State private var showingAPIKeyInput = false
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    if geminiAPIKey.isEmpty {
                        showingAPIKeyInput = true
                    }
                }
                .sheet(isPresented: $showingAPIKeyInput) {
                    APIKeyInputView()
                }
        }
    }
}