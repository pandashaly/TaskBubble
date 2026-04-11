// Item+CoreDataProperties.swift
// TaskBubble
//
// ⚠️ Also update TaskBubble.xcdatamodeld to add:
//   todayDate   Date        optional
//   todayOrder  Integer 32  optional, default 0
//   goal        Relationship → Goal (To-One, optional, Nullify)
// Item+CoreDataProperties.swift
// TaskBubble
//

import Foundation
import CoreData

extension Item {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Item> {
        return NSFetchRequest<Item>(entityName: "Item")
    }

    @NSManaged public var timestamp: Date?
    @NSManaged public var title: String?
    @NSManaged public var category: String?
    @NSManaged public var completed: Bool
    @NSManaged public var deadline: Date?
    @NSManaged public var priority: Int16
    @NSManaged public var linkedResourceType: String?
    @NSManaged public var linkedResourceValue: String?
    @NSManaged public var linkedResourceAppDisplayName: String?
    @NSManaged public var notes: String?
    @NSManaged public var subtasks: NSSet?

    // Today view
    @NSManaged public var todayDate: Date?
    @NSManaged public var todayOrder: Int32
}

extension Item: Identifiable {}
