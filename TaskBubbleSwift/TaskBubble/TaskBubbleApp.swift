//
//
//import AppKit
//import SwiftUI
//
//@main
//struct TaskBubbleApp: App {
//    let persistenceController = PersistenceController.shared
//
//    var body: some Scene {
//        WindowGroup {
//            mainContent
//                .background(FloatingWindowAttacher())
//                .onAppear {
//                    window_size()
//                }
//        }
//        .windowStyle(.hiddenTitleBar)
//        .windowResizability(.contentSize)
//
//        MenuBarExtra {
//            mainContent
//        } label: {
//            Image(systemName: "checklist")
//                .renderingMode(.template)
//        }
//        .menuBarExtraStyle(.window)
//    }
//
//    @ViewBuilder
//    private var mainContent: some View {
//        ContentView()
//            .environment(\.managedObjectContext, persistenceController.container.viewContext)
//            .frame(width: 356, height: 422)
//    }
//
//    func window_size() {
//        if let window = NSApplication.shared.windows.first {
//            window.setContentSize(NSSize(width: 356, height: 422))
//            window.styleMask.remove(.resizable)
//            window.titleVisibility = .hidden
//            window.titlebarAppearsTransparent = true
//            window.isOpaque = true
//            window.backgroundColor = NSColor(Color.Surface.a0)
//            window.styleMask.insert(.fullSizeContentView)
//            window.isMovableByWindowBackground = true
//            window.standardWindowButton(.closeButton)?.isHidden = true
//            window.standardWindowButton(.miniaturizeButton)?.isHidden = true
//            window.standardWindowButton(.zoomButton)?.isHidden = true
//        }
//    }
//}
//
//private struct FloatingWindowAttacher: NSViewRepresentable {
//    func makeNSView(context: Context) -> NSView {
//        FloatingAnchorView()
//    }
//    func updateNSView(_ nsView: NSView, context: Context) {}
//}
//
//private final class FloatingAnchorView: NSView {
//    override func viewDidMoveToWindow() {
//        super.viewDidMoveToWindow()
//        window?.level = .floating
//    }
//}


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
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)

        MenuBarExtra {
            mainContent
        } label: {
            Image(systemName: "checklist")
                .renderingMode(.template)
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
            window.styleMask.remove(.resizable)
            window.titleVisibility = .hidden
            window.titlebarAppearsTransparent = true
            window.isOpaque = true
            window.backgroundColor = NSColor(Color.Surface.a0)
            window.styleMask.insert(.fullSizeContentView)
            window.isMovableByWindowBackground = true
            window.standardWindowButton(.closeButton)?.isHidden = true
            window.standardWindowButton(.miniaturizeButton)?.isHidden = true
            window.standardWindowButton(.zoomButton)?.isHidden = true
        }
    }
}

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
