import SwiftUI

struct NotesView: View {
    @EnvironmentObject var notesManager: NotesManager
    @State private var searchText = ""
    @State private var showingNewFolderDialog = false
    @State private var newFolderName = ""
    // Keep sidebar selection as local state to avoid publishing
    // changes to the EnvironmentObject during view updates.
    @State private var selectedFolderName: String? = nil
    
    private var filteredNotes: [Note] {
        if searchText.isEmpty {
            let folder = selectedFolderName ?? notesManager.selectedFolder
            return notesManager.notesForFolder(folder)
        } else {
            return notesManager.searchNotes(searchText)
        }
    }
    
    var body: some View {
        NavigationSplitView {
            sidebarView
        } detail: {
            detailView
        }
        .searchable(text: $searchText, prompt: "Search notes and transcripts")
        .sheet(isPresented: $showingNewFolderDialog) {
            newFolderDialog
        }
    }
    
    @ViewBuilder
    private var sidebarView: some View {
        List(selection: $selectedFolderName) {
            Section("Folders") {
                ForEach(notesManager.folders, id: \.name) { folder in
                    HStack {
                        Image(systemName: "folder.fill")
                            .foregroundColor(.blue)
                        Text(folder.name)
                        
                        Spacer()
                        
                        let count = notesManager.notesForFolder(folder.name).count
                        if count > 0 {
                            Text("\(count)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.secondary.opacity(0.2))
                                .clipShape(Capsule())
                        }
                    }
                    .tag(folder.name)
                }
            }
            
            Section {
                Button {
                    showingNewFolderDialog = true
                } label: {
                    HStack {
                        Image(systemName: "folder.badge.plus")
                        Text("New Folder")
                    }
                }
            }
        }
        .listStyle(SidebarListStyle())
        .frame(minWidth: 200)
        // Initialize selection from model once, then keep them in sync
        .onAppear {
            if selectedFolderName == nil {
                selectedFolderName = notesManager.selectedFolder
            }
        }
        .onChange(of: selectedFolderName) { newValue in
            // Defer publishing to the next run loop to avoid
            // "Publishing changes from within view updates" warning.
            let value = newValue ?? "General"
            DispatchQueue.main.async {
                notesManager.selectedFolder = value
            }
        }
    }
    
    @ViewBuilder
    private var detailView: some View {
        if filteredNotes.isEmpty {
            emptyStateView
        } else {
            notesList
        }
    }
    
    @ViewBuilder
    private var emptyStateView: some View {
        ContentUnavailableView {
            Label("No Notes", systemImage: "note.text")
        } description: {
            Text("No notes found in this folder")
        } actions: {
            Button("Record New Note") {
                // Switch to recording tab - this would need to be coordinated with the parent view
            }
            .buttonStyle(.borderedProminent)
        }
    }
    
    @ViewBuilder
    private var notesList: some View {
        List {
            ForEach(filteredNotes) { note in
                NoteRowView(note: note)
            }
            .onDelete(perform: deleteNotes)
        }
        .listStyle(PlainListStyle())
    }
    
    @ViewBuilder
    private var newFolderDialog: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Folder Name", text: $newFolderName)
                } header: {
                    Text("Create New Folder")
                } footer: {
                    Text("Enter a name for the new folder")
                }
            }
            .navigationTitle("New Folder")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        showingNewFolderDialog = false
                        newFolderName = ""
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        notesManager.createFolder(named: newFolderName.trimmingCharacters(in: .whitespacesAndNewlines))
                        showingNewFolderDialog = false
                        newFolderName = ""
                    }
                    .disabled(newFolderName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
        .frame(width: 400, height: 200)
    }
    
    private func deleteNotes(at offsets: IndexSet) {
        for index in offsets {
            let note = filteredNotes[index]
            notesManager.deleteNote(note)
        }
    }
}

struct NoteRowView: View {
    let note: Note
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(note.displayTitle)
                        .font(.headline)
                        .lineLimit(1)
                    
                    HStack {
                        Image(systemName: "folder.fill")
                            .foregroundColor(.blue)
                            .font(.caption)
                        Text(note.folderName)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Image(systemName: "clock")
                            .foregroundColor(.secondary)
                            .font(.caption)
                        Text(note.formattedDuration)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                Text(note.formattedDate)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                if let err = note.transcriptionError, !err.isEmpty {
                    Label("Transcription Error: \(err)", systemImage: "xmark.octagon.fill")
                        .foregroundColor(.red)
                        .font(.footnote)
                }
                if let err = note.summaryError, !err.isEmpty {
                    Label("Summary Error: \(err)", systemImage: "exclamationmark.triangle.fill")
                        .foregroundColor(.orange)
                        .font(.footnote)
                }
                Text(note.transcript)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(nil)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    NotesView()
        .environmentObject(NotesManager())
}
