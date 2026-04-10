//
//  SubtaskPopup.swift
//  TaskBubble
//
//  Created by Shalyca Sottoriva on 10/04/2026.
//

// SubtaskPopup.swift
// TaskBubble
// Floating popup showing subtasks with checkboxes. Triggered from the subtask indicator pill.

import CoreData
import SwiftUI

struct SubtaskPopupButton: View {
    @ObservedObject var item: Item
    @State private var showPopup = false

    private var count: Int { item.subtasks?.count ?? 0 }
    private var doneCount: Int {
        ((item.subtasks as? Set<Subtask>) ?? [])
            .filter { ($0.linkedResourceValue ?? "").hasPrefix("[x]") }
            .count
    }

    var body: some View {
        if count > 0 {
            Button {
                showPopup = true
            } label: {
                HStack(spacing: 2) {
                    Image(systemName: "list.bullet")
                        .font(.system(size: 8, weight: .medium))
                        .foregroundColor(Color.Surface.a50)
                    Text("\(doneCount)/\(count)")
                        .font(.custom("Montserrat-Bold", size: 8))
                        .foregroundColor(doneCount == count ? Color.Success.a10 : Color.Surface.a60)
                }
                .padding(.horizontal, 5).padding(.vertical, 1)
                .background(Capsule().fill(doneCount == count
                    ? Color.Success.a20.opacity(0.4)
                    : Color.Surface.a20.opacity(0.5)))
            }
            .buttonStyle(.plain)
            .popover(isPresented: $showPopup, arrowEdge: .bottom) {
                SubtaskPopupView(item: item, isPresented: $showPopup)
            }
        }
    }
}

struct SubtaskPopupView: View {
    @ObservedObject var item: Item
    @Binding var isPresented: Bool
    @Environment(\.managedObjectContext) private var viewContext

    private var sortedSubtasks: [Subtask] {
        ((item.subtasks as? Set<Subtask>) ?? []).sorted { $0.sortOrder < $1.sortOrder }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack {
                HStack(spacing: 5) {
                    Image(systemName: "list.bullet")
                        .font(.system(size: 11)).foregroundColor(AppColors.shalyPurple)
                    Text("Subtasks")
                        .font(.custom("Montserrat-Bold", size: 13)).foregroundColor(AppColors.textWhite)
                }
                Spacer()
                Text("\(completedCount)/\(sortedSubtasks.count)")
                    .font(.custom("Montserrat-Regular", size: 11)).foregroundColor(Color.Surface.a50)
                Button { isPresented = false } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 13)).foregroundColor(Color.Surface.a40)
                }
                .buttonStyle(.plain).padding(.leading, 6)
            }
            .padding(.horizontal, 14).padding(.vertical, 10)
            .background(Color.Surface.a10)

            // Progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Rectangle().fill(Color.Surface.a20.opacity(0.5)).frame(height: 2)
                    Rectangle()
                        .fill(progressColor)
                        .frame(width: geo.size.width * progress, height: 2)
                }
            }
            .frame(height: 2)

            // Subtask list
            if sortedSubtasks.isEmpty {
                Text("No subtasks")
                    .font(.custom("Montserrat-Regular", size: 12)).foregroundColor(Color.Surface.a50)
                    .padding(14)
            } else {
                VStack(spacing: 0) {
                    ForEach(sortedSubtasks) { sub in
                        SubtaskRow(subtask: sub, onToggle: { toggle(sub) })
                        if sub != sortedSubtasks.last {
                            Divider().background(Color.Surface.a30.opacity(0.3)).padding(.horizontal, 10)
                        }
                    }
                }
                .padding(.vertical, 4)
            }
        }
        .background(AppColors.card)
        .frame(width: 260)
        .cornerRadius(12)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.Surface.a30.opacity(0.4), lineWidth: 0.5))
    }

    private var completedCount: Int {
        sortedSubtasks.filter { isCompleted($0) }.count
    }

    private var progress: CGFloat {
        guard !sortedSubtasks.isEmpty else { return 0 }
        return CGFloat(completedCount) / CGFloat(sortedSubtasks.count)
    }

    private var progressColor: Color {
        progress >= 1.0 ? Color.Success.a0 : AppColors.shalyPurple
    }

    private func isCompleted(_ sub: Subtask) -> Bool {
        sub.linkedResourceValue?.hasPrefix("[x]") ?? false
    }

    private func toggle(_ sub: Subtask) {
        let current = sub.linkedResourceValue ?? ""
        if current.hasPrefix("[x]") {
            sub.linkedResourceValue = String(current.dropFirst(3))
        } else {
            sub.linkedResourceValue = "[x]" + current
        }
        try? viewContext.save()
    }
}

struct SubtaskRow: View {
    @ObservedObject var subtask: Subtask
    var onToggle: () -> Void

    private var isCompleted: Bool {
        subtask.linkedResourceValue?.hasPrefix("[x]") ?? false
    }

    private var displayTitle: String {
        let v = subtask.linkedResourceValue ?? ""
        return v.hasPrefix("[x]") ? String(v.dropFirst(3)) : v
    }

    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: 10) {
                ZStack {
                    Circle()
                        .stroke(isCompleted ? Color.Success.a0 : Color.Surface.a30, lineWidth: 1.5)
                        .frame(width: 16, height: 16)
                    if isCompleted {
                        Circle().fill(Color.Success.a0.opacity(0.15)).frame(width: 16, height: 16)
                        Image(systemName: "checkmark")
                            .font(.system(size: 7, weight: .bold)).foregroundColor(Color.Success.a0)
                    }
                }
                Text(displayTitle)
                    .font(.custom("Montserrat-Regular", size: 12))
                    .foregroundColor(isCompleted ? Color.Surface.a50 : AppColors.textWhite)
                    .strikethrough(isCompleted)
                    .lineLimit(2)
                Spacer()
            }
            .padding(.horizontal, 14).padding(.vertical, 8)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Subtask indicator (updated to use SubtaskPopupButton)

struct SubtaskIndicator: View {
    @ObservedObject var item: Item
    private var count: Int { item.subtasks?.count ?? 0 }
    var body: some View {
        SubtaskPopupButton(item: item)
    }
}
