////
////  ProjectDashboardView.swift
////  TaskBubble
////
////  Created by Shalyca Sottoriva on 10/04/2026.
////
//
//// ProjectDashboardView.swift
//// TaskBubble
//
//import CoreData
//import SwiftUI
//
//// MARK: - Task status for project filtering
//
//enum ProjectTaskStatus: String, CaseIterable, Identifiable {
//    case all    = "All"
//    case todo   = "To Do"
//    case doing  = "Doing"
//    case done   = "Done"
//    var id: String { rawValue }
//}
//
//// MARK: - Main dashboard
//
//struct ProjectDashboardView: View {
//
//    // Injected
//    let items: [Item]
//    @ObservedObject var appDetectionService: AppDetectionService
//    var onAddProject: () -> Void
//    var onSelectProject: (Project) -> Void
//    var onSelectTask: (Item) -> Void
//    var onAddTask: () -> Void
//    var onSearch: () -> Void
//    var onSort: () -> Void
//
//    // Core Data
//    @Environment(\.managedObjectContext) private var viewContext
//    @FetchRequest(
//        sortDescriptors: [NSSortDescriptor(keyPath: \Project.timestamp, ascending: true)],
//        animation: .default
//    ) private var projects: FetchedResults<Project>
//
//    @State private var selectedStatus: ProjectTaskStatus = .all
//    @State private var archivingIDs: Set<NSManagedObjectID> = []
//
//    // All project tasks flattened
//    private var allProjectItems: [Item] {
//        items.filter { $0.value(forKey: "project") != nil }
//    }
//
//    private var filteredItems: [Item] {
//        let pool = allProjectItems.filter { !archivingIDs.contains($0.objectID) }
//        switch selectedStatus {
//        case .all:   return pool
//        case .todo:  return pool.filter { ($0.value(forKey: "taskStatus") as? String) == "todo"  || ($0.value(forKey: "taskStatus") as? String) == nil && !$0.completed }
//        case .doing: return pool.filter { ($0.value(forKey: "taskStatus") as? String) == "doing" }
//        case .done:  return pool.filter { $0.completed }
//        }
//    }
//
//    var body: some View {
//        ZStack {
//            AppColors.background.ignoresSafeArea()
//
//            VStack(spacing: 0) {
//                toolbar
//                ScrollView(showsIndicators: false) {
//                    VStack(alignment: .leading, spacing: 0) {
//                        projectsSection
//                        statusPills
//                        taskListSection
//                    }
//                    .padding(.bottom, 16)
//                }
//                addTaskFAB
//            }
//        }
//    }
//
//    // MARK: - Toolbar
//
//    private var toolbar: some View {
//        HStack(alignment: .center) {
//            Image(systemName: "square.grid.2x2.fill")
//                .font(.system(size: 13))
//                .foregroundColor(AppColors.shalyPurple)
//            Text("Project Dashboard")
//                .font(AppFonts.headline)
//                .foregroundColor(AppColors.textWhite)
//            Spacer()
//            TaskToolbarCircleButtons(onAdd: onAddTask, onSearch: onSearch, diameter: 26)
//        }
//        .padding(.horizontal, 14)
//        .padding(.vertical, 10)
//        .background(AppColors.background)
//        .overlay(
//            Rectangle()
//                .frame(height: 0.5)
//                .foregroundColor(Color.Surface.a30.opacity(0.5)),
//            alignment: .bottom
//        )
//    }
//
//    // MARK: - Projects horizontal scroller
//
//    private var projectsSection: some View {
//        VStack(alignment: .leading, spacing: 0) {
//            HStack {
//                Text("PROJECTS")
//                    .font(AppFonts.numbers)
//                    .foregroundColor(Color.Surface.a50)
//                    .tracking(1)
//                Spacer()
//                Button(action: onAddProject) {
//                    HStack(spacing: 4) {
//                        Image(systemName: "plus")
//                            .font(.system(size: 9, weight: .bold))
//                        Text("Add project")
//                            .font(AppFonts.numbers)
//                    }
//                    .foregroundColor(AppColors.shalyPurple)
//                }
//                .buttonStyle(.plain)
//            }
//            .padding(.horizontal, 14)
//            .padding(.top, 12)
//            .padding(.bottom, 8)
//
//            ScrollView(.horizontal, showsIndicators: false) {
//                HStack(spacing: 9) {
//                    ForEach(projects) { project in
//                        ProjectFolderCard(project: project)
//                            .onTapGesture { onSelectProject(project) }
//                    }
//                    // Empty state placeholder
//                    if projects.isEmpty {
//                        Text("No projects yet")
//                            .font(AppFonts.label)
//                            .foregroundColor(Color.Surface.a50)
//                            .padding(.vertical, 20)
//                            .padding(.horizontal, 4)
//                    }
//                }
//                .padding(.horizontal, 14)
//                .padding(.bottom, 6)
//            }
//        }
//    }
//
//    // MARK: - Status pills
//
//    private var statusPills: some View {
//        ScrollView(.horizontal, showsIndicators: false) {
//            HStack(spacing: 6) {
//                ForEach(ProjectTaskStatus.allCases) { status in
//                    Button { selectedStatus = status } label: {
//                        Text(status.rawValue)
//                            .font(.custom("Montserrat-Bold", size: 10))
//                            .padding(.horizontal, 10)
//                            .padding(.vertical, 4)
//                            .background(
//                                Capsule()
//                                    .fill(selectedStatus == status
//                                          ? AppColors.shalyPurple
//                                          : Color.Surface.a20.opacity(0.5))
//                            )
//                            .overlay(
//                                Capsule()
//                                    .stroke(selectedStatus == status
//                                            ? AppColors.shalyPurple
//                                            : Color.Surface.a30.opacity(0.6),
//                                            lineWidth: 0.5)
//                            )
//                            .foregroundColor(selectedStatus == status
//                                             ? .white
//                                             : Color.Surface.a60)
//                    }
//                    .buttonStyle(.plain)
//                }
//            }
//            .padding(.horizontal, 14)
//            .padding(.vertical, 8)
//        }
//    }
//
//    // MARK: - Task list
//
//    private var taskListSection: some View {
//        LazyVStack(spacing: 5) {
//            if filteredItems.isEmpty {
//                Text("No tasks here yet")
//                    .font(AppFonts.label)
//                    .foregroundColor(Color.Surface.a50)
//                    .frame(maxWidth: .infinity)
//                    .padding(.top, 20)
//            } else {
//                ForEach(filteredItems) { item in
//                    let proj = item.value(forKey: "project") as? Project
//                    ProjectTaskRow(
//                        item: item,
//                        projectColor: proj?.color ?? AppColors.shalyPurple,
//                        appDetectionService: appDetectionService,
//                        isArchiving: archivingIDs.contains(item.objectID),
//                        onSelect: { onSelectTask(item) },
//                        onComplete: { handleComplete(item) }
//                    )
//                    .padding(.horizontal, 14)
//                }
//            }
//        }
//    }
//
//    // MARK: - FAB
//
//    private var addTaskFAB: some View {
//        Button(action: onAddTask) {
//            HStack(spacing: 6) {
//                Image(systemName: "plus")
//                    .font(.system(size: 11, weight: .bold))
//                Text("Add task to project")
//                    .font(.custom("Montserrat-Bold", size: 11))
//            }
//            .foregroundColor(AppColors.shalyPurple)
//            .frame(maxWidth: .infinity)
//            .padding(.vertical, 10)
//            .background(
//                Capsule()
//                    .fill(Color.Primary.a0.opacity(0.12))
//            )
//            .overlay(
//                Capsule()
//                    .stroke(Color.Primary.a0.opacity(0.4), lineWidth: 0.5)
//            )
//        }
//        .buttonStyle(.plain)
//        .padding(.horizontal, 14)
//        .padding(.vertical, 10)
//        .background(AppColors.background)
//        .overlay(
//            Rectangle()
//                .frame(height: 0.5)
//                .foregroundColor(Color.Surface.a30.opacity(0.4)),
//            alignment: .top
//        )
//    }
//
//    // MARK: - Completion + archive
//
//    private func handleComplete(_ item: Item) {
//        guard !item.completed else { return }
//        item.completed = true
//        saveContext()
//        withAnimation(.easeInOut(duration: 0.3)) {
//            _ = archivingIDs.insert(item.objectID)
//        }
//        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
//            withAnimation(.easeOut(duration: 0.4)) {
//                _ = archivingIDs.remove(item.objectID)
//            }
//        }
//    }
//
//    private func saveContext() {
//        try? viewContext.save()
//    }
//}
//
//// MARK: - Folder card
//
//struct ProjectFolderCard: View {
//    @ObservedObject var project: Project
//
//    var body: some View {
//        VStack(alignment: .leading, spacing: 0) {
//            // Folder tab
//            HStack {
//                RoundedRectangle(cornerRadius: 4)
//                    .fill(project.color)
//                    .frame(width: 38, height: 9)
//                    .padding(.leading, 7)
//                Spacer()
//            }
//            // Folder body
//            VStack(alignment: .leading, spacing: 4) {
//                Text(project.name ?? "Untitled")
//                    .font(.custom("Montserrat-Bold", size: 10))
//                    .foregroundColor(AppColors.textWhite)
//                    .lineLimit(1)
//                Text("\(project.taskCount) tasks")
//                    .font(.custom("Montserrat-SemiBold", size: 9))
//                    .foregroundColor(Color.white.opacity(0.5))
//                // Progress dots
//                HStack(spacing: 3) {
//                    let filled = min(project.completedCount, 3)
//                    let total = min(project.taskCount, 3)
//                    ForEach(0..<max(total, 1), id: \.self) { i in
//                        Circle()
//                            .fill(project.color.opacity(i < filled ? 0.9 : 0.3))
//                            .frame(width: 5, height: 5)
//                    }
//                }
//                .padding(.top, 2)
//            }
//            .padding(.horizontal, 8)
//            .padding(.vertical, 7)
//            .frame(width: 82, alignment: .leading)
//            .background(project.color.opacity(0.12))
//            .overlay(
//                RoundedRectangle(cornerRadius: 6)
//                    .stroke(Color.white.opacity(0.07), lineWidth: 0.5),
//                alignment: .center
//            )
//            .cornerRadius(6, corners: [.bottomLeft, .bottomRight, .topRight])
//        }
//        .frame(width: 82)
//    }
//}
//
//// MARK: - Unified project task row (no status header)
//
//struct ProjectTaskRow: View {
//    @ObservedObject var item: Item
//    let projectColor: Color
//    @ObservedObject var appDetectionService: AppDetectionService
//    var isArchiving: Bool = false
//    var onSelect: () -> Void
//    var onComplete: () -> Void
//
//    var body: some View {
//        HStack(spacing: 7) {
//            // Coloured left flag
//            Rectangle()
//                .fill(projectColor)
//                .frame(width: 3)
//                .cornerRadius(9, corners: [.topLeft, .bottomLeft])
//
//            // Checkmark
//            Button(action: onComplete) {
//                ZStack {
//                    Circle()
//                        .stroke(item.completed ? Color.Success.a0 : Color.Surface.a30, lineWidth: 1.5)
//                        .frame(width: 15, height: 15)
//                    if item.completed {
//                        Circle()
//                            .fill(Color.Success.a0.opacity(0.15))
//                            .frame(width: 15, height: 15)
//                        Image(systemName: "checkmark")
//                            .font(.system(size: 7, weight: .bold))
//                            .foregroundColor(Color.Success.a0)
//                    }
//                }
//            }
//            .buttonStyle(.plain)
//
//            // Priority dot
//            Circle()
//                .fill(priorityColor)
//                .frame(width: 5, height: 5)
//
//            // Text info
//            VStack(alignment: .leading, spacing: 2) {
//                Text(item.title ?? "Untitled")
//                    .font(.custom("Montserrat-SemiBold", size: 11))
//                    .foregroundColor(item.completed ? Color.Surface.a50 : AppColors.textWhite)
//                    .strikethrough(item.completed)
//                    .lineLimit(1)
//
//                HStack(spacing: 5) {
//                    if let deadline = item.deadline {
//                        Text(deadline, style: .date)
//                            .font(.custom("Montserrat-Regular", size: 9))
//                            .foregroundColor(Color.Surface.a50)
//                    }
//                    if isArchiving {
//                        Text("archiving…")
//                            .font(.custom("Montserrat-Regular", size: 9))
//                            .foregroundColor(Color.Success.a0.opacity(0.7))
//                    }
//                    SubtaskIndicator(item: item)
//                }
//            }
//
//            Spacer(minLength: 0)
//
//            // App / link chip
//            if let type = item.linkedResourceType, let value = item.linkedResourceValue {
//                AppLinkChip(
//                    resourceType: type,
//                    resourceValue: value,
//                    appDetectionService: appDetectionService
//                )
//            }
//
//            // Status badge
//            ProjectStatusBadge(item: item)
//
//            // Info button
//            Button(action: onSelect) {
//                Image(systemName: "info.circle")
//                    .font(.system(size: 11))
//                    .foregroundColor(Color.Surface.a40)
//            }
//            .buttonStyle(.plain)
//        }
//        .padding(.vertical, 7)
//        .padding(.trailing, 9)
//        .background(AppColors.card)
//        .cornerRadius(9)
//        .overlay(
//            RoundedRectangle(cornerRadius: 9)
//                .stroke(Color.Surface.a30.opacity(0.35), lineWidth: 0.5)
//        )
//        .opacity(isArchiving ? 0.45 : 1)
//        .animation(.easeInOut(duration: 0.3), value: isArchiving)
//    }
//
//    private var priorityColor: Color {
//        switch TaskPriority(rawValue: item.priority) ?? .low {
//        case .high:   return Color.Danger.a10
//        case .medium: return Color.Warning.a10
//        case .low:    return Color.Info.a10
//        }
//    }
//}
//
//// MARK: - Status badge
//
//struct ProjectStatusBadge: View {
//    @ObservedObject var item: Item
//
//    // The app doesn't store a "taskStatus" string yet.
//    // Using completed flag and priority as a proxy for now;
//    // wire up a real taskStatus attribute in Core Data when ready.
//    private var statusLabel: String {
//        if item.completed { return "Done" }
//        if item.priority >= 1 { return "Doing" }
//        return "To Do"
//    }
//    private var bg: Color {
//        if item.completed { return Color.Success.a20.opacity(0.5) }
//        if item.priority >= 1 { return Color.Primary.a20.opacity(0.4) }
//        return Color.Surface.a20.opacity(0.6)
//    }
//    private var fg: Color {
//        if item.completed { return Color.Success.a10 }
//        if item.priority >= 1 { return Color.Primary.a30 }
//        return Color.Surface.a60
//    }
//
//    var body: some View {
//        Text(statusLabel)
//            .font(.custom("Montserrat-Bold", size: 8))
//            .padding(.horizontal, 6)
//            .padding(.vertical, 2)
//            .background(Capsule().fill(bg))
//            .foregroundColor(fg)
//            .textCase(.uppercase)
//    }
//}
//
//// MARK: - App/link chip
//
//struct AppLinkChip: View {
//    let resourceType: String
//    let resourceValue: String
//    @ObservedObject var appDetectionService: AppDetectionService
//
//    var body: some View {
//        Group {
//            if resourceType == LinkedResourceType.app.rawValue {
//                if let icon = appDetectionService.getIcon(for: resourceValue) {
//                    Image(nsImage: icon)
//                        .resizable()
//                        .scaledToFit()
//                        .frame(width: 14, height: 14)
//                        .cornerRadius(3)
//                } else {
//                    chipPlaceholder(systemName: "app")
//                }
//            } else {
//                LinkIconView(link: resourceValue)
//                    .frame(width: 14, height: 14)
//            }
//        }
//        .frame(width: 20, height: 20)
//        .background(Color.Surface.a20.opacity(0.5))
//        .cornerRadius(4)
//    }
//
//    private func chipPlaceholder(systemName: String) -> some View {
//        Image(systemName: systemName)
//            .font(.system(size: 9))
//            .foregroundColor(Color.Surface.a50)
//    }
//}
//
//// MARK: - Subtask indicator
//
//struct SubtaskIndicator: View {
//    @ObservedObject var item: Item
//
//    private var count: Int { item.subtasks?.count ?? 0 }
//
//    var body: some View {
//        if count > 0 {
//            HStack(spacing: 2) {
//                Image(systemName: "list.bullet")
//                    .font(.system(size: 8, weight: .medium))
//                    .foregroundColor(Color.Surface.a50)
//                Text("\(count)")
//                    .font(.custom("Montserrat-Bold", size: 8))
//                    .foregroundColor(Color.Surface.a60)
//            }
//            .padding(.horizontal, 5)
//            .padding(.vertical, 1)
//            .background(Capsule().fill(Color.Surface.a20.opacity(0.5)))
//        }
//    }
//}
//
//// MARK: - RoundedCorner helper (used by folder card)
//
//extension View {
//    func cornerRadius(_ radius: CGFloat, corners: RectCorner) -> some View {
//        clipShape(RoundedCornerShape(radius: radius, corners: corners))
//    }
//}
//
//struct RectCorner: OptionSet {
//    let rawValue: Int
//    static let topLeft     = RectCorner(rawValue: 1 << 0)
//    static let topRight    = RectCorner(rawValue: 1 << 1)
//    static let bottomLeft  = RectCorner(rawValue: 1 << 2)
//    static let bottomRight = RectCorner(rawValue: 1 << 3)
//    static let all: RectCorner = [.topLeft, .topRight, .bottomLeft, .bottomRight]
//}
//
//struct RoundedCornerShape: Shape {
//    var radius: CGFloat
//    var corners: RectCorner
//    func path(in rect: CGRect) -> Path {
//        var path = Path()
//        let tl = corners.contains(.topLeft)     ? radius : 0
//        let tr = corners.contains(.topRight)    ? radius : 0
//        let bl = corners.contains(.bottomLeft)  ? radius : 0
//        let br = corners.contains(.bottomRight) ? radius : 0
//        path.move(to: CGPoint(x: rect.minX + tl, y: rect.minY))
//        path.addLine(to: CGPoint(x: rect.maxX - tr, y: rect.minY))
//        path.addArc(center: CGPoint(x: rect.maxX - tr, y: rect.minY + tr), radius: tr, startAngle: .degrees(-90), endAngle: .degrees(0), clockwise: false)
//        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - br))
//        path.addArc(center: CGPoint(x: rect.maxX - br, y: rect.maxY - br), radius: br, startAngle: .degrees(0), endAngle: .degrees(90), clockwise: false)
//        path.addLine(to: CGPoint(x: rect.minX + bl, y: rect.maxY))
//        path.addArc(center: CGPoint(x: rect.minX + bl, y: rect.maxY - bl), radius: bl, startAngle: .degrees(90), endAngle: .degrees(180), clockwise: false)
//        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + tl))
//        path.addArc(center: CGPoint(x: rect.minX + tl, y: rect.minY + tl), radius: tl, startAngle: .degrees(180), endAngle: .degrees(270), clockwise: false)
//        path.closeSubpath()
//        return path
//    }
//}

