//
//  Project+CoreData.swift
//  TaskBubble
//
//  Created by Shalyca Sottoriva on 10/04/2026.
//

// Project+CoreData.swift
// TaskBubble
//
// Add a "Project" entity to your TaskBubble.xcdatamodeld with these attributes:
//   id            : UUID
//   name          : String
//   notes         : String  (optional)
//   colorHex      : String  (optional)  e.g. "#BC6CD9"
//   deadline      : Date    (optional)
//   priority      : Integer 16
//   timestamp     : Date    (optional)
//   linkedResourceType     : String (optional)
//   linkedResourceValue    : String (optional)
//   linkedResourceAppDisplayName : String (optional)
//
// Then add a To-Many relationship "tasks" → Item (inverse: "project" on Item)
// and a To-One relationship "project" on Item → Project (optional, nullify)

import CoreData
import Foundation

@objc(Project)
public class Project: NSManagedObject {}

extension Project {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Project> {
        NSFetchRequest<Project>(entityName: "Project")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var name: String?
    @NSManaged public var notes: String?
    @NSManaged public var colorHex: String?
    @NSManaged public var deadline: Date?
    @NSManaged public var priority: Int16
    @NSManaged public var timestamp: Date?
    @NSManaged public var linkedResourceType: String?
    @NSManaged public var linkedResourceValue: String?
    @NSManaged public var linkedResourceAppDisplayName: String?
    @NSManaged public var tasks: NSSet?
}

extension Project: Identifiable {}

// MARK: - Convenience helpers

extension Project {

    /// Colour from the stored hex, falling back to the app accent.
    var color: Color {
        guard let hex = colorHex else { return Color.Primary.a0 }
        return Color(hex: hex)
    }

    var taskArray: [Item] {
        let set = tasks as? Set<Item> ?? []
        return set.sorted { ($0.timestamp ?? .distantPast) < ($1.timestamp ?? .distantPast) }
    }

    var taskCount: Int { tasks?.count ?? 0 }

    var completedCount: Int {
        taskArray.filter { $0.completed }.count
    }

    var progress: Double {
        guard taskCount > 0 else { return 0 }
        return Double(completedCount) / Double(taskCount)
    }

    var priorityEnum: TaskPriority {
        TaskPriority(rawValue: priority) ?? .low
    }
}

// MARK: - Palette swatches for the colour picker

import SwiftUI

struct ProjectPalette {
    static let swatches: [(hex: String, color: Color)] = [
        ("#BC6CD9", Color.Purple.normal),
        ("#856CD9", Color.Purple.dark),
        ("#D96CC0", Color.Pink.normal),
        ("#D9856C", Color.Orange.normal),
        ("#D9BC6C", Color.Gold.normal),
        ("#6CD985", Color.Green.normal),
        ("#6CD9BC", Color.Teal.normal),
        ("#6CC0D9", Color.water),
    ]
}
