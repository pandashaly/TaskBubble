
//
//  AddTaskView.swift
//  TaskBubble
//
//  Created by Shalyca Sottoriva on 02/04/2026.


//
//  AddTaskView.swift
//  TaskBubble
//
//  Created by Shalyca Sottoriva on 02/04/2026.
//

import SwiftUI

struct AddTaskView: View {
    @Binding var newTaskTitle: String
    @Binding var taskNotes: String
    @Binding var inputCategory: TaskCategory
    @Binding var inputPriority: TaskPriority
    @Binding var taskDeadline: Date?
    @Binding var showAppPicker: Bool
    @Binding var showLinkInput: Bool
    @Binding var selectedApp: DetectedApp?
    @Binding var linkURL: String
    @Binding var mainLinkBundleIdentifier: String?
    @Binding var subtaskDrafts: [SubtaskDraft]
    @Binding var activeSubtaskID: UUID?

    let isEditing: Bool
    let addTask: () -> Void
    let cancelAction: () -> Void

    @ObservedObject var appDetectionService: AppDetectionService

    @State private var showDeadlineSheet = false
    @State private var deadlineDraft = Date()
    @State private var showExpandedNotes = false
    @FocusState private var focusedSubtaskID: UUID?
    @StateObject private var notesCoordinator = RichTextCoordinator()

    private var notesBinding: Binding<String> {
        Binding(
            get: { taskNotes },
            set: { taskNotes = clampedNotes($0) }
        )
    }

