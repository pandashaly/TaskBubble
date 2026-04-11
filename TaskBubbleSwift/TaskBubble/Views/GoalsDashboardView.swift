//
//  GoalsDashboardView.swift
//  TaskBubble
//
//  Created by Shalyca Sottoriva on 11/04/2026.
//

// GoalsDashboardView.swift
// TaskBubble
//
// Core Data: add a "Goal" entity (see comments below).

import CoreData
import SwiftUI

// MARK: - Goal Core Data entity setup
//
// Add "Goal" entity to TaskBubble.xcdatamodeld:
//   id            UUID
//   name          String
//   notes         String   (optional)
//   colorHex      String   (optional)
//   deadline      Date     (optional)
//   coverImageData Binary  (optional) — stores the cover image as PNG data
//   timestamp     Date     (optional)
//   priority      Integer 16
//
// Relationships:
//   Goal → tasks   (To-Many, Item,    inverse: goal,    delete rule: Nullify)
//   Goal → projects (To-Many, Project, inverse: goals,   delete rule: Nullify)
//   Item    → goal  (To-One,  Goal,    optional, Nullify)
//   Project → goals (To-Many, Goal,    optional, Nullify)
// GoalsDashboardView.swift
// TaskBubble
//
// IMPORTANT — In your xcdatamodeld, set the Goal entity's Codegen to "Manual/None"
// then add Goal+CoreData.swift (provided separately) for the class + extensions.
// OR set Codegen to "Class Definition" and delete Goal+CoreData.swift entirely.

import CoreData
import SwiftUI

struct GoalsDashboardView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Goal.timestamp, ascending: false)],
        animation: .default
    ) private var goals: FetchedResults<Goal>

    var onSelectGoal: (Goal) -> Void
    var onAddGoal: () -> Void
    var onBack: () -> Void
    var onNavigate: ((TBPage) -> Void)? = nil

    @State private var showNavDrawer = false

    private var avgProgress: Int {
        guard !goals.isEmpty else { return 0 }
        let total = goals.reduce(0.0) { $0 + $1.progress }
        return Int((total / Double(goals.count)) * 100)
    }
    private var totalTasksLeft: Int {
        goals.reduce(0) { $0 + ($1.taskCount - $1.completedCount) }
    }

    var body: some View {
        ZStack(alignment: .topLeading) {
            AppColors.background.ignoresSafeArea()
            VStack(spacing: 0) {
                TBPageHeader(
                    title: "Goals", icon: "target",
                    onBack: onBack,
                    onNavDrawer: { withAnimation { showNavDrawer.toggle() } },
                    onAdd: onAddGoal,
                    accentColor: Color.Green.normal
                )
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        if !goals.isEmpty { statsRow }
                        LazyVStack(spacing: 10) {
                            ForEach(goals) { goal in
                                GoalCard(goal: goal)
                                    .onTapGesture { onSelectGoal(goal) }
                                    .padding(.horizontal, 14)
                            }
                            if goals.isEmpty { emptyState }
                        }
                        .padding(.top, 10).padding(.bottom, 16)
                    }
                }
                TBAddFAB(label: "Create new goal", action: onAddGoal)
            }
            if showNavDrawer {
                TBNavDrawer(isOpen: $showNavDrawer, currentPage: .goals) { page in
                    showNavDrawer = false; onNavigate?(page)
                }.zIndex(20)
            }
        }
    }

    private var statsRow: some View {
        HStack(spacing: 8) {
            statCard(value: "\(goals.count)", label: "active goals", color: Color.Green.normal)
            statCard(value: "\(avgProgress)%", label: "avg progress", color: Color.Success.a0)
            statCard(value: "\(totalTasksLeft)", label: "tasks left", color: AppColors.shalyPurple)
        }
        .padding(.horizontal, 14).padding(.top, 10).padding(.bottom, 4)
    }

    private func statCard(value: String, label: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(value).font(.custom("Montserrat-Bold", size: 18)).foregroundColor(color)
            Text(label).font(.custom("Montserrat-Regular", size: 9)).foregroundColor(Color.Surface.a50)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10).background(AppColors.card).cornerRadius(9)
        .overlay(RoundedRectangle(cornerRadius: 9).stroke(Color.Surface.a30.opacity(0.35), lineWidth: 0.5))
    }

    private var emptyState: some View {
        VStack(spacing: 10) {
            Image(systemName: "target").font(.system(size: 28)).foregroundColor(Color.Surface.a30)
            Text("No goals yet").font(.custom("Montserrat-SemiBold", size: 13)).foregroundColor(Color.Surface.a50)
            Text("Create a goal to track long-term progress")
                .font(.custom("Montserrat-Regular", size: 11)).foregroundColor(Color.Surface.a40)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity).padding(.vertical, 30).padding(.horizontal, 20)
    }
}

