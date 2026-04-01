import SwiftUI
import CoreData

// MARK: - Confetti Component
struct ConfettiPiece: Identifiable {
    let id = UUID()
    var x: CGFloat
    var y: CGFloat
    var color: Color
    var size: CGFloat
    var rotation: Double
    var opacity: Double
}

struct ConfettiView: View {
    @Binding var isFinished: Bool
    @State private var pieces: [ConfettiPiece] = []
    let timer = Timer.publish(every: 0.03, on: .main, in: .common).autoconnect()
    
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
        .onAppear { createConfetti() }
        .onReceive(timer) { _ in updateConfetti() }
    }
    
    private func createConfetti() {
        let colors: [Color] = [.red, .blue, .green, .yellow, .pink, .purple, .orange]
        for _ in 0..<50 {
            pieces.append(ConfettiPiece(
                x: CGFloat.random(in: 0...370),
                y: CGFloat.random(in: -100...0),
                color: colors.randomElement() ?? .blue,
                size: CGFloat.random(in: 5...12),
                rotation: Double.random(in: 0...360),
                opacity: 1.0
            ))
        }
    }
    
    private func updateConfetti() {
        for i in 0..<pieces.count {
            pieces[i].y += CGFloat.random(in: 5...10)
            pieces[i].x += CGFloat.random(in: -2...2)
            pieces[i].rotation += 10
            pieces[i].opacity -= 0.01
        }
        pieces.removeAll { $0.opacity <= 0 || $0.y > 450 }
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
    
    @State private var currentView: AppView = .dashboard
    @State private var selectedCategory: TaskCategory? = nil
    @State private var showConfetti: Bool = false
    @State private var selectedTask: Item? = nil
    
    // Task Input States
    @State private var newTaskTitle: String = ""
    @State private var inputCategory: TaskCategory = .daily
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
                    dashboardView
                case .categoryList:
                    categoryListView
                case .addTask:
                    addTaskView
                }
            }
            
            if showConfetti {
                ConfettiView(isFinished: $showConfetti)
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
    
    private var dashboardView: some View {
        VStack(spacing: 20) {
            Text("Dashboard")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .padding(.top)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                ForEach(TaskCategory.allCases) { category in
                    Button(action: {
                        withAnimation {
                            selectedCategory = category
                            currentView = .categoryList
                        }
                    }) {
                        VStack {
                            Image(systemName: categoryIcon(for: category))
                                .font(.title)
                            Text(category.rawValue)
                                .font(.headline)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(category.color.opacity(0.2))
                        .cornerRadius(12)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding()
            
            Spacer()
            
            Button(action: {
                withAnimation {
                    currentView = .addTask
                }
            }) {
                Label("Add New Task", systemImage: "plus.circle.fill")
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .buttonStyle(.plain)
            .padding()
        }
    }
    
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
                Button(action: {
                    withAnimation {
                        currentView = .addTask
                    }
                }) {
                    Image(systemName: "plus").font(.headline)
                }
                .buttonStyle(.plain)
            }
            .padding()
            .background((selectedCategory?.color ?? .blue).opacity(0.1))
            
            List {
                let categoryTasks = items.filter { $0.category == selectedCategory?.rawValue }
                if categoryTasks.isEmpty {
                    Text("No tasks yet!").foregroundColor(.secondary).padding()
                } else {
                    ForEach(categoryTasks) { item in
                        TaskRow(item: item, onSelect: { selectedTask = item }, onComplete: {
                            if !item.completed { showConfetti = true }
                            item.completed.toggle()
                            saveContext()
                        })
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
                            Button(action: { showAppPicker = true }) {
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
        
        // Ensure Core Data operations happen on the main thread
        DispatchQueue.main.async {
            let newItem = Item(context: viewContext)
            newItem.timestamp = Date()
            newItem.title = newTaskTitle
            newItem.category = inputCategory.rawValue
            newItem.completed = false
            
            // DEFENSIVE: Only set deadline if explicitly selected, otherwise leave as nil
            // If your Core Data model marks 'deadline' as non-optional, this might crash.
            // Ensure 'Optional' is checked for 'deadline' in TaskBubble.xcdatamodeld.
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
            
            // Reset and navigate back
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
    
    private func saveContext() {
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            print("Unresolved error \(nsError), \(nsError.userInfo)")
            // If saving fails, delete the item to prevent a corrupt state
            viewContext.rollback()
        }
    }
    
    private func categoryIcon(for category: TaskCategory) -> String {
        switch category {
        case .goals: return "target"
        case .daily: return "sun.max"
        case .weekly: return "calendar"
        case .routine: return "repeat"
        }
    }
}

// MARK: - Supporting Views

struct TaskRow: View {
    @ObservedObject var item: Item
    var onSelect: () -> Void
    var onComplete: () -> Void
    @StateObject private var appDetectionService = AppDetectionService()
    
    var body: some View {
        HStack {
            Button(action: onComplete) {
                Image(systemName: item.completed ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(item.completed ? .green : .gray)
                    .font(.title3)
            }
            .buttonStyle(.plain)
            
            VStack(alignment: .leading) {
                Text(item.title ?? "Untitled")
                    .strikethrough(item.completed)
                if let deadline = item.deadline {
                    Text(deadline, style: .date).font(.caption2).foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            if let type = item.linkedResourceType, let value = item.linkedResourceValue {
                if type == LinkedResourceType.app.rawValue {
                    if let icon = appDetectionService.getIcon(for: value) {
                        Image(nsImage: icon).resizable().frame(width: 16, height: 16)
                    }
                } else {
                    Image(systemName: "safari").font(.caption2).foregroundColor(.blue)
                }
            }
            
            Button(action: onSelect) {
                Image(systemName: "chevron.right").font(.caption).foregroundColor(.secondary)
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 4)
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
            List(appDetectionService.installedApps.filter { searchText.isEmpty || $0.displayName.localizedCaseInsensitiveContains(searchText) }) { app in
                HStack {
                    Image(nsImage: app.icon).resizable().frame(width: 24, height: 24)
                    Text(app.displayName)
                    Spacer()
                }
                .contentShape(Rectangle())
                .onTapGesture { selectedApp = app; isPresented = false }
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