    private func formCard<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(10)
            .background(AppColors.background)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.Surface.a30.opacity(0.4), lineWidth: 1)
            )
    }

    private var notesSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("Notes")
                    .font(.headline)
                    .foregroundColor(.white)
                Spacer()
                Text("\(wordCount(taskNotes))/\(maxNotesWords)")
                    .font(.caption)
                    .foregroundColor(
                        wordCount(taskNotes) >= maxNotesWords ? .red :
                        wordCount(taskNotes) >= 250 ? .red :
                        wordCount(taskNotes) >= 200 ? .yellow : .secondary
                    )
            }

            // Editor with expand button in bottom-right corner
            ZStack(alignment: .bottomTrailing) {
                RichTextEditor(text: notesBinding, sharedCoordinator: notesCoordinator)
                    .frame(minHeight: 85, maxHeight: 125)
                    .padding(6)
                    .background(Color.Surface.a10)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.22), lineWidth: 1)
                    )

                // Expand button
                Button {
                    showExpandedNotes = true
                } label: {
                    Image(systemName: "arrow.up.left.and.arrow.down.right")
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundColor(.secondary)
                        .padding(5)
                        .background(Color.Surface.a20.opacity(0.9))
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                }
                .buttonStyle(.plain)
                .padding(6)
            }
        }
        .sheet(isPresented: $showExpandedNotes) {
            ExpandedNotesView(text: notesBinding, coordinator: notesCoordinator)
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            headerBar
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: 12) {
                        // Main Details Card
                        formCard {
                            VStack(alignment: .leading, spacing: 12) {
                                taskNameRow
                                Divider().background(Color.Surface.a30.opacity(0.3))
                                notesSection
                                Divider().background(Color.Surface.a30.opacity(0.3))
                                priorityPills
                                Divider().background(Color.Surface.a30.opacity(0.3))
                                deadlineAndLabelRow
                            }
                        }
                        
                        // Subtasks Card
                        formCard {
                            subtasksSection
                        }
                        Color.clear
                            .frame(height: 1)
                            .id("BOTTOM")
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .padding(.bottom, 8)
                }
                .onChange(of: subtaskDrafts.count) { _, _ in
                    withAnimation {
                        proxy.scrollTo("BOTTOM", anchor: .bottom)
                    }
                }
            }
        }
        .background(AppColors.background)
        .frame(width: 330, height: 420)
        .onAppear {
            if let d = taskDeadline {
                deadlineDraft = d
            } else {
                deadlineDraft = Date()
            }
        }
        .onChange(of: taskDeadline) { _, new in
            if let d = new {
                deadlineDraft = d
            }
        }
        .sheet(isPresented: $showDeadlineSheet) {
            VStack(spacing: 16) {
                Text("Deadline").font(.headline)
                DatePicker("", selection: $deadlineDraft, displayedComponents: .date)
                    .datePickerStyle(.automatic)
                    .labelsHidden()
                HStack {
                    Spacer()
                    Button("Remove") { taskDeadline = nil ; showDeadlineSheet = false}
                    Button("Cancel") { showDeadlineSheet = false }
                    Button("Done") {
                        taskDeadline = deadlineDraft
                        showDeadlineSheet = false
                    }
                    .buttonStyle(.glassProminent)
                }
            }
            .padding()
            .frame(width: 240)
        }
    }

    private var headerBar: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .center) {
                Text("Your Task")
                    .font(.title2.weight(.bold))

                Spacer()

//                 Removed the empty button that was causing unexpected dismissals
                Circle()
                    .strokeBorder(Color.secondary.opacity(0.55), lineWidth: 1.5)
                    .frame(width: 30, height: 30)
                    .accessibilityHidden(true)
            }

            HStack {
                Button("Cancel") {
                    cancelAction()
                }
                .buttonStyle(.plain)
                .foregroundColor(.accentColor)

                Spacer()

                Button(isEditing ? "Save" : "Add") {
                    addTask()
                }
                .buttonStyle(.plain)
                .foregroundColor(.accentColor)
                .fontWeight(.semibold)
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 10)
        .padding(.bottom, 8)
        .background(AppColors.background)
    }

    private var taskNameRow: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Task Name")
                .font(.headline)
                .foregroundColor(.white)
            HStack(alignment: .center, spacing: 8) {
                TextField("To Do...", text: $newTaskTitle)
                    .textFieldStyle(.roundedBorder)
                    .background(AppColors.card)
                    .font(.body)
                
                Button(action: {
                    appDetectionService.loadInstalledApplications()
                    showAppPicker = true
                }) {
                    if let app = selectedApp {
                        Image(nsImage: app.icon)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                    } else if !linkURL.isEmpty {
                        LinkIconView(link: linkURL)
                            .frame(width: 20, height: 20)
                    } else {
                        Image(systemName: "app.badge")
                            .font(.body)
                            .foregroundColor(AppColors.shalyPurple)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var mainLinkIcon: some View {
        if let app = selectedApp {
            Image(nsImage: app.icon)
                .resizable()
                .scaledToFit()
                .frame(width: 28, height: 28)
        } else if !linkURL.isEmpty {
            LinkIconView(link: linkURL)
                .frame(width: 28, height: 28)
        
        } else if let bid = mainLinkBundleIdentifier, let img = appDetectionService.getIcon(for: bid) {
            Image(nsImage: img)
                .resizable()
                .scaledToFit()
                .frame(width: 28, height: 28)
        } else {
            Image(systemName: "link.badge.plus")
                .font(.title3)
                .foregroundColor(.secondary)
        }
    }

    private var priorityPills: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Priority")
                .font(.headline)
                .foregroundColor(.white)
            HStack(spacing: 6) {
                ForEach(TaskPriority.allCases) { p in
                    Button {
                        inputPriority = p
                    } label: {
                        Text(p.shortLabel)
                            .font(.caption.weight(.medium))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                Capsule()
                                    .fill(inputPriority == p ? p.color.opacity(0.25) : Color.gray.opacity(0.12))
                            )
                            .overlay(
                                Capsule()
                                    .stroke(inputPriority == p ? p.color : Color.gray.opacity(0.3), lineWidth: 1)
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var deadlineAndLabelRow: some View {
        HStack(alignment: .top, spacing: 10) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Deadline")
                    .font(.headline)
                    .foregroundColor(.white)
                Button(action: {
                    deadlineDraft = taskDeadline ?? Date()
                    showDeadlineSheet = true
                }) {
                    Group {
                        if let d = taskDeadline {
                            Text(d, style: .date)
                                .font(.caption.weight(.medium))
                        } else {
                            Text("Deadline")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 10)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                }
                .buttonStyle(.plain)
            }
            .frame(maxWidth: .infinity)

            VStack(alignment: .leading, spacing: 4) {
                Text("Category")
                    .font(.headline)
                    .foregroundColor(.white)
                Menu {
                    ForEach(TaskCategory.assignableCategories) { cat in
                        Button(cat.rawValue) {
                            inputCategory = cat
                        }
                    }
                } label: {
                    HStack {
                        Text(inputCategory.rawValue)
                            .font(.caption.weight(.medium))
                        Spacer()
                        Image(systemName: "chevron.up.chevron.down")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 10)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                }
                .menuStyle(.borderlessButton)
            }
            .frame(maxWidth: .infinity)
        }
    }

    private var subtasksSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Subtasks")
                    .font(.headline)
                Spacer()
                if subtaskDrafts.count < 10 {
                    Button {
                        let newDraft = SubtaskDraft()
                        subtaskDrafts.append(newDraft)
                        DispatchQueue.main.async {
                            focusedSubtaskID = newDraft.id
                        }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.accentColor)
                    }
                    .buttonStyle(.plain)
                }
            }

            if subtaskDrafts.isEmpty {
                Text("Add up to 10 subtasks.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            } else {
                VStack(spacing: 8) {
                    ForEach(subtaskDrafts) { draft in
                        subtaskRow(draft: binding(for: draft.id))
                    }
                }
            }
        }
    }

    private func binding(for id: UUID) -> Binding<SubtaskDraft> {
        Binding(
            get: { subtaskDrafts.first { $0.id == id } ?? SubtaskDraft(id: id) },
            set: { new in
                if let i = subtaskDrafts.firstIndex(where: { $0.id == id }) {
                    subtaskDrafts[i] = new
                }
            }
        )
    }

    private func subtaskRow(draft: Binding<SubtaskDraft>) -> some View {
        let id = draft.wrappedValue.id
        let isAtMax = wordCount(draft.wrappedValue.title) >= maxSubtaskWords
        let titleBinding = Binding(
            get: { draft.wrappedValue.title },
            set: { draft.wrappedValue.title = clampedSubtask($0) }
        )

        return VStack(alignment: .leading, spacing: 3) {
            HStack(spacing: 10) {
                TextField("Subtask title...", text: titleBinding)
                    .textFieldStyle(.roundedBorder)
                    .font(.subheadline)
                    .focused($focusedSubtaskID, equals: id)
                    .onSubmit {
                        // Only create a new draft if the current field has text
                        let hasText = !draft.wrappedValue.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                        guard hasText, subtaskDrafts.count < 10 else { return }
                        let newDraft = SubtaskDraft()
                        withAnimation{subtaskDrafts.append(newDraft)}
                        focusedSubtaskID = nil
                        // Focus the new field after SwiftUI updates
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            focusedSubtaskID = newDraft.id
                        }
                    }

                Button {
                    subtaskDrafts.removeAll { $0.id == id }
                } label: {
                    Image(systemName: "minus.circle.fill")
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
            }

            // Warning pill — only visible when the word limit is reached
            if isAtMax {
                HStack(spacing: 4) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 9, weight: .semibold))
                    Text("Word limit reached")
                        .font(.system(size: 10, weight: .medium))
                }
                .foregroundColor(Color.Warning.a0)
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(Color.Warning.a20)
                .clipShape(Capsule())
                .transition(.scale(scale: 0.85).combined(with: .opacity))
            }
        }
        .padding(.vertical, 2)
        .animation(.spring(response: 0.25, dampingFraction: 0.7), value: isAtMax)
    }
}

