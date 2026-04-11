//
//  GoalDetailView.swift
//  TaskBubble
//
//  Created by Shalyca Sottoriva on 11/04/2026.
//

// GoalDetailView.swift
// TaskBubble
// GoalDetailView.swift
// TaskBubble

import CoreData
import SwiftUI

struct GoalDetailView: View {
    @ObservedObject var goal: Goal
    let allGoals: [Goal]
    @ObservedObject var appDetectionService: AppDetectionService

    var onBack: () -> Void
    var onSelectGoal: (Goal) -> Void
    var onSelectTask: (Item) -> Void
    var onAddTask: () -> Void
    var onEditGoal: () -> Void
    var onNavigate: ((TBPage) -> Void)? = nil

    @Environment(\.managedObjectContext) private var viewContext
    @State private var selectedFilter: GoalFilter = .all
    @State private var archivingIDs: Set<NSManagedObjectID> = []
    @State private var showNavDrawer = false
    @State private var showCoverPicker = false

    enum GoalFilter: String, CaseIterable, Identifiable {
        case all = "All", tasks = "Tasks", routine = "Routine", done = "Done"
        var id: String { rawValue }
    }

    private var filteredTasks: [Item] {
        let sorted = goal.taskArray.sorted {
            ($0.timestamp ?? .distantPast) > ($1.timestamp ?? .distantPast)
        }
        switch selectedFilter {
        case .all:     return sorted.filter { !$0.completed || archivingIDs.contains($0.objectID) }
        case .tasks:   return sorted.filter { !$0.completed }
        case .routine: return sorted.filter { !$0.completed }
        case .done:    return sorted.filter { $0.completed }
        }
    }

    var body: some View {
        ZStack(alignment: .topLeading) {
            AppColors.background.ignoresSafeArea()
            VStack(spacing: 0) {
                goalTabs
                coverBlock
                progressBlock
                filterPills
                ScrollView(showsIndicators: false) {
                    taskList
                        .padding(.top, 4).padding(.bottom, 16)
                }
                .scrollContentBackground(.hidden)
                TBAddFAB(label: "Add task to \(goal.name ?? "goal")", action: onAddTask)
            }
            if showNavDrawer {
                TBNavDrawer(isOpen: $showNavDrawer, currentPage: .goals) { page in
                    showNavDrawer = false; onNavigate?(page)
                }.zIndex(20)
            }
        }
        .sheet(isPresented: $showCoverPicker) {
            GoalCoverPickerView(goal: goal)
        }
    }

    // MARK: - Task list (broken out to help type-checker)

    private var taskList: some View {
        LazyVStack(spacing: 4) {
            if filteredTasks.isEmpty {
                emptyTasksView
            } else {
                ForEach(filteredTasks) { item in
                    taskRowView(for: item)
                }
            }
        }
    }

    private var emptyTasksView: some View {
        Text(goal.taskArray.isEmpty ? "No tasks yet — tap + to add" : "Nothing in this filter")
            .font(.custom("Montserrat-Regular", size: 12))
            .foregroundColor(Color.Surface.a50)
            .frame(maxWidth: .infinity).padding(.top, 20)
    }

    private func taskRowView(for item: Item) -> some View {
        TBTaskRow(
            item: item,
            appDetectionService: appDetectionService,
            showProjectFlag: true,
            isArchiving: archivingIDs.contains(item.objectID),
            onSelect: { onSelectTask(item) },
            onComplete: { handleComplete(item) }
        )
        .padding(.horizontal, 14)
    }

    // MARK: - Goal tabs

    private var goalTabs: some View {
        HStack(spacing: 0) {
            Button(action: onBack) {
                ZStack {
                    Circle().fill(Color.Surface.a20.opacity(0.4)).frame(width: 22, height: 22)
                    Image(systemName: "chevron.left")
                        .font(.system(size: 9, weight: .bold)).foregroundColor(Color.Surface.a60)
                }
            }
            .buttonStyle(.plain).padding(.leading, 12)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 0) {
                    ForEach(allGoals) { g in
                        goalTab(g)
                    }
                    Button(action: {}) {
                        Text("＋")
                            .font(.custom("Montserrat-Bold", size: 12))
                            .foregroundColor(AppColors.shalyPurple)
                            .padding(.horizontal, 10).padding(.vertical, 8)
                    }.buttonStyle(.plain)
                }
            }

