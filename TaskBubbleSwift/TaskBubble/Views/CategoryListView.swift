////
////  CategoryListView.swift
////  TaskBubble
////
//
//import CoreData
//import SwiftUI
//
//struct CategoryListView: View {
//    @Environment(\.managedObjectContext) private var viewContext
//
//    let category: TaskCategory
//    let items: [Item]
//    @Binding var sortOption: TaskSortOption
//    @ObservedObject var appDetectionService: AppDetectionService
//    @StateObject private var motivationalService = MotivationalService()
//    @State private var completedTaskIDs: Set<NSManagedObjectID> = Set<NSManagedObjectID>()
//
//    var onBack: () -> Void
//    var onAddTask: () -> Void
//    var onSelectTask: (Item) -> Void
//    var onTaskComplete: (Item, CGPoint) -> Void
//
//    var body: some View {
//        VStack(spacing: 0) {
//            HStack {
//                Button(action: onBack) {
//                    Image(systemName: "chevron.left").font(.headline)
//                }
//                .buttonStyle(.plain)
//                Spacer()
//                Text(category.rawValue).font(.headline)
//                Spacer()
//                Menu {
//                    Picker("Sort By", selection: $sortOption) {
//                        ForEach(TaskSortOption.allCases) { option in
//                            Text(option.rawValue).tag(option)
//                        }
//                    }
//                } label: {
//                    Image(systemName: "arrow.up.arrow.down").font(.headline)
//                }
//                .menuStyle(.borderlessButton)
//                .fixedSize()
//
//                Button(action: onAddTask) {
//                    Image(systemName: "plus").font(.headline)
//                }
//                .buttonStyle(.plain)
//                .padding(.leading, 8)
//            }
//            .padding()
//            .background(category.color.opacity(0.1))
//
//            if category == .allTasks {
//                achievementBlock
//            }
//
//            let categoryTasks = sortedTasks(items.filter { item in
//                if category == .allTasks {
//                    // Include tasks that are not completed OR were just completed (within 2s)
//                    return !item.completed || completedTaskIDs.contains(item.objectID)
//                } else {
//                    return item.category == category.rawValue
//                }
//            })
//            
//            List {
//                if categoryTasks.isEmpty {
//                    Text("No tasks yet!").foregroundColor(.secondary).padding()
//                } else {
//                    ForEach(categoryTasks) { item in
//                        TaskRow(
//                            item: item,
//                            onSelect: { onSelectTask(item) },
//                            onComplete: { location in
//                                if category == .allTasks {
//                                    handleTaskCompletion(item, location: location)
//                                } else {
//                                    onTaskComplete(item, location)
//                                }
//                            },
//                            appDetectionService: appDetectionService,
//                            isTemporarilyCompleted: completedTaskIDs.contains(item.objectID)
//                        )
//                    }
//                    .onDelete { offsets in
//                        offsets.map { categoryTasks[$0] }.forEach(viewContext.delete)
//                        saveContext()
//                    }
//                }
//            }
//            .listStyle(.plain)
//            .scrollContentBackground(.hidden)
//        }
//        .background(AppColors.background)
//    }
//
//    private func sortedTasks(_ tasks: [Item]) -> [Item] {
//        switch sortOption {
//        case .alphabetical:
//            return tasks.sorted { ($0.title ?? "") < ($1.title ?? "") }
//        case .dueDate:
//            return tasks.sorted {
//                let d1 = $0.deadline ?? Date.distantFuture
//                let d2 = $1.deadline ?? Date.distantFuture
//                return d1 < d2
//            }
//        case .priority:
//            return tasks.sorted { $0.priority > $1.priority }
//        case .timestamp:
//            return tasks.sorted { ($0.timestamp ?? Date.distantPast) < ($1.timestamp ?? Date.distantPast) }
//        }
//    }
//
//    private var achievementBlock: some View {
//        let completedCount = items.filter { $0.completed }.count
//        return VStack(spacing: 8) {
//            HStack {
//                VStack(alignment: .leading, spacing: 4) {
//                    Text("You have completed \(completedCount) tasks!")
//                        .font(.subheadline.weight(.bold))
//                    
//                    Text(motivationalService.currentMessage)
//                        .font(.caption)
//                        .foregroundColor(.secondary)
//                        .transition(.opacity)
//                        .id(motivationalService.currentMessage)
//                }
//                Spacer()
//                Image(systemName: "trophy.fill")
//                    .font(.title2)
//                    .foregroundColor(.yellow)
//            }
//            .padding(12)
//            .background(Color.yellow.opacity(0.1))
//            .cornerRadius(12)
//            .overlay(
//                RoundedRectangle(cornerRadius: 12)
//                    .stroke(Color.yellow.opacity(0.2), lineWidth: 1)
//            )
//        }
//        .padding(.horizontal)
//        .padding(.top, 12)
//        .onAppear {
//            updateMotivation()
//        }
//    }
//
//    private func updateMotivation() {
//        let completedToday = items.filter { $0.completed }.count
//        let remainingToday = items.filter { !$0.completed }.count
//        motivationalService.updateMessage(completed: completedToday, remaining: remainingToday)
//    }
//
//    private func handleTaskCompletion(_ item: Item, location: CGPoint) {
//        // Mark as completed in UI immediately
//        withAnimation {
//            _ = completedTaskIDs.insert(item.objectID)
//        }
//        
//        // Trigger the confetti and actual completion
//        onTaskComplete(item, location)
//        updateMotivation()
//        
//        // Remove from list after 2 seconds
//        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
//            withAnimation {
//                _ = completedTaskIDs.remove(item.objectID)
//            }
//        }
//    }
//
//    private func saveContext() {
//        do {
//            try viewContext.save()
//        } catch {
//            let nsError = error as NSError
//            print("Unresolved error \(nsError), \(nsError.userInfo)")
//            viewContext.rollback()
//        }
//    }
//}