// ProjectDashboardView.swift
// TaskBubble

import CoreData
import SwiftUI

// MARK: - Task status

enum ProjectTaskStatus: String, CaseIterable, Identifiable {
    case all   = "All"
    case todo  = "To Do"
    case doing = "Doing"
    case done  = "Done"
    var id: String { rawValue }
}

// MARK: - Dashboard

struct ProjectDashboardView: View {

    let items: [Item]
    @ObservedObject var appDetectionService: AppDetectionService
    var onAddProject: () -> Void
    var onSelectProject: (Project) -> Void
    var onSelectTask: (Item) -> Void
    var onAddTask: () -> Void
    var onSearch: () -> Void
    var onSort: () -> Void
    var onBack: (() -> Void)? = nil
    var onNavigate: ((TBPage) -> Void)? = nil

    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Project.timestamp, ascending: true)],
        animation: .default
    ) private var projects: FetchedResults<Project>

    @State private var selectedStatus: ProjectTaskStatus = .all
    @State private var archivingIDs: Set<NSManagedObjectID> = []
    @State private var showNavDrawer = false

    // Tasks that belong to ANY project
    private var allProjectItems: [Item] {
        items.filter { ($0.value(forKey: "project") as? Project) != nil }
    }

    private var filteredItems: [Item] {
        let pool = allProjectItems.filter { !archivingIDs.contains($0.objectID) }
        switch selectedStatus {
        case .all:   return pool.filter { !$0.completed }
        case .todo:  return pool.filter { !$0.completed && $0.priority == 0 }
        case .doing: return pool.filter { !$0.completed && $0.priority > 0 }
        case .done:  return pool.filter { $0.completed }
        }
    }

    var body: some View {
        ZStack(alignment: .topLeading) {
            AppColors.background.ignoresSafeArea()

            VStack(spacing: 0) {
                TBPageHeader(
                    title: "Projects",
                    icon: "folder.fill",
                    onBack: onBack,
                    onNavDrawer: { withAnimation { showNavDrawer.toggle() } },
                    onSearch: onSearch,
                    onAdd: onAddTask,
                    accentColor: Color.Purple.normal
                )

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 0) {
                        projectsSection
                        statusPills
                        taskListSection
                    }
                    .padding(.bottom, 16)
                }

                TBAddFAB(label: "Add task to project", action: onAddTask)
            }

            if showNavDrawer {
                TBNavDrawer(isOpen: $showNavDrawer, currentPage: .projects) { page in
                    showNavDrawer = false
                    onNavigate?(page)
                }
                .zIndex(20)
            }
        }
    }

    // MARK: - Projects section

    private var projectsSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("PROJECTS")
                    .font(.custom("Montserrat-Bold", size: 9))
                    .foregroundColor(Color.Surface.a50)
                    .tracking(1)
                Spacer()
                Button(action: onAddProject) {
                    HStack(spacing: 4) {
                        Image(systemName: "plus")
                            .font(.system(size: 9, weight: .bold))
                        Text("Add project")
                            .font(.custom("Montserrat-Bold", size: 9))
                    }
                    .foregroundColor(AppColors.shalyPurple)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 14)
            .padding(.top, 12)
            .padding(.bottom, 8)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 9) {
                    ForEach(projects) { project in
                        ProjectFolderCard(project: project)
                            .onTapGesture { onSelectProject(project) }
                    }
                    if projects.isEmpty {
                        Text("Tap Add project to get started")
                            .font(.custom("Montserrat-Regular", size: 11))
                            .foregroundColor(Color.Surface.a50)
                            .padding(.vertical, 20)
                    }
                }
                .padding(.horizontal, 14)
                .padding(.bottom, 8)
            }
        }
    }

    // MARK: - Status pills

    private var statusPills: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 6) {
                ForEach(ProjectTaskStatus.allCases) { s in
                    Button { selectedStatus = s } label: {
                        Text(s.rawValue)
                            .font(.custom("Montserrat-Bold", size: 10))
                            .padding(.horizontal, 10).padding(.vertical, 4)
                            .background(Capsule().fill(selectedStatus == s ? AppColors.shalyPurple : Color.Surface.a20.opacity(0.5)))
                            .overlay(Capsule().stroke(selectedStatus == s ? AppColors.shalyPurple : Color.Surface.a30.opacity(0.6), lineWidth: 0.5))
                            .foregroundColor(selectedStatus == s ? .white : Color.Surface.a60)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 14).padding(.vertical, 7)
        }
    }

    // MARK: - Task list

    private var taskListSection: some View {
        LazyVStack(spacing: 5) {
            if filteredItems.isEmpty {
                Text(allProjectItems.isEmpty
                     ? "Add tasks inside a project to see them here"
                     : "No tasks in this filter")
                    .font(.custom("Montserrat-Regular", size: 12))
                    .foregroundColor(Color.Surface.a50)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 20)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)
            } else {
                ForEach(filteredItems) { item in
                    let proj = item.value(forKey: "project") as? Project
                    ProjectTaskRow(
                        item: item,
                        projectColor: proj?.color ?? Color.Surface.a30,
                        appDetectionService: appDetectionService,
                        isArchiving: archivingIDs.contains(item.objectID),
                        onSelect: { onSelectTask(item) },
                        onComplete: { handleComplete(item) }
                    )
                    .padding(.horizontal, 14)
                }
            }
        }
    }

    private func handleComplete(_ item: Item) {
        guard !item.completed else { return }
        item.completed = true
        try? viewContext.save()
        withAnimation(.easeInOut(duration: 0.3)) { _ = archivingIDs.insert(item.objectID) }
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            withAnimation(.easeOut(duration: 0.4)) { _ = archivingIDs.remove(item.objectID) }
        }
    }
}