            HStack(spacing: 0) {
                Button { withAnimation { showNavDrawer.toggle() } } label: {
                    ZStack {
                        Circle().fill(Color.Surface.a20.opacity(0.4)).frame(width: 22, height: 22)
                        VStack(spacing: 2.5) {
                            ForEach(0..<3, id: \.self) { _ in
                                Rectangle().fill(Color.Surface.a60).frame(width: 9, height: 1.2).cornerRadius(1)
                            }
                        }
                    }
                }.buttonStyle(.plain)

                Button(action: onEditGoal) {
                    ZStack {
                        Circle().fill(Color.Surface.a20.opacity(0.4)).frame(width: 22, height: 22)
                        Image(systemName: "square.and.pencil")
                            .font(.system(size: 9)).foregroundColor(Color.Surface.a50)
                    }
                }.buttonStyle(.plain).padding(.leading, 5)
            }
            .padding(.trailing, 12)
        }
        .padding(.vertical, 8)
        .background(AppColors.background)
        .overlay(Rectangle().frame(height: 0.5).foregroundColor(Color.Surface.a30.opacity(0.4)), alignment: .bottom)
    }

    private func goalTab(_ g: Goal) -> some View {
        let isActive = g.objectID == goal.objectID
        return Button { onSelectGoal(g) } label: {
            Text(g.name ?? "Goal")
                .font(.custom(isActive ? "Montserrat-Bold" : "Montserrat-Medium", size: 11))
                .foregroundColor(isActive ? g.displayColor : Color.Surface.a50)
                .padding(.horizontal, 12).padding(.vertical, 8)
                .overlay(
                    Rectangle()
                        .fill(isActive ? g.displayColor : Color.clear)
                        .frame(height: 2),
                    alignment: .bottom
                )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Cover

    private var coverBlock: some View {
        ZStack(alignment: .bottomLeading) {
            if let data = goal.coverImageData, let nsImg = NSImage(data: data) {
                Image(nsImage: nsImg)
                    .resizable().scaledToFill()
                    .frame(height: 72).clipped()
                    .overlay(Color.black.opacity(0.35))
            } else {
                Rectangle().fill(goal.displayColor.opacity(0.18)).frame(height: 72)
            }

            // Edit cover
            Button { showCoverPicker = true } label: {
                HStack(spacing: 3) {
                    Image(systemName: "photo").font(.system(size: 8))
                    Text("Cover").font(.custom("Montserrat-SemiBold", size: 8))
                }
                .foregroundColor(.white.opacity(0.8))
                .padding(.horizontal, 7).padding(.vertical, 3)
                .background(RoundedRectangle(cornerRadius: 5).fill(Color.black.opacity(0.3)))
            }
            .buttonStyle(.plain).padding(7)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)

            // Title
            VStack(alignment: .leading, spacing: 2) {
                Text(goal.name ?? "Untitled")
                    .font(.custom("Montserrat-Bold", size: 16)).foregroundColor(.white)
                if let dl = goal.deadline {
                    Text("Due \(dl, style: .date)")
                        .font(.custom("Montserrat-Regular", size: 9)).foregroundColor(.white.opacity(0.7))
                }
            }
            .padding(10)
        }
        .frame(height: 72)
    }

    // MARK: - Progress block

    private var progressBlock: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 8) {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 99).fill(Color.Surface.a20.opacity(0.5)).frame(height: 4)
                        RoundedRectangle(cornerRadius: 99)
                            .fill(goal.progress >= 1.0 ? Color.Success.a0 : goal.displayColor)
                            .frame(width: geo.size.width * CGFloat(goal.progress), height: 4)
                    }
                }
                .frame(height: 4)
                Text("\(Int(goal.progress * 100))%")
                    .font(.custom("Montserrat-Bold", size: 10))
                    .foregroundColor(goal.progress >= 1.0 ? Color.Success.a0 : goal.displayColor)
            }

            HStack(spacing: 12) {
                Text("\(goal.completedCount) done")
                    .font(.custom("Montserrat-Regular", size: 9)).foregroundColor(Color.Surface.a50)
                Text("\(goal.taskCount - goal.completedCount) left")
                    .font(.custom("Montserrat-Regular", size: 9)).foregroundColor(Color.Surface.a50)
                Spacer()
                linkedProjectChips
            }
        }
        .padding(.horizontal, 14).padding(.vertical, 8)
        .background(Color.Surface.a10.opacity(0.5))
        .overlay(Rectangle().frame(height: 0.5).foregroundColor(Color.Surface.a30.opacity(0.3)), alignment: .bottom)
    }

    @ViewBuilder
    private var linkedProjectChips: some View {
        if let projs = goal.projects as? Set<Project>, !projs.isEmpty {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 5) {
                    ForEach(Array(projs), id: \.objectID) { proj in
                        HStack(spacing: 3) {
                            Image(systemName: "folder.fill").font(.system(size: 7)).foregroundColor(proj.color)
                            Text(proj.name ?? "").font(.custom("Montserrat-Bold", size: 8)).foregroundColor(proj.color)
                        }
                        .padding(.horizontal, 6).padding(.vertical, 2)
                        .background(proj.color.opacity(0.12)).cornerRadius(5)
                        .overlay(RoundedRectangle(cornerRadius: 5).stroke(proj.color.opacity(0.3), lineWidth: 0.5))
                    }
                }
            }
        }
    }

    // MARK: - Filter pills

    private var filterPills: some View {
        HStack(spacing: 6) {
            ForEach(GoalFilter.allCases) { f in
                filterPill(f)
            }
            Spacer()
        }
        .padding(.horizontal, 14).padding(.vertical, 7)
    }

    private func filterPill(_ f: GoalFilter) -> some View {
        Button { selectedFilter = f } label: {
            HStack(spacing: 3) {
                if f == .routine {
                    Image(systemName: "repeat").font(.system(size: 8))
                }
                Text(f.rawValue).font(.custom("Montserrat-Bold", size: 9))
            }
            .padding(.horizontal, 10).padding(.vertical, 4)
            .background(Capsule().fill(selectedFilter == f ? goal.displayColor : Color.Surface.a20.opacity(0.5)))
            .overlay(Capsule().stroke(selectedFilter == f ? goal.displayColor : Color.Surface.a30.opacity(0.5), lineWidth: 0.5))
            .foregroundColor(selectedFilter == f ? .white : Color.Surface.a60)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Complete + archive

    private func handleComplete(_ item: Item) {
        guard !item.completed else { return }
        item.completed = true
        try? viewContext.save()
        withAnimation { _ = archivingIDs.insert(item.objectID) }
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            withAnimation { _ = archivingIDs.remove(item.objectID) }
        }
    }
}

