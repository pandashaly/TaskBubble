//
//  TaskCalendarBlock.swift
//  TaskBubble
//
//  Reusable week/month calendar with deadline dots. Pass items + callbacks; use anywhere.
//
//
//import CoreData
//import SwiftUI
//
//enum TaskCalendarItemHelpers {
//    static func tasksWithDeadline(on day: Date, items: [Item], calendar: Calendar = .current) -> [Item] {
//        items.filter { item in
//            guard let dl = item.deadline else { return false }
//            return calendar.isDate(dl, inSameDayAs: day)
//        }
//        .sorted {
//            ($0.deadline ?? .distantPast) < ($1.deadline ?? .distantPast)
//        }
//    }
//
//    /// Dot when at least one **incomplete** task is due that day.
//    static func hasIncompleteDeadline(on day: Date, items: [Item], calendar: Calendar = .current) -> Bool {
//        items.contains { item in
//            guard !item.completed, let dl = item.deadline else { return false }
//            return calendar.isDate(dl, inSameDayAs: day)
//        }
//    }
//}
//
//struct TaskCalendarBlock: View {
//    /// Tasks whose `deadline` is used for dots and day lists (typically all fetched items).
//    let items: [Item]
//    @Binding var scope: TaskCalendarScope
//    /// Called when the user taps a day. Second argument is tasks with a deadline on that calendar day (may be empty).
//    var onSelectDay: (Date, [Item]) -> Void
//
//    @State private var focusDate: Date = Date()
//    @State private var selectedDay: Date = Calendar.current.startOfDay(for: Date())
//
//    private let calendar = Calendar.current
//
//    private let cardInset: CGFloat = 8
//
//    var body: some View {
//        VStack(alignment: .leading, spacing: 6) {
//            header
//
//            switch scope {
//            case .week:
//                TaskCalendarWeekStrip(
//                    weekDates: weekDates(containing: focusDate),
//                    selectedDay: $selectedDay,
//                    items: items,
//                    onSelectDay: onSelectDay
//                )
//            case .month:
//                TaskCalendarMonthGrid(
//                    focusMonth: focusDate,
//                    selectedDay: $selectedDay,
//                    items: items,
//                    onSelectDay: onSelectDay
//                )
//            }
//        }
//        .padding(cardInset)
//        .background(Color.blue.opacity(0.08))
//        .cornerRadius(12)
//        .padding(.horizontal)
//    }
//
//    private var header: some View {
//        HStack(spacing: 8) {
//            Button {
//                stepFocus(-1)
//            } label: {
//                Image(systemName: "chevron.left")
//                    .font(.caption.weight(.semibold))
//                    .foregroundStyle(.secondary)
//            }
//            .buttonStyle(.plain)
//
//            Spacer(minLength: 0)
//
//            HStack(spacing: 8) {
//                Text(monthYearString(for: focusDate))
//                    .font(.headline)
//                    .foregroundStyle(.primary)
//
//                Button {
//                    withAnimation(.easeInOut(duration: 0.2)) {
//                        scope = scope == .week ? .month : .week
//                    }
//                } label: {
//                    Image(systemName: "calendar")
//                        .font(.body.weight(.medium))
//                        .foregroundStyle(Color.blue.opacity(scope == .month ? 1.0 : 0.65))
//                        .frame(width: 30, height: 30)
//                        .background(
//                            Circle()
//                                .fill(scope == .month ? Color.blue.opacity(0.2) : Color.blue.opacity(0.1))
//                        )
//                        .overlay(
//                            Circle()
//                                .strokeBorder(Color.blue.opacity(scope == .month ? 0.45 : 0.22), lineWidth: 0.5)
//                        )
//                }
//                .buttonStyle(.plain)
//                .help(scope == .month ? "Show week view" : "Show month view")
//            }
//
//            Spacer(minLength: 0)
//
//            Button {
//                stepFocus(1)
//            } label: {
//                Image(systemName: "chevron.right")
//                    .font(.caption.weight(.semibold))
//                    .foregroundStyle(.secondary)
//            }
//            .buttonStyle(.plain)
//        }
//    }
//
//    private func monthYearString(for date: Date) -> String {
//        let f = DateFormatter()
//        f.dateFormat = "MMMM yyyy"
//        return f.string(from: date)
//    }
//
//    private func stepFocus(_ delta: Int) {
//        if scope == .week {
//            guard let next = calendar.date(byAdding: .day, value: 7 * delta, to: focusDate) else { return }
//            focusDate = next
//        } else {
//            guard let next = calendar.date(byAdding: .month, value: delta, to: focusDate) else { return }
//            focusDate = next
//        }
//    }
//
//    private func weekDates(containing date: Date) -> [Date] {
//        guard let interval = calendar.dateInterval(of: .weekOfYear, for: date) else { return [] }
//        var days: [Date] = []
//        var d = interval.start
//        for _ in 0..<7 {
//            days.append(d)
//            guard let next = calendar.date(byAdding: .day, value: 1, to: d) else { break }
//            d = next
//        }
//        return days
//    }
//}
//
//// MARK: - Week strip
//
//struct TaskCalendarWeekStrip: View {
//    let weekDates: [Date]
//    @Binding var selectedDay: Date
//    let items: [Item]
//    var onSelectDay: (Date, [Item]) -> Void
//
//    private let calendar = Calendar.current
//
//    var body: some View {
//        VStack(spacing: 4) {
//            HStack(spacing: 0) {
//                ForEach(weekDates, id: \.timeIntervalSince1970) { day in
//                    Text(day, format: .dateTime.weekday(.narrow))
//                        .font(.caption2)
//                        .foregroundStyle(.secondary)
//                        .frame(maxWidth: .infinity)
//                }
//            }
//
//            HStack(spacing: 0) {
//                ForEach(weekDates, id: \.timeIntervalSince1970) { day in
//                    TaskCalendarDayCell(
//                        day: day,
//                        isSelected: calendar.isDate(day, inSameDayAs: selectedDay),
//                        hasDeadline: TaskCalendarItemHelpers.hasIncompleteDeadline(on: day, items: items)
//                    ) {
//                        selectedDay = calendar.startOfDay(for: day)
//                        let list = TaskCalendarItemHelpers.tasksWithDeadline(on: selectedDay, items: items)
//                        onSelectDay(selectedDay, list)
//                    }
//                    .frame(maxWidth: .infinity)
//                }
//            }
//        }
//    }
//}
//
//// MARK: - Month grid
//
//struct TaskCalendarMonthGrid: View {
//    let focusMonth: Date
//    @Binding var selectedDay: Date
//    let items: [Item]
//    var onSelectDay: (Date, [Item]) -> Void
//
//    private let calendar = Calendar.current
//    private let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 7)
//
//    var body: some View {
//        let cells = monthCells(for: focusMonth)
//
//        VStack(spacing: 4) {
//            HStack(spacing: 0) {
//                ForEach(0..<7, id: \.self) { i in
//                    let wd = (calendar.firstWeekday - 1 + i) % 7 + 1
//                    Text(calendar.veryShortWeekdaySymbols[wd - 1])
//                        .font(.caption2)
//                        .foregroundStyle(.secondary)
//                        .frame(maxWidth: .infinity)
//                }
//            }
//
//            LazyVGrid(columns: columns, spacing: 3) {
//                ForEach(Array(cells.enumerated()), id: \.offset) { _, cell in
//                    if let day = cell {
//                        TaskCalendarDayCell(
//                            day: day,
//                            isSelected: calendar.isDate(day, inSameDayAs: selectedDay),
//                            hasDeadline: TaskCalendarItemHelpers.hasIncompleteDeadline(on: day, items: items),
//                            compact: true
//                        ) {
//                            selectedDay = calendar.startOfDay(for: day)
//                            let list = TaskCalendarItemHelpers.tasksWithDeadline(on: selectedDay, items: items)
//                            onSelectDay(selectedDay, list)
//                        }
//                    } else {
//                        Color.clear
//                            .frame(height: 26)
//                    }
//                }
//            }
//        }
//    }
//
//    private func monthCells(for month: Date) -> [Date?] {
//        guard
//            let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: month)),
//            let range = calendar.range(of: .day, in: .month, for: monthStart)
//        else { return [] }
//
//        let firstWeekday = calendar.component(.weekday, from: monthStart)
//        let leading = (firstWeekday - calendar.firstWeekday + 7) % 7
//
//        var cells: [Date?] = Array(repeating: nil, count: leading)
//        for day in range {
//            if let d = calendar.date(byAdding: .day, value: day - 1, to: monthStart) {
//                cells.append(d)
//            }
//        }
//        while cells.count % 7 != 0 {
//            cells.append(nil)
//        }
//        return cells
//    }
//}
//
//// MARK: - Day cell
//
//struct TaskCalendarDayCell: View {
//    let day: Date
//    let isSelected: Bool
//    let hasDeadline: Bool
//    var compact: Bool = false
//    let action: () -> Void
//
//    private let calendar = Calendar.current
//
//    var body: some View {
//        Button(action: action) {
//            VStack(spacing: compact ? 2 : 3) {
//                Text("\(calendar.component(.day, from: day))")
//                    .font(compact ? .caption2.weight(.medium) : .subheadline.weight(.medium))
//                    .foregroundStyle(isSelected ? Color.blue : Color.secondary)
//
//                Circle()
//                    .fill(hasDeadline ? Color.blue : Color.clear)
//                    .frame(width: compact ? 4 : 5, height: compact ? 4 : 5)
//            }
//            .frame(maxWidth: .infinity)
//            .padding(.vertical, compact ? 3 : 6)
//            .background(
//                Circle()
//                    .fill(isSelected ? Color.blue.opacity(0.12) : Color.gray.opacity(0.06))
//            )
//            .overlay(
//                Circle()
//                    .strokeBorder(
//                        isSelected ? Color.blue : Color.gray.opacity(0.35),
//                        lineWidth: isSelected ? 1.25 : 0.5
//                    )
//            )
//        }
//        .buttonStyle(.plain)
//        .contentShape(Circle())
//    }
//}