// MARK: - Folder card

struct ProjectFolderCard: View {
    @ObservedObject var project: Project

    var body: some View {
        ZStack(alignment: .topLeading) {
            // Folder body
            RoundedRectangle(cornerRadius: 8)
                .fill(project.color.opacity(0.13))
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(project.color.opacity(0.3), lineWidth: 0.7))
                .frame(width: 86, height: 60)
                .offset(y: 12)

            // Folder tab
            HStack(spacing: 0) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(project.color)
                    .frame(width: 38, height: 10)
                Spacer()
            }
            .frame(width: 86)
            .offset(x: 0, y: 4)

            // Content
            VStack(alignment: .leading, spacing: 3) {
                Text(project.name ?? "Untitled")
                    .font(.custom("Montserrat-Bold", size: 10))
                    .foregroundColor(AppColors.textWhite)
                    .lineLimit(1)
                Text("\(project.taskCount) tasks")
                    .font(.custom("Montserrat-SemiBold", size: 9))
                    .foregroundColor(project.color.opacity(0.9))

                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 99)
                            .fill(Color.Surface.a30.opacity(0.4)).frame(height: 2.5)
                        RoundedRectangle(cornerRadius: 99)
                            .fill(project.color)
                            .frame(width: geo.size.width * CGFloat(project.progress), height: 2.5)
                    }
                }
                .frame(height: 2.5)
                .padding(.top, 2)
            }
            .padding(.horizontal, 9)
            .padding(.top, 28)
            .padding(.bottom, 8)
            .frame(width: 86, alignment: .leading)
        }
        .frame(width: 86, height: 78)
        .contentShape(Rectangle())
    }
}

