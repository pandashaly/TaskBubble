//
//  TaskToolbarCircleButtons.swift
//  TaskBubble
//

import AppKit
import SwiftUI

/// Small overlapping circular actions (add + search). Drop in any toolbar area; parent supplies callbacks.
struct TaskToolbarCircleButtons: View {
    var onAdd: () -> Void
    var onSearch: () -> Void
    /// Default 30; use ~26 with a smaller dashboard header.
    var diameter: CGFloat = 30

    private var overlap: CGFloat { diameter * (10.0 / 30.0) }
    private var iconFont: Font { .system(size: max(10, diameter * 13.0 / 30.0), weight: .medium) }

    private var iconTint: Color {
        Color(red: 0.32, green: 0.38, blue: 0.47)
    }

    var body: some View {
        HStack(spacing: -overlap) {
            circleButton(systemName: "plus", filled: false, action: onAdd)
                .zIndex(0)
            circleButton(systemName: "magnifyingglass", filled: true, action: onSearch)
                .zIndex(1)
        }
        .accessibilityElement(children: .contain)
    }

    private func circleButton(systemName: String, filled: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(iconFont)
                .foregroundStyle(iconTint)
                .frame(width: diameter, height: diameter)
                .background(
                    Circle().fill(backgroundColor(filled: filled))
                )
                .overlay(
                    Circle()
                        .strokeBorder(Color.gray.opacity(0.32), lineWidth: 0.5)
                )
        }
        .buttonStyle(.plain)
        .contentShape(Circle())
        .help(systemName == "plus" ? "Add task" : "Search tasks")
    }

    private func backgroundColor(filled: Bool) -> Color {
        if filled {
            return Color(nsColor: .textBackgroundColor)
        }
        return Color(nsColor: .controlBackgroundColor)
    }
}
