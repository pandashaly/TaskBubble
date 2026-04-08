import AppKit
import SwiftUI

@main
struct TaskBubbleApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            mainContent
                .background(FloatingWindowAttacher())
                .onAppear {
                    window_size()
                }
        }
        .windowStyle(.hiddenTitleBar) // Remove title bar for more space
        .windowResizability(.contentSize) // Keep it fixed to content size

        MenuBarExtra("TaskBubble", systemImage: "checklist") {
            mainContent
        }
        .menuBarExtraStyle(.window)
    }

    @ViewBuilder
    private var mainContent: some View {
        ContentView()
            .environment(\.managedObjectContext, persistenceController.container.viewContext)
            .frame(width: 356, height: 422)
    }

    func window_size() {
        if let window = NSApplication.shared.windows.first {
            window.setContentSize(NSSize(width: 356, height: 422))
            window.styleMask.remove(.resizable) // Disable resizing
            window.titleVisibility = .hidden // Hide title
            window.titlebarAppearsTransparent = true
            window.backgroundColor = NSColor(Color.Surface.a0)
            //------
            window.styleMask.insert(.fullSizeContentView)
            window.isMovableByWindowBackground = true
            window.standardWindowButton(.closeButton)?.isHidden = true
            window.standardWindowButton(.miniaturizeButton)?.isHidden = true
            window.standardWindowButton(.zoomButton)?.isHidden = true
        }
    }
}

// Pins NSWindow.Level.floating to the hosting window only (avoids touching the menu-bar panel).
private struct FloatingWindowAttacher: NSViewRepresentable {
    func makeNSView(context: Context) -> NSView {
        FloatingAnchorView()
    }

    func updateNSView(_ nsView: NSView, context: Context) {}
}

private final class FloatingAnchorView: NSView {
    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        window?.level = .floating
    }
}
