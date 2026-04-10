//
//  ProjectDetailView.swift
//  TaskBubble
//
//  Created by Shalyca Sottoriva on 10/04/2026.
//

import CoreData
import SwiftUI

struct ProjectDetailView: View {

    @ObservedObject var project: Project
    @ObservedObject var appDetectionService: AppDetectionService

    var onBack: () -> Void
    var onSelectTask: (Item) -> Void
    var onAddTask: () -> Void
    var onEditProject: () -> Void

    @Environment(\.managedObjectContext) private var viewContext
    @State private var selectedStatus: ProjectTaskStatus = .all
    @State private var archivingIDs: Set<NSManagedObjectID> = []

    private var projectTasks: [Item] {
        project.taskArray
    }

    private var filteredTasks: [Item] {
        let pool = projectTasks.filter { !archivingIDs.contains($0.objectID) }
        switch selectedStatus {
        case .all:   return pool
        case .todo:  return pool.filter { !$0.completed && $0.priority < 1 }
        case .doing: return pool.filter { !$0.completed && $0.priority >= 1 }
        case .done:  return pool.filter { $0.completed }
        }
    }

    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            VStack(spacing: 0) {
                navBar
                miniFolderBanner
                statusPills
                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: 5) {
                        if filteredTasks.isEmpty {
                            Text("No tasks here yet")
                                .font(AppFonts.label)
                                .foregroundColor(Color.Surface.a50)
                                .frame(maxWidth: .infinity)
                                .padding(.top, 20)
                        } else {
                            ForEach(filteredTasks) { item in
                                ProjectTaskRow(
                                    item: item,
                                    projectColor: project.color,
                                    appDetectionService: appDetectionService,
                                    isArchiving: archivingIDs.contains(item.objectID),
                                    onSelect: { onSelectTask(item) },
                                    onComplete: { handleComplete(item) }
                                )
                                .padding(.horizontal, 14)
                            }
                        }
                    }
                    .padding(.top, 4)
                    .padding(.bottom, 16)
                }
                addTaskFAB
            }
        }
    }

    // MARK: - Nav bar

    private var navBar: some View {
        HStack(spacing: 8) {
            Button(action: onBack) {
                ZStack {
                    Circle()
                        .fill(Color.Surface.a20.opacity(0.4))
                        .frame(width: 26, height: 26)
                    Image(systemName: "chevron.left")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(Color.Surface.a60)
                }
            }
            .buttonStyle(.plain)

            Text(project.name ?? "Project")
                .font(AppFonts.headline)
                .foregroundColor(AppColors.textWhite)

            Spacer()

            Button(action: onEditProject) {
                ZStack {
                    Circle()
                        .fill(Color.Surface.a20.opacity(0.4))
                        .frame(width: 26, height: 26)
                    Image(systemName: "square.and.pencil")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(Color.Surface.a50)
                }
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(AppColors.background)
        .overlay(
            Rectangle()
                .frame(height: 0.5)
                .foregroundColor(Color.Surface.a30.opacity(0.4)),
            alignment: .bottom
        )
    }

    // MARK: - Mini folder banner

    private var miniFolderBanner: some View {
        VStack(spacing: 0) {
            // Folder tab strip
            HStack {
                project.color
                    .frame(maxWidth: .infinity)
                    .frame(height: 6)
                    .cornerRadius(5, corners: [.topLeft, .topRight])
            }
            // Folder body
            HStack(spacing: 10) {
                // Icon
                ZStack {
                    RoundedRectangle(cornerRadius: 7)
                        .fill(project.color.opacity(0.2))
                        .frame(width: 32, height: 32)
                    Image(systemName: "folder.fill")
                        .font(.system(size: 15))
                        .foregroundColor(project.color)
                }

                // Name + meta + progress bar
                VStack(alignment: .leading, spacing: 3) {
                    Text(project.name ?? "Untitled")
                        .font(.custom("Montserrat-Bold", size: 12))
                        .foregroundColor(AppColors.textWhite)
                    HStack(spacing: 6) {
                        if let d = project.deadline {
                            Text("Due \(d, style: .date)")
                                .font(.custom("Montserrat-Regular", size: 9))
                                .foregroundColor(Color.Surface.a50)
                        }
                        Text("·  \(project.taskCount) tasks")
                            .font(.custom("Montserrat-Regular", size: 9))
                            .foregroundColor(Color.Surface.a50)
                    }
                    // Progress bar
                    HStack(spacing: 4) {
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 99)
                                    .fill(Color.Surface.a30.opacity(0.4))
                                    .frame(height: 3)
                                RoundedRectangle(cornerRadius: 99)
                                    .fill(project.color)
                                    .frame(width: geo.size.width * CGFloat(project.progress), height: 3)
                            }
                        }
                        .frame(height: 3)
                        Text("\(Int(project.progress * 100))%")
                            .font(.custom("Montserrat-Bold", size: 9))
                            .foregroundColor(project.color)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                // Stats
                VStack(alignment: .trailing, spacing: 3) {
                    Text("\(project.completedCount) done")
                        .font(.custom("Montserrat-Regular", size: 9))
                        .foregroundColor(Color.Surface.a50)
                    Text("\(project.taskCount - project.completedCount) left")
                        .font(.custom("Montserrat-Bold", size: 10))
                        .foregroundColor(AppColors.textWhite)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(project.color.opacity(0.1))
            .overlay(
                RoundedRectangle(cornerRadius: 0)
                    .stroke(Color.white.opacity(0.07), lineWidth: 0.5)
            )
            .cornerRadius(9, corners: [.bottomLeft, .bottomRight, .topRight])
        }
        .padding(.horizontal, 14)
        .padding(.top, 10)
    }

    // MARK: - Status pills

    private var statusPills: some View {
        HStack(spacing: 6) {
            ForEach(ProjectTaskStatus.allCases) { status in
                Button { selectedStatus = status } label: {
                    Text(status.rawValue)
                        .font(.custom("Montserrat-Bold", size: 9))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 3)
                        .background(
                            Capsule().fill(selectedStatus == status
                                           ? AppColors.shalyPurple
                                           : Color.Surface.a20.opacity(0.5))
                        )
                        .overlay(
                            Capsule().stroke(selectedStatus == status
                                             ? AppColors.shalyPurple
                                             : Color.Surface.a30.opacity(0.5),
                                             lineWidth: 0.5)
                        )
                        .foregroundColor(selectedStatus == status ? .white : Color.Surface.a60)
                }
                .buttonStyle(.plain)
            }
            Spacer()
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
    }

    // MARK: - FAB

    private var addTaskFAB: some View {
        Button(action: onAddTask) {
            HStack(spacing: 6) {
                Image(systemName: "plus")
                    .font(.system(size: 11, weight: .bold))
                Text("Add task to this project")
                    .font(.custom("Montserrat-Bold", size: 11))
            }
            .foregroundColor(AppColors.shalyPurple)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(Capsule().fill(Color.Primary.a0.opacity(0.12)))
            .overlay(Capsule().stroke(Color.Primary.a0.opacity(0.4), lineWidth: 0.5))
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(AppColors.background)
        .overlay(
            Rectangle()
                .frame(height: 0.5)
                .foregroundColor(Color.Surface.a30.opacity(0.4)),
            alignment: .top
        )
    }

    // MARK: - Completion + archive

    private func handleComplete(_ item: Item) {
        guard !item.completed else { return }
        item.completed = true
        try? viewContext.save()
        withAnimation(.easeInOut(duration: 0.3)) {
            _ = archivingIDs.insert(item.objectID)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            withAnimation(.easeOut(duration: 0.4)) {
                _ = archivingIDs.remove(item.objectID)
            }
        }
    }
}