// MARK: - Expanded Notes Editor

struct ExpandedNotesView: View {
    @Binding var text: String
    var coordinator: RichTextCoordinator
    @Environment(\.dismiss) private var dismiss

    private var count: Int { wordCount(text) }
    private var isAtMax: Bool { count >= maxNotesWords }

    var body: some View {
        HStack(spacing: 0) {

            // ── Main editor area ──────────────────────────────────────
            VStack(spacing: 0) {
                // Toolbar
                HStack(spacing: 4) {
                    Text("Notes")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.leading, 4)

                    Spacer()

                    FormatButton(icon: "bold",          label: "Bold")          { coordinator.applyFormat(.bold) }
                    FormatButton(icon: "italic",        label: "Italic")        { coordinator.applyFormat(.italic) }
                    FormatButton(icon: "underline",     label: "Underline")     { coordinator.applyFormat(.underline) }
                    FormatButton(icon: "strikethrough", label: "Strikethrough") { coordinator.applyFormat(.strikethrough) }

                    Divider()
                        .frame(height: 16)
                        .padding(.horizontal, 4)

                    FormatButton(icon: "chevron.left.forwardslash.chevron.right", label: "Code") {
                        coordinator.applyFormat(.code)
                    }

                    Divider()
                        .frame(height: 16)
                        .padding(.horizontal, 4)

                    Button("Done") { dismiss() }
                        .buttonStyle(.plain)
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(AppColors.shalyPurple)
                        .padding(.trailing, 4)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
                .background(Color.Surface.a10)

                Divider().background(Color.Surface.a30.opacity(0.5))

                // Editor
                ZStack(alignment: .bottomTrailing) {
                    RichTextEditor(
                        text: $text,
                        font: .systemFont(ofSize: 13),
                        textColor: .labelColor,
                        richText: true,
                        sharedCoordinator: coordinator
                    )
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(10)

                    // Word count + warning pill
                    VStack(alignment: .trailing, spacing: 4) {
                        if isAtMax {
                            HStack(spacing: 4) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .font(.system(size: 9, weight: .semibold))
                                Text("Word limit reached")
                                    .font(.system(size: 10, weight: .medium))
                            }
                            .foregroundColor(Color.Warning.a0)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(Color.Warning.a20)
                            .clipShape(Capsule())
                            .transition(.scale(scale: 0.85).combined(with: .opacity))
                        }

                        Text("\(count)/\(maxNotesWords)")
                            .font(.caption2)
                            .foregroundColor(isAtMax ? Color.Danger.a0 : count >= 250 ? Color.Warning.a0 : .secondary)
                            .monospacedDigit()
                    }
                    .padding(10)
                    .animation(.spring(response: 0.25, dampingFraction: 0.7), value: isAtMax)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .background(AppColors.background)
        .frame(width: 560, height: 380)
    }
}

// MARK: - Small format toolbar button
private struct FormatButton: View {
    let icon: String
    let label: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.secondary)
                .frame(width: 28, height: 28)
                .background(Color.Surface.a20.opacity(0.6))
                .clipShape(RoundedRectangle(cornerRadius: 6))
        }
        .buttonStyle(.plain)
        .help(label)
    }
}