// TaskCalendarBlock.swift
// TaskBubble — red deadline dots, same logic

import CoreData
import SwiftUI

enum TaskCalendarItemHelpers {
    static func tasksWithDeadline(on day: Date, items: [Item], calendar: Calendar = .current) -> [Item] {
        items.filter { item in
            guard let dl = item.deadline else { return false }
            return calendar.isDate(dl, inSameDayAs: day)
        }
        .sorted { ($0.deadline ?? .distantPast) < ($1.deadline ?? .distantPast) }
    }

    static func hasIncompleteDeadline(on day: Date, items: [Item], calendar: Calendar = .current) -> Bool {
        items.contains { item in
            guard !item.completed, let dl = item.deadline else { return false }
            return calendar.isDate(dl, inSameDayAs: day)
        }
    }
}

struct TaskCalendarBlock: View {
    let items: [Item]
    @Binding var scope: TaskCalendarScope
    var onSelectDay: (Date, [Item]) -> Void

    @State private var focusDate: Date = Date()
    @State private var selectedDay: Date = Calendar.current.startOfDay(for: Date())
    private let calendar = Calendar.current

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            header
            switch scope {
            case .week:
                TaskCalendarWeekStrip(weekDates: weekDates(containing: focusDate),
                                      selectedDay: $selectedDay, items: items, onSelectDay: onSelectDay)
            case .month:
                TaskCalendarMonthGrid(focusMonth: focusDate,
                                      selectedDay: $selectedDay, items: items, onSelectDay: onSelectDay)
            }
        }
        .padding(8)
        .background(Color.blue.opacity(0.08))
        .cornerRadius(12)
        .padding(.horizontal)
    }

    private var header: some View {
        HStack(spacing: 8) {
            Button { stepFocus(-1) } label: {
                Image(systemName: "chevron.left").font(.caption.weight(.semibold)).foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
            Spacer(minLength: 0)
            HStack(spacing: 8) {
                Text(monthYearString(for: focusDate)).font(.headline).foregroundStyle(.primary)
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) { scope = scope == .week ? .month : .week }
                } label: {
                    Image(systemName: "calendar")
                        .font(.body.weight(.medium))
                        .foregroundStyle(Color.blue.opacity(scope == .month ? 1.0 : 0.65))
                        .frame(width: 30, height: 30)
                        .background(Circle().fill(scope == .month ? Color.blue.opacity(0.2) : Color.blue.opacity(0.1)))
                        .overlay(Circle().strokeBorder(Color.blue.opacity(scope == .month ? 0.45 : 0.22), lineWidth: 0.5))
                }
                .buttonStyle(.plain)
                .help(scope == .month ? "Show week view" : "Show month view")
            }
            Spacer(minLength: 0)
            Button { stepFocus(1) } label: {
                Image(systemName: "chevron.right").font(.caption.weight(.semibold)).foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
        }
    }

    private func monthYearString(for date: Date) -> String {
        let f = DateFormatter(); f.dateFormat = "MMMM yyyy"; return f.string(from: date)
    }

    private func stepFocus(_ delta: Int) {
        let component: Calendar.Component = scope == .week ? .day : .month
        let value = scope == .week ? 7 * delta : delta
        if let next = calendar.date(byAdding: component, value: value, to: focusDate) { focusDate = next }
    }

    private func weekDates(containing date: Date) -> [Date] {
        guard let interval = calendar.dateInterval(of: .weekOfYear, for: date) else { return [] }
        var days: [Date] = []; var d = interval.start
        for _ in 0..<7 { days.append(d); if let n = calendar.date(byAdding: .day, value: 1, to: d) { d = n } }
        return days
    }
}