// MARK: - Unified project task row

struct ProjectTaskRow: View {
    @ObservedObject var item: Item
    let projectColor: Color
    @ObservedObject var appDetectionService: AppDetectionService
    var isArchiving: Bool = false
    var onSelect: () -> Void
    var onComplete: () -> Void

    var body: some View {
        HStack(spacing: 0) {
            Rectangle()
                .fill(projectColor)
                .frame(width: 3)
                .cornerRadius(9, corners: [.topLeft, .bottomLeft])

            HStack(spacing: 7) {
                Button(action: onComplete) {
                    ZStack {
                        Circle()
                            .stroke(item.completed ? Color.Success.a0 : Color.Surface.a30, lineWidth: 1.5)
                            .frame(width: 15, height: 15)
                        if item.completed {
                            Circle().fill(Color.Success.a0.opacity(0.15)).frame(width: 15, height: 15)
                            Image(systemName: "checkmark")
                                .font(.system(size: 7, weight: .bold)).foregroundColor(Color.Success.a0)
                        }
                    }
                }
                .buttonStyle(.plain)

                Circle().fill(priorityColor).frame(width: 5, height: 5)

                VStack(alignment: .leading, spacing: 2) {
                    Text(item.title ?? "Untitled")
                        .font(.custom("Montserrat-SemiBold", size: 11))
                        .foregroundColor(item.completed ? Color.Surface.a50 : AppColors.textWhite)
                        .strikethrough(item.completed).lineLimit(1)
                    HStack(spacing: 5) {
                        if let dl = item.deadline {
                            Text(dl, style: .date)
                                .font(.custom("Montserrat-Regular", size: 9))
                                .foregroundColor(Color.Surface.a50)
                        }
                        if isArchiving {
                            Text("archiving…")
                                .font(.custom("Montserrat-Regular", size: 9))
                                .foregroundColor(Color.Success.a0.opacity(0.7))
                        }
                        SubtaskIndicator(item: item)
                    }
                }

                Spacer(minLength: 0)

                if let type = item.linkedResourceType, let value = item.linkedResourceValue {
                    AppLinkChip(resourceType: type, resourceValue: value, appDetectionService: appDetectionService)
                }

                ProjectStatusBadge(item: item)

                Button(action: onSelect) {
                    Image(systemName: "info.circle")
                        .font(.system(size: 11)).foregroundColor(Color.Surface.a40)
                }
                .buttonStyle(.plain)
            }
            .padding(.vertical, 7).padding(.trailing, 9).padding(.leading, 7)
        }
        .background(AppColors.card)
        .cornerRadius(9)
        .overlay(RoundedRectangle(cornerRadius: 9).stroke(Color.Surface.a30.opacity(0.35), lineWidth: 0.5))
        .opacity(isArchiving ? 0.45 : 1)
        .animation(.easeInOut(duration: 0.3), value: isArchiving)
    }

