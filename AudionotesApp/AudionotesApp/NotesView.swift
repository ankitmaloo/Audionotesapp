import SwiftUI

struct NotesView: View {
    @EnvironmentObject var notesManager: NotesManager
    @State private var searchText = ""
    @State private var showingNewFolderDialog = false
    @State private var newFolderName = ""
    @State private var selectedFolderName: String? = nil
    @State private var hoveredNoteId: UUID? = nil
    @State private var hoveredFolderName: String? = nil
    @State private var selectedNote: Note? = nil

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
            atmosphericSidebarView
        } detail: {
            ZStack {
                // Atmospheric background
                DesignSystem.Colors.atmosphericBackground
                    .ignoresSafeArea()

                // Grain texture overlay
                Image(systemName: "circle.grid.cross.fill")
                    .resizable(resizingMode: .tile)
                    .foregroundColor(.white.opacity(0.02))
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    // Custom search bar with glass morphism
                    if !filteredNotes.isEmpty {
                        glassMorphismSearchBar
                            .padding(.horizontal, DesignSystem.Spacing.lg)
                            .padding(.top, DesignSystem.Spacing.lg)
                            .padding(.bottom, DesignSystem.Spacing.md)
                    }

                    detailView
                }
            }
        }
        .sheet(isPresented: $showingNewFolderDialog) {
            newFolderDialog
        }
        .sheet(item: $selectedNote) { note in
            NoteDetailView(note: note)
        }
    }

    // MARK: - Glass Morphism Search Bar

    @ViewBuilder
    private var glassMorphismSearchBar: some View {
        HStack(spacing: DesignSystem.Spacing.md) {
            Image(systemName: "magnifyingglass")
                .font(DesignSystem.Typography.bodyMedium(weight: .medium))
                .foregroundColor(DesignSystem.Colors.secondaryText)

            TextField("Search notes and transcripts...", text: $searchText)
                .textFieldStyle(.plain)
                .font(DesignSystem.Typography.bodyMedium())
                .foregroundColor(DesignSystem.Colors.primaryText)

            if !searchText.isEmpty {
                Button(action: {
                    withAnimation(DesignSystem.Animations.quick) {
                        searchText = ""
                    }
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(DesignSystem.Typography.bodyMedium())
                        .foregroundColor(DesignSystem.Colors.secondaryText)
                }
                .buttonStyle(.plain)
                .transition(.scale.combined(with: .opacity))
            }
        }
        .padding(DesignSystem.Spacing.md)
        .glassMorphism()
        .shadow(
            color: DesignSystem.Shadows.subtle.color,
            radius: DesignSystem.Shadows.subtle.radius,
            x: DesignSystem.Shadows.subtle.x,
            y: DesignSystem.Shadows.subtle.y
        )
    }

    // MARK: - Atmospheric Sidebar

    @ViewBuilder
    private var atmosphericSidebarView: some View {
        ZStack {
            // Sidebar gradient background
            DesignSystem.Colors.sidebarGradient
                .ignoresSafeArea()

            VStack(spacing: DesignSystem.Spacing.lg) {
                // Header
                VStack(spacing: DesignSystem.Spacing.xs) {
                    Text("Collections")
                        .font(DesignSystem.Typography.titleMedium(weight: .bold))
                        .foregroundColor(DesignSystem.Colors.primaryText)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, DesignSystem.Spacing.md)
                        .padding(.top, DesignSystem.Spacing.lg)

                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    DesignSystem.Colors.primaryAccent.opacity(0.3),
                                    DesignSystem.Colors.secondaryAccent.opacity(0.3)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(height: 2)
                        .padding(.horizontal, DesignSystem.Spacing.md)
                }

                // Folders list
                ScrollView {
                    VStack(spacing: DesignSystem.Spacing.sm) {
                        ForEach(notesManager.folders, id: \.name) { folder in
                            AnimatedFolderRow(
                                folder: folder,
                                notesCount: notesManager.notesForFolder(folder.name).count,
                                isSelected: (selectedFolderName ?? notesManager.selectedFolder) == folder.name,
                                isHovered: hoveredFolderName == folder.name,
                                onTap: {
                                    withAnimation(DesignSystem.Animations.smooth) {
                                        selectedFolderName = folder.name
                                    }
                                },
                                onHover: { isHovered in
                                    withAnimation(DesignSystem.Animations.quick) {
                                        hoveredFolderName = isHovered ? folder.name : nil
                                    }
                                }
                            )
                        }
                    }
                    .padding(.horizontal, DesignSystem.Spacing.md)
                }

                // New folder button
                Button(action: { showingNewFolderDialog = true }) {
                    HStack(spacing: DesignSystem.Spacing.sm) {
                        Image(systemName: "folder.badge.plus")
                            .font(DesignSystem.Typography.bodyMedium(weight: .medium))
                        Text("New Folder")
                            .font(DesignSystem.Typography.bodyMedium(weight: .medium))
                    }
                    .foregroundColor(DesignSystem.Colors.primaryAccent)
                    .frame(maxWidth: .infinity)
                    .padding(DesignSystem.Spacing.md)
                    .background(
                        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                            .fill(Color.white.opacity(0.6))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                            .strokeBorder(DesignSystem.Colors.primaryAccent.opacity(0.3), lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)
                .padding(.horizontal, DesignSystem.Spacing.md)
                .padding(.bottom, DesignSystem.Spacing.md)
            }
        }
        .frame(minWidth: 240, idealWidth: 280)
        .onChange(of: selectedFolderName) { newValue in
            let value = newValue ?? "General"
            DispatchQueue.main.async {
                notesManager.selectedFolder = value
            }
        }
        .onAppear {
            if selectedFolderName == nil {
                selectedFolderName = notesManager.selectedFolder
            }
        }
    }

    // MARK: - Detail View

    @ViewBuilder
    private var detailView: some View {
        if filteredNotes.isEmpty {
            dramaticEmptyStateView
        } else {
            asymmetricNotesList
        }
    }

    // MARK: - Dramatic Empty State

    @ViewBuilder
    private var dramaticEmptyStateView: some View {
        VStack(spacing: DesignSystem.Spacing.xxl) {
            Spacer()

            VStack(spacing: DesignSystem.Spacing.lg) {
                // Large decorative icon
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    DesignSystem.Colors.primaryAccent.opacity(0.1),
                                    DesignSystem.Colors.secondaryAccent.opacity(0.1)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 140, height: 140)

                    Image(systemName: "note.text")
                        .font(.system(size: 56, weight: .light))
                        .foregroundColor(DesignSystem.Colors.primaryAccent)
                }

                VStack(spacing: DesignSystem.Spacing.md) {
                    Text("No Notes Yet")
                        .font(DesignSystem.Typography.titleLarge(weight: .bold))
                        .foregroundColor(DesignSystem.Colors.primaryText)

                    Text(searchText.isEmpty ? "Your collection awaits\nStart recording to create your first note" : "No notes match your search")
                        .font(DesignSystem.Typography.bodyLarge())
                        .foregroundColor(DesignSystem.Colors.secondaryText)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                }
            }

            Spacer()
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Asymmetric Notes List

    @ViewBuilder
    private var asymmetricNotesList: some View {
        ScrollView {
            LazyVStack(spacing: DesignSystem.Spacing.lg) {
                ForEach(Array(filteredNotes.enumerated()), id: \.element.id) { index, note in
                    AsymmetricNoteCard(
                        note: note,
                        index: index,
                        isHovered: hoveredNoteId == note.id,
                        onHover: { isHovered in
                            withAnimation(DesignSystem.Animations.quick) {
                                hoveredNoteId = isHovered ? note.id : nil
                            }
                        },
                        onTap: {
                            selectedNote = note
                        }
                    )
                    .staggeredFadeIn(index: index)
                    .contextMenu {
                        Button(role: .destructive) {
                            withAnimation(DesignSystem.Animations.smooth) {
                                notesManager.deleteNote(note)
                            }
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
            }
            .padding(DesignSystem.Spacing.lg)
        }
    }

    // MARK: - New Folder Dialog

    @ViewBuilder
    private var newFolderDialog: some View {
        NavigationView {
            ZStack {
                DesignSystem.Colors.atmosphericBackground
                    .ignoresSafeArea()

                VStack(spacing: DesignSystem.Spacing.lg) {
                    VStack(spacing: DesignSystem.Spacing.md) {
                        Text("Create New Folder")
                            .font(DesignSystem.Typography.titleMedium(weight: .bold))
                            .foregroundColor(DesignSystem.Colors.primaryText)

                        TextField("Folder Name", text: $newFolderName)
                            .textFieldStyle(.plain)
                            .font(DesignSystem.Typography.bodyLarge())
                            .padding(DesignSystem.Spacing.md)
                            .background(Color.white.opacity(0.8))
                            .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md))
                            .overlay(
                                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                                    .strokeBorder(DesignSystem.Colors.primaryAccent.opacity(0.2), lineWidth: 1)
                            )
                    }
                    .padding(DesignSystem.Spacing.xl)

                    HStack(spacing: DesignSystem.Spacing.md) {
                        Button("Cancel") {
                            showingNewFolderDialog = false
                            newFolderName = ""
                        }
                        .buttonStyle(.bordered)

                        Button("Create") {
                            notesManager.createFolder(named: newFolderName.trimmingCharacters(in: .whitespacesAndNewlines))
                            showingNewFolderDialog = false
                            newFolderName = ""
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(newFolderName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                    .padding(.horizontal, DesignSystem.Spacing.xl)
                }
            }
        }
        .frame(width: 450, height: 220)
    }

    private func deleteNotes(at offsets: IndexSet) {
        withAnimation(DesignSystem.Animations.smooth) {
            for index in offsets {
                let note = filteredNotes[index]
                notesManager.deleteNote(note)
            }
        }
    }
}

// MARK: - Animated Folder Row

struct AnimatedFolderRow: View {
    let folder: Folder
    let notesCount: Int
    let isSelected: Bool
    let isHovered: Bool
    let onTap: () -> Void
    let onHover: (Bool) -> Void

    private var folderColor: Color {
        if let colors = DesignSystem.Colors.folderColors[folder.name] {
            return (isHovered || isSelected) ? colors.active : colors.idle
        }
        return DesignSystem.Colors.primaryAccent
    }

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: DesignSystem.Spacing.md) {
                // Animated folder icon
                ZStack {
                    Circle()
                        .fill(folderColor.opacity(0.15))
                        .frame(width: 36, height: 36)
                        .scaleEffect(isHovered ? 1.1 : 1.0)

                    Image(systemName: isSelected ? "folder.fill" : "folder")
                        .font(DesignSystem.Typography.bodyMedium(weight: .semibold))
                        .foregroundColor(folderColor)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(folder.name)
                        .font(DesignSystem.Typography.bodyMedium(weight: isSelected ? .semibold : .medium))
                        .foregroundColor(isSelected ? DesignSystem.Colors.primaryText : DesignSystem.Colors.secondaryText)

                    if notesCount > 0 {
                        Text("\(notesCount) \(notesCount == 1 ? "note" : "notes")")
                            .font(DesignSystem.Typography.caption())
                            .foregroundColor(DesignSystem.Colors.tertiaryText)
                    }
                }

                Spacer()

                if notesCount > 0 {
                    Text("\(notesCount)")
                        .font(DesignSystem.Typography.caption(weight: .semibold))
                        .foregroundColor(folderColor)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(folderColor.opacity(0.15))
                        )
                }
            }
            .padding(DesignSystem.Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                    .fill(
                        isSelected
                            ? Color.white.opacity(0.8)
                            : (isHovered ? Color.white.opacity(0.4) : Color.clear)
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                    .strokeBorder(
                        isSelected ? folderColor.opacity(0.3) : Color.clear,
                        lineWidth: 1
                    )
            )
        }
        .buttonStyle(.plain)
        .onHover(perform: onHover)
        .animation(DesignSystem.Animations.quick, value: isHovered)
        .animation(DesignSystem.Animations.smooth, value: isSelected)
    }
}

// MARK: - Asymmetric Note Card

struct AsymmetricNoteCard: View {
    let note: Note
    let index: Int
    let isHovered: Bool
    let onHover: (Bool) -> Void
    let onTap: () -> Void

    // Determine card gradient based on index
    private var cardGradient: Color {
        let gradients = [
            DesignSystem.Colors.cardGradient1,
            DesignSystem.Colors.cardGradient2,
            DesignSystem.Colors.cardGradient3,
            DesignSystem.Colors.cardGradient4
        ]
        return gradients[index % gradients.count]
    }

    // Asymmetric positioning
    private var asymmetricOffset: CGFloat {
        let offsets: [CGFloat] = [0, 8, -8, 4, -4]
        return offsets[index % offsets.count]
    }

    // Varied card heights
    private var cardHeight: CGFloat {
        let transcript = note.transcript
        let hasErrors = (note.transcriptionError != nil && !note.transcriptionError!.isEmpty) ||
                       (note.summaryError != nil && !note.summaryError!.isEmpty)

        if hasErrors || transcript.count > 300 {
            return DesignSystem.Card.maxHeight
        } else if transcript.count > 150 {
            return 240
        } else {
            return DesignSystem.Card.minHeight
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Decorative accent border
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [
                            DesignSystem.Colors.primaryAccent.opacity(0.6),
                            DesignSystem.Colors.secondaryAccent.opacity(0.6)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(height: 3)

            VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                // Header with title and date
                HStack(alignment: .top, spacing: DesignSystem.Spacing.md) {
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                        Text(note.displayTitle)
                            .font(DesignSystem.Typography.titleSmall(weight: .bold))
                            .foregroundColor(DesignSystem.Colors.primaryText)
                            .lineLimit(2)

                        HStack(spacing: DesignSystem.Spacing.sm) {
                            // Folder badge
                            HStack(spacing: 4) {
                                Image(systemName: "folder.fill")
                                    .font(DesignSystem.Typography.caption())
                                Text(note.folderName)
                                    .font(DesignSystem.Typography.caption(weight: .medium))
                            }
                            .foregroundColor(folderColor)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                Capsule()
                                    .fill(folderColor.opacity(0.12))
                            )

                            // Duration
                            HStack(spacing: 4) {
                                Image(systemName: "waveform")
                                    .font(DesignSystem.Typography.caption())
                                Text(note.formattedDuration)
                                    .font(DesignSystem.Typography.mono(size: 11))
                            }
                            .foregroundColor(DesignSystem.Colors.secondaryText)
                        }
                    }

                    Spacer()

                    // Date with monospaced font
                    Text(note.formattedDate)
                        .font(DesignSystem.Typography.caption(weight: .medium))
                        .foregroundColor(DesignSystem.Colors.tertiaryText)
                }

                // Error messages
                if let err = note.transcriptionError, !err.isEmpty {
                    Label("Transcription Error: \(err)", systemImage: "xmark.octagon.fill")
                        .font(DesignSystem.Typography.bodySmall())
                        .foregroundColor(.red)
                        .padding(DesignSystem.Spacing.sm)
                        .background(
                            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.sm)
                                .fill(Color.red.opacity(0.1))
                        )
                }

                if let err = note.summaryError, !err.isEmpty {
                    Label("Summary Error: \(err)", systemImage: "exclamationmark.triangle.fill")
                        .font(DesignSystem.Typography.bodySmall())
                        .foregroundColor(.orange)
                        .padding(DesignSystem.Spacing.sm)
                        .background(
                            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.sm)
                                .fill(Color.orange.opacity(0.1))
                        )
                }

                // Transcript with refined typography
                Text(note.transcript)
                    .font(DesignSystem.Typography.bodyMedium())
                    .foregroundColor(DesignSystem.Colors.secondaryText)
                    .lineSpacing(6)
                    .lineLimit(8)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(DesignSystem.Spacing.lg)
        }
        .frame(height: cardHeight)
        .atmosphericCard(gradient: cardGradient, isHovered: isHovered)
        .offset(x: asymmetricOffset)
        .onHover(perform: onHover)
        .onTapGesture(perform: onTap)
        .contentShape(Rectangle())
        .animation(DesignSystem.Animations.dramatic, value: isHovered)
    }

    private var folderColor: Color {
        if let colors = DesignSystem.Colors.folderColors[note.folderName] {
            return colors.idle
        }
        return DesignSystem.Colors.primaryAccent
    }
}

#Preview {
    NotesView()
        .environmentObject(NotesManager())
}