// CategoryListView.swift
// TaskBubble
//
//import CoreData
//import SwiftUI
//
//struct CategoryListView: View {
//    @Environment(\.managedObjectContext) private var viewContext
//    let category: TaskCategory
//    let items: [Item]
//    @Binding var sortOption: TaskSortOption
//    @ObservedObject var appDetectionService: AppDetectionService
//    @StateObject private var motivationalService = MotivationalService()
//    @State private var completedTaskIDs: Set<NSManagedObjectID> = []
//    @State private var showNavDrawer = false
//    var onBack: () -> Void
//    var onAddTask: () -> Void
//    var onSelectTask: (Item) -> Void
//    var onTaskComplete: (Item, CGPoint) -> Void
//    var onNavigate: ((TBPage) -> Void)? = nil
//
//    private var fabLabel: String {
//        switch category {
//        case .today: return "Add task to Today"
//        case .goals: return "Add task to Goals"
//        case .routine: return "Add task to Routine"
//        default: return "Add new task"
//        }
//    }
//
//    var body: some View {
//        ZStack(alignment: .topLeading) {
//            AppColors.background.ignoresSafeArea()
//            VStack(spacing: 0) {
//                TBPageHeader(
//                    title: category.rawValue, icon: category.icon,
//                    onBack: onBack,
//                    onNavDrawer: { withAnimation { showNavDrawer.toggle() } },
//                    onSort: {
//                        let all = TaskSortOption.allCases
//                        if let idx = all.firstIndex(of: sortOption) { sortOption = all[(idx + 1) % all.count] }
//                    },
//                    onAdd: onAddTask, accentColor: category.color
//                )
//                if category == .allTasks { achievementBlock }
//                let categoryTasks = sortedTasks(items.filter { item in
//                    category == .allTasks
//                        ? (!item.completed || completedTaskIDs.contains(item.objectID))
//                        : item.category == category.rawValue
//                })
//                List {
//                    if categoryTasks.isEmpty {
//                        Text("No tasks yet!").font(.custom("Montserrat-Regular", size: 13))
//                            .foregroundColor(Color.Surface.a50).padding()
//                    } else {
//                        ForEach(categoryTasks) { item in
//                            TaskRow(item: item,
//                                    onSelect: { onSelectTask(item) },
//                                    onComplete: { loc in
//                                        if category == .allTasks { handleTaskCompletion(item, location: loc) }
//                                        else { onTaskComplete(item, loc) }
//                                    },
//                                    appDetectionService: appDetectionService,
//                                    isTemporarilyCompleted: completedTaskIDs.contains(item.objectID))
//                        }
//                        .onDelete { offsets in
//                            offsets.map { categoryTasks[$0] }.forEach(viewContext.delete); saveContext()
//                        }
//                    }
//                }
//                .listStyle(.plain).scrollContentBackground(.hidden)
//                TBAddFAB(label: fabLabel, action: onAddTask)
//            }
//            if showNavDrawer {
//                TBNavDrawer(isOpen: $showNavDrawer, currentPage: tbPage(for: category)) { page in
//                    showNavDrawer = false; onNavigate?(page)
//                }.zIndex(20)
//            }
//        }
//    }
//
//    private func tbPage(for cat: TaskCategory) -> TBPage {
//        switch cat {
//        case .today: return .today;
//        case .goals: return .goals
//        case .routine: return .routine;
//        case .projects: return .projects;
//        case .allTasks: return .allTasks
//        }
//    }
//
//    private func sortedTasks(_ tasks: [Item]) -> [Item] {
//        switch sortOption {
//        case .alphabetical: return tasks.sorted { ($0.title ?? "") < ($1.title ?? "") }
//        case .dueDate: return tasks.sorted { ($0.deadline ?? .distantFuture) < ($1.deadline ?? .distantFuture) }
//        case .priority: return tasks.sorted { $0.priority > $1.priority }
//        case .timestamp: return tasks.sorted { ($0.timestamp ?? .distantPast) < ($1.timestamp ?? .distantPast) }
//        }
//    }
//
//    private var achievementBlock: some View {
//        let count = items.filter { $0.completed }.count
//        return VStack(spacing: 8) {
//            HStack {
//                VStack(alignment: .leading, spacing: 4) {
//                    Text("You've completed \(count) tasks!")
//                        .font(.custom("Montserrat-Bold", size: 13)).foregroundColor(AppColors.textWhite)
//                    Text(motivationalService.currentMessage)
//                        .font(.custom("Montserrat-Regular", size: 11)).foregroundColor(.secondary)
//                        .transition(.opacity).id(motivationalService.currentMessage)
//                }
//                Spacer()
//                Image(systemName: "trophy.fill").font(.title2).foregroundColor(.yellow)
//            }
//            .padding(12).background(Color.yellow.opacity(0.08)).cornerRadius(12)
//            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.yellow.opacity(0.18), lineWidth: 0.5))
//        }
//        .padding(.horizontal, 14).padding(.top, 10).onAppear { updateMotivation() }
//    }
//
//    private func updateMotivation() {
//        motivationalService.updateMessage(completed: items.filter { $0.completed }.count,
//                                          remaining: items.filter { !$0.completed }.count)
//    }
//
//    private func handleTaskCompletion(_ item: Item, location: CGPoint) {
//        withAnimation { _ = completedTaskIDs.insert(item.objectID) }
//        onTaskComplete(item, location); updateMotivation()
//        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
//            withAnimation { _ = completedTaskIDs.remove(item.objectID) }
//        }
//    }
//
//    private func saveContext() {
//        do { try viewContext.save() } catch { viewContext.rollback() }
//    }
//}

