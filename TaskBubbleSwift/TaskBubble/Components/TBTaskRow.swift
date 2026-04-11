//
//  TBTaskRow.swift
//  TaskBubble
//
//  Created by Shalyca Sottoriva on 11/04/2026.
//

// TBTaskRow.swift
// TaskBubble
// THE single reusable task row. Use this everywhere instead of TaskRow / ProjectTaskRow / UnifiedTaskRow.
// All three old implementations are replaced by this one.

import CoreData
import SwiftUI

struct TBTaskRow: View {
    @ObservedObject var item: Item
    @ObservedObject var appDetectionService: AppDetectionService

    // Visual options
    var showProjectFlag: Bool = true   // show colored left flag (gray if no project)
    var isArchiving: Bool = false

    // Actions
    var onSelect: () -> Void
    var onComplete: () -> Void

    @State private var showSubtaskWarning = false
    @Environment(\.managedObjectContext) private var viewContext

    // MARK: - Computed

    private var projectColor: Color {
        if showProjectFlag, let proj = item.value(forKey: "project") as? Project {
            return proj.color
        }
        return Color.Surface.a30
    }

    private var incompleteSubtaskCount: Int {
        ((item.subtasks as? Set<Subtask>) ?? [])
            .filter { !($0.linkedResourceValue?.hasPrefix("[x]") ?? false) }
            .count
    }

    private var priorityColor: Color {
        switch TaskPriority(rawValue: item.priority) ?? .low {
        case .high:   return Color.Danger.a10
        case .medium: return Color.Warning.a10
        case .low:    return Color.Info.a10
        }
    }

    private var isOverdue: Bool {
        guard let dl = item.deadline, !item.completed else { return false }
        return dl < Date()
    }

    // MARK: - Body

    var body: some View {
        // ⚠️ KEY FIX: wrap in ZStack so List row hit-testing doesn't swallow button taps.
        // The whole row background is a plain button for onSelect,
        // but the checkmark is a separate overlay button.
        ZStack(alignment: .leading) {
            // Row background — tapping anywhere except checkmark opens detail
            Button(action: onSelect) {
                HStack(spacing: 0) {
                    // Left flag
                    if showProjectFlag {
                        Rectangle()
                            .fill(projectColor)
                            .frame(width: 3)
                    }

                    HStack(spacing: 7) {
                        // Spacer so checkmark button sits above this
                        Color.clear.frame(width: 22, height: 15)

                        Circle().fill(priorityColor).frame(width: 5, height: 5)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(item.title ?? "Untitled")
                                .font(.custom("Montserrat-SemiBold", size: 11))
                                .foregroundColor(item.completed ? Color.Surface.a50 : AppColors.textWhite)
                                .strikethrough(item.completed)
                                .lineLimit(1)

                            HStack(spacing: 5) {
                                if let dl = item.deadline {
                                    Text(dl, style: .date)
                                        .font(.custom("Montserrat-Regular", size: 9))
                                        .foregroundColor(isOverdue ? Color.Danger.a10 : Color.Surface.a50)
                                }
                                if isArchiving {
                                    Text("archiving…")
                                        .font(.custom("Montserrat-Regular", size: 9))
                                        .foregroundColor(Color.Success.a0.opacity(0.7))
                                }
                                SubtaskIndicator(item: item)
                            }
                        }

                        Spacer(minLength: 0)

                        // App / link chip
                        if let type = item.linkedResourceType,
                           let value = item.linkedResourceValue {
                            TBLinkChip(
                                resourceType: type,
                                resourceValue: value,
                                appDetectionService: appDetectionService
                            )
                        }

                        // Status badge
                        TBStatusBadge(item: item)
                    }
                    .padding(.vertical, 7)
                    .padding(.trailing, 9)
                    .padding(.leading, showProjectFlag ? 7 : 10)
                }
                .background(AppColors.card)
                .cornerRadius(9)
                .overlay(
                    RoundedRectangle(cornerRadius: 9)
                        .stroke(Color.Surface.a30.opacity(0.35), lineWidth: 0.5)
                )
            }
            .buttonStyle(.plain)

            // Checkmark — sits on top as a separate tappable zone
            Button(action: {
                if !item.completed && incompleteSubtaskCount > 0 {
                    showSubtaskWarning = true
                } else {
                    onComplete()
                }
            }) {
                ZStack {
                    Circle()
                        .stroke(
                            item.completed ? Color.Success.a0 : Color.Surface.a30,
                            lineWidth: 1.5
                        )
                        .frame(width: 15, height: 15)
                    if item.completed {
                        Circle()
                            .fill(Color.Success.a0.opacity(0.15))
                            .frame(width: 15, height: 15)
                        Image(systemName: "checkmark")
                            .font(.system(size: 7, weight: .bold))
                            .foregroundColor(Color.Success.a0)
                    }
                }
            }
            .buttonStyle(.plain)
            .padding(.leading, showProjectFlag ? 13 : 10)
            .alert("Incomplete subtasks", isPresented: $showSubtaskWarning) {
                Button("Mark done anyway", role: .destructive) { onComplete() }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This task has \(incompleteSubtaskCount) incomplete subtask\(incompleteSubtaskCount == 1 ? "" : "s"). Mark as done anyway?")
            }
        }
        .opacity(isArchiving ? 0.45 : 1)
        .animation(.easeInOut(duration: 0.3), value: isArchiving)
        // ⚠️ Remove default List row styling
        .listRowBackground(Color.clear)
        .listRowInsets(EdgeInsets(top: 3, leading: 0, bottom: 3, trailing: 0))
        .listRowSeparator(.hidden)
    }
}

