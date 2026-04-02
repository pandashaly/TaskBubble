//
//  dashboardView.swift
//  TaskBubble
//
//  Created by Shalyca Sottoriva on 02/04/2026.
//

import SwiftUI

struct DashboardView: View {
    @Binding var waterIntake: Int
    
    var onCategoryTap: (TaskCategory) -> Void
    var onAddTask: () -> Void
    
    var body: some View {
        VStack(spacing: 15) {
            HStack {
                Image(systemName: "bubbles.and.sparkles.fill")
                    .foregroundColor(.blue)
                    .font(.title2)
                
                Text("TaskBubble")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
            }
            .padding(.top)
            
            // Water Tracker
            HStack {
                Text("Water Intake")
                    .font(.headline)
                
                Spacer()
                
                HStack(spacing: 4) {
                    ForEach(0..<8) { index in
                        Image(systemName: index < waterIntake ? "drop.fill" : "drop")
                            .foregroundColor(.blue)
                            .onTapGesture {
                                if index == waterIntake {
                                    waterIntake = min(waterIntake + 1, 8)
                                } else if index < waterIntake {
                                    waterIntake = index + 1
                                }
                            }
                    }
                }
                
                Button(action: {
                    waterIntake = 0
                }) {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.caption)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(Color.blue.opacity(0.1))
            .cornerRadius(12)
            .padding(.horizontal)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                ForEach(TaskCategory.allCases) { category in
                    Button(action: {
                        onCategoryTap(category)
                    }) {
                        VStack {
                            Image(systemName: categoryIcon(for: category))
                                .font(.title)
                            
                            Text(category.rawValue)
                                .font(.headline)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(category.color.opacity(0.2))
                        .cornerRadius(12)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal)
            
            Spacer()
            
            Button(action: {
                onAddTask()
            }) {
                Label("Add New Task", systemImage: "plus.circle.fill")
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .buttonStyle(.plain)
            .padding()
        }
    }
    
    private func categoryIcon(for category: TaskCategory) -> String {
        switch category {
        case .goals: return "target"
        case .daily: return "sun.max"
        case .weekly: return "calendar"
        case .routine: return "repeat"
        }
    }
}