// CategoryListView.swift
// TaskBubble

import CoreData
import SwiftUI

struct CategoryListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    let category: TaskCategory
    let items: [Item]
    @Binding var sortOption: TaskSortOption
    @ObservedObject var appDetectionService: AppDetectionService
    @StateObject private var motivationalService = MotivationalService()
    @State private var completedTaskIDs: Set<NSManagedObjectID> = []
    @State private var showNavDrawer = false
    @State private var archivingIDs: Set<NSManagedObjectID> = []
    @State private var showBatchMode = false
    var onBack: () -> Void
    var onAddTask: () -> Void
    var onSelectTask: (Item) -> Void
    var onTaskComplete: (Item, CGPoint) -> Void
    var onNavigate: ((TBPage) -> Void)? = nil

    private var fabLabel: String {
        switch category {
        case .today:    return "Add task to Today"
        case .goals:    return "Add task to Goals"
        case .routine:  return "Add task to Routine"
        default:        return "Add new task"
        }
    }

    private var categoryTasks: [Item] {
        let pool: [Item]
        if category == .allTasks {
            pool = items.filter { !$0.completed || completedTaskIDs.contains($0.objectID) }
        } else {
            pool = items.filter { $0.category == category.rawValue && (!$0.completed || completedTaskIDs.contains($0.objectID)) }
        }
        // Newest first
        return pool.sorted { ($0.timestamp ?? .distantPast) > ($1.timestamp ?? .distantPast) }
    }

    var body: some View {
        ZStack(alignment: .topLeading) {
            AppColors.background.ignoresSafeArea()

            VStack(spacing: 0) {
                TBPageHeader(
                    title: category.rawValue,
                    icon: category.icon,
                    onBack: onBack,
                    onNavDrawer: { withAnimation { showNavDrawer.toggle() } },
                    onSort: {
                        let all = TaskSortOption.allCases
                        if let idx = all.firstIndex(of: sortOption) { sortOption = all[(idx + 1) % all.count] }
                    },
                    onAdd: onAddTask,
                    accentColor: category.color
                )

                if category == .allTasks { achievementBlock }

                // Batch mode button
                if categoryTasks.filter({ !$0.completed }).count > 0 {
                    Button {
                        showBatchMode = true
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "timer").font(.system(size: 11))
                            Text("Batch Productivity Mode")
                                .font(.custom("Montserrat-SemiBold", size: 11))
                        }
                        .foregroundColor(AppColors.shalyPurple)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 7)
                        .background(AppColors.shalyPurple.opacity(0.1))
                        .overlay(Rectangle().frame(height: 0.5).foregroundColor(AppColors.shalyPurple.opacity(0.2)), alignment: .bottom)
                    }
                    .buttonStyle(.plain)
                }

                if categoryTasks.isEmpty {
                    Spacer()
                    VStack(spacing: 8) {
                        Image(systemName: category.icon)
                            .font(.system(size: 28)).foregroundColor(Color.Surface.a30)
                        Text("No tasks yet")
                            .font(.custom("Montserrat-Regular", size: 13)).foregroundColor(Color.Surface.a50)
                    }
                    .frame(maxWidth: .infinity)
                    Spacer()
                } else {
                    ScrollView(showsIndicators: false) {
                        LazyVStack(spacing: 5) {
                            ForEach(categoryTasks) { item in
                                UnifiedTaskRow(
                                    item: item,
                                    appDetectionService: appDetectionService,
                                    isArchiving: archivingIDs.contains(item.objectID),
                                    onSelect: { onSelectTask(item) },
                                    onComplete: { handleComplete(item) }
                                )
                                .padding(.horizontal, 14)
                            }
                        }
                        .padding(.vertical, 8)
                    }
                }

                TBAddFAB(label: fabLabel, action: onAddTask)
            }

            if showNavDrawer {
                TBNavDrawer(isOpen: $showNavDrawer, currentPage: tbPage(for: category)) { page in
                    showNavDrawer = false; onNavigate?(page)
                }.zIndex(20)
            }
        }
        .sheet(isPresented: $showBatchMode) {
            BatchProductivityEntryView(items: categoryTasks, appDetectionService: appDetectionService)
                .environment(\.managedObjectContext, viewContext)
        }
    }

    private func tbPage(for cat: TaskCategory) -> TBPage {
        switch cat {
        case .today: return .today; case .goals: return .goals
        case .routine: return .routine; case .projects: return .projects; case .allTasks: return .allTasks
        }
    }

    private var achievementBlock: some View {
        let count = items.filter { $0.completed }.count
        return VStack(spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("You've completed \(count) tasks!")
                        .font(.custom("Montserrat-Bold", size: 13)).foregroundColor(AppColors.textWhite)
                    Text(motivationalService.currentMessage)
                        .font(.custom("Montserrat-Regular", size: 11)).foregroundColor(.secondary)
                        .transition(.opacity).id(motivationalService.currentMessage)
                }
                Spacer()
                Image(systemName: "trophy.fill").font(.title2).foregroundColor(.yellow)
            }
            .padding(12).background(Color.yellow.opacity(0.08)).cornerRadius(12)
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.yellow.opacity(0.18), lineWidth: 0.5))
        }
        .padding(.horizontal, 14).padding(.top, 10).onAppear { updateMotivation() }
    }

    private func updateMotivation() {
        motivationalService.updateMessage(
            completed: items.filter { $0.completed }.count,
            remaining: items.filter { !$0.completed }.count
        )
    }

    private func handleComplete(_ item: Item) {
        withAnimation { _ = archivingIDs.insert(item.objectID) }
        item.completed = true
        onTaskComplete(item, .zero)
        updateMotivation()
        try? viewContext.save()
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            withAnimation { _ = archivingIDs.remove(item.objectID) }
        }
    }
}

