import SwiftUI

struct WaterTrackerView: View {
    @ObservedObject var waterService: WaterIntakeService
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Water Intake")
                    .font(.headline)
//                Text("Daily goal: 8 cups")
//                    .font(.caption2)
//                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            HStack(spacing: 12) {
                // Counter Display
                HStack(spacing: 6) {
                    ZStack {
                        Image(systemName: "drop.fill")
                            .font(.system(size: 28))
                            .foregroundColor(.blue)
                        
                        Text("\(waterService.currentIntake)")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                            .offset(y: 2)
                    }
                    
                    if waterService.currentIntake >= 8 {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .font(.caption)
                    }
                }
                
                // Droplets (visual indicator for the first 8)
                HStack(spacing: 4) {
                    ForEach(0..<8) { index in
                        Image(systemName: index < waterService.currentIntake ? "drop.fill" : "drop")
                            .font(.system(size: 14))
                            .foregroundColor(.blue.opacity(index < waterService.currentIntake ? 1.0 : 0.4))
                    }
                }
                
                // Add Button
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        waterService.updateIntake(delta: 1)
                    }
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
                .buttonStyle(.plain)
                
                // Reset Button (moved to the end, smaller)
                Button(action: {
                    waterService.resetIntake()
                }) {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.caption2)
                        .foregroundColor(.secondary.opacity(0.5))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
        .background(Color.blue.opacity(0.08))
        .cornerRadius(12)
        .padding(.horizontal)
    }
}
