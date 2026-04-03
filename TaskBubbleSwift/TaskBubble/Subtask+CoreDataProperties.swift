import Foundation
import CoreData

extension Subtask {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Subtask> {
        return NSFetchRequest<Subtask>(entityName: "Subtask")
    }

    @NSManaged public var sortOrder: Int16
    @NSManaged public var linkedResourceType: String?
    @NSManaged public var linkedResourceValue: String?
    @NSManaged public var linkedResourceAppDisplayName: String?
    @NSManaged public var parent: Item?

}

extension Subtask: Identifiable {
    public var id: NSManagedObjectID { objectID }
}