// MARK: - THIS IS ORIGINAL
//
//import SwiftUI
//
//struct AddTaskView: View {
//    @Binding var newTaskTitle: String
//    @Binding var taskNotes: String
//    @Binding var inputCategory: TaskCategory
//    @Binding var inputPriority: TaskPriority
//    @Binding var taskDeadline: Date?
//    @Binding var showAppPicker: Bool
//    @Binding var showLinkInput: Bool
//    @Binding var selectedApp: DetectedApp?
//    @Binding var linkURL: String
//    @Binding var mainLinkBundleIdentifier: String?
//    @Binding var subtaskDrafts: [SubtaskDraft]
//    @Binding var activeSubtaskID: UUID?
//
//    let isEditing: Bool
//    let addTask: () -> Void
//    let cancelAction: () -> Void
//
//    @ObservedObject var appDetectionService: AppDetectionService
//
//    @State private var showDeadlineSheet = false
//    @State private var deadlineDraft = Date()
//    @FocusState private var focusedSubtaskID: UUID?
//
//    private var notesBinding: Binding<String> {
//        Binding(
//            get: { taskNotes },
//            set: { taskNotes = clampedNotes($0) }
//        )
//    }
//
//    private func formCard<Content: View>(@ViewBuilder content: () -> Content) -> some View {
//        content()
//            .frame(maxWidth: .infinity, alignment: .leading)
//            .padding(10)
//            .background(AppColors.background)
//            .cornerRadius(12)
//            .overlay(
//                RoundedRectangle(cornerRadius: 12)
//                    .stroke(Color.Surface.a30.opacity(0.4), lineWidth: 1)
//            )
//    }
//
//    private var notesSection: some View {
//        VStack(alignment: .leading, spacing: 6) {
//            HStack {
//                Text("Notes")
//                    .font(.headline)
//                    .foregroundColor(.white)
//                Spacer()
//                Text("\(wordCount(taskNotes))/\(maxNotesWords)")
//                    .font(.caption)
//                    .foregroundColor(
//                        wordCount(taskNotes) >= maxNotesWords ? .red :
//                        wordCount(taskNotes) >= 250 ? .red :
//                        wordCount(taskNotes) >= 200 ? .yellow : .secondary
//                    )
//            }
//            RichTextEditor(text: notesBinding)
//                .frame(minHeight: 60, maxHeight: 120)
//                .padding(6)
//                .background(Color.Surface.a10)
//                .cornerRadius(8)
//                .overlay(
//                    RoundedRectangle(cornerRadius: 8)
//                        .stroke(Color.gray.opacity(0.22), lineWidth: 1)
//                )
//        }
//    }
//
//    var body: some View {
//        VStack(spacing: 0) {
//            headerBar
//            ScrollViewReader { proxy in
//                ScrollView {
//                    VStack(alignment: .leading, spacing: 12) {
//                        // Main Details Card
//                        formCard {
//                            VStack(alignment: .leading, spacing: 12) {
//                                taskNameRow
//                                Divider().background(Color.Surface.a30.opacity(0.3))
//                                notesSection
//                                Divider().background(Color.Surface.a30.opacity(0.3))
//                                priorityPills
//                                Divider().background(Color.Surface.a30.opacity(0.3))
//                                deadlineAndLabelRow
//                            }
//                        }
//                        
//                        // Subtasks Card
//                        formCard {
//                            subtasksSection
//                        }
//                        Color.clear
//                            .frame(height: 1)
//                            .id("BOTTOM")
//                    }
//                    .padding(.horizontal, 12)
//                    .padding(.vertical, 10)
//                    .padding(.bottom, 8)
//                }
//                .onChange(of: subtaskDrafts.count) { _, _ in
//                    withAnimation {
//                        proxy.scrollTo("BOTTOM", anchor: .bottom)
//                    }
//                }
//            }
//        }
//        .background(AppColors.background)
//        .frame(width: 330, height: 420)
//        .onAppear {
//            if let d = taskDeadline {
//                deadlineDraft = d
//            } else {
//                deadlineDraft = Date()
//            }
//        }
//        .onChange(of: taskDeadline) { _, new in
//            if let d = new {
//                deadlineDraft = d
//            }
//        }
//        .sheet(isPresented: $showDeadlineSheet) {
//            VStack(spacing: 16) {
//                Text("Deadline").font(.headline)
//                DatePicker("", selection: $deadlineDraft, displayedComponents: .date)
//                    .datePickerStyle(.automatic)
//                    .labelsHidden()
//                HStack {
//                    Spacer()
//                    Button("Remove") { taskDeadline = nil ; showDeadlineSheet = false}
//                    Button("Cancel") { showDeadlineSheet = false }
//                    Button("Done") {
//                        taskDeadline = deadlineDraft
//                        showDeadlineSheet = false
//                    }
//                    .buttonStyle(.glassProminent)
//                }
//            }
//            .padding()
//            .frame(width: 240)
//        }
//    }
//
//    private var headerBar: some View {
//        VStack(alignment: .leading, spacing: 12) {
//            HStack(alignment: .center) {
//                Text("Your Task")
//                    .font(.title2.weight(.bold))
//
//                Spacer()
//
//                // Removed the empty button that was causing unexpected dismissals
//                Circle()
//                    .strokeBorder(Color.secondary.opacity(0.55), lineWidth: 1.5)
//                    .frame(width: 30, height: 30)
//                    .accessibilityHidden(true)
//            }
//
//            HStack {
//                Button("Cancel") {
//                    cancelAction()
//                }
//                .buttonStyle(.plain)
//                .foregroundColor(.accentColor)
//
//                Spacer()
//
//                Button(isEditing ? "Save" : "Add") {
//                    addTask()
//                }
//                .buttonStyle(.plain)
//                .foregroundColor(.accentColor)
//                .fontWeight(.semibold)
//            }
//        }
//        .padding(.horizontal, 16)
//        .padding(.top, 10)
//        .padding(.bottom, 8)
//        .background(AppColors.background)
//    }
//
//    private var taskNameRow: some View {
//        VStack(alignment: .leading, spacing: 4) {
//            Text("Task Name")
//                .font(.headline)
//                .foregroundColor(.white)
//            HStack(alignment: .center, spacing: 8) {
//                TextField("To Do...", text: $newTaskTitle)
//                    .textFieldStyle(.roundedBorder)
//                    .font(.body)
//                
//                Button(action: {
//                    appDetectionService.loadInstalledApplications()
//                    showAppPicker = true
//                }) {
//                    if let app = selectedApp {
//                        Image(nsImage: app.icon)
//                            .resizable()
//                            .scaledToFit()
//                            .frame(width: 20, height: 20)
//                    } else if !linkURL.isEmpty {
//                        LinkIconView(link: linkURL)
//                            .frame(width: 20, height: 20)
//                    } else {
//                        Image(systemName: "app.badge")
//                            .font(.body)
//                            .foregroundColor(AppColors.shalyPurple)
//                    }
//                }
//            }
//        }
//    }
//
//    @ViewBuilder
//    private var mainLinkIcon: some View {
//        if let app = selectedApp {
//            Image(nsImage: app.icon)
//                .resizable()
//                .scaledToFit()
//                .frame(width: 28, height: 28)
//        } else if !linkURL.isEmpty {
//            LinkIconView(link: linkURL)
//                .frame(width: 28, height: 28)
//        
//        } else if let bid = mainLinkBundleIdentifier, let img = appDetectionService.getIcon(for: bid) {
//            Image(nsImage: img)
//                .resizable()
//                .scaledToFit()
//                .frame(width: 28, height: 28)
//        } else {
//            Image(systemName: "link.badge.plus")
//                .font(.title3)
//                .foregroundColor(.secondary)
//        }
//    }
//
//    private var priorityPills: some View {
//        VStack(alignment: .leading, spacing: 6) {
//            Text("Priority")
//                .font(.headline)
//                .foregroundColor(.white)
//            HStack(spacing: 6) {
//                ForEach(TaskPriority.allCases) { p in
//                    Button {
//                        inputPriority = p
//                    } label: {
//                        Text(p.shortLabel)
//                            .font(.caption.weight(.medium))
//                            .padding(.horizontal, 12)
//                            .padding(.vertical, 6)
//                            .background(
//                                Capsule()
//                                    .fill(inputPriority == p ? p.color.opacity(0.25) : Color.gray.opacity(0.12))
//                            )
//                            .overlay(
//                                Capsule()
//                                    .stroke(inputPriority == p ? p.color : Color.gray.opacity(0.3), lineWidth: 1)
//                            )
//                    }
//                    .buttonStyle(.plain)
//                }
//            }
//        }
//    }
//
//    private var deadlineAndLabelRow: some View {
//        HStack(alignment: .top, spacing: 10) {
//            VStack(alignment: .leading, spacing: 4) {
//                Text("Deadline")
//                    .font(.headline)
//                    .foregroundColor(.white)
//                Button(action: {
//                    deadlineDraft = taskDeadline ?? Date()
//                    showDeadlineSheet = true
//                }) {
//                    Group {
//                        if let d = taskDeadline {
//                            Text(d, style: .date)
//                                .font(.caption.weight(.medium))
//                        } else {
//                            Text("Deadline")
//                                .font(.caption)
//                                .foregroundColor(.secondary)
//                        }
//                    }
//                    .frame(maxWidth: .infinity)
//                    .padding(.vertical, 8)
//                    .padding(.horizontal, 10)
//                    .background(Color.gray.opacity(0.1))
//                    .cornerRadius(8)
//                }
//                .buttonStyle(.plain)
//            }
//            .frame(maxWidth: .infinity)
//
//            VStack(alignment: .leading, spacing: 4) {
//                Text("Category")
//                    .font(.headline)
//                    .foregroundColor(.white)
//                Menu {
//                    ForEach(TaskCategory.assignableCategories) { cat in
//                        Button(cat.rawValue) {
//                            inputCategory = cat
//                        }
//                    }
//                } label: {
//                    HStack {
//                        Text(inputCategory.rawValue)
//                            .font(.caption.weight(.medium))
//                        Spacer()
//                        Image(systemName: "chevron.up.chevron.down")
//                            .font(.caption2)
//                            .foregroundColor(.secondary)
//                    }
//                    .frame(maxWidth: .infinity)
//                    .padding(.vertical, 8)
//                    .padding(.horizontal, 10)
//                    .background(Color.gray.opacity(0.1))
//                    .cornerRadius(8)
//                }
//                .menuStyle(.borderlessButton)
//            }
//            .frame(maxWidth: .infinity)
//        }
//    }
//
//    private var subtasksSection: some View {
//        VStack(alignment: .leading, spacing: 8) {
//            HStack {
//                Text("Subtasks")
//                    .font(.headline)
//                Spacer()
//                if subtaskDrafts.count < 10 {
//                    Button {
//                        let newDraft = SubtaskDraft()
//                        subtaskDrafts.append(newDraft)
//                        DispatchQueue.main.async {
//                            focusedSubtaskID = newDraft.id
//                        }
//                    } label: {
//                        Image(systemName: "plus.circle.fill")
//                            .foregroundColor(.accentColor)
//                    }
//                    .buttonStyle(.plain)
//                }
//            }
//
//            if subtaskDrafts.isEmpty {
//                Text("Add up to 10 subtasks.")
//                    .font(.caption)
//                    .foregroundColor(.secondary)
//            } else {
//                VStack(spacing: 8) {
//                    ForEach(subtaskDrafts) { draft in
//                        subtaskRow(draft: binding(for: draft.id))
//                    }
//                }
//            }
//        }
//    }
//
//    private func binding(for id: UUID) -> Binding<SubtaskDraft> {
//        Binding(
//            get: { subtaskDrafts.first { $0.id == id } ?? SubtaskDraft(id: id) },
//            set: { new in
//                if let i = subtaskDrafts.firstIndex(where: { $0.id == id }) {
//                    subtaskDrafts[i] = new
//                }
//            }
//        )
//    }
//
//    private func subtaskRow(draft: Binding<SubtaskDraft>) -> some View {
//        let id = draft.wrappedValue.id
//        let isAtMax = wordCount(draft.wrappedValue.title) >= maxSubtaskWords
//        let titleBinding = Binding(
//            get: { draft.wrappedValue.title },
//            set: { draft.wrappedValue.title = clampedSubtask($0) }
//        )
//
//        return VStack(alignment: .leading, spacing: 3) {
//            HStack(spacing: 10) {
//                TextField("Subtask title...", text: titleBinding)
//                    .textFieldStyle(.roundedBorder)
//                    .font(.subheadline)
//                    .focused($focusedSubtaskID, equals: id)
//                    .onSubmit {
//                        // Only create a new draft if the current field has text
//                        let hasText = !draft.wrappedValue.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
//                        guard hasText, subtaskDrafts.count < 10 else { return }
//                        let newDraft = SubtaskDraft()
//                        withAnimation{subtaskDrafts.append(newDraft)}
//                        focusedSubtaskID = nil
//                        // Focus the new field after SwiftUI updates
//                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//                            focusedSubtaskID = newDraft.id
//                        }
//                    }
//
//                Button {
//                    subtaskDrafts.removeAll { $0.id == id }
//                } label: {
//                    Image(systemName: "minus.circle.fill")
//                        .foregroundColor(.secondary)
//                }
//                .buttonStyle(.plain)
//            }
//
//            // Warning pill — only visible when the word limit is reached
//            if isAtMax {
//                HStack(spacing: 4) {
//                    Image(systemName: "exclamationmark.triangle.fill")
//                        .font(.system(size: 9, weight: .semibold))
//                    Text("Max \(maxSubtaskWords) words")
//                        .font(.system(size: 10, weight: .medium))
//                }
//                .foregroundColor(Color.Warning.a0)
//                .padding(.horizontal, 8)
//                .padding(.vertical, 3)
//                .background(Color.Warning.a20)
//                .clipShape(Capsule())
//                .transition(.scale(scale: 0.85).combined(with: .opacity))
//            }
//        }
//        .padding(.vertical, 2)
//        .animation(.spring(response: 0.25, dampingFraction: 0.7), value: isAtMax)
//    }
//}

