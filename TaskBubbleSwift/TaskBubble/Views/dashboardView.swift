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
        VStack(spacing: 18) {
            
            // Top Header
            HStack {
                Image(systemName: "bubbles.and.sparkles.fill")
                    .foregroundColor(.white)
                    .font(.title2)
                
                Text("TaskBubble")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                
                Spacer()
            }
            .padding(.horizontal)
            .padding(.top)
            
            // Horizontal Categories
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 14) {
                    ForEach(TaskCategory.allCases) { category in
                        Button(action: {
                            onCategoryTap(category)
                        }) {
                            HStack(spacing: 6) {
                                Image(systemName: category.icon)
                                    .font(.caption)
                                
                                Text(category.rawValue)
                                    .font(.system(size: 14))
                                    .fontWeight(.bold)
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 12)
                            .background(category.color.opacity(0.15))
                            .cornerRadius(10)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal)
            }
            
            // Water Tracker
            WaterTrackerView(waterIntake: $waterIntake)
            
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
}
