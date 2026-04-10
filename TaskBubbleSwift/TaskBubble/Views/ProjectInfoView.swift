//
//  ProjectInfoView.swift
//  TaskBubble
//
//  Created by Shalyca Sottoriva on 10/04/2026.
//

// ProjectInfoView.swift
// TaskBubble
//
// Used both for creating a new project and editing an existing one.
// Pass nil for `project` to create; pass an existing Project to edit.

import CoreData
import SwiftUI

struct ProjectInfoView: View {

    // nil = create mode, non-nil = edit mode
    var project: Project?
    @ObservedObject var appDetectionService: AppDetectionService

    var onSave: () -> Void
    var onCancel: () -> Void

    @Environment(\.managedObjectContext) private var viewContext

    // Form state
    @State private var name: String = ""
    @State private var notes: String = ""
    @State private var selectedColorHex: String = "#BC6CD9"
    @State private var priority: TaskPriority = .medium
    @State private var deadline: Date? = nil
    @State private var deadlineDraft: Date = Date()
    @State private var showDeadlinePicker = false
    @State private var showAppPicker = false
    @State private var selectedApp: DetectedApp? = nil
    @State private var linkURL: String = ""

    private var isEditing: Bool { project != nil }

    var body: some View {
        VStack(spacing: 0) {
            headerBar
            Divider().background(Color.Surface.a30.opacity(0.4))
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    nameSection
                    divider
                    colorSection
                    divider
                    notesSection
                    divider
                    prioritySection
                    divider
                    deadlineSection
                    divider
                    appLinkSection
                }
                .padding(.bottom, 12)
            }
            saveButton
        }
        .background(AppColors.background)
        .frame(width: 330, height: 430)
        .onAppear { populateFromProject() }
        .sheet(isPresented: $showDeadlinePicker) {
            VStack(spacing: 16) {
                Text("Deadline")
                    .font(AppFonts.headline)
                    .foregroundColor(AppColors.textWhite)
                DatePicker("", selection: $deadlineDraft, displayedComponents: .date)
                    .datePickerStyle(.automatic)
                    .labelsHidden()
                HStack {
                    Spacer()
                    Button("Remove") { deadline = nil; showDeadlinePicker = false }
                        .buttonStyle(.plain)
                        .foregroundColor(Color.Danger.a10)
                    Button("Cancel") { showDeadlinePicker = false }
                        .buttonStyle(.plain)
                        .foregroundColor(Color.Surface.a60)
                    Button("Done") {
                        deadline = deadlineDraft
                        showDeadlinePicker = false
                    }
                    .buttonStyle(.glassProminent)
                }
            }
            .padding()
            .frame(width: 240)
        }
        .sheet(isPresented: $showAppPicker) {
            AppPickerView(
                appDetectionService: appDetectionService,
                selectedApp: $selectedApp,
                linkURL: $linkURL,
                isPresented: $showAppPicker
            )
        }
    }

    // MARK: - Header

    private var headerBar: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(isEditing ? "Edit Project" : "New Project")
                    .font(.custom("Montserrat-Bold", size: 16))
                    .foregroundColor(AppColors.textWhite)
                Spacer()
                // Colour swatch preview
                Circle()
                    .fill(Color(hex: selectedColorHex))
                    .frame(width: 18, height: 18)
                    .overlay(Circle().stroke(Color.white.opacity(0.3), lineWidth: 1))
            }
            HStack {
                Button("Cancel", action: onCancel)
                    .buttonStyle(.plain)
                    .foregroundColor(Color.Surface.a60)
                    .font(AppFonts.label)
                Spacer()
                Button(isEditing ? "Save" : "Create") { saveProject() }
                    .buttonStyle(.plain)
                    .font(.custom("Montserrat-Bold", size: 13))
                    .foregroundColor(AppColors.shalyPurple)
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 12)
        .padding(.bottom, 10)
    }

    // MARK: - Sections

    private var nameSection: some View {
        sectionWrap {
            sectionLabel("Project Name")
            TextField("e.g. App Redesign", text: $name)
                .textFieldStyle(.roundedBorder)
                .font(AppFonts.taskText)
        }
    }

    private var colorSection: some View {
        sectionWrap {
            sectionLabel("Colour")
            HStack(spacing: 8) {
                ForEach(ProjectPalette.swatches, id: \.hex) { swatch in
                    Button {
                        selectedColorHex = swatch.hex
                    } label: {
                        ZStack {
                            Circle()
                                .fill(swatch.color)
                                .frame(width: 24, height: 24)
                            if selectedColorHex == swatch.hex {
                                Circle()
                                    .stroke(Color.white, lineWidth: 2)
                                    .frame(width: 24, height: 24)
                                Image(systemName: "checkmark")
                                    .font(.system(size: 8, weight: .bold))
                                    .foregroundColor(.white)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.top, 2)
        }
    }

    private var notesSection: some View {
        sectionWrap {
            sectionLabel("Notes")
            RichTextEditor(text: $notes)
                .frame(minHeight: 55, maxHeight: 80)
                .padding(6)
                .background(Color.Surface.a10)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.Surface.a30.opacity(0.5), lineWidth: 0.5)
                )
        }
    }

    private var prioritySection: some View {
        sectionWrap {
            sectionLabel("Priority")
            HStack(spacing: 6) {
                ForEach(TaskPriority.allCases) { p in
                    Button { priority = p } label: {
                        Text(p.shortLabel)
                            .font(.custom("Montserrat-Bold", size: 10))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 5)
                            .background(
                                Capsule().fill(priority == p
                                               ? p.color.opacity(0.22)
                                               : Color.Surface.a20.opacity(0.3))
                            )
                            .overlay(
                                Capsule().stroke(priority == p
                                                 ? p.color
                                                 : Color.Surface.a30.opacity(0.5),
                                                 lineWidth: 0.5)
                            )
                            .foregroundColor(priority == p ? p.color : Color.Surface.a60)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var deadlineSection: some View {
        sectionWrap {
            sectionLabel("Deadline")
            Button {
                deadlineDraft = deadline ?? Date()
                showDeadlinePicker = true
            } label: {
                HStack {
                    if let d = deadline {
                        Text(d, style: .date)
                            .font(.custom("Montserrat-Medium", size: 11))
                            .foregroundColor(AppColors.textWhite)
                    } else {
                        Text("Set deadline")
                            .font(.custom("Montserrat-Regular", size: 11))
                            .foregroundColor(Color.Surface.a50)
                    }
                    Spacer()
                    Image(systemName: "calendar")
                        .font(.system(size: 11))
                        .foregroundColor(Color.Surface.a50)
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 10)
                .background(Color.Surface.a10)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.Surface.a30.opacity(0.5), lineWidth: 0.5)
                )
            }
            .buttonStyle(.plain)
        }
    }

    private var appLinkSection: some View {
        sectionWrap {
            sectionLabel("App / Link")
            Button {
                appDetectionService.loadInstalledApplications()
                showAppPicker = true
            } label: {
                HStack(spacing: 8) {
                    // Icon
                    Group {
                        if let app = selectedApp {
                            Image(nsImage: app.icon)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 18, height: 18)
                                .cornerRadius(4)
                        } else if !linkURL.isEmpty {
                            LinkIconView(link: linkURL)
                                .frame(width: 18, height: 18)
                        } else {
                            ZStack {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color.Surface.a20.opacity(0.5))
                                    .frame(width: 18, height: 18)
                                Image(systemName: "link.badge.plus")
                                    .font(.system(size: 9))
                                    .foregroundColor(Color.Surface.a50)
                            }
                        }
                    }
                    // Label
                    if let app = selectedApp {
                        Text(app.displayName)
                            .font(.custom("Montserrat-Medium", size: 11))
                            .foregroundColor(AppColors.textWhite)
                    } else if !linkURL.isEmpty {
                        Text(linkURL)
                            .font(.custom("Montserrat-Regular", size: 10))
                            .foregroundColor(AppColors.textWhite)
                            .lineLimit(1)
                    } else {
                        Text("Attach app or link")
                            .font(.custom("Montserrat-Regular", size: 11))
                            .foregroundColor(Color.Surface.a50)
                    }
                    Spacer()
                    if selectedApp != nil || !linkURL.isEmpty {
                        Button {
                            selectedApp = nil
                            linkURL = ""
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 12))
                                .foregroundColor(Color.Surface.a40)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 10)
                .background(Color.Surface.a10)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.Surface.a30.opacity(0.5), lineWidth: 0.5)
                )
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Save button

    private var saveButton: some View {
        Button(action: saveProject) {
            Text(isEditing ? "Save changes" : "Create project")
                .font(.custom("Montserrat-Bold", size: 12))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(Capsule().fill(AppColors.shalyPurple))
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(AppColors.background)
        .overlay(
            Rectangle()
                .frame(height: 0.5)
                .foregroundColor(Color.Surface.a30.opacity(0.4)),
            alignment: .top
        )
    }

    // MARK: - Helpers

    private func sectionWrap<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            content()
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
    }

    private func sectionLabel(_ text: String) -> some View {
        Text(text.uppercased())
            .font(.custom("Montserrat-Bold", size: 9))
            .foregroundColor(Color.Surface.a50)
            .tracking(0.8)
    }

    private var divider: some View {
        Divider()
            .background(Color.Surface.a30.opacity(0.35))
            .padding(.horizontal, 14)
    }

    // MARK: - Populate on edit

    private func populateFromProject() {
        guard let p = project else { return }
        name = p.name ?? ""
        notes = p.notes ?? ""
        selectedColorHex = p.colorHex ?? "#BC6CD9"
        priority = p.priorityEnum
        deadline = p.deadline
        if let type = p.linkedResourceType, let value = p.linkedResourceValue {
            if type == LinkedResourceType.app.rawValue {
                selectedApp = appDetectionService.installedApps.first { $0.id == value }
            } else {
                linkURL = value
            }
        }
    }

    // MARK: - Save

    private func saveProject() {
        guard !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }

        let proj = project ?? Project(context: viewContext)
        if project == nil {
            proj.id = UUID()
            proj.timestamp = Date()
        }
        proj.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        proj.notes = notes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : notes
        proj.colorHex = selectedColorHex
        proj.priority = priority.rawValue
        proj.deadline = deadline

        if let app = selectedApp {
            proj.linkedResourceType = LinkedResourceType.app.rawValue
            proj.linkedResourceValue = app.id
            proj.linkedResourceAppDisplayName = app.displayName
        } else if !linkURL.isEmpty {
            proj.linkedResourceType = LinkedResourceType.url.rawValue
            proj.linkedResourceValue = linkURL
            proj.linkedResourceAppDisplayName = nil
        } else {
            proj.linkedResourceType = nil
            proj.linkedResourceValue = nil
            proj.linkedResourceAppDisplayName = nil
        }

        try? viewContext.save()
        onSave()
    }
}
