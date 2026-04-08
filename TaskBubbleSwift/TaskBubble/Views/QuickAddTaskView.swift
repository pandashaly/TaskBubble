import SwiftUI

struct QuickAddTaskView: View {
    @Binding var newTaskTitle: String
    @Binding var selectedApp: DetectedApp?
    @Binding var showAppPicker: Bool
    @Binding var linkURL: String
    @State private var isHoveringAppIcon = false
    
    let onAdd: () -> Void
    let onExpand: () -> Void
    let onCancel: () -> Void
    
    @ObservedObject var appDetectionService: AppDetectionService
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text("Quick Add")
                    .font(.headline)
                Spacer()
                Button(action: onCancel) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(AppColors.shalyPurple)
                }
                .buttonStyle(.plain)
            }
            //.padding(.top, -4)
            
            HStack(spacing: 8) {
                TextField("To Do...", text: $newTaskTitle)
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
                    } else if !linkURL.isEmpty {
                        LinkIconView(link: linkURL)
                            .frame(width: 24, height: 24)
                    } else {
                        Image(systemName: "app.badge")
                            .font(.title3)
                            .foregroundColor(isHoveringAppIcon ? AppColors.shalyPurple.opacity(0.05) : AppColors.shalyPurple) //TODO fix hover
                    }
                }
                .buttonStyle(.plain)
                .frame(width: 32, height: 32)
                .background(AppColors.card)
                .cornerRadius(6)
            }
            
            HStack {
                Button(action: onAdd) {
                    Text("Add Task")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(AppColors.shalyPurple)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .buttonStyle(.plain)
                //.disabled(newTaskTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty) TODO -whats this???
            }
            
            Divider()
            
            Button(action: onExpand) {
                HStack {
                    Text("Advanced")
                    Image(systemName: "chevron.down")
                }
                .fontWeight(.semibold)
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

//import SwiftUI
//
//struct QuickAddTaskView: View {
//    @Binding var newTaskTitle: String
//    @Binding var selectedApp: DetectedApp?
//    @Binding var showAppPicker: Bool
//    @Binding var linkURL: String
//    
//    let onAdd: () -> Void
//    let onExpand: () -> Void
//    let onCancel: () -> Void
//    
//    @ObservedObject var appDetectionService: AppDetectionService
//    
//    var body: some View {
//        let isAddDisabled = newTaskTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
//        
//        VStack(spacing: 12) {
//            
//            // Header
//            HStack {
//                Text("Quick Add")
//                    .font(.headline)
//                    .foregroundColor(AppColors.textWhite)
//                
//                Spacer()
//                
//                Button(action: onCancel) {
//                    Image(systemName: "xmark.circle.fill")
//                        .foregroundColor(AppColors.textBlack)
//                }
//                .buttonStyle(.plain)
//            }
//            
//            // Task Input + App Picker
//            HStack(spacing: 8) {
//                TextField("Task name...", text: $newTaskTitle)
//                    .font(.body)
//                    .padding(8)
//                    .background(AppColors.background)
//                    .cornerRadius(6)
//                    .overlay(
//                        RoundedRectangle(cornerRadius: 6)
//                            .stroke(AppColors.border, lineWidth: 1)
//                    )
//                
//                Button(action: {
//                    appDetectionService.loadInstalledApplications()
//                    showAppPicker = true
//                }) {
//                    if let app = selectedApp {
//                        Image(nsImage: app.icon)
//                            .resizable()
//                            .scaledToFit()
//                            .frame(width: 24, height: 24)
//                    } else if !linkURL.isEmpty {
//                        LinkIconView(link: linkURL)
//                            .frame(width: 24, height: 24)
//                    } else {
//                        Image(systemName: "app.badge")
//                            .font(.title3)
//                            .foregroundColor(AppColors.textBlack)
//                    }
//                }
//                .buttonStyle(.plain)
//                .frame(width: 32, height: 32)
//                .background(AppColors.card)
//                .cornerRadius(6)
//            }
//            
//            // Add Task Button
//            Button(action: onAdd) {
//                Text("Add Task")
//                    .fontWeight(.semibold)
//                    .frame(maxWidth: .infinity)
//                    .padding(.vertical, 8)
//                    .background(
//                        isAddDisabled
//                        ? AppColors.shalyPurple.opacity(0.5)
//                        : AppColors.shalyPurple
//                    )
//                    .foregroundColor(AppColors.textWhite)
//                    .cornerRadius(8)
//            }
//            .buttonStyle(.plain)
//            .disabled(isAddDisabled)
//            
//            Divider()
//            
//            // Advanced Button
//            Button(action: onExpand) {
//                HStack {
//                    Text("Advanced")
//                    Image(systemName: "chevron.down")
//                }
//                .fontWeight(.semibold)
//                .foregroundColor(AppColors.textBlack)
//                .frame(maxWidth: .infinity)
//            }
//            .buttonStyle(.plain)
//            
//        }
//        .padding(16)
//        .frame(width: 300)
//        .background(AppColors.card)
//        .cornerRadius(12)
//        .shadow(color: AppColors.background, radius: 10)
//    }
//}
