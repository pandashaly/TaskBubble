import SwiftUI
import CoreData
import AppKit

// MARK: - Confetti Component
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
            // Upward-focused explosion (cannon style)
            let angle = Double.random(in: (-.pi * 0.75)...(-.pi * 0.25)) // Focus upward
            let speed = Double.random(in: 4...12)
            pieces.append(ConfettiPiece(
                x: origin.x,
                y: origin.y,
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
            pieces[i].vy += 0.25 // Stronger gravity for a more dynamic arc
            pieces[i].rotation += 20
            pieces[i].opacity -= 0.012
        }
        pieces.removeAll { $0.opacity <= 0 || $0.y > 422 || $0.x < 0 || $0.x > 356 }
        if pieces.isEmpty {
            isFinished = false
        }
    }
}

// MARK: - Main Content View
struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var appDetectionService = AppDetectionService()
    
    @FetchRequest<Item>(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
        animation: .default)
    private var items: FetchedResults<Item>
    
    @StateObject private var waterService: WaterIntakeService
    @State private var currentView: AppView = .dashboard
    
    private let timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()

    init() {
        let context = PersistenceController.shared.container.viewContext
        _waterService = StateObject(wrappedValue: WaterIntakeService(context: context))
    }
    @State private var selectedCategory: TaskCategory? = nil
    @State private var showConfetti: Bool = false
    @State private var confettiOrigin: CGPoint = .zero
    @State private var selectedTask: Item? = nil
    @State private var sortOption: TaskSortOption = .timestamp
    @State private var showTaskSearch: Bool = false
    @State private var calendarScope: TaskCalendarScope = .week
    @State private var showCalendarDayTasks: Bool = false
    @State private var calendarSheetDate: Date = Date()
    @State private var calendarDayTasks: [Item] = []
    @State private var calendarAddDay: Date?
    @State private var showCalendarAddConfirm: Bool = false

    // Task Input States
    @State private var newTaskTitle: String = ""
    @State private var taskNotes: String = ""
    @State private var inputCategory: TaskCategory = .today
    @State private var inputPriority: TaskPriority = .medium
    @State private var taskDeadline: Date? = nil
    @State private var showAppPicker: Bool = false
    @State private var showLinkInput: Bool = false
    @State private var selectedApp: DetectedApp? = nil
    @State private var linkURL: String = ""
    @State private var mainLinkBundleIdentifier: String? = nil
    @State private var subtaskDrafts: [SubtaskDraft] = []
    @State private var activeSubtaskID: UUID? = nil
    @State private var editingTask: Item? = nil
    @State private var showQuickAdd: Bool = false
    
    enum AppView {
        case dashboard, categoryList, addTask
    }
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                switch currentView {
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
                                currentView = .categoryList
                            }
                        },
                        onAddTask: {
                            editingTask = nil
                            resetAddTaskForm()
                            withAnimation {
                                showQuickAdd = true
                            }
                        },
                        onSearch: { showTaskSearch = true }
                    )
                case .categoryList:
                    if let cat = selectedCategory {
                        CategoryListView(
                            category: cat,
                            items: Array(items),
                            sortOption: $sortOption,
                            appDetectionService: appDetectionService,
                            onBack: {
                                withAnimation {
                                    currentView = .dashboard
                                }
                            },
                            onAddTask: {
                                editingTask = nil
                                resetAddTaskForm()
                                withAnimation {
                                    showQuickAdd = true
                                }
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
                case .addTask:
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
                            withAnimation {
                                currentView = .dashboard
                            }
                        },
                        appDetectionService: appDetectionService
                    )
                }
            }
            
            if showConfetti {
                ConfettiView(isFinished: $showConfetti, origin: confettiOrigin)
                    .allowsHitTesting(false)
            }
            
            if showQuickAdd {
                Color.black.opacity(0.3)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        showQuickAdd = false
                    }
                
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
                        withAnimation {
                            currentView = .addTask
                        }
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
        .frame(width: 356, height: 422)
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
                    withAnimation {
                        currentView = .addTask
                    }
                }
            )
        }
        .sheet(isPresented: $showTaskSearch) {
            TaskSearchView(items: Array(items)) { item in
                showTaskSearch = false
                DispatchQueue.main.async {
                    selectedTask = item
                }
            }
        }
        .sheet(isPresented: $showCalendarDayTasks) {
            CalendarDayTasksSheet(date: calendarSheetDate, tasks: calendarDayTasks) { item in
                selectedTask = item
            }
        }
        .onChange(of: selectedApp) { _, newApp in
            guard let app = newApp else { return }
            if let id = activeSubtaskID {
                if let i = subtaskDrafts.firstIndex(where: { $0.id == id }) {
                    subtaskDrafts[i].detectedApp = app
                    subtaskDrafts[i].linkURL = ""
                    subtaskDrafts[i].appBundleIdentifier = nil
                }
                selectedApp = nil
                activeSubtaskID = nil
            } else {
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
            if !open, selectedApp == nil {
                activeSubtaskID = nil
            }
        }
        .onChange(of: showLinkInput) { _, open in
            if !open { activeSubtaskID = nil }
        }
        .onReceive(timer) { _ in
            waterService.refreshCurrentIntake()
        }
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
                    withAnimation {
                        currentView = .addTask
                    }
                }
                calendarAddDay = nil
            }
            Button("Cancel", role: .cancel) {
                calendarAddDay = nil
            }
        } message: {
            if let d = calendarAddDay {
                Text(DateFormatter.localizedString(from: d, dateStyle: .medium, timeStyle: .none))
            }
        }
    }
    
    private var linkBindingForSheet: Binding<String> {
        Binding(
            get: {
                if let id = activeSubtaskID, let d = subtaskDrafts.first(where: { $0.id == id }) {
                    return d.linkURL
                }
                return linkURL
            },
            set: { new in
                if let id = activeSubtaskID, let i = subtaskDrafts.firstIndex(where: { $0.id == id }) {
                    subtaskDrafts[i].linkURL = new
                    subtaskDrafts[i].detectedApp = nil
                    subtaskDrafts[i].appBundleIdentifier = nil
                } else {
                    linkURL = new
                }
            }
        )
    }

    private func resetAddTaskForm() {
        newTaskTitle = ""
        taskNotes = ""
        inputCategory = .today
        inputPriority = .medium
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
        inputPriority = TaskPriority(rawValue: item.priority) ?? .medium
        taskDeadline = item.deadline
        mainLinkBundleIdentifier = nil
        selectedApp = nil
        linkURL = ""
        if let type = item.linkedResourceType, let value = item.linkedResourceValue {
            if type == LinkedResourceType.app.rawValue {
                selectedApp = appDetectionService.installedApps.first { $0.id == value }
                if selectedApp == nil {
                    mainLinkBundleIdentifier = value
                }
            } else {
                linkURL = value
            }
        }
        let subs = (item.subtasks as? Set<Subtask>) ?? []
        subtaskDrafts = subs.sorted { $0.sortOrder < $1.sortOrder }.compactMap { st -> SubtaskDraft? in
            guard let type = st.linkedResourceType, let value = st.linkedResourceValue else { return nil }
            if type == LinkedResourceType.app.rawValue {
                let app = appDetectionService.installedApps.first { $0.id == value }
                return SubtaskDraft(
                    detectedApp: app,
                    linkURL: "",
                    appBundleIdentifier: app == nil ? value : nil
                )
            }
            return SubtaskDraft(linkURL: value)
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
                if let app = draft.detectedApp {
                    let sub = Subtask(context: viewContext)
                    sub.parent = item
                    sub.sortOrder = order
                    order += 1
                    sub.linkedResourceType = LinkedResourceType.app.rawValue
                    sub.linkedResourceValue = app.id
                    sub.linkedResourceAppDisplayName = app.displayName
                } else if let bid = draft.appBundleIdentifier, draft.linkURL.isEmpty {
                    let sub = Subtask(context: viewContext)
                    sub.parent = item
                    sub.sortOrder = order
                    order += 1
                    sub.linkedResourceType = LinkedResourceType.app.rawValue
                    sub.linkedResourceValue = bid
                    sub.linkedResourceAppDisplayName = nil
                } else if !draft.linkURL.isEmpty {
                    let sub = Subtask(context: viewContext)
                    sub.parent = item
                    sub.sortOrder = order
                    order += 1
                    sub.linkedResourceType = LinkedResourceType.url.rawValue
                    sub.linkedResourceValue = draft.linkURL
                    sub.linkedResourceAppDisplayName = nil
                }
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

// MARK: - Supporting Views

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
                
                VStack(alignment: .leading) {
                    HStack(spacing: 4) {
                        if item.priority > 0 {
                            Circle()
                                .fill(priorityColor(for: item.priority))
                                .frame(width: 6, height: 6)
                        }
                        Text(item.title ?? "Untitled")
                            .strikethrough(isDone)
                    }
                    if let deadline = item.deadline {
                        Text(deadline, style: .date).font(.caption2).foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
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
                            LinkIconView(link: value)
                                    .frame(width: 20, height: 20)
                            //Image(systemName: "safari").font(.caption).foregroundColor(.blue)
                        }
                    }
                    .buttonStyle(.plain)
                    .padding(.trailing, 4)
                }
                
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
        case 0: return .blue
        case 1: return .orange
        case 2: return .red
        default: return .gray
        }
    }
}