struct TaskCalendarWeekStrip: View {
    let weekDates: [Date]
    @Binding var selectedDay: Date
    let items: [Item]
    var onSelectDay: (Date, [Item]) -> Void
    private let calendar = Calendar.current
    var body: some View {
        VStack(spacing: 4) {
            HStack(spacing: 0) {
                ForEach(weekDates, id: \.timeIntervalSince1970) { day in
                    Text(day, format: .dateTime.weekday(.narrow)).font(.caption2).foregroundStyle(.secondary).frame(maxWidth: .infinity)
                }
            }
            HStack(spacing: 0) {
                ForEach(weekDates, id: \.timeIntervalSince1970) { day in
                    TaskCalendarDayCell(
                        day: day,
                        isSelected: calendar.isDate(day, inSameDayAs: selectedDay),
                        hasDeadline: TaskCalendarItemHelpers.hasIncompleteDeadline(on: day, items: items)
                    ) {
                        selectedDay = calendar.startOfDay(for: day)
                        onSelectDay(selectedDay, TaskCalendarItemHelpers.tasksWithDeadline(on: selectedDay, items: items))
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
    }
}

struct TaskCalendarMonthGrid: View {
    let focusMonth: Date
    @Binding var selectedDay: Date
    let items: [Item]
    var onSelectDay: (Date, [Item]) -> Void
    private let calendar = Calendar.current
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 7)
    var body: some View {
        let cells = monthCells(for: focusMonth)
        VStack(spacing: 4) {
            HStack(spacing: 0) {
                ForEach(0..<7, id: \.self) { i in
                    let wd = (calendar.firstWeekday - 1 + i) % 7 + 1
                    Text(calendar.veryShortWeekdaySymbols[wd - 1]).font(.caption2).foregroundStyle(.secondary).frame(maxWidth: .infinity)
                }
            }
            LazyVGrid(columns: columns, spacing: 3) {
                ForEach(Array(cells.enumerated()), id: \.offset) { _, cell in
                    if let day = cell {
                        TaskCalendarDayCell(
                            day: day,
                            isSelected: calendar.isDate(day, inSameDayAs: selectedDay),
                            hasDeadline: TaskCalendarItemHelpers.hasIncompleteDeadline(on: day, items: items),
                            compact: true
                        ) {
                            selectedDay = calendar.startOfDay(for: day)
                            onSelectDay(selectedDay, TaskCalendarItemHelpers.tasksWithDeadline(on: selectedDay, items: items))
                        }
                    } else { Color.clear.frame(height: 26) }
                }
            }
        }
    }
    private func monthCells(for month: Date) -> [Date?] {
        guard let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: month)),
              let range = calendar.range(of: .day, in: .month, for: monthStart) else { return [] }
        let leading = (calendar.component(.weekday, from: monthStart) - calendar.firstWeekday + 7) % 7
        var cells: [Date?] = Array(repeating: nil, count: leading)
        for day in range { if let d = calendar.date(byAdding: .day, value: day - 1, to: monthStart) { cells.append(d) } }
        while cells.count % 7 != 0 { cells.append(nil) }
        return cells
    }
}

struct TaskCalendarDayCell: View {
    let day: Date; let isSelected: Bool; let hasDeadline: Bool
    var compact: Bool = false
    let action: () -> Void
    private let calendar = Calendar.current
    var body: some View {
        Button(action: action) {
            VStack(spacing: compact ? 2 : 3) {
                Text("\(calendar.component(.day, from: day))")
                    .font(compact ? .caption2.weight(.medium) : .subheadline.weight(.medium))
                    .foregroundStyle(isSelected ? Color.blue : Color.secondary)
                // ← RED dot instead of blue
                Circle()
                    .fill(hasDeadline ? Color.red.opacity(0.85) : Color.clear)
                    .frame(width: compact ? 4 : 5, height: compact ? 4 : 5)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, compact ? 3 : 6)
            .background(Circle().fill(isSelected ? Color.blue.opacity(0.12) : Color.gray.opacity(0.06)))
            .overlay(Circle().strokeBorder(isSelected ? Color.blue : Color.gray.opacity(0.35), lineWidth: isSelected ? 1.25 : 0.5))
        }
        .buttonStyle(.plain)
        .contentShape(Circle())
    }
}
