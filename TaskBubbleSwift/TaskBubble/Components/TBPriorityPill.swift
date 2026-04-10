import SwiftUI

struct TBPriorityPill: View {
    let priority: TaskPriority
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(priority.shortLabel)
                .font(.system(size: 13, weight: isSelected ? .bold : .medium))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(isSelected ? priority.color.opacity(0.2) : Color.Surface.a10)
                .foregroundColor(isSelected ? priority.color : .secondary)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(isSelected ? priority.color.opacity(0.4) : Color.clear, lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }
}

struct TBPrioritySelector: View {
    @Binding var selection: TaskPriority
    var showLabel: Bool = true
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if showLabel {
                Text("Priority")
                    .font(.headline)
                    .foregroundColor(.white)
            }
            
            HStack(spacing: 8) {
                ForEach(TaskPriority.allCases) { priority in
                    TBPriorityPill(
                        priority: priority,
                        isSelected: selection == priority,
                        action: { selection = priority }
                    )
                }
            }
        }
    }
}