//struct AppPickerView: View {
//    @ObservedObject var appDetectionService: AppDetectionService
//    @Binding var selectedApp: DetectedApp?
//    @Binding var isPresented: Bool
//    @State private var searchText: String = ""
//    
//    var body: some View {
//        VStack {
//            Text("Select an App").font(.headline).padding(.top)
//            TextField("Search apps...", text: $searchText).textFieldStyle(RoundedBorderTextFieldStyle()).padding(.horizontal)
//            
//            if appDetectionService.isLoading {
//                Spacer()
//                ProgressView("Scanning apps...")
//                Spacer()
//            } else {
//                List(appDetectionService.installedApps.filter { searchText.isEmpty || $0.displayName.localizedCaseInsensitiveContains(searchText) }) { app in
//                    HStack {
//                        Image(nsImage: app.icon).resizable().frame(width: 24, height: 24)
//                        Text(app.displayName)
//                        Spacer()
//                    }
//                    .contentShape(Rectangle())
//                    .onTapGesture { selectedApp = app; isPresented = false }
//                }
//            }
//            Button("Cancel") { isPresented = false }.padding()
//        }
//        .frame(width: 300, height: 400)
//    }
//}
//
//struct LinkInputView: View {
//    @Binding var linkURL: String
//    @Binding var isPresented: Bool
//    @State private var tempURL: String = ""
//    
//    var body: some View {
//        VStack(spacing: 16) {
//            Text("Enter URL").font(.headline)
//            TextField("https://...", text: $tempURL).textFieldStyle(RoundedBorderTextFieldStyle()).padding(.horizontal)
//            HStack {
//                Button("Cancel") { isPresented = false }
//                Button("Save") { linkURL = tempURL; isPresented = false }.buttonStyle(.borderedProminent)
//            }
//        }
//        .padding().frame(width: 300, height: 150).onAppear { tempURL = linkURL }
//    }
//}

