import Foundation
import SwiftUI

// MARK: - Task Category
public enum TaskCategory: String, CaseIterable, Identifiable, Codable {
    case goals = "Goals"
    case daily = "Daily To-Do"
    case weekly = "Weekly Tasks"
    case routine = "Routine"
    
    public var id: String { self.rawValue }
    
    public var color: Color {
        switch self {
        case .goals: return Color("plilac")
        case .daily: return Color("psage")
        case .weekly: return Color("pblue")
        case .routine: return Color("ppink")
        }
    }
}

// MARK: - Task Priority
public enum TaskPriority: Int16, CaseIterable, Identifiable, Codable {
    case low = 0
    case medium = 1
    case high = 2
    
    public var id: Int16 { self.rawValue }
    
    public var displayName: String {
        switch self {
        case .low: return "Low"
        case .medium: return "Medium"
        case .high: return "High"
        }
    }
    
    public var color: Color {
        switch self {
        case .low: return .blue
        case .medium: return .orange
        case .high: return .red
        }
    }
}

// MARK: - Sort Option
public enum TaskSortOption: String, CaseIterable, Identifiable {
    case alphabetical = "Alphabetical"
    case dueDate = "Due Date"
    case priority = "Priority"
    case timestamp = "Created"
    
    public var id: String { self.rawValue }
}

// MARK: - Linked Resource
public enum LinkedResourceType: String, Codable {
    case app = "App"
    case url = "URL"
}

public struct LinkedResource: Codable {
    public var type: LinkedResourceType
    public var value: String // Bundle ID for apps, URL string for links
    public var displayName: String?
    
    public init(type: LinkedResourceType, value: String, displayName: String? = nil) {
        self.type = type
        self.value = value
        self.displayName = displayName
    }
}

// MARK: - Task Model (for non-CoreData use or mapping)
public struct TaskItem: Identifiable {
    public let id: UUID
    public var title: String
    public var category: TaskCategory
    public var deadline: Date?
    public var completed: Bool
    public var priority: TaskPriority
    public var resource: LinkedResource?
    
    public init(id: UUID = UUID(), title: String, category: TaskCategory, deadline: Date? = nil, completed: Bool = false, priority: TaskPriority = .medium, resource: LinkedResource? = nil) {
        self.id = id
        self.title = title
        self.category = category
        self.deadline = deadline
        self.completed = completed
        self.priority = priority
        self.resource = resource
    }
}

