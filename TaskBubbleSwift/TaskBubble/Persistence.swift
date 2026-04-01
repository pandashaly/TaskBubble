import CoreData

public struct PersistenceController {
    public static let shared = PersistenceController()

    public static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        for i in 0..<5 {
            let newItem = Item(context: viewContext)
            newItem.timestamp = Date()
            newItem.title = "Sample Task \(i)"
            newItem.category = TaskCategory.daily.rawValue
            newItem.completed = false
            newItem.deadline = Date()
        }
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            print("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    public let container: NSPersistentCloudKitContainer

    public init(inMemory: Bool = false) {
        // Explicitly load the model to avoid "model not found" crashes
        guard let modelURL = Bundle.main.url(forResource: "TaskBubble", withExtension: "momd"),
              let model = NSManagedObjectModel(contentsOf: modelURL) else {
            fatalError("Unable to find TaskBubble.momd in main bundle")
        }
        
        container = NSPersistentCloudKitContainer(name: "TaskBubble", managedObjectModel: model)
        
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                
                // If migration fails, we can delete the store and try again (Development only!)
                print("Core Data failed to load: \(error). Attempting to reset store...")
                if let url = storeDescription.url {
                    try? FileManager.default.removeItem(at: url)
                    // Try loading again after deletion
                    PersistenceController.shared.container.loadPersistentStores { _, retryError in
                        if let retryError = retryError {
                            fatalError("Unresolved error after reset: \(retryError)")
                        }
                    }
                }
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }
}