struct AppPickerView: View {
    @ObservedObject var appDetectionService: AppDetectionService
    @Binding var selectedApp: DetectedApp?
    @Binding var linkURL: String
    @Binding var isPresented: Bool
    
    @State private var searchText: String = ""
    @State private var tempURL: String = ""
    
    var body: some View {
        VStack(spacing: 12) {
            
            Text("Link App")
                .font(.headline)
                .padding(.top)
            
            // URL INPUT
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
            // OR DIVIDER
            HStack {
                Text("or")
                    .foregroundColor(.secondary)
                    .font(.headline)
            }
            .padding(.horizontal)
            
            // SEARCH APPS
            TextField("Search apps...", text: $searchText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
            
            if appDetectionService.isLoading {
                Spacer()
                ProgressView("Scanning apps...")
                Spacer()
            } else {
                List(
                    appDetectionService.installedApps.filter {
                        searchText.isEmpty ||
                        $0.displayName.localizedCaseInsensitiveContains(searchText)
                    }
                ) { app in
                    HStack {
                        Image(nsImage: app.icon)
                            .resizable()
                            .frame(width: 24, height: 24)
                        
                        Text(app.displayName)
                        
                        Spacer()
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        selectedApp = app
                        isPresented = false
                    }
                }
            }
            
            Button("Cancel") {
                isPresented = false
            }
            .padding(.bottom)
        }
        .frame(width: 320, height: 400)
        .onAppear {
            tempURL = linkURL
        }
    }
}

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
                    Text(item.category ?? "Task").font(.caption).padding(4).background(Color.blue.opacity(0.1)).cornerRadius(4)
                    Spacer()
                    Button("Edit") { onEdit() }.buttonStyle(.plain)
                    Button("Close") { dismiss() }.buttonStyle(.plain)
                }
                Text(item.title ?? "Untitled").font(.title2).bold()
                if let notes = item.notes, !notes.isEmpty {
                    Text(notes)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                if let deadline = item.deadline {
                    Label("Deadline: \(deadline, style: .date)", systemImage: "calendar").foregroundColor(.secondary)
                }
                Divider()
                if !sortedSubtasks.isEmpty {
                    Text("Subtasks").font(.headline)
                    ForEach(sortedSubtasks) { sub in
                        if let type = sub.linkedResourceType, let value = sub.linkedResourceValue {
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
                                            Image(nsImage: icon).resizable().frame(width: 24, height: 24)
                                        }
                                        Text(sub.linkedResourceAppDisplayName ?? "Open App")
                                    } else {
                                        LinkIconView(link: value).frame(width: 24, height: 24)
                                        Text("Open Link")
                                    }
                                    Spacer()
                                    Image(systemName: "arrow.up.right.square")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .padding(10)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color.gray.opacity(0.08))
                                .cornerRadius(8)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                if let type = item.linkedResourceType, let value = item.linkedResourceValue {
                    Button(action: {
                        if type == LinkedResourceType.app.rawValue { appDetectionService.launchApp(bundleIdentifier: value) }
                        else if let url = normalizedURL(from: value) {
                            NSWorkspace.shared.open(url)
                        }
                    }) {
                        HStack {
                            if type == LinkedResourceType.app.rawValue {
                                if let icon = appDetectionService.getIcon(for: value) { Image(nsImage: icon).resizable().frame(width: 32, height: 32) }
                                Text("Open \(item.linkedResourceAppDisplayName ?? "App")")
                            } else {
                                LinkIconView(link: value)
                                    .frame(width: 32, height: 32)
                                Text("Open Link")
                            }
                        }
                        .padding().frame(maxWidth: .infinity).background(Color.blue.opacity(0.1)).cornerRadius(8)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding()
        }
        .frame(minWidth: 350, minHeight: 280)
    }
}