//===================
//
// MARK: - THIS IS THE PROTOTYPE
//import SwiftUI
//
//struct AddTaskView: View {
//    @Binding var newTaskTitle: String
//    @Binding var taskNotes: String
//    @Binding var inputCategory: TaskCategory
//    @Binding var inputPriority: TaskPriority
//    @Binding var taskDeadline: Date?
//    @Binding var showAppPicker: Bool
//    @Binding var showLinkInput: Bool
//    @Binding var selectedApp: DetectedApp?
//    @Binding var linkURL: String
//    @Binding var mainLinkBundleIdentifier: String?
//    @Binding var subtaskDrafts: [SubtaskDraft]
//    @Binding var activeSubtaskID: UUID?
//
//    let isEditing: Bool
//    let addTask: () -> Void
//    let cancelAction: () -> Void
//
//    @ObservedObject var appDetectionService: AppDetectionService
//
//    @State private var showDeadlineSheet = false
//    @State private var deadlineDraft = Date()
//
//    var body: some View {
//        VStack(spacing: 20) {
//
//            header
//
//            ScrollView {
//                VStack(spacing: 18) {
//
//                    mainCard
//
//                    prioritySection
//
//                    bottomRow
//
//                    subtasksSection
//                }
//                .padding(.horizontal, 20)
//                .padding(.bottom, 20)
//            }
//        }
//        .frame(width: 380, height: 520)
//        .background(Color.black.opacity(0.96))
//    }
//}
//
//extension AddTaskView {
//
//    private var header: some View {
//        HStack {
//            Text(isEditing ? "Edit task" : "Add new task")
//                .font(.system(size: 28, weight: .semibold))
//                .foregroundColor(.white)
//
//            Spacer()
//
//            Button(action: addTask) {
//                Circle()
//                    .fill(Color.white.opacity(0.08))
//                    .frame(width: 46, height: 46)
//                    .overlay(
//                        Image(systemName: "arrow.up.right")
//                            .foregroundColor(.white)
//                    )
//            }
//            .buttonStyle(.plain)
//        }
//        .padding(.horizontal, 20)
//        .padding(.top, 20)
//    }
//
//    private var mainCard: some View {
//        VStack(alignment: .leading, spacing: 18) {
//
//            fieldTitle("Task Name")
//
//            HStack {
//                pillTextField("What needs to be done?", text: $newTaskTitle)
//
//                Button(action: {
//                    appDetectionService.loadInstalledApplications()
//                    showAppPicker = true
//                }) {
//                    ZStack {
//                        RoundedRectangle(cornerRadius: 14)
//                            .fill(Color.white.opacity(0.06))
//                            .frame(width: 50, height: 50)
//
//                        if let app = selectedApp {
//                            Image(nsImage: app.icon)
//                                .resizable()
//                                .scaledToFit()
//                                .frame(width: 24, height: 24)
//                        } else {
//                            Image(systemName: "app.badge")
//                                .font(.title3)
//                                .foregroundColor(.white.opacity(0.7))
//                        }
//                    }
//                }
//                .buttonStyle(.plain)
//            }
//
//            fieldTitle("Description")
//
//            TextEditor(text: $taskNotes)
//                .frame(height: 120)
//                .padding(14)
//                .background(
//                    RoundedRectangle(cornerRadius: 18)
//                        .fill(Color.white.opacity(0.05))
//                )
//                .foregroundColor(.white)
//
//            HStack(spacing: 12) {
//
//                VStack(alignment: .leading, spacing: 8) {
//                    fieldTitle("Due Date")
//
//                    Button {
//                        showDeadlineSheet = true
//                    } label: {
//                        datePill
//                    }
//                    .buttonStyle(.plain)
//                }
//
//                VStack(alignment: .leading, spacing: 8) {
//                    fieldTitle("Category")
//
//                    categoryPill
//                }
//            }
//        }
//        .padding(20)
//        .background(
//            RoundedRectangle(cornerRadius: 24)
//                .fill(Color.white.opacity(0.04))
//        )
//    }
//
//    private var prioritySection: some View {
//        VStack(alignment: .leading, spacing: 12) {
//            fieldTitle("Priority")
//
//            HStack(spacing: 12) {
//                ForEach(TaskPriority.allCases) { p in
//                    Button {
//                        inputPriority = p
//                    } label: {
//                        Text(p.shortLabel)
//                            .foregroundColor(inputPriority == p ? .black : .white.opacity(0.8))
//                            .frame(maxWidth: .infinity)
//                            .padding(.vertical, 12)
//                            .background(
//                                Capsule()
//                                    .fill(inputPriority == p ? Color.white : Color.white.opacity(0.06))
//                            )
//                    }
//                    .buttonStyle(.plain)
//                }
//            }
//        }
//    }
//
//    private var bottomRow: some View {
//        HStack {
//            Button("Cancel") {
//                cancelAction()
//            }
//            .foregroundColor(.gray)
//
//            Spacer()
//
//            Button(isEditing ? "Save Task" : "Add Task") {
//                addTask()
//            }
//            .foregroundColor(.black)
//            .padding(.horizontal, 20)
//            .padding(.vertical, 10)
//            .background(Capsule().fill(Color.white))
//        }
//    }
//
//    private var subtasksSection: some View {
//        VStack(alignment: .leading, spacing: 12) {
//            fieldTitle("Subtasks")
//
//            ForEach(subtaskDrafts) { draft in
//                HStack {
//                    RoundedRectangle(cornerRadius: 12)
//                        .fill(Color.white.opacity(0.05))
//                        .frame(width: 44, height: 44)
//
//                    Text("Subtask")
//                        .foregroundColor(.white.opacity(0.8))
//
//                    Spacer()
//                }
//            }
//        }
//    }
//
//    private func fieldTitle(_ text: String) -> some View {
//        Text(text)
//            .font(.subheadline)
//            .foregroundColor(.gray)
//    }
//
//    private func pillTextField(_ placeholder: String, text: Binding<String>) -> some View {
//        TextField(placeholder, text: text)
//            .padding()
//            .background(
//                RoundedRectangle(cornerRadius: 18)
//                    .fill(Color.white.opacity(0.05))
//            )
//            .foregroundColor(.white)
//    }
//
//    private var datePill: some View {
//        HStack {
//            if let deadline = taskDeadline {
//                Text(deadline, style: .date)
//                .foregroundColor(.white.opacity(0.85))
//
//            } else {
//                Text("Select")
//                .foregroundColor(.white.opacity(0.85))
//            }
//
//            Spacer()
//        }
//        .padding()
//        .background(
//            RoundedRectangle(cornerRadius: 18)
//                .fill(Color.white.opacity(0.05))
//        )
//    }
//
//    private var categoryPill: some View {
//        HStack {
//            Text(inputCategory.rawValue)
//                .foregroundColor(.white.opacity(0.85))
//
//            Spacer()
//
//            Image(systemName: "chevron.down")
//                .foregroundColor(.gray)
//        }
//        .padding()
//        .background(
//            RoundedRectangle(cornerRadius: 18)
//                .fill(Color.white.opacity(0.05))
//        )
//    }
//}
//

//===================
