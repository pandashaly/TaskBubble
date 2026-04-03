import Foundation
import CoreData

extension WaterIntake {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<WaterIntake> {
        return NSFetchRequest<WaterIntake>(entityName: "WaterIntake")
    }

    @NSManaged public var count: Int32
    @NSManaged public var date: Date?

}

extension WaterIntake : Identifiable {

}
