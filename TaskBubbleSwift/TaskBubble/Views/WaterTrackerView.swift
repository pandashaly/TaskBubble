//
//  WaterTrackerView.swift
//  TaskBubble
//
//  Created by Shalyca Sottoriva on 02/04/2026.
//


import SwiftUI

struct WaterTrackerView: View {
    @Binding var waterIntake: Int
    
    var body: some View {
        HStack {
            Text("Water Intake")
                .font(.headline)
            
            Spacer()
            
            HStack(spacing: 6) {
                ForEach(0..<8) { index in
                    Image(systemName: index < waterIntake ? "drop.fill" : "drop")
                        .foregroundColor(.blue)
                        .font(.title3)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                waterIntake = index + 1
                            }
                        }
                }
            }
            
            Button(action: {
                withAnimation(.easeInOut(duration: 0.2)) {
                    if waterIntake < 8 {
                        waterIntake += 1
                    }
                }
            }) {
                Image(systemName: "plus.circle.fill")
                    .font(.title3)
                    .foregroundColor(.blue)
            }
            .buttonStyle(.plain)
            .padding(.leading, 6)
            
            Button(action: {
                withAnimation(.easeInOut(duration: 0.2)) {
                    waterIntake = 0
                }
            }) {
                Image(systemName: "arrow.counterclockwise")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .buttonStyle(.plain)
            .padding(.leading, 4)
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
        .background(Color.blue.opacity(0.08))
        .cornerRadius(12)
        .padding(.horizontal)
        .animation(.easeInOut(duration: 0.2), value: waterIntake)
    }
}

//TODO change design. add log for storing daily water tracking information for user analytics
//add confetti when 8 cups have been drank
