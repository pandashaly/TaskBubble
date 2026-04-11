//
//  TodayView.swift
//  TaskBubble
//
//  Created by Shalyca Sottoriva on 11/04/2026.
//

// TodayView.swift
// TaskBubble
//
// Core Data: add `todayOrder` (Integer 32, optional) and `todayDate` (Date, optional) to Item entity.
// todayDate = the calendar day this task was added to Today.
// todayOrder = drag-sort index within the Today list.
// TodayView.swift
// TaskBubble
// TodayView.swift
// TaskBubble

import CoreData
import SwiftUI

struct TodayView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var appDetectionService: AppDetectionService
    @ObservedObject var waterService: WaterIntakeService

    var onSelectTask: (Item) -> Void
    var onAddTask: () -> Void
    var onSearch: () -> Void
    var onNavigate: ((TBPage) -> Void)? = nil
    var onBatchFocus: () -> Void

    // All items passed from ContentView — we filter client-side
    // so we don't depend on todayDate/todayOrder being in Core Data yet.
    let allItems: [Item]

    @State private var showNavDrawer = false
    @State private var showCalendarPopup = false
    @State private var archivingIDs: Set<NSManagedObjectID> = []
    @State private var showCarryOverPrompt = false
    @State private var yesterdayLeftovers: [Item] = []

    // Today items: category == "Today" and not completed,
    // OR items the user explicitly added to today (todayDate == today if property exists).
    // Falls back gracefully if todayDate isn't in the model yet.
    private var todayActive: [Item] {
        allItems
            .filter { item in
                guard !item.completed else { return false }
                // If todayDate is available and set to today, include it
                if let td = item.value(forKey: "todayDate") as? Date {
                    return Calendar.current.isDateInToday(td)
                }
                // Fallback: show Today category tasks
                return item.category == TaskCategory.today.rawValue
            }
            .sorted {
                // Use todayOrder if available, otherwise timestamp descending
                let o0 = (($0.value(forKey: "todayOrder") as? Int32) ?? 0)
                let o1 = (($1.value(forKey: "todayOrder") as? Int32) ?? 0)
                if o0 != o1 { return o0 < o1 }
                return ($0.timestamp ?? .distantPast) > ($1.timestamp ?? .distantPast)
            }
    }

    private var todayDone: [Item] {
        allItems.filter { item in
            guard item.completed else { return false }
            if let td = item.value(forKey: "todayDate") as? Date {
                return Calendar.current.isDateInToday(td)
            }
            return item.category == TaskCategory.today.rawValue
        }
    }

    private var totalCount: Int { todayActive.count + todayDone.count }
    private var progress: Double {
        guard totalCount > 0 else { return 0 }
        return Double(todayDone.count) / Double(totalCount)
    }

    var body: some View {
        ZStack(alignment: .topLeading) {
            AppColors.background.ignoresSafeArea()

            VStack(spacing: 0) {
                headerBar

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        dateProgressBlock
                        Divider().background(Color.Surface.a30.opacity(0.3))
                        taskListSection
                    }
                }
                .scrollContentBackground(.hidden)

                TBAddFAB(label: "Add to Today", action: onAddTask)
            }

            if showNavDrawer {
                TBNavDrawer(isOpen: $showNavDrawer, currentPage: .today) { page in
                    showNavDrawer = false; onNavigate?(page)
                }.zIndex(20)
            }
        }
        .sheet(isPresented: $showCalendarPopup) {
            TodayCalendarSheet()
        }
    }

    // MARK: - Header

    private var headerBar: some View {
        HStack(alignment: .center) {
            TBWindowControls()
            Button { withAnimation { showNavDrawer.toggle() } } label: {
                ZStack {
                    Circle().fill(Color.Surface.a20.opacity(0.45)).frame(width: 22, height: 22)
                    VStack(spacing: 3) {
                        ForEach(0..<3, id: \.self) { _ in
                            Rectangle().fill(Color.Surface.a60).frame(width: 9, height: 1.2).cornerRadius(1)
                        }
                    }
                }
            }.buttonStyle(.plain).padding(.leading, 5)

            HStack(spacing: 6) {
                Image(systemName: "sun.max.fill")
                    .font(.system(size: 12, weight: .semibold)).foregroundColor(.yellow)
                Text("Today")
                    .font(.custom("Montserrat-Bold", size: 15)).foregroundColor(AppColors.textWhite)
            }.padding(.leading, 5)

            Spacer()

            HStack(spacing: 0) {
                circleBtn("magnifyingglass", action: onSearch)
                circleBtn("plus", filled: true, action: onAddTask)
            }
        }
        .padding(.horizontal, 12).padding(.vertical, 9)
        .overlay(Rectangle().frame(height: 0.5).foregroundColor(Color.Surface.a30.opacity(0.4)), alignment: .bottom)
    }

    // MARK: - Date + progress + water + batch

    private var dateProgressBlock: some View {
        VStack(spacing: 0) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(weekdayString)
                        .font(.custom("Montserrat-Bold", size: 10))
                        .foregroundColor(AppColors.shalyPurple).tracking(0.5)
                    Button(action: { showCalendarPopup = true }) {
                        Text(dateString)
                            .font(.custom("Montserrat-Bold", size: 24))
                            .foregroundColor(AppColors.textWhite)
                    }
                    .buttonStyle(.plain)
                    Text("\(totalCount) tasks · \(todayDone.count) done")
                        .font(.custom("Montserrat-Regular", size: 10)).foregroundColor(Color.Surface.a50)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 6) {
                    VStack(alignment: .trailing, spacing: 1) {
                        Text("\(Int(progress * 100))%")
                            .font(.custom("Montserrat-Bold", size: 20))
                            .foregroundColor(progress >= 1 ? Color.Success.a0 : AppColors.shalyPurple)
                        Text("complete")
                            .font(.custom("Montserrat-Regular", size: 9)).foregroundColor(Color.Surface.a50)
                    }
                    waterMini
                }
            }
            .padding(.horizontal, 14).padding(.top, 10).padding(.bottom, 8)

            // Progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Rectangle().fill(Color.Surface.a20.opacity(0.5)).frame(height: 4)
                    Rectangle()
                        .fill(progress >= 1 ? Color.Success.a0 : AppColors.shalyPurple)
                        .frame(width: geo.size.width * CGFloat(progress), height: 4)
                        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: progress)
                }
            }
            .frame(height: 4)
            .padding(.horizontal, 14).padding(.bottom, 10)

            // Batch focus button
            Button(action: onBatchFocus) {
                HStack(spacing: 7) {
                    ZStack {
                        Circle().fill(AppColors.shalyPurple.opacity(0.2)).frame(width: 26, height: 26)
                        Image(systemName: "timer")
                            .font(.system(size: 12, weight: .semibold)).foregroundColor(AppColors.shalyPurple)
                    }
                    VStack(alignment: .leading, spacing: 1) {
                        Text("Batch Focus Mode")
                            .font(.custom("Montserrat-Bold", size: 12)).foregroundColor(AppColors.textWhite)
                        Text("Select tasks · set timer · execute")
                            .font(.custom("Montserrat-Regular", size: 9)).foregroundColor(Color.Surface.a50)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 9, weight: .semibold)).foregroundColor(Color.Surface.a40)
                }
                .padding(.horizontal, 12).padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(AppColors.shalyPurple.opacity(0.09))
                        .overlay(RoundedRectangle(cornerRadius: 10)
                            .stroke(AppColors.shalyPurple.opacity(0.25), lineWidth: 0.5))
                )
                .padding(.horizontal, 14).padding(.bottom, 10)
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Water mini

    private var waterMini: some View {
        Button(action: { waterService.updateIntake(delta: 1) }) {
            HStack(spacing: 4) {
                Image(systemName: "drop.fill").font(.system(size: 11)).foregroundColor(Color.water)
                Text("\(waterService.currentIntake)")
                    .font(.custom("Montserrat-Bold", size: 11)).foregroundColor(AppColors.textWhite)
                Image(systemName: "plus").font(.system(size: 8, weight: .bold)).foregroundColor(Color.water.opacity(0.7))
            }
            .padding(.horizontal, 8).padding(.vertical, 4)
            .background(RoundedRectangle(cornerRadius: 8).fill(Color.water.opacity(0.1)))
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.water.opacity(0.3), lineWidth: 0.5))
        }
        .buttonStyle(.plain)
        .contextMenu { Button("Reset water") { waterService.resetIntake() } }
    }

    // MARK: - Task list with drag-to-reorder

    private var taskListSection: some View {
        VStack(spacing: 0) {
            if totalCount == 0 {
                emptyState
            } else {
                // Active tasks — draggable via List
                if !todayActive.isEmpty {
                    List {
                        ForEach(todayActive) { item in
                            TBTaskRow(
                                item: item,
                                appDetectionService: appDetectionService,
                                showProjectFlag: true,
                                isArchiving: archivingIDs.contains(item.objectID),
                                onSelect: { onSelectTask(item) },
                                onComplete: { handleComplete(item) }
                            )
                        }
                        .onMove { from, to in reorderActive(from: from, to: to) }
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                    .scrollDisabled(true)
                    .frame(height: CGFloat(todayActive.count) * 52)
                }

                // Done section
                if !todayDone.isEmpty {
                    HStack(spacing: 5) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 9)).foregroundColor(Color.Success.a0)
                        Text("DONE TODAY")
                            .font(.custom("Montserrat-Bold", size: 9))
                            .foregroundColor(Color.Success.a0).tracking(0.6)
                        Spacer()
                    }
                    .padding(.horizontal, 14).padding(.top, 10).padding(.bottom, 4)

                    VStack(spacing: 4) {
                        ForEach(todayDone) { item in
                            TBTaskRow(
                                item: item,
                                appDetectionService: appDetectionService,
                                showProjectFlag: true,
                                onSelect: { onSelectTask(item) },
                                onComplete: {}
                            )
                            .padding(.horizontal, 14)
                            .opacity(0.55)
                        }
                    }
                    .padding(.bottom, 8)
                }
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 10) {
            Image(systemName: "sun.max")
                .font(.system(size: 28)).foregroundColor(Color.Surface.a30)
            Text("Nothing planned yet")
                .font(.custom("Montserrat-SemiBold", size: 13)).foregroundColor(Color.Surface.a50)
            Text("Add tasks to focus on today")
                .font(.custom("Montserrat-Regular", size: 11)).foregroundColor(Color.Surface.a40)
        }
        .frame(maxWidth: .infinity).padding(.vertical, 30)
    }

    // MARK: - Helpers

    private var weekdayString: String {
        let f = DateFormatter(); f.dateFormat = "EEEE"; return f.string(from: Date()).uppercased()
    }
    private var dateString: String {
        let f = DateFormatter(); f.dateFormat = "MMMM d"; return f.string(from: Date())
    }

    private func handleComplete(_ item: Item) {
        guard !item.completed else { return }
        item.completed = true
        try? viewContext.save()
        withAnimation { _ = archivingIDs.insert(item.objectID) }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation { _ = archivingIDs.remove(item.objectID) }
        }
    }

    private func reorderActive(from source: IndexSet, to destination: Int) {
        var reordered = todayActive
        reordered.move(fromOffsets: source, toOffset: destination)
        for (idx, item) in reordered.enumerated() {
            item.setValue(Int32(idx), forKey: "todayOrder")
        }
        try? viewContext.save()
    }

    private func circleBtn(_ icon: String, filled: Bool = false, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(filled ? Color(nsColor: .textBackgroundColor) : Color(nsColor: .controlBackgroundColor))
                    .frame(width: 22, height: 22)
                    .overlay(Circle().strokeBorder(Color.gray.opacity(0.32), lineWidth: 0.5))
                Image(systemName: icon)
                    .font(.system(size: 9, weight: .medium))
                    .foregroundColor(Color(red: 0.32, green: 0.38, blue: 0.47))
            }
        }.buttonStyle(.plain).padding(.leading, -4)
    }
}

// MARK: - Calendar sheet

struct TodayCalendarSheet: View {
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Calendar")
                    .font(.custom("Montserrat-Bold", size: 15)).foregroundColor(AppColors.textWhite)
                Spacer()
                Button("Done") { dismiss() }
                    .buttonStyle(.plain).foregroundColor(AppColors.shalyPurple)
                    .font(.custom("Montserrat-SemiBold", size: 12))
            }
            .padding(.horizontal, 14).padding(.vertical, 12)
            Divider().background(Color.Surface.a30.opacity(0.4))
            Text("Wire up TaskCalendarBlock here")
                .font(.custom("Montserrat-Regular", size: 12)).foregroundColor(Color.Surface.a50)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .background(AppColors.background)
        .frame(width: 320, height: 340)
    }
}
