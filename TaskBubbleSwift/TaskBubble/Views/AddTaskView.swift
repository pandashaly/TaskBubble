//
//  AddTaskView.swift
//  TaskBubble
//
//  Created by Shalyca Sottoriva on 02/04/2026.
//


import SwiftUI

struct AddTaskView: View {
    @Binding var newTaskTitle: String
    @Binding var inputCategory: TaskCategory
    @Binding var inputPriority: TaskPriority
    @Binding var showDeadlinePicker: Bool
    @Binding var selectedDeadline: Date
    @Binding var showAppPicker: Bool
    @Binding var showLinkInput: Bool
    @Binding var selectedApp: DetectedApp?
    @Binding var linkURL: String

    let addTask: () -> Void
    let cancelAction: () -> Void

    @ObservedObject var appDetectionService: AppDetectionService
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button("Cancel") {
                    cancelAction()
                }
                .buttonStyle(.plain)
                
                Spacer()
                
                Text("New Task")
                    .font(.headline)
                
                Spacer()
                
                Button("Add") {
                    addTask()
                }
                .buttonStyle(.plain)
                .foregroundColor(.blue)
                .bold()
            }
            .padding()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    
                    TextField("What needs to be done?", text: $newTaskTitle)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .font(.title3)
                    
                    VStack(alignment: .leading) {
                        Text("Category")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Picker("", selection: $inputCategory) {
                            ForEach(TaskCategory.allCases) { category in
                                Text(category.rawValue).tag(category)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Priority")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Picker("", selection: $inputPriority) {
                            ForEach(TaskPriority.allCases) { priority in
                                Text(priority.displayName).tag(priority)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                    
                    Toggle(isOn: $showDeadlinePicker) {
                        Label("Add Deadline", systemImage: "calendar")
                    }
                    
                    if showDeadlinePicker {
                        DatePicker("", selection: $selectedDeadline, displayedComponents: .date)
                            .datePickerStyle(.graphical)
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Link Tool")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        HStack {
                            Button(action: {
                                appDetectionService.loadInstalledApplications()
                                showAppPicker = true
                            }) {
                                Label("App", systemImage: "app.badge")
                                    .padding(8)
                                    .background(Color.gray.opacity(0.1))
                                    .cornerRadius(8)
                            }
                            .buttonStyle(.plain)
                            
                            Button(action: {
                                showLinkInput = true
                            }) {
                                Label("URL", systemImage: "link")
                                    .padding(8)
                                    .background(Color.gray.opacity(0.1))
                                    .cornerRadius(8)
                            }
                            .buttonStyle(.plain)
                            
                            Spacer()
                            
                            if let app = selectedApp {
                                Image(nsImage: app.icon)
                                    .resizable()
                                    .frame(width: 24, height: 24)
                            } else if !linkURL.isEmpty {
                                Image(systemName: "safari")
                            }
                        }
                    }
                }
                .padding()
            }
        }
    }
}
