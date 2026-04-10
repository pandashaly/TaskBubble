//
//  TBNoteEditor.swift
//  TaskBubble
//
//  Created by Shalyca Sottoriva on 10/04/2026.
//

// TBNoteEditor.swift
// TaskBubble
// Reusable rich-text note editor with word count, expand button, and full expanded sheet.
// Usage:
//   TBNoteEditor(text: $myText, coordinator: myCoordinator, onExpand: { showExpanded = true })
//   .sheet(isPresented: $showExpanded) {
//       TBNoteEditorExpanded(text: $myText, coordinator: myCoordinator)
//   }

import SwiftUI
import AppKit

// MARK: - Compact note editor (inline)

struct TBNoteEditor: View {
    @Binding var text: String
    var coordinator: RichTextCoordinator
    var showLabel: Bool = true
    var minHeight: CGFloat = 85
    var maxHeight: CGFloat = 125
    var onExpand: () -> Void

    private var count: Int { wordCount(text) }
    private var countColor: Color {
        count >= maxNotesWords ? Color.Danger.a0
        : count >= 250 ? Color.Warning.a0
        : .secondary
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            if showLabel {
                HStack {
                    Text("Notes")
                        .font(.custom("Montserrat-SemiBold", size: 13))
                        .foregroundColor(.white)
                    Spacer()
                    Text("\(count)/\(maxNotesWords)")
                        .font(.custom("Montserrat-Regular", size: 10))
                        .foregroundColor(countColor)
                }
            }
            ZStack(alignment: .bottomTrailing) {
                RichTextEditor(text: notesBinding, sharedCoordinator: coordinator)
                    .frame(minHeight: minHeight, maxHeight: maxHeight)
                    .padding(6)
                    .background(Color.Surface.a10)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.22), lineWidth: 1)
                    )
                Button(action: onExpand) {
                    Image(systemName: "arrow.up.left.and.arrow.down.right")
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundColor(.secondary)
                        .padding(5)
                        .background(Color.Surface.a20.opacity(0.9))
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                }
                .buttonStyle(.plain)
                .padding(6)
            }
        }
    }

    private var notesBinding: Binding<String> {
        Binding(get: { text }, set: { text = clampedNotes($0) })
    }
}

// MARK: - Full-screen expanded note editor sheet

struct TBNoteEditorExpanded: View {
    @Binding var text: String
    var coordinator: RichTextCoordinator
    @Environment(\.dismiss) private var dismiss

    private var count: Int { wordCount(text) }
    private var isAtMax: Bool { count >= maxNotesWords }

    var body: some View {
        VStack(spacing: 0) {
            // Toolbar
            HStack(spacing: 4) {
                Text("Notes")
                    .font(.custom("Montserrat-Bold", size: 14))
                    .foregroundColor(.white)
                    .padding(.leading, 4)
                Spacer()
                toolbarBtn(icon: "bold",          label: "Bold")          { coordinator.applyFormat(.bold) }
                toolbarBtn(icon: "italic",        label: "Italic")        { coordinator.applyFormat(.italic) }
                toolbarBtn(icon: "underline",     label: "Underline")     { coordinator.applyFormat(.underline) }
                toolbarBtn(icon: "strikethrough", label: "Strikethrough") { coordinator.applyFormat(.strikethrough) }
                Divider().frame(height: 16).padding(.horizontal, 4)
                toolbarBtn(icon: "chevron.left.forwardslash.chevron.right", label: "Code") {
                    coordinator.applyFormat(.code)
                }
                Divider().frame(height: 16).padding(.horizontal, 4)
                Button("Done") { dismiss() }
                    .buttonStyle(.plain)
                    .font(.custom("Montserrat-SemiBold", size: 12))
                    .foregroundColor(AppColors.shalyPurple)
                    .padding(.trailing, 4)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .background(Color.Surface.a10)

            Divider().background(Color.Surface.a30.opacity(0.5))

            ZStack(alignment: .bottomTrailing) {
                RichTextEditor(
                    text: notesBinding,
                    font: .systemFont(ofSize: 13),
                    textColor: .labelColor,
                    richText: true,
                    sharedCoordinator: coordinator
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(10)

                VStack(alignment: .trailing, spacing: 4) {
                    if isAtMax {
                        warnPill
                    }
                    Text("\(count)/\(maxNotesWords)")
                        .font(.caption2)
                        .foregroundColor(isAtMax ? Color.Danger.a0 : count >= 250 ? Color.Warning.a0 : .secondary)
                        .monospacedDigit()
                }
                .padding(10)
                .animation(.spring(response: 0.25, dampingFraction: 0.7), value: isAtMax)
            }
        }
        .background(AppColors.background)
        .frame(width: 560, height: 380)
    }

    private var notesBinding: Binding<String> {
        Binding(get: { text }, set: { text = clampedNotes($0) })
    }

    private var warnPill: some View {
        HStack(spacing: 4) {
            Image(systemName: "exclamationmark.triangle.fill").font(.system(size: 9, weight: .semibold))
            Text("Word limit reached").font(.system(size: 10, weight: .medium))
        }
        .foregroundColor(Color.Warning.a0)
        .padding(.horizontal, 8).padding(.vertical, 3)
        .background(Color.Warning.a20)
        .clipShape(Capsule())
        .transition(.scale(scale: 0.85).combined(with: .opacity))
    }

    private func toolbarBtn(icon: String, label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.secondary)
                .frame(width: 28, height: 28)
                .background(Color.Surface.a20.opacity(0.6))
                .clipShape(RoundedRectangle(cornerRadius: 6))
        }
        .buttonStyle(.plain)
        .help(label)
    }
}
