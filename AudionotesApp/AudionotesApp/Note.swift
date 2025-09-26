import Foundation

struct Note: Identifiable, Codable {
    let id = UUID()
    let title: String
    let systemAudioURL: URL
    let microphoneURL: URL
    let folderName: String
    let createdAt: Date
    let duration: TimeInterval
    var transcript: String
    // Optional timestamped transcripts for each source
    var microphoneTranscriptTimestamped: String? = nil
    var systemTranscriptTimestamped: String? = nil
    // Error reporting fields
    var transcriptionError: String? = nil
    var summaryError: String? = nil
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: createdAt)
    }
    
    var formattedDuration: String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    var displayTitle: String {
        title.isEmpty ? "Untitled Note" : title
    }
}

struct Folder {
    let name: String
    let isDefault: Bool
    
    static let defaultFolders = [
        Folder(name: "General", isDefault: true),
        Folder(name: "Meetings", isDefault: true),
        Folder(name: "Ideas", isDefault: true),
        Folder(name: "Lectures", isDefault: true)
    ]
}