// MARK: - Cover picker

struct GoalCoverPickerView: View {
    @ObservedObject var goal: Goal
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 16) {
            Text("Choose Cover Image")
                .font(.custom("Montserrat-Bold", size: 15)).foregroundColor(AppColors.textWhite)
            Text("Drag and drop an image, or click to browse")
                .font(.custom("Montserrat-Regular", size: 11)).foregroundColor(Color.Surface.a50)
                .multilineTextAlignment(.center)

            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.Surface.a30.opacity(0.5), style: StrokeStyle(lineWidth: 1, dash: [6, 4]))
                .frame(height: 100)
                .overlay(
                    VStack(spacing: 6) {
                        Image(systemName: "photo.badge.plus").font(.system(size: 24)).foregroundColor(Color.Surface.a40)
                        Text("Drop image here").font(.custom("Montserrat-Regular", size: 11)).foregroundColor(Color.Surface.a50)
                    }
                )
                .onDrop(of: ["public.image"], isTargeted: nil) { providers in
                    providers.first?.loadDataRepresentation(forTypeIdentifier: "public.image") { data, _ in
                        if let data = data {
                            DispatchQueue.main.async {
                                goal.coverImageData = data
                                try? viewContext.save()
                                dismiss()
                            }
                        }
                    }
                    return true
                }

            HStack(spacing: 10) {
                if goal.coverImageData != nil {
                    Button("Remove cover") {
                        goal.coverImageData = nil
                        try? viewContext.save()
                        dismiss()
                    }
                    .buttonStyle(.plain).foregroundColor(Color.Danger.a10)
                    .font(.custom("Montserrat-SemiBold", size: 12))
                }
                Spacer()
                Button("Cancel") { dismiss() }
                    .buttonStyle(.plain).foregroundColor(Color.Surface.a60)
                    .font(.custom("Montserrat-Regular", size: 12))
            }
        }
        .padding(20).background(AppColors.background)
        .frame(width: 300, height: 240)
    }
}