// MARK: - Unified task row (project-style, gray left flag)

struct UnifiedTaskRow: View {
    @ObservedObject var item: Item
    @ObservedObject var appDetectionService: AppDetectionService
    var isArchiving: Bool = false
    var onSelect: () -> Void
    var onComplete: () -> Void
    @State private var showSubtaskWarning = false
    @Environment(\.managedObjectContext) private var viewContext

    private var incompleteSubtaskCount: Int {
        ((item.subtasks as? Set<Subtask>) ?? [])
            .filter { !($0.linkedResourceValue?.hasPrefix("[x]") ?? false) }
            .count
    }

    var body: some View {
        HStack(spacing: 0) {
            // Left flag — gray for unlinked, project color if linked
            Rectangle()
                .fill(projectColor)
                .frame(width: 3)
                .cornerRadius(9, corners: [.topLeft, .bottomLeft])

            HStack(spacing: 7) {
                // Checkmark
                Button(action: {
                    if !item.completed && incompleteSubtaskCount > 0 {
                        showSubtaskWarning = true
                    } else {
                        onComplete()
                    }
                }) {
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
                .alert("Incomplete subtasks", isPresented: $showSubtaskWarning) {
                    Button("Mark done anyway", role: .destructive) { onComplete() }
                    Button("Cancel", role: .cancel) {}
                } message: {
                    Text("This task has \(incompleteSubtaskCount) incomplete subtask\(incompleteSubtaskCount == 1 ? "" : "s"). Mark as done anyway?")
                }

                Circle().fill(priorityColor).frame(width: 5, height: 5)

                VStack(alignment: .leading, spacing: 2) {
                    Text(item.title ?? "Untitled")
                        .font(.custom("Montserrat-SemiBold", size: 11))
                        .foregroundColor(item.completed ? Color.Surface.a50 : AppColors.textWhite)
                        .strikethrough(item.completed).lineLimit(1)
                    HStack(spacing: 5) {
                        if let dl = item.deadline {
                            let overdue = dl < Date() && !item.completed
                            Text(dl, style: .date)
                                .font(.custom("Montserrat-Regular", size: 9))
                                .foregroundColor(overdue ? Color.Danger.a10 : Color.Surface.a50)
                        }
                        if isArchiving {
                            Text("archiving…")
                                .font(.custom("Montserrat-Regular", size: 9))
                                .foregroundColor(Color.Success.a0.opacity(0.7))
                        }
                        // Subtask indicator (now clickable)
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

    private var projectColor: Color {
        if let proj = item.value(forKey: "project") as? Project {
            return proj.color
        }
        return Color.Surface.a30
    }

    private var priorityColor: Color {
        switch TaskPriority(rawValue: item.priority) ?? .low {
        case .high: return Color.Danger.a10
        case .medium: return Color.Warning.a10
        case .low: return Color.Info.a10
        }
    }
}
