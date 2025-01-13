//
//  TaskBubbleApp.swift
//  TaskBubble
//
//  Created by Bocal on 03/01/2025.
//

import SwiftUI

@main
struct TaskBubbleApp: App {
    var body: some Scene {
        WindowGroup {
            TaskBubbleView()
                .frame(width: 370, height: 220)
                .onAppear {
                    window_size()
                }
        }
    }

    func window_size() {
        // Get the current window
        if let window = NSApplication.shared.windows.first {
            window.setContentSize(NSSize(width: 370, height: 220)) // Match your default size
            window.styleMask.remove(.resizable) // Disable resizing (optional)
        }
    }
}
