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

    private var notesBinding: Binding<String> {
        Binding(
            get: { taskNotes },
            set: { taskNotes = clampedNotes($0) }
        )
    }

    private func formCard<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(14)
            .background(Color(.bgdark.opacity(0.15)))
            .cornerRadius(14)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color.blue.opacity(0.12), lineWidth: 1)
            )
    }

    private var notesSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Notes")
                .font(.caption)
                .foregroundColor(.secondary)
            TextEditor(text: notesBinding)
                .font(.body)
                .scrollContentBackground(.hidden)
                .frame(minHeight: 100, maxHeight: 140)
                .padding(8)
                .background(Color(nsColor: .textBackgroundColor))
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray.opacity(0.22), lineWidth: 1)
                )
            HStack {
                Spacer()
                Text("\(wordCount(taskNotes)) / \(maxNotesWords) words")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            headerBar

            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    formCard {
                        taskNameRow
                    }

                    formCard {
                        notesSection
                    }

                    formCard {
                        priorityPills
                    }

                    formCard {
                        deadlineAndLabelRow
                    }

                    formCard {
                        subtasksSection
                    }
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .padding(.bottom, 8)
            }
        }
        .background(Color(nsColor: .windowBackgroundColor).opacity(0.95))
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
                    .datePickerStyle(.graphical)
                    .labelsHidden()
                HStack {
                    Button("Remove deadline") {
                        taskDeadline = nil
                        showDeadlineSheet = false
                    }
                    .buttonStyle(.plain)
                    Spacer()
                    Button("Cancel") { showDeadlineSheet = false }
                    Button("Done") {
                        taskDeadline = deadlineDraft
                        showDeadlineSheet = false
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .padding()
            .frame(width: 320)
        }
    }

    private var headerBar: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .center) {
                Text("Your Task")
                    .font(.title2.weight(.bold))

                Spacer()

                // Removed the empty button that was causing unexpected dismissals
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
        .background(Color(nsColor: .windowBackgroundColor))
    }

    private var taskNameRow: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Task Name")
                .font(.title3)
                .foregroundColor(.secondary)
            HStack(alignment: .center, spacing: 8) {
                TextField("What needs to be done?", text: $newTaskTitle)
                    .textFieldStyle(.roundedBorder)
                    .font(.caption)

                Menu {
                    Button("Choose App") {
                        activeSubtaskID = nil
                        appDetectionService.loadInstalledApplications()
                        showAppPicker = true
                    }
                    Button("Enter URL") {
                        activeSubtaskID = nil
                        showLinkInput = true
                    }
                } label: {
                    mainLinkIcon
                }
                .menuStyle(.borderlessButton)
                .frame(width: 40, height: 40)
                .background(Color.gray.opacity(0.08))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )
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
        VStack(alignment: .leading, spacing: 8) {
            Text("Priority")
                .font(.title3)
                .foregroundColor(.secondary)
            HStack(spacing: 8) {
                ForEach(TaskPriority.allCases) { p in
                    Button {
                        inputPriority = p
                    } label: {
                        Text(p.shortLabel)
                            .font(.subheadline.weight(.medium))
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
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
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Deadline")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Button(action: {
                    deadlineDraft = taskDeadline ?? Date()
                    showDeadlineSheet = true
                }) {
                    Group {
                        if let d = taskDeadline {
                            Text(d, style: .date)
                                .font(.subheadline.weight(.medium))
                        } else {
                            Text("Deadline")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .padding(.horizontal, 12)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                }
                .buttonStyle(.plain)
            }
            .frame(maxWidth: .infinity)

            VStack(alignment: .leading, spacing: 6) {
                Text("Label")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Menu {
                    ForEach(TaskCategory.assignableCategories) { cat in
                        Button(cat.rawValue) {
                            inputCategory = cat
                        }
                    }
                } label: {
                    HStack {
                        Text(inputCategory.rawValue)
                            .font(.subheadline.weight(.medium))
                        Spacer()
                        Image(systemName: "chevron.up.chevron.down")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .padding(.horizontal, 12)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
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
                        subtaskDrafts.append(SubtaskDraft())
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.accentColor)
                    }
                    .buttonStyle(.plain)
                }
            }

            if subtaskDrafts.isEmpty {
                Text("Add up to 10 subtasks with an app or URL.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            } else {
                ScrollView {
                    VStack(spacing: 8) {
                        ForEach(subtaskDrafts) { draft in
                            subtaskRow(draft: binding(for: draft.id))
                        }
                    }
                }
                .frame(maxHeight: 220)
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
        return HStack(spacing: 10) {
            Menu {
                Button("Choose App") {
                    activeSubtaskID = id
                    appDetectionService.loadInstalledApplications()
                    showAppPicker = true
                }
                Button("Enter URL") {
                    activeSubtaskID = id
                    showLinkInput = true
                }
            } label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .strokeBorder(Color.secondary.opacity(0.35), style: StrokeStyle(lineWidth: 1, dash: [5, 4]))
                        .background(RoundedRectangle(cornerRadius: 10).fill(Color(nsColor: .textBackgroundColor).opacity(0.5)))

                    subtaskIcon(for: draft.wrappedValue)
                        .padding(8)
                }
                .frame(width: 56, height: 56)
            }
            .menuStyle(.borderlessButton)

            Text("App or link")
                .font(.caption)
                .foregroundColor(.secondary)

            Spacer(minLength: 0)

            Button {
                subtaskDrafts.removeAll { $0.id == id }
            } label: {
                Image(systemName: "minus.circle.fill")
                    .font(.title3)
                    .foregroundColor(.secondary)
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 4)
    }

    @ViewBuilder
    private func subtaskIcon(for draft: SubtaskDraft) -> some View {
        if let app = draft.detectedApp {
            Image(nsImage: app.icon)
                .resizable()
                .scaledToFit()
        } else if let bid = draft.appBundleIdentifier, let img = appDetectionService.getIcon(for: bid) {
            Image(nsImage: img)
                .resizable()
                .scaledToFit()
        } else if !draft.linkURL.isEmpty {
            LinkIconView(link: draft.linkURL)
        } else {
            Image(systemName: "square.dashed")
                .foregroundColor(.secondary)
        }
    }
}