// MARK: - Link chip

struct TBLinkChip: View {
    let resourceType: String
    let resourceValue: String
    @ObservedObject var appDetectionService: AppDetectionService

    var body: some View {
        Group {
            if resourceType == LinkedResourceType.app.rawValue,
               let icon = appDetectionService.getIcon(for: resourceValue) {
                Image(nsImage: icon)
                    .resizable().scaledToFit()
                    .frame(width: 14, height: 14).cornerRadius(3)
            } else if resourceType == LinkedResourceType.url.rawValue {
                LinkIconView(link: resourceValue).frame(width: 14, height: 14)
            } else {
                Image(systemName: "app")
                    .font(.system(size: 9)).foregroundColor(Color.Surface.a50)
            }
        }
        .frame(width: 20, height: 20)
        .background(Color.Surface.a20.opacity(0.5))
        .cornerRadius(4)
        .padding(.trailing, 3)
    }
}

// MARK: - Status badge

struct TBStatusBadge: View {
    @ObservedObject var item: Item

    private var info: (String, Color, Color) {
        if item.completed {
            return ("Done", Color.Success.a20.opacity(0.5), Color.Success.a10)
        }
        if item.priority >= 1 {
            return ("Doing", Color.Primary.a20.opacity(0.4), Color.Primary.a30)
        }
        return ("To Do", Color.Surface.a20.opacity(0.6), Color.Surface.a60)
    }

    var body: some View {
        let (label, bg, fg) = info
        Text(label)
            .font(.custom("Montserrat-Bold", size: 8))
            .padding(.horizontal, 6).padding(.vertical, 2)
            .background(Capsule().fill(bg))
            .foregroundColor(fg)
    }
}

// MARK: - Corner helpers (canonical — only defined here, used via extension)

extension View {
    func tbCornerRadius(_ radius: CGFloat, corners: TBRectCorner) -> some View {
        clipShape(TBRoundedCornerShape(radius: radius, corners: corners))
    }
}

struct TBRectCorner: OptionSet {
    let rawValue: Int
    static let topLeft     = TBRectCorner(rawValue: 1 << 0)
    static let topRight    = TBRectCorner(rawValue: 1 << 1)
    static let bottomLeft  = TBRectCorner(rawValue: 1 << 2)
    static let bottomRight = TBRectCorner(rawValue: 1 << 3)
    static let all: TBRectCorner = [.topLeft, .topRight, .bottomLeft, .bottomRight]
}

struct TBRoundedCornerShape: Shape {
    var radius: CGFloat; var corners: TBRectCorner
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let tl = corners.contains(.topLeft)     ? radius : 0
        let tr = corners.contains(.topRight)    ? radius : 0
        let bl = corners.contains(.bottomLeft)  ? radius : 0
        let br = corners.contains(.bottomRight) ? radius : 0
        p.move(to: CGPoint(x: rect.minX + tl, y: rect.minY))
        p.addLine(to: CGPoint(x: rect.maxX - tr, y: rect.minY))
        p.addArc(center: CGPoint(x: rect.maxX - tr, y: rect.minY + tr), radius: tr, startAngle: .degrees(-90), endAngle: .degrees(0), clockwise: false)
        p.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - br))
        p.addArc(center: CGPoint(x: rect.maxX - br, y: rect.maxY - br), radius: br, startAngle: .degrees(0), endAngle: .degrees(90), clockwise: false)
        p.addLine(to: CGPoint(x: rect.minX + bl, y: rect.maxY))
        p.addArc(center: CGPoint(x: rect.minX + bl, y: rect.maxY - bl), radius: bl, startAngle: .degrees(90), endAngle: .degrees(180), clockwise: false)
        p.addLine(to: CGPoint(x: rect.minX, y: rect.minY + tl))
        p.addArc(center: CGPoint(x: rect.minX + tl, y: rect.minY + tl), radius: tl, startAngle: .degrees(180), endAngle: .degrees(270), clockwise: false)
        p.closeSubpath()
        return p
    }
}
