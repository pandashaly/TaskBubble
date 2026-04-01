import SwiftUI

@main
struct TaskBubbleApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .frame(width: 370, height: 450) // Original fixed size
                .onAppear {
                    window_size()
                }
        }
        .windowStyle(.hiddenTitleBar) // Remove title bar for more space
        .windowResizability(.contentSize) // Keep it fixed to content size
    }

    func window_size() {
        if let window = NSApplication.shared.windows.first {
            window.setContentSize(NSSize(width: 370, height: 450))
            window.styleMask.remove(.resizable) // Disable resizing
            window.titleVisibility = .hidden // Hide title
            window.titlebarAppearsTransparent = true
        }
    }
}
