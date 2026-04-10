

import SwiftUI
import CoreData
import AppKit

// MARK: - Confetti

struct ConfettiPiece: Identifiable {
    let id = UUID()
    var x: CGFloat
    var y: CGFloat
    var vx: CGFloat
    var vy: CGFloat
    var color: Color
    var size: CGFloat
    var rotation: Double
    var opacity: Double
}

struct ConfettiView: View {
    @Binding var isFinished: Bool
    var origin: CGPoint
    @State private var pieces: [ConfettiPiece] = []
    let timer = Timer.publish(every: 0.02, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            ForEach(pieces) { piece in
                Rectangle()
                    .fill(piece.color)
                    .frame(width: piece.size, height: piece.size)
                    .position(x: piece.x, y: piece.y)
                    .rotationEffect(.degrees(piece.rotation))
                    .opacity(piece.opacity)
            }
        }
        .onAppear { createCannonExplosion() }
        .onReceive(timer) { _ in updateConfetti() }
    }

    private func createCannonExplosion() {
        let colors: [Color] = [.red, .blue, .green, .yellow, .pink, .purple, .orange, .cyan, .mint]
        for _ in 0..<50 {
            let angle = Double.random(in: (-.pi * 0.75)...(-.pi * 0.25))
            let speed = Double.random(in: 4...12)
            pieces.append(ConfettiPiece(
                x: origin.x, y: origin.y,
                vx: CGFloat(cos(angle) * speed),
                vy: CGFloat(sin(angle) * speed),
                color: colors.randomElement() ?? .blue,
                size: CGFloat.random(in: 4...10),
                rotation: Double.random(in: 0...360),
                opacity: 1.0
            ))
        }
    }

    private func updateConfetti() {
        for i in 0..<pieces.count {
            pieces[i].x += pieces[i].vx
            pieces[i].y += pieces[i].vy
            pieces[i].vy += 0.25
            pieces[i].rotation += 20
            pieces[i].opacity -= 0.012
        }
        pieces.removeAll { $0.opacity <= 0 || $0.y > 422 || $0.x < 0 || $0.x > 356 }
        if pieces.isEmpty { isFinished = false }
    }
}

// MARK: - ContentView

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var appDetectionService = AppDetectionService()

    @FetchRequest<Item>(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
        animation: .default)
    private var items: FetchedResults<Item>

    @StateObject private var waterService: WaterIntakeService
    private let timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()

    init() {
        let context = PersistenceController.shared.container.viewContext
        _waterService = StateObject(wrappedValue: WaterIntakeService(context: context))
    }

    // MARK: Navigation state
    @State private var currentView: AppView = .dashboard
    @State private var selectedCategory: TaskCategory? = nil
    @State private var selectedProject: Project? = nil   // ← new

    // MARK: Overlays / sheets
    @State private var showConfetti = false
    @State private var confettiOrigin: CGPoint = .zero
    @State private var selectedTask: Item? = nil
    @State private var showTaskSearch = false
    @State private var calendarScope: TaskCalendarScope = .week
    @State private var showCalendarDayTasks = false
    @State private var calendarSheetDate: Date = Date()
    @State private var calendarDayTasks: [Item] = []
    @State private var calendarAddDay: Date?
    @State private var showCalendarAddConfirm = false
    @State private var showProjectInfo = false           // ← new  (create / edit project sheet)
    @State private var editingProject: Project? = nil   // ← new  (nil = create)

    // MARK: Task form state
    @State private var newTaskTitle = ""
    @State private var taskNotes = ""
    @State private var inputCategory: TaskCategory = .today
    @State private var inputPriority: TaskPriority = .medium
    @State private var taskDeadline: Date? = nil
    @State private var showAppPicker = false
    @State private var showLinkInput = false
    @State private var selectedApp: DetectedApp? = nil
    @State private var linkURL = ""
    @State private var mainLinkBundleIdentifier: String? = nil
    @State private var subtaskDrafts: [SubtaskDraft] = []
    @State private var activeSubtaskID: UUID? = nil
    @State private var editingTask: Item? = nil
    @State private var showQuickAdd = false
    