    private var priorityColor: Color {
        switch TaskPriority(rawValue: item.priority) ?? .low {
        case .high:   return Color.Danger.a10
        case .medium: return Color.Warning.a10
        case .low:    return Color.Info.a10
        }
    }
}

// MARK: - Status badge

struct ProjectStatusBadge: View {
    @ObservedObject var item: Item
    var body: some View {
        let (label, bg, fg) = info
        Text(label)
            .font(.custom("Montserrat-Bold", size: 8))
            .padding(.horizontal, 6).padding(.vertical, 2)
            .background(Capsule().fill(bg))
            .foregroundColor(fg)
    }
    private var info: (String, Color, Color) {
        if item.completed { return ("Done",  Color.Success.a20.opacity(0.5), Color.Success.a10) }
        if item.priority >= 1 { return ("Doing", Color.Primary.a20.opacity(0.4), Color.Primary.a30) }
        return ("To Do", Color.Surface.a20.opacity(0.6), Color.Surface.a60)
    }
}

// MARK: - App/link chip

struct AppLinkChip: View {
    let resourceType: String
    let resourceValue: String
    @ObservedObject var appDetectionService: AppDetectionService
    var body: some View {
        Group {
            if resourceType == LinkedResourceType.app.rawValue,
               let icon = appDetectionService.getIcon(for: resourceValue) {
                Image(nsImage: icon).resizable().scaledToFit()
                    .frame(width: 14, height: 14).cornerRadius(3)
            } else if resourceType == LinkedResourceType.url.rawValue {
                LinkIconView(link: resourceValue).frame(width: 14, height: 14)
            } else {
                Image(systemName: "app").font(.system(size: 9)).foregroundColor(Color.Surface.a50)
            }
        }
        .frame(width: 20, height: 20)
        .background(Color.Surface.a20.opacity(0.5))
        .cornerRadius(4).padding(.trailing, 3)
    }
}

