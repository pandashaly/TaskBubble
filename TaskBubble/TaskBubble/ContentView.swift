//
//  ContentView.swift
//  TaskBubble
//
//  Created by Bocal on 03/01/2025.
//

//import SwiftUI
//import CoreData
//
//struct TaskBubbleView: View {
//    @State private var newTask: String = ""
////    @State private var tasks: [Task] = []
////    @State private var activeCat: String = "Goals"
////    @State private var isDarkMode: Bool = false
////    
////    let categories = [
////        Category(name: "Goals", color: Color("PastelLilac")),
////        Category(name: "To-Do", color: Color("PastelGreen")),
////        Category(name: "Weekly", color: Color("PastelBlue")),
////        Category(name: "Routine", color: Color("PastelPink"))
////    ]
////    
//    var body: some View {
//        ZStack(alignment: .topLeading) {
//            VStack {
//                // Add your main TaskBubble UI elements here
//                TextField("Add a new task...", text: $newTask)
//                    .font(.body)
//                    .background(Color.white)
//                    .padding(14)
//                    .cornerRadius(8)
//                    .shadow(radius: 2)
//            }
//            .frame(width: 370, height: 220) // Default size
//            //        .frame(minWidth: 350, maxWidth: 350, minHeight: 450, maxHeight: 450)
//            .background(Color.theme.pgray)
//            .cornerRadius(15)
//            .shadow(radius: 5)
//            
//            Text(" Task Bubble")
//                .font(.system(size: 19, weight: .semibold))
//        }
//    }
//}
//    
//#Preview(traits: .sizeThatFitsLayout) {
//        TaskBubbleView()
//}

//-------------------------------------------------------------------

import SwiftUI

//MARK: Task model and task details
struct Task: Identifiable {
    let id: UUID
    var text: String
    var category: String
    var completed: Bool
    var appIcon: String?
    var dueDate: Date
    var priority: Int
}

// MARK: Category Model
struct Category {
    let name: String
    let color: Color
}

// MARK: Categories for the dashboard
let categories = [
    Category(name: "Goals", color: Color("plilac")),
    Category(name: "Daily To-Do", color: Color("psage")),
    Category(name: "Weekly Tasks", color: Color("pblue")),
    Category(name: "Routine", color: Color("ppink"))
]

let appIcons: [(names: String, icon: String)] = [
    ("Safari", "🌐"),
    ("Notes", "📝"),
    ("Calendar", "📆"),
    ("Mail", "💌"),
    ("Messages", "💬")
]

// MARK: - TaskBubbleView
struct TaskBubbleView: View {
    @State private var tasks: [Task] = []
    @Environment(\.colorScheme) var colorScheme // Detect light/dark mode
    @State private var isDarkMode: Bool = false
    @State private var newTaskText: String = ""
    @State private var activeCategory: String = "Goals"
    @State private var selectedAppIcon: String? = nil
    @State private var sortOption: String = "Default"
    @State private var waterIntake: Int = 0
    @State private var confetti: Bool = false
    

    var body: some View {
        ZStack {
            // Background color
            (isDarkMode ? Color("darkbg") : Color("lightbg"))
                            .edgesIgnoringSafeArea(.all)

            VStack(alignment: .leading, spacing: 14) {
                // Header
                HStack(alignment: .top, spacing: 12) {
                    Text("🫧")
                        .font(.system(size: 26))
                        .offset(x: 2, y: -2)
                    Text("Task Bubble")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(isDarkMode ? .black : .white) // WHY IS THIS NOT WORKING??
                        .offset(x: -6)
                }
                .padding(.top)

                // Categories (Bubbles)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(categories, id: \.name) { category in
                            Text(category.name)
                                .font(.system(size: 14, weight: .medium))
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(category.color)
                                .foregroundColor(isDarkMode ? .white : .black)
                                .cornerRadius(16)
                                .shadow(radius: 2)
                        }
                    }
                    .padding(.horizontal)
                }
                // Spacer for now (to expand later)
                Spacer()
                
                // Add new tasks
                HStack {
                    TextField("Add a new task...", text: $newTaskText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                    
                    Button(action: addTask) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(Color.blue)
                    }
                }
                
                Spacer()
                
                // Water Intake
                HStack{
                    Button(action: { waterTracker() }) {
                        Image(systemName: "drop.fill")
                            .font(.title2)
                            .foregroundColor(Color.blue)
                    }
                    
                    Text("\(waterIntake)/8 Glasses")
                        .font(.caption)
                        .foregroundColor(isDarkMode ? .white : .black)
                }
            }
            .padding()
        }
    }
    
    //write your functions in here (within the TaskBubbleView struct)
    //functions you will need...
    // - addTask
    // - taskDoneToggle
    // - deleteTask
    // - Confetti
    // - waterIntake
    // - sort Tasks
    // - DarkModeToggle
    
    // Add Task
    private func addTask() {
        guard !newTaskText.isEmpty else {return}
        let newTask = Task(
            id: UUID(),
            text: newTaskText,
            category: activeCategory,
            completed: false,
            appIcon: selectedAppIcon,
            dueDate: Date(),
            priority: 0
        )
        tasks.append(newTask)
        newTaskText = ""
        selectedAppIcon = nil
    }
    
    // Task Completion Toggle
    private func toggleTaskDone(_ task: Task) {
        if let i = tasks.firstIndex(where: { $0.id == task.id }) { tasks[i].completed.toggle()
        }
    }
    
    // Delete Tasks
    private func deleteTask(_ task: Task) {
        tasks.removeAll { $0.id == task.id }
    }
    
    // Sort Tasks
    private func sortTasks() -> [Task] {
        switch sortOption {
        case "Alphabetical":
            return tasks.sorted { $0.text < $1.text }
        case "Due Date":
            return tasks.sorted { $0.dueDate < $1.dueDate }
        case "Priority":
            return tasks.sorted { $0.priority < $1.priority }
        default:
            return tasks
        }
    }
    private func waterTracker() {
        waterIntake = min(waterIntake + 1, 8)
    }
}

// MARK: - Preview
#Preview {
    TaskBubbleView()
}
