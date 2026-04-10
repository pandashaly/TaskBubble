//
//  PriorityPills.swift
//  TaskBubble
//
//  Created by Shalyca Sottoriva on 10/04/2026.
//

import SwiftUI

struct PriorityPills: View {
    // This connects to the @State in your parent view
    @Binding var selection: TaskPriority
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Priority")
                .font(.headline)
                .foregroundColor(.white)
            
            HStack(spacing: 6) {
                ForEach(TaskPriority.allCases) { p in
                    Button {
                        selection = p
                    } label: {
                        Text(p.shortLabel)
                            .font(.body)
                            .frame(maxWidth: .infinity)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                Capsule()
                                    .fill(selection == p ? p.color.opacity(0.25) : Color.gray.opacity(0.12))
                            )
                            .overlay(
                                Capsule()
                                    .stroke(selection == p ? p.color : Color.gray.opacity(0.3), lineWidth: 1)
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

//how to use
//
//struct TaskEditView: View {
//    @State private var inputPriority: TaskPriority = .medium
//    
//    var body: some View {
//        VStack {
//            // Simply call it like this:
//            PriorityPicker(selection: $inputPriority)
//            
//            Spacer()
//        }
//        .padding()
//    }
//}