//    let isMenuBar: Bool
//    init(isMenuBar: Bool) {
//        // 1. Assign the new property
//        self.isMenuBar = isMenuBar
//    }

    // MARK: - App view enum
    enum AppView {
        case dashboard
        case categoryList
        case projectDashboard   // ← new
        case projectDetail      // ← new
        case addTask
    }

    // MARK: - Body

    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()

            VStack(spacing: 0) {
                switch currentView {

                // ── Dashboard ──────────────────────────────────────────────
                case .dashboard:
                    DashboardView(
                        waterService: waterService,
                        items: Array(items),
                        calendarScope: $calendarScope,
                        onCalendarDay: { day, dayTasks in
                            if dayTasks.isEmpty {
                                calendarAddDay = day
                                showCalendarAddConfirm = true
                            } else {
                                calendarSheetDate = day
                                calendarDayTasks = dayTasks
                                showCalendarDayTasks = true
                            }
                        },
                        onCategoryTap: { category in
                            withAnimation {
                                selectedCategory = category
                                // Route "Projects" to the project dashboard
                                if category.rawValue == "Projects" {
                                    currentView = .projectDashboard
                                } else {
                                    currentView = .categoryList
                                }
                            }
                        },
                        onAddTask: {
                            editingTask = nil
                            resetAddTaskForm()
                            withAnimation { showQuickAdd = true }
                        },
                        onSearch: { showTaskSearch = true }
                    )

                // ── Category list ──────────────────────────────────────────
                case .categoryList:
                    if let cat = selectedCategory {
                        CategoryListView(
                            category: cat,
                            items: Array(items),
                            sortOption: .constant(.timestamp),
                            appDetectionService: appDetectionService,
                            onBack: {
                                withAnimation { currentView = .dashboard }
                            },
                            onAddTask: {
                                editingTask = nil
                                resetAddTaskForm()
                                withAnimation { showQuickAdd = true }
                            },
                            onSelectTask: { selectedTask = $0 },
                            onTaskComplete: { item, location in
                                if !item.completed {
                                    confettiOrigin = location
                                    showConfetti = true
                                }
                                item.completed.toggle()
                                saveContext()
                            }
                        )
                    }

                // ── Project dashboard ──────────────────────────────────────
                case .projectDashboard:
                    ProjectDashboardView(
                        items: Array(items),
                        appDetectionService: appDetectionService,
                        onAddProject: {
                            editingProject = nil
                            showProjectInfo = true
                        },
                        onSelectProject: { project in
                            selectedProject = project
                            withAnimation { currentView = .projectDetail }
                        },
                        onSelectTask: { selectedTask = $0 },
                        onAddTask: {
                            editingTask = nil
                            resetAddTaskForm()
                            withAnimation { showQuickAdd = true }
                        },
                        onSearch: { showTaskSearch = true },
                        onSort: {}
                    )
                    .environment(\.managedObjectContext, viewContext)

                // ── Project detail ─────────────────────────────────────────
                case .projectDetail:
                    if let proj = selectedProject {
                        ProjectDetailView(
                            project: proj,
                            appDetectionService: appDetectionService,
                            onBack: {
                                withAnimation { currentView = .projectDashboard }
                            },
                            onSelectTask: { selectedTask = $0 },
                            onAddTask: {
                                editingTask = nil
                                resetAddTaskForm()
                                withAnimation { showQuickAdd = true }
                            },
                            onEditProject: {
                                editingProject = proj
                                showProjectInfo = true
                            }
                        )
                        .environment(\.managedObjectContext, viewContext)
                    }

                // ── Add task (sheet-driven, EmptyView here) ────────────────
                case .addTask:
                    EmptyView()
                }
            }

            // Confetti overlay
            if showConfetti {
                ConfettiView(isFinished: $showConfetti, origin: confettiOrigin)
                    .allowsHitTesting(false)
            }

            // Quick-add overlay
            if showQuickAdd {
                Rectangle()
                    .fill(.ultraThinMaterial.opacity(0.85))
                    .background(Color.black.opacity(0.25))
                    .ignoresSafeArea()
                    .onTapGesture { showQuickAdd = false }

                QuickAddTaskView(
                    newTaskTitle: $newTaskTitle,
                    selectedApp: $selectedApp,
                    showAppPicker: $showAppPicker,
                    linkURL: $linkURL,
                    onAdd: {
                        saveOrUpdateTask()
                        showQuickAdd = false
                    },
                    onExpand: {
                        showQuickAdd = false
                        withAnimation { currentView = .addTask }
                    },
                    onCancel: {
                        showQuickAdd = false
                        resetAddTaskForm()
                    },
                    appDetectionService: appDetectionService
                )
                .transition(.scale.combined(with: .opacity))
                .zIndex(10)
            }
        }

        // ── Sheets ─────────────────────────────────────────────────────────

        .sheet(isPresented: $showAppPicker) {
            AppPickerView(
                appDetectionService: appDetectionService,
                selectedApp: $selectedApp,
                linkURL: linkBindingForSheet,
                isPresented: $showAppPicker
            )
        }
        .sheet(item: $selectedTask) { item in
            TaskDetailView(
                item: item,
                appDetectionService: appDetectionService,
                onEdit: {
                    selectedTask = nil
                    populateFormFromItem(item)
                    editingTask = item
                    withAnimation { currentView = .addTask }
                }
            )
        }
        .sheet(isPresented: Binding(
            get: { currentView == .addTask },
            set: { if !$0 { currentView = .dashboard } }
        )) {
            AddTaskView(
                newTaskTitle: $newTaskTitle,
                taskNotes: $taskNotes,
                inputCategory: $inputCategory,
                inputPriority: $inputPriority,
                taskDeadline: $taskDeadline,
                showAppPicker: $showAppPicker,
                showLinkInput: $showLinkInput,
                selectedApp: $selectedApp,
                linkURL: $linkURL,
                mainLinkBundleIdentifier: $mainLinkBundleIdentifier,
                subtaskDrafts: $subtaskDrafts,
                activeSubtaskID: $activeSubtaskID,
                isEditing: editingTask != nil,
                addTask: saveOrUpdateTask,
                cancelAction: {
                    editingTask = nil
                    resetAddTaskForm()
                    currentView = .dashboard
                },
                appDetectionService: appDetectionService
            )
        }
        .sheet(isPresented: $showTaskSearch) {
            TaskSearchView(items: Array(items)) { item in
                showTaskSearch = false
                DispatchQueue.main.async { selectedTask = item }
            }
        }
        .sheet(isPresented: $showCalendarDayTasks) {
            CalendarDayTasksSheet(date: calendarSheetDate, tasks: calendarDayTasks) { item in
                selectedTask = item
            }
        }
        // Project create / edit sheet
        .sheet(isPresented: $showProjectInfo) {
            ProjectInfoView(
                project: editingProject,
                appDetectionService: appDetectionService,
                onSave: { showProjectInfo = false },
                onCancel: { showProjectInfo = false }
            )
            .environment(\.managedObjectContext, viewContext)
        }

        // ── onChange handlers ──────────────────────────────────────────────

        .onChange(of: selectedApp) { _, newApp in
            guard newApp != nil else { return }
            if activeSubtaskID == nil {
                linkURL = ""
                mainLinkBundleIdentifier = nil
            }
        }
        .onChange(of: linkURL) { _, new in
            guard activeSubtaskID == nil else { return }
            if !new.isEmpty {
                selectedApp = nil
                mainLinkBundleIdentifier = nil
            }
        }
        .onChange(of: showAppPicker) { _, open in
            if !open, selectedApp == nil { activeSubtaskID = nil }
        }
        .onChange(of: showLinkInput) { _, open in
            if !open { activeSubtaskID = nil }
        }
        .onReceive(timer) { _ in waterService.refreshCurrentIntake() }
        .confirmationDialog(
            "Add a task for this day?",
            isPresented: $showCalendarAddConfirm,
            titleVisibility: .visible
        ) {
            Button("Add Task") {
                if let d = calendarAddDay {
                    editingTask = nil
                    resetAddTaskForm()
                    taskDeadline = Calendar.current.startOfDay(for: d)
                    withAnimation { currentView = .addTask }
                }
                calendarAddDay = nil
            }
            Button("Cancel", role: .cancel) { calendarAddDay = nil }
        } message: {
            if let d = calendarAddDay {
                Text(DateFormatter.localizedString(from: d, dateStyle: .medium, timeStyle: .none))
            }
        }
    }

    // MARK: - Helpers

    private var linkBindingForSheet: Binding<String> {
        Binding(get: { linkURL }, set: { linkURL = $0 })
    }

    private func resetAddTaskForm() {
        newTaskTitle = ""
        taskNotes = ""
        inputCategory = .allTasks
        inputPriority = .low
        taskDeadline = nil
        selectedApp = nil
        linkURL = ""
        mainLinkBundleIdentifier = nil
        subtaskDrafts = []
        activeSubtaskID = nil
    }

    private func populateFormFromItem(_ item: Item) {
        newTaskTitle = item.title ?? ""
        taskNotes = item.notes ?? ""
        if let cat = item.category, let c = TaskCategory(rawValue: cat) {
            inputCategory = c
        } else {
            inputCategory = .today
        }
        inputPriority = TaskPriority(rawValue: item.priority) ?? .low
        taskDeadline = item.deadline
        mainLinkBundleIdentifier = nil
        selectedApp = nil
        linkURL = ""
        if let type = item.linkedResourceType, let value = item.linkedResourceValue {
            if type == LinkedResourceType.app.rawValue {
                selectedApp = appDetectionService.installedApps.first { $0.id == value }
                if selectedApp == nil { mainLinkBundleIdentifier = value }
            } else {
                linkURL = value
            }
        }
        let subs = (item.subtasks as? Set<Subtask>) ?? []
        subtaskDrafts = subs.sorted { $0.sortOrder < $1.sortOrder }.map {
            SubtaskDraft(title: $0.linkedResourceValue ?? "")
        }
    }

    private func saveOrUpdateTask() {
        guard !newTaskTitle.isEmpty else { return }
        DispatchQueue.main.async {
            let item: Item
            if let editing = editingTask {
                item = editing
            } else {
                item = Item(context: viewContext)
                item.timestamp = Date()
                item.completed = false
            }
            item.title = newTaskTitle
            item.notes = taskNotes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : taskNotes
            item.category = inputCategory.rawValue
            item.priority = inputPriority.rawValue
            item.deadline = taskDeadline

            if let app = selectedApp {
                item.linkedResourceType = LinkedResourceType.app.rawValue
                item.linkedResourceValue = app.id
                item.linkedResourceAppDisplayName = app.displayName
            } else if !linkURL.isEmpty {
                item.linkedResourceType = LinkedResourceType.url.rawValue
                item.linkedResourceValue = linkURL
                item.linkedResourceAppDisplayName = nil
            } else if let bid = mainLinkBundleIdentifier {
                item.linkedResourceType = LinkedResourceType.app.rawValue
                item.linkedResourceValue = bid
                item.linkedResourceAppDisplayName = nil
            } else {
                item.linkedResourceType = nil
                item.linkedResourceValue = nil
                item.linkedResourceAppDisplayName = nil
            }

            if let existing = item.subtasks as? Set<Subtask> {
                existing.forEach { viewContext.delete($0) }
            }
            var order: Int16 = 0
            for draft in subtaskDrafts.prefix(10) {
                let sub = Subtask(context: viewContext)
                sub.parent = item
                sub.sortOrder = order
                order += 1
                sub.linkedResourceType = "Text"
                sub.linkedResourceValue = draft.title
                sub.linkedResourceAppDisplayName = nil
            }
            saveContext()
            withAnimation {
                editingTask = nil
                resetAddTaskForm()
                selectedCategory = inputCategory
                currentView = .categoryList
            }
        }
    }

    private func saveContext() {
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            print("Unresolved error \(nsError), \(nsError.userInfo)")
            viewContext.rollback()
        }
    }
}

