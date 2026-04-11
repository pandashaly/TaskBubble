//
//  GoalCoreData.swift
//  TaskBubble
//
//  Created by Shalyca Sottoriva on 11/04/2026.
//

// Goal+CoreData.swift
// TaskBubble
//
// SETUP STEPS:
// 1. In TaskBubble.xcdatamodeld, click the Goal entity
// 2. In the Data Model Inspector (right panel), set Codegen to "Manual/None"
// 3. This file provides the class and all helpers manually.
//
// Goal entity attributes in xcdatamodeld:
//   id                              UUID         optional
//   name                            String       optional
//   notes                           String       optional
//   colorHex                        String       optional
//   deadline                        Date         optional
//   coverImageData                  Binary Data  optional  (tick "Allows External Storage")
//   timestamp                       Date         optional
//   priority                        Integer 16   optional  default 0
//   linkedResourceType              String       optional
//   linkedResourceValue             String       optional
//   linkedResourceAppDisplayName    String       optional
//
// Relationships:
//   tasks    To-Many  → Item     inverse: goal    delete: Nullify
//   projects To-Many  → Project  inverse: goals   delete: Nullify
//
// Also on Item entity:   add relationship "goal"    To-One → Goal    optional, Nullify
// Also on Project entity: add relationship "goals"  To-Many → Goal   optional, Nullify

import CoreData
import Foundation
import SwiftUI

@objc(Goal)
public class Goal: NSManagedObject {}

extension Goal {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Goal> {
        NSFetchRequest<Goal>(entityName: "Goal")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var name: String?
    @NSManaged public var notes: String?
    @NSManaged public var colorHex: String?
    @NSManaged public var deadline: Date?
    @NSManaged public var coverImageData: Data?
    @NSManaged public var timestamp: Date?
    @NSManaged public var priority: Int16
    @NSManaged public var linkedResourceType: String?
    @NSManaged public var linkedResourceValue: String?
    @NSManaged public var linkedResourceAppDisplayName: String?
    @NSManaged public var tasks: NSSet?
    @NSManaged public var projects: NSSet?
}

extension Goal: Identifiable {}

extension Goal {
    /// Resolves the stored hex to a Color, falling back to green.
    var displayColor: Color {
        guard let hex = colorHex else { return Color.Green.normal }
        return Color(hex: hex)
    }

    var taskArray: [Item] {
        (tasks as? Set<Item> ?? [])
            .sorted { ($0.timestamp ?? .distantPast) < ($1.timestamp ?? .distantPast) }
    }

    var taskCount: Int { tasks?.count ?? 0 }

    var completedCount: Int { taskArray.filter { $0.completed }.count }

    var progress: Double {
        guard taskCount > 0 else { return 0 }
        return Double(completedCount) / Double(taskCount)
    }

    var priorityEnum: TaskPriority {
        TaskPriority(rawValue: priority) ?? .low
    }
}

// MARK: - Colour swatches for goal colour picker (reuses ProjectPalette)

struct GoalPalette {
    static let swatches: [(hex: String, color: Color)] = [
        ("#6CD985", Color.Green.normal),
        ("#6CD9BC", Color.Teal.normal),
        ("#6CC0D9", Color.water),
        ("#BC6CD9", Color.Purple.normal),
        ("#D96CC0", Color.Pink.normal),
        ("#D9BC6C", Color.Gold.normal),
        ("#D9856C", Color.Orange.normal),
        ("#856CD9", Color.Purple.dark),
    ]
}