// MARK: - Subtask indicator

struct SubtaskIndicator: View {
    @ObservedObject var item: Item
    private var count: Int { item.subtasks?.count ?? 0 }
    var body: some View {
        if count > 0 {
            HStack(spacing: 2) {
                Image(systemName: "list.bullet")
                    .font(.system(size: 8, weight: .medium)).foregroundColor(Color.Surface.a50)
                Text("\(count)")
                    .font(.custom("Montserrat-Bold", size: 8)).foregroundColor(Color.Surface.a60)
            }
            .padding(.horizontal, 5).padding(.vertical, 1)
            .background(Capsule().fill(Color.Surface.a20.opacity(0.5)))
        }
    }
}

// MARK: - Corner radius helper

extension View {
    func cornerRadius(_ radius: CGFloat, corners: RectCorner) -> some View {
        clipShape(RoundedCornerShape(radius: radius, corners: corners))
    }
}

struct RectCorner: OptionSet {
    let rawValue: Int
    static let topLeft     = RectCorner(rawValue: 1 << 0)
    static let topRight    = RectCorner(rawValue: 1 << 1)
    static let bottomLeft  = RectCorner(rawValue: 1 << 2)
    static let bottomRight = RectCorner(rawValue: 1 << 3)
    static let all: RectCorner = [.topLeft, .topRight, .bottomLeft, .bottomRight]
}

