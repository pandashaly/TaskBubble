import Foundation
import AppKit
import SwiftUI

public struct DetectedApp: Identifiable, Hashable {
    public let id: String // Bundle Identifier
    public let displayName: String
    public let icon: NSImage
    public let appURL: URL
    
    public init(id: String, displayName: String, icon: NSImage, appURL: URL) {
        self.id = id
        self.displayName = displayName
        self.icon = icon
        self.appURL = appURL
    }
}

public class AppDetectionService: ObservableObject {
    @Published public var installedApps: [DetectedApp] = []
    @Published public var isLoading: Bool = false
    
    public init() {
        loadInstalledApplications()
    }
    
    public func loadInstalledApplications() {
        self.isLoading = true
        DispatchQueue.global(qos: .userInitiated).async {
            let workspace = NSWorkspace.shared
            let applicationsURL = URL(fileURLWithPath: "/Applications")
            let fileManager = FileManager.default
            
            var detectedApps: [DetectedApp] = []
            
            // Search /Applications and /System/Applications
            let searchPaths = [applicationsURL, URL(fileURLWithPath: "/System/Applications")]
            
            for path in searchPaths {
                if let enumerator = fileManager.enumerator(at: path, includingPropertiesForKeys: [.isApplicationKey], options: [.skipsPackageDescendants, .skipsHiddenFiles]) {
                    for case let fileURL as URL in enumerator {
                        if fileURL.pathExtension == "app" {
                            if let bundle = Bundle(url: fileURL),
                               let bundleIdentifier = bundle.bundleIdentifier {
                                
                                let displayName = bundle.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String ?? 
                                                  bundle.object(forInfoDictionaryKey: "CFBundleName") as? String ?? 
                                                  fileURL.deletingPathExtension().lastPathComponent
                                
                                let icon = workspace.icon(forFile: fileURL.path)
                                
                                // Basic filter for user-facing apps
                                if !bundleIdentifier.starts(with: "com.apple.pkg.") {
                                    detectedApps.append(DetectedApp(
                                        id: bundleIdentifier,
                                        displayName: displayName,
                                        icon: icon,
                                        appURL: fileURL
                                    ))
                                }
                            }
                        }
                    }
                }
            }
            
            DispatchQueue.main.async {
                self.installedApps = detectedApps.sorted { $0.displayName.localizedCompare($1.displayName) == .orderedAscending }
                self.isLoading = false
            }
        }
    }
    
    public func launchApp(bundleIdentifier: String) {
        if let appURL = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleIdentifier) {
            let configuration = NSWorkspace.OpenConfiguration()
            NSWorkspace.shared.openApplication(at: appURL, configuration: configuration) { _, error in
                if let error = error {
                    print("Error launching app: \(error.localizedDescription)")
                }
            }
        }
    }
    
    public func openURL(_ urlString: String) {
        if let url = URL(string: urlString) {
            NSWorkspace.shared.open(url)
        }
    }
    
    public func getIcon(for bundleIdentifier: String) -> NSImage? {
        if let appURL = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleIdentifier) {
            return NSWorkspace.shared.icon(forFile: appURL.path)
        }
        return nil
    }
}
