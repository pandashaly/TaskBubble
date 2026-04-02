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
            
            HStack(spacing: 4) {
                ForEach(0..<8) { index in
                    Image(systemName: index < waterIntake ? "drop.fill" : "drop")
                        .foregroundColor(.blue)
                        .onTapGesture {
                            updateWaterIntake(for: index)
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
    }
    
    private func updateWaterIntake(for index: Int) {
        if index == waterIntake {
            waterIntake = min(waterIntake + 1, 8)
        } else if index < waterIntake {
            waterIntake = index + 1
        }
    }
}
