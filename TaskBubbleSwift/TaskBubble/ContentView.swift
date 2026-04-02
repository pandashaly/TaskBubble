import SwiftUI
import CoreData

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
        pieces.removeAll { $0.opacity <= 0 || $0.y > 450 || $0.x < 0 || $0.x > 370 }
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
    
    @AppStorage("waterIntake") private var waterIntake: Int = 0
    @State private var currentView: AppView = .dashboard
    @State private var selectedCategory: TaskCategory? = nil
    @State private var showConfetti: Bool = false
    @State private var confettiOrigin: CGPoint = .zero
    @State private var selectedTask: Item? = nil
    @State private var sortOption: TaskSortOption = .timestamp
    
    // Task Input States
    @State private var newTaskTitle: String = ""
    @State private var inputCategory: TaskCategory = .today
    @State private var inputPriority: TaskPriority = .medium
    @State private var selectedDeadline: Date = Date()
    @State private var showDeadlinePicker: Bool = false
    @State private var showAppPicker: Bool = false
    @State private var showLinkInput: Bool = false
    @State private var selectedApp: DetectedApp? = nil
    @State private var linkURL: String = ""
    
    enum AppView {
        case dashboard, categoryList, addTask
    }
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                switch currentView {
                case .dashboard:
                    DashboardView(
                        waterIntake: $waterIntake,
                        onCategoryTap: { category in
                            withAnimation {
                                selectedCategory = category
                                currentView = .categoryList
                            }
                        },
                        onAddTask: {
                            withAnimation {
                                currentView = .addTask
                            }
                        }
                    )
                case .categoryList:
                    categoryListView
                case .addTask:
                    addTaskView
                }
            }
            
            if showConfetti {
                ConfettiView(isFinished: $showConfetti, origin: confettiOrigin)
                    .allowsHitTesting(false)
            }
        }
        .frame(width: 370, height: 450)
        .sheet(isPresented: $showAppPicker) {
            AppPickerView(appDetectionService: appDetectionService, selectedApp: $selectedApp, isPresented: $showAppPicker)
        }
        .sheet(isPresented: $showLinkInput) {
            LinkInputView(linkURL: $linkURL, isPresented: $showLinkInput)
        }
        .sheet(item: $selectedTask) { item in
            TaskDetailView(item: item, appDetectionService: appDetectionService)
        }
    }
    
    // MARK: - Subviews
    
    
    private var categoryListView: some View {
        VStack(spacing: 0) {
            HStack {
                Button(action: {
                    withAnimation {
                        currentView = .dashboard
                    }
                }) {
                    Image(systemName: "chevron.left").font(.headline)
                }
                .buttonStyle(.plain)
                Spacer()
                Text(selectedCategory?.rawValue ?? "").font(.headline)
                Spacer()
                Menu {
                    Picker("Sort By", selection: $sortOption) {
                        ForEach(TaskSortOption.allCases) { option in
                            Text(option.rawValue).tag(option)
                        }
                    }
                } label: {
                    Image(systemName: "arrow.up.arrow.down").font(.headline)
                }
                .menuStyle(.borderlessButton)
                .fixedSize()
                
                Button(action: {
                    withAnimation {
                        currentView = .addTask
                    }
                }) {
                    Image(systemName: "plus").font(.headline)
                }
                .buttonStyle(.plain)
                .padding(.leading, 8)
            }
            .padding()
            .background((selectedCategory?.color ?? .blue).opacity(0.1))
            
            List {
                let categoryTasks = sortedTasks(items.filter { $0.category == selectedCategory?.rawValue })
                if categoryTasks.isEmpty {
                    Text("No tasks yet!").foregroundColor(.secondary).padding()
                } else {
                    ForEach(categoryTasks) { item in
                        TaskRow(item: item, onSelect: { selectedTask = item }, onComplete: { location in
                            if !item.completed {
                                confettiOrigin = location
                                showConfetti = true
                            }
                            item.completed.toggle()
                            saveContext()
                        }, appDetectionService: appDetectionService)
                    }
                    .onDelete { offsets in
                        offsets.map { categoryTasks[$0] }.forEach(viewContext.delete)
                        saveContext()
                    }
                }
            }
            .listStyle(.plain)
        }
    }
    
    private var addTaskView: some View {
        VStack(spacing: 0) {
            HStack {
                Button("Cancel") {
                    withAnimation {
                        currentView = .dashboard
                    }
                }
                .buttonStyle(.plain)
                Spacer()
                Text("New Task").font(.headline)
                Spacer()
                Button("Add") {
                    addTask()
                }
                .buttonStyle(.plain)
                .foregroundColor(.blue)
                .bold()
            }
            .padding()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    TextField("What needs to be done?", text: $newTaskTitle)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .font(.title3)
                    
                    VStack(alignment: .leading) {
                        Text("Category").font(.caption).foregroundColor(.secondary)
                        Picker("", selection: $inputCategory) {
                            ForEach(TaskCategory.allCases) { category in
                                Text(category.rawValue).tag(category)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Priority").font(.caption).foregroundColor(.secondary)
                        Picker("", selection: $inputPriority) {
                            ForEach(TaskPriority.allCases) { priority in
                                Text(priority.displayName).tag(priority)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                    
                    Toggle(isOn: $showDeadlinePicker) {
                        Label("Add Deadline", systemImage: "calendar")
                    }
                    
                    if showDeadlinePicker {
                        DatePicker("", selection: $selectedDeadline, displayedComponents: .date)
                            .datePickerStyle(.graphical)
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Link Tool").font(.caption).foregroundColor(.secondary)
                        HStack {
                            Button(action: {
                                appDetectionService.loadInstalledApplications()
                                showAppPicker = true
                            }) {
                                Label("App", systemImage: "app.badge")
                                    .padding(8)
                                    .background(Color.gray.opacity(0.1))
                                    .cornerRadius(8)
                            }
                            .buttonStyle(.plain)
                            
                            Button(action: { showLinkInput = true }) {
                                Label("URL", systemImage: "link")
                                    .padding(8)
                                    .background(Color.gray.opacity(0.1))
                                    .cornerRadius(8)
                            }
                            .buttonStyle(.plain)
                            
                            Spacer()
                            
                            if let app = selectedApp {
                                Image(nsImage: app.icon).resizable().frame(width: 24, height: 24)
                            } else if !linkURL.isEmpty {
                                Image(systemName: "safari")
                            }
                        }
                    }
                }
                .padding()
            }
        }
    }
    
    private func addTask() {
        guard !newTaskTitle.isEmpty else { return }
        
        DispatchQueue.main.async {
            let newItem = Item(context: viewContext)
            newItem.timestamp = Date()
            newItem.title = newTaskTitle
            newItem.category = inputCategory.rawValue
            newItem.priority = inputPriority.rawValue
            newItem.completed = false
            
            if showDeadlinePicker {
                newItem.deadline = selectedDeadline
            } else {
                newItem.deadline = nil
            }
            
            if let app = selectedApp {
                newItem.linkedResourceType = LinkedResourceType.app.rawValue
                newItem.linkedResourceValue = app.id
                newItem.linkedResourceAppDisplayName = app.displayName
            } else if !linkURL.isEmpty {
                newItem.linkedResourceType = LinkedResourceType.url.rawValue
                newItem.linkedResourceValue = linkURL
            }
            
            saveContext()
            
            withAnimation {
                newTaskTitle = ""
                selectedApp = nil
                linkURL = ""
                showDeadlinePicker = false
                selectedCategory = inputCategory
                currentView = .categoryList
            }
        }
    }
    
    private func sortedTasks(_ tasks: [Item]) -> [Item] {
        switch sortOption {
        case .alphabetical:
            return tasks.sorted { ($0.title ?? "") < ($1.title ?? "") }
        case .dueDate:
            return tasks.sorted {
                let d1 = $0.deadline ?? Date.distantFuture
                let d2 = $1.deadline ?? Date.distantFuture
                return d1 < d2
            }
        case .priority:
            return tasks.sorted { $0.priority > $1.priority } // High priority first
        case .timestamp:
            return tasks.sorted { ($0.timestamp ?? Date.distantPast) < ($1.timestamp ?? Date.distantPast) }
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
    
    var body: some View {
        GeometryReader { geometry in
            HStack {
                Button(action: {
                    let frame = geometry.frame(in: .global)
                    let center = CGPoint(x: frame.minX + 20, y: frame.midY)
                    onComplete(center)
                }) {
                    Image(systemName: item.completed ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(item.completed ? .green : .gray)
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
                            .strikethrough(item.completed)
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
                        } else if let url = URL(string: value) {
                            NSWorkspace.shared.open(url)
                        }
                    }) {
                        if type == LinkedResourceType.app.rawValue {
                            if let icon = appDetectionService.getIcon(for: value) {
                                Image(nsImage: icon).resizable().frame(width: 20, height: 20)
                            }
                        } else {
                            Image(systemName: "safari").font(.caption).foregroundColor(.blue)
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

struct AppPickerView: View {
    @ObservedObject var appDetectionService: AppDetectionService
    @Binding var selectedApp: DetectedApp?
    @Binding var isPresented: Bool
    @State private var searchText: String = ""
    
    var body: some View {
        VStack {
            Text("Select an App").font(.headline).padding(.top)
            TextField("Search apps...", text: $searchText).textFieldStyle(RoundedBorderTextFieldStyle()).padding(.horizontal)
            
            if appDetectionService.isLoading {
                Spacer()
                ProgressView("Scanning apps...")
                Spacer()
            } else {
                List(appDetectionService.installedApps.filter { searchText.isEmpty || $0.displayName.localizedCaseInsensitiveContains(searchText) }) { app in
                    HStack {
                        Image(nsImage: app.icon).resizable().frame(width: 24, height: 24)
                        Text(app.displayName)
                        Spacer()
                    }
                    .contentShape(Rectangle())
                    .onTapGesture { selectedApp = app; isPresented = false }
                }
            }
            Button("Cancel") { isPresented = false }.padding()
        }
        .frame(width: 300, height: 400)
    }
}

struct LinkInputView: View {
    @Binding var linkURL: String
    @Binding var isPresented: Bool
    @State private var tempURL: String = ""
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Enter URL").font(.headline)
            TextField("https://...", text: $tempURL).textFieldStyle(RoundedBorderTextFieldStyle()).padding(.horizontal)
            HStack {
                Button("Cancel") { isPresented = false }
                Button("Save") { linkURL = tempURL; isPresented = false }.buttonStyle(.borderedProminent)
            }
        }
        .padding().frame(width: 300, height: 150).onAppear { tempURL = linkURL }
    }
}

struct TaskDetailView: View {
    @ObservedObject var item: Item
    @ObservedObject var appDetectionService: AppDetectionService
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text(item.category ?? "Task").font(.caption).padding(4).background(Color.blue.opacity(0.1)).cornerRadius(4)
                Spacer()
                Button("Close") { dismiss() }.buttonStyle(.plain)
            }
            Text(item.title ?? "Untitled").font(.title2).bold()
            if let deadline = item.deadline {
                Label("Deadline: \(deadline, style: .date)", systemImage: "calendar").foregroundColor(.secondary)
            }
            Divider()
            if let type = item.linkedResourceType, let value = item.linkedResourceValue {
                Button(action: {
                    if type == LinkedResourceType.app.rawValue { appDetectionService.launchApp(bundleIdentifier: value) }
                    else if let url = URL(string: value) { NSWorkspace.shared.open(url) }
                }) {
                    HStack {
                        if type == LinkedResourceType.app.rawValue {
                            if let icon = appDetectionService.getIcon(for: value) { Image(nsImage: icon).resizable().frame(width: 32, height: 32) }
                            Text("Open \(item.linkedResourceAppDisplayName ?? "App")")
                        } else {
                            Image(systemName: "safari").font(.title)
                            Text("Open Link")
                        }
                    }
                    .padding().frame(maxWidth: .infinity).background(Color.blue.opacity(0.1)).cornerRadius(8)
                }
                .buttonStyle(.plain)
            }
            Spacer()
        }
        .padding().frame(width: 350, height: 300)
    }
}