// MARK: - Goal card

struct GoalCard: View {
    @ObservedObject var goal: Goal

    private var statusLabel: String {
        if goal.progress >= 1.0 { return "COMPLETE" }
        if goal.completedCount > 0 { return "IN PROGRESS" }
        return "NOT STARTED"
    }
    private var statusColor: Color {
        if goal.progress >= 1.0 { return Color.Success.a0 }
        if goal.completedCount > 0 { return goal.displayColor }
        return Color.Surface.a40
    }
    private var isUrgent: Bool {
        guard let dl = goal.deadline else { return false }
        let twoWeeks = Calendar.current.date(byAdding: .day, value: 14, to: Date()) ?? Date()
        return dl <= twoWeeks && goal.progress < 1.0
    }

    var body: some View {
        VStack(spacing: 0) {
            // Cover
            ZStack(alignment: .bottomLeading) {
                coverBackground
                // Status dot top-left
                HStack(spacing: 4) {
                    Circle().fill(statusColor).frame(width: 7, height: 7)
                    Text(statusLabel)
                        .font(.custom("Montserrat-Bold", size: 8))
                        .foregroundColor(statusColor).tracking(0.5)
                }
                .padding(7)
                // Title + deadline top-right area (bottom of cover)
                HStack {
                    Spacer()
                    VStack(alignment: .trailing, spacing: 1) {
                        Text(goal.name ?? "Untitled")
                            .font(.custom("Montserrat-Bold", size: 14)).foregroundColor(.white)
                        if let dl = goal.deadline {
                            Text(dl, style: .date)
                                .font(.custom("Montserrat-Regular", size: 9)).foregroundColor(.white.opacity(0.7))
                        }
                    }
                    .padding(8)
                }
                // Urgent dot
                if isUrgent {
                    Circle().fill(Color.Danger.a0).frame(width: 8, height: 8)
                        .overlay(Circle().stroke(Color.white, lineWidth: 1.5))
                        .padding(6)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                }
            }
            .frame(height: 64)

            // Body
            VStack(alignment: .leading, spacing: 6) {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 99).fill(Color.Surface.a20.opacity(0.5)).frame(height: 4)
                        RoundedRectangle(cornerRadius: 99)
                            .fill(goal.progress >= 1.0 ? Color.Success.a0 : goal.displayColor)
                            .frame(width: geo.size.width * CGFloat(goal.progress), height: 4)
                    }
                }
                .frame(height: 4)

                HStack {
                    Text("\(goal.completedCount)/\(goal.taskCount) tasks")
                        .font(.custom("Montserrat-Regular", size: 10)).foregroundColor(Color.Surface.a50)
                    Spacer()
                    Text("\(Int(goal.progress * 100))%")
                        .font(.custom("Montserrat-Bold", size: 11))
                        .foregroundColor(goal.progress >= 1.0 ? Color.Success.a0 : goal.displayColor)
                    linkedProjectDots
                }
            }
            .padding(.horizontal, 10).padding(.vertical, 8)
            .background(AppColors.card)
        }
        .cornerRadius(12)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(goal.displayColor.opacity(0.25), lineWidth: 0.5))
        .contentShape(Rectangle())
    }

    @ViewBuilder
    private var coverBackground: some View {
        if let data = goal.coverImageData, let nsImg = NSImage(data: data) {
            Image(nsImage: nsImg)
                .resizable().scaledToFill()
                .frame(height: 64).clipped()
                .overlay(Color.black.opacity(0.35))
        } else {
            Rectangle().fill(goal.displayColor.opacity(0.18)).frame(height: 64)
        }
    }

    @ViewBuilder
    private var linkedProjectDots: some View {
        if let projs = goal.projects as? Set<Project>, !projs.isEmpty {
            HStack(spacing: 3) {
                ForEach(Array(projs.prefix(2)), id: \.objectID) { proj in
                    Circle().fill(proj.color).frame(width: 7, height: 7)
                }
                if projs.count > 2 {
                    Text("+\(projs.count - 2)")
                        .font(.custom("Montserrat-Bold", size: 8)).foregroundColor(Color.Surface.a50)
                }
            }
        }
    }
}