// MARK: - TaskRow  (subtask indicator added)

struct TaskRow: View {
    @ObservedObject var item: Item
    var onSelect: () -> Void
    var onComplete: (CGPoint) -> Void
    @ObservedObject var appDetectionService: AppDetectionService
    var isTemporarilyCompleted: Bool = false

    var body: some View {
        let isDone = item.completed || isTemporarilyCompleted
        return GeometryReader { geometry in
            HStack {
                // Checkmark button
                Button(action: {
                    let frame = geometry.frame(in: .global)
                    let center = CGPoint(x: frame.minX + 20, y: frame.midY)
                    onComplete(center)
                }) {
                    Image(systemName: isDone ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(isDone ? .green : .gray)
                        .font(.title3)
                }
                .buttonStyle(.plain)

                // Title + deadline + subtask indicator
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 4) {
                        if item.priority > 0 {
                            Circle()
                                .fill(priorityColor(for: item.priority))
                                .frame(width: 6, height: 6)
                        }
                        Text(item.title ?? "Untitled")
                            .strikethrough(isDone)
                    }
                    HStack(spacing: 6) {
                        if let deadline = item.deadline {
                            Text(deadline, style: .date)
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        // ← Subtask indicator
                        SubtaskIndicator(item: item)
                    }
                }

                Spacer()

                // App / link icon
                if let type = item.linkedResourceType, let value = item.linkedResourceValue {
                    Button(action: {
                        if type == LinkedResourceType.app.rawValue {
                            appDetectionService.launchApp(bundleIdentifier: value)
                        } else if let url = normalizedURL(from: value) {
                            NSWorkspace.shared.open(url)
                        }
                    }) {
                        if type == LinkedResourceType.app.rawValue {
                            if let icon = appDetectionService.getIcon(for: value) {
                                Image(nsImage: icon).resizable().frame(width: 20, height: 20)
                            }
                        } else {
                            LinkIconView(link: value).frame(width: 20, height: 20)
                        }
                    }
                    .buttonStyle(.plain)
                    .padding(.trailing, 4)
                }

                // Info button
                Button(action: onSelect) {
                    Image(systemName: "info.circle").font(.caption).foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding(.vertical, 4)
        }
        .frame(height: 40)
    }

    private func priorityColor(for priority: Int16) -> Color {
        switch priority {
        case 1: return .orange
        case 2: return .red
        default: return .blue
        }
    }
}

// MARK: - AppPickerView

struct AppPickerView: View {
    @ObservedObject var appDetectionService: AppDetectionService
    @Binding var selectedApp: DetectedApp?
    @Binding var linkURL: String
    @Binding var isPresented: Bool

    @State private var searchText = ""
    @State private var tempURL = ""

    var body: some View {
        VStack(spacing: 12) {
            Text("Link App")
                .font(.headline)
                .padding(.top)

            VStack(alignment: .leading, spacing: 8) {
                Text("Paste a link")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                HStack {
                    TextField("https://...", text: $tempURL)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    Button("Save") {
                        linkURL = tempURL
                        isPresented = false
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(tempURL.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .padding(.horizontal)

            Text("or").foregroundColor(.secondary).font(.headline)

            TextField("Search apps...", text: $searchText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)

            if appDetectionService.isLoading {
                Spacer()
                ProgressView("Scanning apps...")
                Spacer()
            } else {
                List(appDetectionService.installedApps.filter {
                    searchText.isEmpty || $0.displayName.localizedCaseInsensitiveContains(searchText)
                }) { app in
                    HStack {
                        Image(nsImage: app.icon).resizable().frame(width: 24, height: 24)
                        Text(app.displayName)
                        Spacer()
                    }
                    .contentShape(Rectangle())
                    .onTapGesture { selectedApp = app; isPresented = false }
                }
            }

            Button("Cancel") { isPresented = false }.padding(.bottom)
        }
        .background(AppColors.card)
        .frame(width: 320, height: 400)
        .background(Color.black.opacity(0.25))
        .onAppear { tempURL = linkURL }
    }
}

// MARK: - TaskDetailView

struct TaskDetailView: View {
    @ObservedObject var item: Item
    @ObservedObject var appDetectionService: AppDetectionService
    @Environment(\.dismiss) var dismiss
    var onEdit: () -> Void

    private var sortedSubtasks: [Subtask] {
        let subs = (item.subtasks as? Set<Subtask>) ?? []
        return subs.sorted { $0.sortOrder < $1.sortOrder }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text(item.category ?? "Task")
                        .font(.caption).padding(4)
                        .background(Color.blue.opacity(0.1)).cornerRadius(4)
                    Spacer()
                    Button("Edit") { onEdit() }.buttonStyle(.plain)
                    Button("Close") { dismiss() }.buttonStyle(.plain)
                }
                Text(item.title ?? "Untitled").font(.title2).bold()
                if let notes = item.notes, !notes.isEmpty {
                    RichTextEditor(text: .constant(notes))
                        .frame(minHeight: 60, maxHeight: 120)
                        .padding(6)
                        .background(Color.Surface.a10.opacity(0.5))
                        .cornerRadius(8)
                }
                if let deadline = item.deadline {
                    Label("Deadline: \(deadline, style: .date)", systemImage: "calendar")
                        .foregroundColor(.secondary)
                }
                Divider()
                if !sortedSubtasks.isEmpty {
                    Text("Subtasks").font(.headline)
                    ForEach(sortedSubtasks) { sub in
                        HStack {
                            Image(systemName: "circle").font(.caption).foregroundColor(.secondary)
                            Text(sub.linkedResourceValue ?? "").font(.body)
                        }
                        .padding(.vertical, 2)
                    }
                }
                if let type = item.linkedResourceType, let value = item.linkedResourceValue {
                    Button(action: {
                        if type == LinkedResourceType.app.rawValue {
                            appDetectionService.launchApp(bundleIdentifier: value)
                        } else if let url = normalizedURL(from: value) {
                            NSWorkspace.shared.open(url)
                        }
                    }) {
                        HStack {
                            if type == LinkedResourceType.app.rawValue {
                                if let icon = appDetectionService.getIcon(for: value) {
                                    Image(nsImage: icon).resizable().frame(width: 32, height: 32)
                                }
                                Text("Open \(item.linkedResourceAppDisplayName ?? "App")")
                            } else {
                                LinkIconView(link: value).frame(width: 32, height: 32)
                                Text("Open Link")
                            }
                        }
                        .padding().frame(maxWidth: .infinity)
                        .background(Color.blue.opacity(0.1)).cornerRadius(8)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding()
        }
        .frame(minWidth: 350, minHeight: 280)
        .background(AppColors.card)
    }
}
