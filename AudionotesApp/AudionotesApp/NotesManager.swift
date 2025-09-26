import Foundation
import OSLog

@MainActor
final class NotesManager: ObservableObject {
    
    private let logger = Logger(subsystem: "com.audionotesapp", category: "NotesManager")
    
    @Published private(set) var notes: [Note] = []
    @Published private(set) var folders: [Folder] = Folder.defaultFolders
    @Published var selectedFolder: String = "General"
    
    private let documentsDirectory: URL
    private let notesDataFile: URL
    
    init() {
        let supportDirectory = FileManager.default.urls(for: .applicationSupportDirectory, 
                                                       in: .userDomainMask).first!
        documentsDirectory = supportDirectory.appendingPathComponent("AudioNotes")
        notesDataFile = documentsDirectory.appendingPathComponent("notes.json")
        
        createDirectoryStructure()
        loadNotes()
    }
    
    func addNote(_ note: Note) {
        notes.append(note)
        saveNotes()
        logger.info("Added new note: \(note.title)")
    }
    
    func deleteNote(_ note: Note) {
        notes.removeAll { $0.id == note.id }
        
        do {
            try FileManager.default.removeItem(at: note.systemAudioURL)
            try FileManager.default.removeItem(at: note.microphoneURL)
        } catch {
            logger.error("Failed to delete audio files: \(error)")
        }
        
        saveNotes()
        logger.info("Deleted note: \(note.title)")
    }

    func updateNoteTranscript(noteID: UUID, transcript: String) {
        if let index = notes.firstIndex(where: { $0.id == noteID }) {
            notes[index].transcript = transcript
            saveNotes()
            logger.info("Updated transcript for note: \(self.notes[index].title)")
        }
    }
    
    func createFolder(named name: String) {
        guard !folders.contains(where: { $0.name == name }) else { return }
        
        let newFolder = Folder(name: name, isDefault: false)
        folders.append(newFolder)
        
        let folderURL = documentsDirectory.appendingPathComponent(name)
        try? FileManager.default.createDirectory(at: folderURL, 
                                               withIntermediateDirectories: true)
        
        logger.info("Created folder: \(name)")
    }

    func notesForFolder(_ folderName: String) -> [Note] {
        return notes.filter { $0.folderName == folderName }
                   .sorted { $0.createdAt > $1.createdAt }
    }
    
    func searchNotes(_ searchText: String) -> [Note] {
        guard !searchText.isEmpty else { return notes }
        
        return notes.filter { note in
            note.title.localizedCaseInsensitiveContains(searchText) ||
            note.transcript.localizedCaseInsensitiveContains(searchText) ||
            note.folderName.localizedCaseInsensitiveContains(searchText)
        }.sorted { $0.createdAt > $1.createdAt }
    }
    
    func getFileURL(for fileName: String, in folderName: String, fileType: String = "wav") -> URL {
        let folderURL = documentsDirectory.appendingPathComponent(folderName)
        return folderURL.appendingPathComponent("\(fileName).\(fileType)")
    }
    
    private func createDirectoryStructure() {
        for folder in Folder.defaultFolders {
            let folderURL = documentsDirectory.appendingPathComponent(folder.name)
            try? FileManager.default.createDirectory(at: folderURL, 
                                                   withIntermediateDirectories: true)
        }
    }
    
    private func saveNotes() {
        do {
            let data = try JSONEncoder().encode(notes)
            try data.write(to: notesDataFile)
        } catch {
            logger.error("Failed to save notes: \(error)")
        }
    }
    
    private func loadNotes() {
        do {
            let data = try Data(contentsOf: notesDataFile)
            notes = try JSONDecoder().decode([Note].self, from: data)
        } catch {
            logger.info("No existing notes found or failed to load: \(error)")
            notes = []
        }
    }

    func updateNoteMicTimestamped(noteID: UUID, transcriptTS: String) {
        if let index = notes.firstIndex(where: { $0.id == noteID }) {
            notes[index].microphoneTranscriptTimestamped = transcriptTS
            saveNotes()
            logger.info("Updated mic timestamped transcript for note: \(self.notes[index].title)")
        }
    }

    func updateNoteSystemTimestamped(noteID: UUID, transcriptTS: String) {
        if let index = notes.firstIndex(where: { $0.id == noteID }) {
            notes[index].systemTranscriptTimestamped = transcriptTS
            saveNotes()
            logger.info("Updated system timestamped transcript for note: \(self.notes[index].title)")
        }
    }

    func updateNoteTranscriptionError(noteID: UUID, message: String) {
        if let index = notes.firstIndex(where: { $0.id == noteID }) {
            notes[index].transcriptionError = message
            saveNotes()
            logger.error("Transcription error for note: \(self.notes[index].title) — \(message)")
        }
    }

    func updateNoteSummaryError(noteID: UUID, message: String) {
        if let index = notes.firstIndex(where: { $0.id == noteID }) {
            notes[index].summaryError = message
            saveNotes()
            logger.error("Summary error for note: \(self.notes[index].title) — \(message)")
        }
    }
}
