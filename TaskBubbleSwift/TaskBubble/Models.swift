//import Foundation
//import SwiftUI
//
//// MARK: - Task Category
//
//public enum TaskCategory: String, CaseIterable, Identifiable {
//    case today = "Today"
//    case goals = "Goals"
//    case projects = "Projects"
//    case allTasks = "All Tasks"
//    
//    public var id: String { rawValue }
//    
//    public var icon: String {
//        switch self {
//        case .today:
//            return "sun.max"
//        case .goals:
//            return "target"
//        case .projects:
//            return "folder.fill"
//        case .allTasks:
//            return "tray.full"
//        }
//    }
//    
//    public var color: Color {
//        switch self {
//        case .today:
//            return .blue
//        case .goals:
//            return .green
//        case .projects:
//            return .orange
//        case .allTasks:
//            return .purple
//        }
//    }
//
//    /// Categories available when assigning a label (excludes aggregate "All Tasks").
//    public static var assignableCategories: [TaskCategory] {
//        [.today, .goals, .projects]
//    }
//}
//
//
//// MARK: - Task Priority
//public enum TaskPriority: Int16, CaseIterable, Identifiable, Codable {
//    case low = 0
//    case medium = 1
//    case high = 2
//    
//    public var id: Int16 { self.rawValue }
//    
//    public var displayName: String {
//        switch self {
//        case .low: return "Low"
//        case .medium: return "Medium"
//        case .high: return "High"
//        }
//    }
//
//    /// Short labels for compact UI (e.g. pill buttons).
//    public var shortLabel: String {
//        switch self {
//        case .low: return "Low"
//        case .medium: return "Mid"
//        case .high: return "High"
//        }
//    }
//    
//    public var color: Color {
//        switch self {
//        case .low: return .blue
//        case .medium: return .orange
//        case .high: return .red
//        }
//    }
//}
//
//// MARK: - Sort Option
//public enum TaskSortOption: String, CaseIterable, Identifiable {
//    case alphabetical = "Alphabetical"
//    case dueDate = "Due Date"
//    case priority = "Priority"
//    case timestamp = "Created"
//    
//    public var id: String { self.rawValue }
//}
//
//// MARK: - Linked Resource
//public enum LinkedResourceType: String, Codable {
//    case app = "App"
//    case url = "URL"
//}
//
//public struct LinkedResource: Codable {
//    public var type: LinkedResourceType
//    public var value: String // Bundle ID for apps, URL string for links
//    public var displayName: String?
//    
//    public init(type: LinkedResourceType, value: String, displayName: String? = nil) {
//        self.type = type
//        self.value = value
//        self.displayName = displayName
//    }
//}
//
//// MARK: - Subtask draft (add/edit form)
//
//public struct SubtaskDraft: Identifiable, Equatable {
//    public let id: UUID
//    public var title: String
//
//    public init(
//        id: UUID = UUID(),
//        title: String = ""
//    ) {
//        self.id = id
//        self.title = title
//    }
//
//    public static func == (lhs: SubtaskDraft, rhs: SubtaskDraft) -> Bool {
//        lhs.id == rhs.id && lhs.title == rhs.title
//    }
//}
//
//// MARK: - Task Model (for non-CoreData use or mapping)
//public struct TaskItem: Identifiable {
//    public let id: UUID
//    public var title: String
//    public var category: TaskCategory
//    public var deadline: Date?
//    public var completed: Bool
//    public var priority: TaskPriority
//    public var resource: LinkedResource?
//    
//    public init(id: UUID = UUID(), title: String, category: TaskCategory, deadline: Date? = nil, completed: Bool = false, priority: TaskPriority = .medium, resource: LinkedResource? = nil) {
//        self.id = id
//        self.title = title
//        self.category = category
//        self.deadline = deadline
//        self.completed = completed
//        self.priority = priority
//        self.resource = resource
//    }
//}
//


import Foundation
import SwiftUI

public enum TaskCategory: String, CaseIterable, Identifiable {
    case today = "Today", goals = "Goals", routine = "Routine"
    case projects = "Projects", allTasks = "All Tasks"
    public var id: String { rawValue }
    public var icon: String {
        switch self {
        case .today: return "sun.max"; case .goals: return "target"
        case .routine: return "repeat"; case .projects: return "folder.fill"
        case .allTasks: return "tray.full"
        }
    }
    public var color: Color {
        switch self {
        case .today: return .blue; case .goals: return .green
        case .routine: return .orange; case .projects: return Color.Purple.normal
        case .allTasks: return Color.Primary.a0
        }
    }
    public static var assignableCategories: [TaskCategory] { [.today, .goals, .routine] }
}

public enum TaskPriority: Int16, CaseIterable, Identifiable, Codable {
    case low = 0, medium = 1, high = 2
    public var id: Int16 { rawValue }
    public var displayName: String {
        switch self { case .low: return "Low"; case .medium: return "Medium"; case .high: return "High" }
    }
    public var shortLabel: String {
        switch self { case .low: return "Low"; case .medium: return "Mid"; case .high: return "High" }
    }
    public var color: Color {
        switch self { case .low: return .blue; case .medium: return .orange; case .high: return .red }
    }
}

public enum TaskSortOption: String, CaseIterable, Identifiable {
    case alphabetical = "Alphabetical", dueDate = "Due Date", priority = "Priority", timestamp = "Created"
    public var id: String { rawValue }
}

public enum LinkedResourceType: String, Codable { case app = "App", url = "URL" }

public struct LinkedResource: Codable {
    public var type: LinkedResourceType; public var value: String; public var displayName: String?
    public init(type: LinkedResourceType, value: String, displayName: String? = nil) {
        self.type = type; self.value = value; self.displayName = displayName
    }
}

public struct SubtaskDraft: Identifiable, Equatable {
    public let id: UUID; public var title: String
    public init(id: UUID = UUID(), title: String = "") { self.id = id; self.title = title }
    public static func == (lhs: SubtaskDraft, rhs: SubtaskDraft) -> Bool { lhs.id == rhs.id && lhs.title == rhs.title }
}

public struct TaskItem: Identifiable {
    public let id: UUID; public var title: String; public var category: TaskCategory
    public var deadline: Date?; public var completed: Bool; public var priority: TaskPriority; public var resource: LinkedResource?
    public init(id: UUID = UUID(), title: String, category: TaskCategory, deadline: Date? = nil,
                completed: Bool = false, priority: TaskPriority = .medium, resource: LinkedResource? = nil) {
        self.id = id; self.title = title; self.category = category; self.deadline = deadline
        self.completed = completed; self.priority = priority; self.resource = resource
    }
}
