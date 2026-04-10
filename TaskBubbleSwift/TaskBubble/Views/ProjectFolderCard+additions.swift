//
//  ProjectFolderCard+additions.swift
//  TaskBubble
//
//  Created by Shalyca Sottoriva on 11/04/2026.
//

// ProjectFolderCard+Additions.swift
// TaskBubble
// Drop-in replacements for ProjectFolderCard and the projects section scroller.
// Replace the ProjectFolderCard struct and projectsSection in ProjectDashboardView.swift

import SwiftUI

// MARK: - Updated folder card with urgency dot

struct ProjectFolderCard: View {
    @ObservedObject var project: Project

    // Urgent = any task is high priority OR project deadline < 14 days
    private var isUrgent: Bool {
        let now = Date()
        let twoWeeks = Calendar.current.date(byAdding: .day, value: 14, to: now) ?? now
        let hasUrgentTask = project.taskArray.contains { !$0.completed && $0.priority >= 2 }
        let deadlineSoon = (project.deadline.map { $0 <= twoWeeks && $0 >= now }) ?? false
        return hasUrgentTask || deadlineSoon
    }

    var body: some View {
        ZStack(alignment: .topLeading) {
            // Folder body
            RoundedRectangle(cornerRadius: 8)
                .fill(project.color.opacity(0.13))
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(project.color.opacity(0.3), lineWidth: 0.7))
                .frame(width: 86, height: 66)
                .offset(y: 12)

            // Folder tab
            HStack(spacing: 0) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(project.color)
                    .frame(width: 38, height: 12)
                Spacer()
            }
            .frame(width: 86)
            .offset(x: 0, y: 4)

            // Content
            VStack(alignment: .leading, spacing: 3) {
                Text(project.name ?? "Untitled")
                    .font(.custom("Montserrat-Bold", size: 10))
                    .foregroundColor(AppColors.textWhite)
                    .lineLimit(1)
                Text("\(project.taskCount) tasks")
                    .font(.custom("Montserrat-SemiBold", size: 9))
                    .foregroundColor(project.color.opacity(0.9))
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 99)
                            .fill(Color.Surface.a30.opacity(0.4)).frame(height: 2.5)
                        RoundedRectangle(cornerRadius: 99)
                            .fill(project.color)
                            .frame(width: geo.size.width * CGFloat(project.progress), height: 2.5)
                    }
                }
                .frame(height: 2.5)
                .padding(.top, 2)
            }
            .padding(.horizontal, 9)
            .padding(.top, 28)
            .padding(.bottom, 8)
            .frame(width: 86, alignment: .leading)

            // Urgency dot (top-right of card)
            if isUrgent {
                Circle()
                    .fill(Color.Danger.a0)
                    .frame(width: 8, height: 8)
                    .overlay(Circle().stroke(AppColors.background, lineWidth: 1.5))
                    .offset(x: 78, y: 10)
            }
        }
        .frame(width: 86, height: 78)
        .contentShape(Rectangle())
    }
}

// MARK: - Add project placeholder card

struct AddProjectCard: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack(alignment: .topLeading) {
                // Folder body
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.Surface.a20.opacity(0.15))
                    .overlay(RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.Surface.a30.opacity(0.4), lineWidth: 0.7)
                        .overlay(RoundedRectangle(cornerRadius: 8)
                            .strokeBorder(style: StrokeStyle(lineWidth: 0.7, dash: [4, 3]))
                            .foregroundColor(AppColors.shalyPurple.opacity(0.4)))
                    )
                    .frame(width: 86, height: 66)
                    .offset(y: 12)

                // Folder tab (muted)
                HStack(spacing: 0) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.Surface.a30.opacity(0.5))
                        .frame(width: 38, height: 12)
                    Spacer()
                }
                .frame(width: 86)
                .offset(x: 0, y: 4)

                // Plus icon
                VStack(spacing: 4) {
                    ZStack {
                        Circle()
                            .fill(AppColors.shalyPurple.opacity(0.2))
                            .frame(width: 22, height: 22)
                        Image(systemName: "plus")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(AppColors.shalyPurple)
                    }
                    Text("New")
                        .font(.custom("Montserrat-Bold", size: 9))
                        .foregroundColor(AppColors.shalyPurple.opacity(0.8))
                }
                .frame(width: 86, height: 66)
                .offset(y: 12)
            }
            .frame(width: 86, height: 78)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
