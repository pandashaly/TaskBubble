//
//  AppSelector.swift
//  TaskBubble
//
//  Created by Shalyca Sottoriva on 10/04/2026.
//
import SwiftUI

struct AppLinkSelector: View {
    // These sync the state with whichever screen you're on
    @Binding var selectedApp: DetectedApp?
    @Binding var showAppPicker: Bool
    @Binding var linkURL: String
    
    // The service to trigger the app loading
    @ObservedObject var appDetectionService: AppDetectionService
    
    // Internal state so the main view doesn't have to manage hover logic
    @State private var isHovering: Bool = false
    
    var body: some View {
        Button(action: {
            appDetectionService.loadInstalledApplications()
            showAppPicker = true
        }) {
            Group {
                // Priority 1: Show the selected App Icon
                if let app = selectedApp {
                    Image(nsImage: app.icon)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                }
                // Priority 2: Show the Link Icon if a URL exists
                else if !linkURL.isEmpty {
                    LinkIconView(link: linkURL)
                        .frame(width: 24, height: 24)
                }
                // Priority 3: Default fallback icon
                else {
                    Image(systemName: "app.badge")
                        .font(.title3)
                        .foregroundColor(AppColors.shalyPurple)
                }
            }
        }
        .buttonStyle(AppIconButtonStyle(isHovering: isHovering))
        .onHover { isHovering = $0 }
    }
}

//how to use

//HStack {
//    // Your standalone picker
//    AppLinkSelector(
//        selectedApp: $selectedApp,
//        showAppPicker: $showAppPicker,
//        linkURL: $linkURL,
//        appDetectionService: appDetectionService
//    )
//    
//    // ... whatever else you want next to it ...
//}