struct RoundedCornerShape: Shape {
    var radius: CGFloat; var corners: RectCorner
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let tl = corners.contains(.topLeft)     ? radius : 0
        let tr = corners.contains(.topRight)    ? radius : 0
        let bl = corners.contains(.bottomLeft)  ? radius : 0
        let br = corners.contains(.bottomRight) ? radius : 0
        p.move(to: CGPoint(x: rect.minX + tl, y: rect.minY))
        p.addLine(to: CGPoint(x: rect.maxX - tr, y: rect.minY))
        p.addArc(center: CGPoint(x: rect.maxX - tr, y: rect.minY + tr), radius: tr, startAngle: .degrees(-90), endAngle: .degrees(0), clockwise: false)
        p.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - br))
        p.addArc(center: CGPoint(x: rect.maxX - br, y: rect.maxY - br), radius: br, startAngle: .degrees(0), endAngle: .degrees(90), clockwise: false)
        p.addLine(to: CGPoint(x: rect.minX + bl, y: rect.maxY))
        p.addArc(center: CGPoint(x: rect.minX + bl, y: rect.maxY - bl), radius: bl, startAngle: .degrees(90), endAngle: .degrees(180), clockwise: false)
        p.addLine(to: CGPoint(x: rect.minX, y: rect.minY + tl))
        p.addArc(center: CGPoint(x: rect.minX + tl, y: rect.minY + tl), radius: tl, startAngle: .degrees(180), endAngle: .degrees(270), clockwise: false)
        p.closeSubpath()
        return p
    }
}
