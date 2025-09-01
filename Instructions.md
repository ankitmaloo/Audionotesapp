
  # AudioNotes - Audio Recording App with Notes Interface

  A macOS app that provides a notes-like interface for recording and
  organizing audio using the AudioCapService Swift package.

  ## 🏗️ Project Structure

  AudioNotesApp/
  ├── AudioCapService/           # Swift Package for audio recording
  ├── AudioNotesGUI/            # SwiftUI macOS application
  └── INSTRUCTIONS.md           # This file

  ## 🚀 Setup Instructions

  ### 1. Prerequisites
  - macOS 14.4 or later
  - Xcode 15.0 or later
  - Swift 5.9 or later

  ### 2. Create New Xcode Project
  ```bash
  # Navigate to this directory
  cd AudioNotesApp

  # Create new macOS app
  # In Xcode: File → New → Project
  # Choose: macOS → App
  # Product Name: AudioNotesGUI
  # Interface: SwiftUI
  # Language: Swift
  # Save in: AudioNotesApp/AudioNotesGUI/

  3. Add AudioCapService Package Dependency

  1. Open AudioNotesGUI.xcodeproj in Xcode
  2. Select the project in navigator
  3. Go to Package Dependencies tab
  4. Click + button
  5. Enter local path: ../AudioCapService
  6. Click Add Package
  7. Select AudioCapService target and click Add Package

  4. Configure App Permissions

  Add to AudioNotesGUI/Info.plist:
  <key>NSMicrophoneUsageDescription</key>
  <string>This app needs microphone access to record audio
  notes</string>

  5. Replace Default Files

  Copy these enhanced files to your AudioNotesGUI/ folder:
  - Note.swift - Enhanced note model with folders and metadata
  - NotesManager.swift - Folder-based notes management
  - NotesView.swift - Notes interface with sidebar navigation
  - ContentView.swift - Main app container
  - AudioNotesApp.swift - App entry point

  6. Key Code Structure

  AudioNotesApp.swift

  import SwiftUI

  @main
  struct AudioNotesApp: App {
      @AppStorage("geminiAPIKey") private var geminiAPIKey: String =
  ""
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

  ContentView.swift

  import SwiftUI
  import AudioCapService  // 👈 Import the package!

  struct ContentView: View {
      @State private var permission = AudioRecordingPermission()
      @StateObject private var notesManager = NotesManager()

      var body: some View {
          VStack(spacing: 15) {
              switch permission.status {
              case .unknown:
                  requestPermissionView
              case .authorized:
                  recordingView
              case .denied:
                  permissionDeniedView
              }
          }
          .padding()
          .environmentObject(notesManager)
      }

      @ViewBuilder
      private var requestPermissionView: some View {
          LabeledContent("Please Allow Audio Recording") {
              Button("Allow") {
                  permission.request()
              }
          }
      }

      @ViewBuilder
      private var permissionDeniedView: some View {
          LabeledContent("Audio Recording Permission Required") {
              Button("Open System Settings") {
                  NSWorkspace.shared.openSystemSettings()
              }
          }
      }

      @ViewBuilder
      private var recordingView: some View {
          TabView {
              NotesView()
                  .tabItem {
                      Label("Notes", systemImage: "note.text")
                  }
              RecordingView()
                  .tabItem {
                      Label("Record", systemImage: "mic.fill")
                  }
          }
      }
  }

  🎯 Key Features Implemented

  📁 Folder Organization

  - Default folders: General, Meetings, Ideas, Lectures
  - Custom folder creation
  - Files stored in: ~/Library/Application Support/AudioNotes/

  🎵 Audio Recording

  - System audio + microphone recording
  - Uses existing AudioCapService package
  - Automatic file naming with timestamps
  - Integration with Gemini API for transcription

  📝 Notes Interface

  - Sidebar with folder navigation
  - Search across all notes and transcripts
  - Rich metadata display (date, duration, folder)
  - Lorem ipsum placeholders for transcripts
  - Swipe-to-delete functionality

  🎨 UI Components

  - NavigationSplitView for notes-like layout
  - Audio note rows with metadata
  - Recording controls with visual feedback
  - Folder picker and creation dialogs

  🔧 Build Commands

  # Build from command line
  cd AudioNotesGUI
  xcodebuild -scheme AudioNotesGUI -configuration Debug build

  # Or build in Xcode
  # Open AudioNotesGUI.xcodeproj
  # Product → Build (⌘B)

  📂 File Organization

  Audio Files Structure:

  ~/Library/Application Support/AudioNotes/
  ├── General/
  │   ├── my-note-system-1234567890.wav
  │   └── my-note-mic-1234567890.wav
  ├── Meetings/
  ├── Ideas/
  └── Lectures/

  Project Files to Create:

  - Note.swift - Data model with folder support
  - NotesManager.swift - Core data management
  - NotesView.swift - Main notes interface
  - RecordingView.swift - Recording controls
  - ContentView.swift - App container
  - AudioNotesApp.swift - App entry point

  🚨 Important Notes

  1. Package Dependency: The app imports AudioCapService as a package,
   not embedded files
  2. Permissions: Microphone permission is required for recording
  3. API Key: Optional Gemini API key for transcription
  4. File Storage: Uses Application Support directory, not Documents
  5. macOS Only: Designed specifically for macOS with appropriate UI
  patterns

  🧪 Testing

  1. Launch the app
  2. Grant microphone permissions
  3. Play some audio (music, video, etc.)
  4. Switch to Record tab
  5. Enter note title and select folder
  6. Click record button
  7. Stop recording
  8. Check Notes tab for saved recording

  🎉 Success Criteria

  - ✅ Clean package import: import AudioCapService
  - ✅ No embedded AudioCap source files
  - ✅ Notes-like sidebar interface
  - ✅ Folder-based organization
  - ✅ System + mic recording works
  - ✅ Metadata display (date, duration, lorem ipsum)
  - ✅ Search and delete functionality

  The result is a professional audio notes app with a clean
  architecture using the AudioCapService Swift package!

