import SwiftUI

struct QuickAddTaskView: View {
    @Binding var newTaskTitle: String
    @Binding var selectedApp: DetectedApp?
    @Binding var showAppPicker: Bool
    
    let onAdd: () -> Void
    let onExpand: () -> Void
    let onCancel: () -> Void
    
    @ObservedObject var appDetectionService: AppDetectionService
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Quick Add")
                    .font(.headline)
                Spacer()
                Button(action: onCancel) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
            }
            
            HStack(spacing: 8) {
                TextField("Task name...", text: $newTaskTitle)
                    .textFieldStyle(.roundedBorder)
                    .font(.body)
                
                Button(action: {
                    appDetectionService.loadInstalledApplications()
                    showAppPicker = true
                }) {
                    if let app = selectedApp {
                        Image(nsImage: app.icon)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                    } else {
                        Image(systemName: "app.badge")
                            .font(.title3)
                            .foregroundColor(.secondary)
                    }
                }
                .buttonStyle(.plain)
                .frame(width: 32, height: 32)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(6)
            }
            
            HStack {
                Button(action: onAdd) {
                    Text("Add Task")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .buttonStyle(.plain)
                .disabled(newTaskTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            
            Divider()
            
            Button(action: onExpand) {
                HStack {
                    Text("More Details")
                    Image(systemName: "chevron.down")
                }
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.plain)
        }
        .padding(16)
        .frame(width: 300)
        .background(Color(nsColor: .windowBackgroundColor))
        .cornerRadius(12)
        .shadow(radius: 10)
    }
}
