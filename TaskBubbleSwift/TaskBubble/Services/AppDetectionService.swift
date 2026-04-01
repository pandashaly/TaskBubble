import Foundation
import AppKit
import SwiftUI

public struct DetectedApp: Identifiable, Hashable {
    public let id: String // Bundle Identifier or Path
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
            let fileManager = FileManager.default
            
            var detectedApps: [DetectedApp] = []
            
            // Comprehensive list of application directories to scan
            let searchPaths = [
                URL(fileURLWithPath: "/Applications"),
                URL(fileURLWithPath: "/System/Applications"),
                URL.homeDirectory.appendingPathComponent("Applications"),
                // Specific location for Safari Web Apps (macOS Sonoma and later)
                URL.homeDirectory.appendingPathComponent("Applications/Web Apps"),
                // Legacy or alternative Safari Web App locations
                URL.homeDirectory.appendingPathComponent("Library/Containers/com.apple.Safari/Data/Library/WebApps")
            ]
            
            for path in searchPaths {
                guard fileManager.fileExists(atPath: path.path) else { continue }
                
                // Use a shallow scan first for speed, then deeper if needed
                if let contents = try? fileManager.contentsOfDirectory(at: path, includingPropertiesForKeys: [.isApplicationKey], options: [.skipsHiddenFiles]) {
                    for fileURL in contents {
                        if fileURL.pathExtension == "app" {
                            self.processAppBundle(at: fileURL, into: &detectedApps)
                        } else if fileURL.hasDirectoryPath {
                            // Shallow scan one level deeper for folders like "Web Apps"
                            if let subContents = try? fileManager.contentsOfDirectory(at: fileURL, includingPropertiesForKeys: [.isApplicationKey], options: [.skipsHiddenFiles]) {
                                for subURL in subContents where subURL.pathExtension == "app" {
                                    self.processAppBundle(at: subURL, into: &detectedApps)
                                }
                            }
                        }
                    }
                }
            }
            
            DispatchQueue.main.async {
                // Remove duplicates based on bundle ID or path
                var uniqueApps: [String: DetectedApp] = [:]
                for app in detectedApps {
                    uniqueApps[app.id] = app
                }
                
                self.installedApps = Array(uniqueApps.values).sorted { $0.displayName.localizedCompare($1.displayName) == .orderedAscending }
                self.isLoading = false
            }
        }
    }
    
    private func processAppBundle(at fileURL: URL, into apps: inout [DetectedApp]) {
        if let bundle = Bundle(url: fileURL) {
            let bundleIdentifier = bundle.bundleIdentifier ?? fileURL.path
            
            let displayName = bundle.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String ??
                              bundle.object(forInfoDictionaryKey: "CFBundleName") as? String ??
                              fileURL.deletingPathExtension().lastPathComponent
            
            let icon = NSWorkspace.shared.icon(forFile: fileURL.path)
            
            // Filter out system packages but keep user-facing apps and web apps
            if !bundleIdentifier.starts(with: "com.apple.pkg.") {
                apps.append(DetectedApp(
                    id: bundleIdentifier,
                    displayName: displayName,
                    icon: icon,
                    appURL: fileURL
                ))
            }
        }
    }
    
    public func launchApp(bundleIdentifier: String) {
        // Try launching by bundle identifier first
        if let appURL = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleIdentifier) {
            let configuration = NSWorkspace.OpenConfiguration()
            NSWorkspace.shared.openApplication(at: appURL, configuration: configuration) { _, error in
                if let error = error {
                    print("Error launching app by ID: \(error.localizedDescription)")
                }
            }
        } else if FileManager.default.fileExists(atPath: bundleIdentifier) {
            // Fallback: Try launching by path (useful for some web apps)
            let appURL = URL(fileURLWithPath: bundleIdentifier)
            let configuration = NSWorkspace.OpenConfiguration()
            NSWorkspace.shared.openApplication(at: appURL, configuration: configuration) { _, error in
                if let error = error {
                    print("Error launching app by path: \(error.localizedDescription)")
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
        } else if FileManager.default.fileExists(atPath: bundleIdentifier) {
            return NSWorkspace.shared.icon(forFile: bundleIdentifier)
        }
        return nil
    }
}

