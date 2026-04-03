import Foundation
import CoreData
import SwiftUI

class WaterIntakeService: ObservableObject {
    @Published var currentIntake: Int = 0
    private let viewContext: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.viewContext = context
        refreshCurrentIntake()
    }
    
    /// Returns the "tracking day" for a given date.
    /// A tracking day starts at 4:00 AM.
    func trackingDay(for date: Date) -> Date {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day, .hour], from: date)
        
        if let hour = components.hour, hour < 4 {
            // If it's before 4 AM, it belongs to the previous calendar day
            let previousDay = calendar.date(byAdding: .day, value: -1, to: date)!
            components = calendar.dateComponents([.year, .month, .day], from: previousDay)
        } else {
            components = calendar.dateComponents([.year, .month, .day], from: date)
        }
        
        return calendar.date(from: components)!
    }
    
    func refreshCurrentIntake() {
        let today = trackingDay(for: Date())
        currentIntake = fetchIntake(for: today)
    }
    
    func fetchIntake(for date: Date) -> Int {
        let request: NSFetchRequest<WaterIntake> = WaterIntake.fetchRequest()
        request.predicate = NSPredicate(format: "date == %@", date as NSDate)
        
        do {
            let results = try viewContext.fetch(request)
            return Int(results.first?.count ?? 0)
        } catch {
            print("Error fetching water intake: \(error)")
            return 0
        }
    }
    
    func updateIntake(delta: Int) {
        let today = trackingDay(for: Date())
        let request: NSFetchRequest<WaterIntake> = WaterIntake.fetchRequest()
        request.predicate = NSPredicate(format: "date == %@", today as NSDate)
        
        do {
            let results = try viewContext.fetch(request)
            let intake: WaterIntake
            if let existing = results.first {
                intake = existing
            } else {
                intake = WaterIntake(context: viewContext)
                intake.date = today
            }
            
            intake.count = Int32(max(0, Int(intake.count) + delta))
            try viewContext.save()
            currentIntake = Int(intake.count)
        } catch {
            print("Error updating water intake: \(error)")
        }
    }
    
    func resetIntake() {
        let today = trackingDay(for: Date())
        let request: NSFetchRequest<WaterIntake> = WaterIntake.fetchRequest()
        request.predicate = NSPredicate(format: "date == %@", today as NSDate)
        
        do {
            let results = try viewContext.fetch(request)
            if let existing = results.first {
                existing.count = 0
                try viewContext.save()
                currentIntake = 0
            }
        } catch {
            print("Error resetting water intake: \(error)")
        }
    }
}
