//
//  TaskSearchView.swift
//  TaskBubble
//
//
//import SwiftUI
//import CoreData
//
//struct TaskSearchView: View {
//    let items: [Item]
//    var onSelect: (Item) -> Void
//
//    @Environment(\.dismiss) private var dismiss
//    @State private var query: String = ""
//
//    private var filtered: [Item] {
//        let q = query.trimmingCharacters(in: .whitespacesAndNewlines)
//        guard !q.isEmpty else { return [] }
//        return items.filter { ($0.title ?? "").localizedCaseInsensitiveContains(q) }
//    }
//
//    var body: some View {
//        VStack(spacing: 0) {
//            HStack {
//                Text("Search")
//                    .font(.headline)
//                Spacer()
//                Button("Done") { dismiss() }
//                    .buttonStyle(.plain)
//            }
//            .padding(.horizontal)
//            .padding(.top, 12)
//
//            TextField("Search tasks…", text: $query)
//                .textFieldStyle(.roundedBorder)
//                .padding()
//
//            if query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
//                Spacer()
//                Text("Type to search your tasks")
//                    .foregroundStyle(.secondary)
//                Spacer()
//            } else if filtered.isEmpty {
//                Spacer()
//                Text("No matches")
//                    .foregroundStyle(.secondary)
//                Spacer()
//            } else {
//                List(filtered, id: \.objectID) { item in
//                    Button {
//                        onSelect(item)
//                    } label: {
//                        HStack {
//                            Text(item.title ?? "Untitled")
//                                .lineLimit(1)
//                            Spacer()
//                            Text(item.category ?? "")
//                                .font(.caption)
//                                .foregroundStyle(.secondary)
//                        }
//                    }
//                    .buttonStyle(.plain)
//                }
//                .listStyle(.plain)
//            }
//        }
//        .frame(width: 340, height: 400)
//        .background(AppColors.background)
//    }
//}
//
//// TaskSearchView.swift
//// TaskBubble
//
//import SwiftUI
//import CoreData
//
//struct TaskSearchView: View {
//    let items: [Item]
//    var onSelect: (Item) -> Void
//    @Environment(\.dismiss) private var dismiss
//    @State private var query = ""
//    @State private var filterCategory: TaskCategory? = nil
//    @State private var filterStatus: SearchStatus = .all
//
//    enum SearchStatus: String, CaseIterable, Identifiable {
//        case all = "All", active = "Active", done = "Done"
//        var id: String { rawValue }
//    }
//
//    private var filtered: [Item] {
//        let q = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
//        return items.filter { item in
//            // Status filter
//            switch filterStatus {
//            case .active: if item.completed { return false }
//            case .done:   if !item.completed { return false }
//            case .all: break
//            }
//            // Category filter
//            if let cat = filterCategory, item.category != cat.rawValue { return false }
//            // Text filter
//            if q.isEmpty { return true }
//            if (item.title ?? "").lowercased().contains(q) { return true }
//            if (item.notes ?? "").lowercased().contains(q) { return true }
//            if let val = item.linkedResourceValue, val.lowercased().contains(q) { return true }
//            if let name = item.linkedResourceAppDisplayName, name.lowercased().contains(q) { return true }
//            return false
//        }
//        .sorted { ($0.timestamp ?? .distantPast) > ($1.timestamp ?? .distantPast) }
//    }
//
//    var body: some View {
//        VStack(spacing: 0) {
//            // Header
//            HStack {
//                Text("Search")
//                    .font(.custom("Montserrat-Bold", size: 15))
//                    .foregroundColor(AppColors.textWhite)
//                Spacer()
//                Button("Done") { dismiss() }
//                    .buttonStyle(.plain)
//                    .font(.custom("Montserrat-SemiBold", size: 13))
//                    .foregroundColor(AppColors.shalyPurple)
//            }
//            .padding(.horizontal, 14).padding(.top, 12).padding(.bottom, 8)
//
//            // Search field
//            HStack(spacing: 8) {
//                Image(systemName: "magnifyingglass").font(.system(size: 12)).foregroundColor(Color.Surface.a50)
//                TextField("Search tasks, notes, links…", text: $query)
//                    .font(.custom("Montserrat-Regular", size: 13))
//                    .textFieldStyle(.plain)
//                if !query.isEmpty {
//                    Button { query = "" } label: {
//                        Image(systemName: "xmark.circle.fill").font(.system(size: 12)).foregroundColor(Color.Surface.a40)
//                    }
//                    .buttonStyle(.plain)
//                }
//            }
//            .padding(.horizontal, 10).padding(.vertical, 8)
//            .background(Color.Surface.a10)
//            .cornerRadius(8)
//            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.Surface.a30.opacity(0.5), lineWidth: 0.5))
//            .padding(.horizontal, 14)
//
//            // Status pills
//            HStack(spacing: 6) {
//                ForEach(SearchStatus.allCases) { s in
//                    Button { filterStatus = s } label: {
//                        Text(s.rawValue)
//                            .font(.custom("Montserrat-Bold", size: 10))
//                            .padding(.horizontal, 10).padding(.vertical, 3)
//                            .background(Capsule().fill(filterStatus == s ? AppColors.shalyPurple : Color.Surface.a20.opacity(0.5)))
//                            .foregroundColor(filterStatus == s ? .white : Color.Surface.a60)
//                    }
//                    .buttonStyle(.plain)
//                }
//                Divider().frame(height: 14).padding(.horizontal, 2)
//                // Category filter
//                ScrollView(.horizontal, showsIndicators: false) {
//                    HStack(spacing: 6) {
//                        Button {
//                            filterCategory = nil
//                        } label: {
//                            Text("Any category")
//                                .font(.custom("Montserrat-Bold", size: 10))
//                                .padding(.horizontal, 8).padding(.vertical, 3)
//                                .background(Capsule().fill(filterCategory == nil ? Color.Surface.a30 : Color.Surface.a20.opacity(0.4)))
//                                .foregroundColor(filterCategory == nil ? .white : Color.Surface.a60)
//                        }
//                        .buttonStyle(.plain)
//                        ForEach(TaskCategory.allCases) { cat in
//                            Button { filterCategory = cat } label: {
//                                HStack(spacing: 3) {
//                                    Image(systemName: cat.icon).font(.system(size: 8))
//                                    Text(cat.rawValue).font(.custom("Montserrat-Bold", size: 10))
//                                }
//                                .padding(.horizontal, 8).padding(.vertical, 3)
//                                .background(Capsule().fill(filterCategory == cat ? cat.color.opacity(0.3) : Color.Surface.a20.opacity(0.4)))
//                                .foregroundColor(filterCategory == cat ? cat.color : Color.Surface.a60)
//                            }
//                            .buttonStyle(.plain)
//                        }
//                    }
//                }
//            }
//            .padding(.horizontal, 14).padding(.vertical, 8)
//
//            // Results
//            if filtered.isEmpty {
//                Spacer()
//                VStack(spacing: 8) {
//                    Image(systemName: query.isEmpty ? "magnifyingglass" : "doc.text.magnifyingglass")
//                        .font(.system(size: 28)).foregroundColor(Color.Surface.a40)
//                    Text(query.isEmpty ? "Type to search" : "No results for "\(query)"")
//                        .font(.custom("Montserrat-Regular", size: 13)).foregroundColor(Color.Surface.a50)
//                }
//                Spacer()
//            } else {
//                List(filtered, id: \.objectID) { item in
//                    Button {
//                        onSelect(item)
//                        dismiss()
//                    } label: {
//                        SearchResultRow(item: item, query: query)
//                    }
//                    .buttonStyle(.plain)
//                    .listRowBackground(AppColors.background)
//                    .listRowInsets(EdgeInsets(top: 4, leading: 14, bottom: 4, trailing: 14))
//                }
//                .listStyle(.plain)
//                .scrollContentBackground(.hidden)
//            }
//        }
//        .background(AppColors.background)
//        .frame(width: 360, height: 480)
//    }
//}
//
//struct SearchResultRow: View {
//    @ObservedObject var item: Item
//    let query: String
//
//    private var categoryColor: Color {
//        TaskCategory(rawValue: item.category ?? "")?.color ?? Color.Surface.a40
//    }
//
//    var body: some View {
//        HStack(spacing: 8) {
//            // Priority dot
//            Circle()
//                .fill(priorityColor)
//                .frame(width: 6, height: 6)
//                .padding(.leading, 2)
//
//            VStack(alignment: .leading, spacing: 2) {
//                Text(item.title ?? "Untitled")
//                    .font(.custom("Montserrat-SemiBold", size: 12))
//                    .foregroundColor(item.completed ? Color.Surface.a50 : AppColors.textWhite)
//                    .strikethrough(item.completed)
//                    .lineLimit(1)
//
//                HStack(spacing: 6) {
//                    if let cat = item.category {
//                        Text(cat)
//                            .font(.custom("Montserrat-Regular", size: 9))
//                            .padding(.horizontal, 5).padding(.vertical, 1)
//                            .background(Capsule().fill(categoryColor.opacity(0.2)))
//                            .foregroundColor(categoryColor)
//                    }
//                    if let dl = item.deadline {
//                        let isOverdue = dl < Date() && !item.completed
//                        Text(dl, style: .date)
//                            .font(.custom("Montserrat-Regular", size: 9))
//                            .foregroundColor(isOverdue ? Color.Danger.a10 : Color.Surface.a50)
//                    }
//                    if item.completed {
//                        Text("Done")
//                            .font(.custom("Montserrat-Bold", size: 8))
//                            .padding(.horizontal, 5).padding(.vertical, 1)
//                            .background(Capsule().fill(Color.Success.a20.opacity(0.5)))
//                            .foregroundColor(Color.Success.a10)
//                    }
//                    if let sub = item.subtasks, sub.count > 0 {
//                        Text("\(sub.count) subtasks")
//                            .font(.custom("Montserrat-Regular", size: 9))
//                            .foregroundColor(Color.Surface.a50)
//                    }
//                }
//            }
//
//            Spacer()
//
//            Image(systemName: "chevron.right")
//                .font(.system(size: 9)).foregroundColor(Color.Surface.a40)
//        }
//        .padding(.vertical, 6).padding(.horizontal, 10)
//        .background(AppColors.card)
//        .cornerRadius(8)
//        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.Surface.a30.opacity(0.35), lineWidth: 0.5))
//    }
//
//    private var priorityColor: Color {
//        switch TaskPriority(rawValue: item.priority) ?? .low {
//        case .high: return Color.Danger.a10
//        case .medium: return Color.Warning.a10
//        case .low: return Color.Info.a10
//        }
//    }
//}


// TaskSearchView.swift
// TaskBubble

import SwiftUI
import CoreData

struct TaskSearchView: View {
    let items: [Item]
    var onSelect: (Item) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var query = ""
    @State private var filterCategory: TaskCategory? = nil
    @State private var filterStatus: SearchStatus = .all

    enum SearchStatus: String, CaseIterable, Identifiable {
        case all = "All", active = "Active", done = "Done"
        var id: String { rawValue }
    }

    private var filtered: [Item] {
        let q = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        return items.filter { item in
            // Status filter
            switch filterStatus {
            case .active: if item.completed { return false }
            case .done:   if !item.completed { return false }
            case .all: break
            }
            // Category filter
            if let cat = filterCategory, item.category != cat.rawValue { return false }
            // Text filter
            if q.isEmpty { return true }
            if (item.title ?? "").lowercased().contains(q) { return true }
            if (item.notes ?? "").lowercased().contains(q) { return true }
            if let val = item.linkedResourceValue, val.lowercased().contains(q) { return true }
            if let name = item.linkedResourceAppDisplayName, name.lowercased().contains(q) { return true }
            return false
        }
        .sorted { ($0.timestamp ?? .distantPast) > ($1.timestamp ?? .distantPast) }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Search")
                    .font(.custom("Montserrat-Bold", size: 15))
                    .foregroundColor(AppColors.textWhite)
                Spacer()
                Button("Done") { dismiss() }
                    .buttonStyle(.plain)
                    .font(.custom("Montserrat-SemiBold", size: 13))
                    .foregroundColor(AppColors.shalyPurple)
            }
            .padding(.horizontal, 14).padding(.top, 12).padding(.bottom, 8)

            // Search field
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass").font(.system(size: 12)).foregroundColor(Color.Surface.a50)
                TextField("Search tasks, notes, links…", text: $query)
                    .font(.custom("Montserrat-Regular", size: 13))
                    .textFieldStyle(.plain)
                if !query.isEmpty {
                    Button { query = "" } label: {
                        Image(systemName: "xmark.circle.fill").font(.system(size: 12)).foregroundColor(Color.Surface.a40)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 10).padding(.vertical, 8)
            .background(Color.Surface.a10)
            .cornerRadius(8)
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.Surface.a30.opacity(0.5), lineWidth: 0.5))
            .padding(.horizontal, 14)

            // Status pills
            HStack(spacing: 6) {
                ForEach(SearchStatus.allCases) { s in
                    Button { filterStatus = s } label: {
                        Text(s.rawValue)
                            .font(.custom("Montserrat-Bold", size: 10))
                            .padding(.horizontal, 10).padding(.vertical, 3)
                            .background(Capsule().fill(filterStatus == s ? AppColors.shalyPurple : Color.Surface.a20.opacity(0.5)))
                            .foregroundColor(filterStatus == s ? .white : Color.Surface.a60)
                    }
                    .buttonStyle(.plain)
                }
                Divider().frame(height: 14).padding(.horizontal, 2)
                // Category filter
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        Button {
                            filterCategory = nil
                        } label: {
                            Text("Any category")
                                .font(.custom("Montserrat-Bold", size: 10))
                                .padding(.horizontal, 8).padding(.vertical, 3)
                                .background(Capsule().fill(filterCategory == nil ? Color.Surface.a30 : Color.Surface.a20.opacity(0.4)))
                                .foregroundColor(filterCategory == nil ? .white : Color.Surface.a60)
                        }
                        .buttonStyle(.plain)
                        ForEach(TaskCategory.allCases) { cat in
                            Button { filterCategory = cat } label: {
                                HStack(spacing: 3) {
                                    Image(systemName: cat.icon).font(.system(size: 8))
                                    Text(cat.rawValue).font(.custom("Montserrat-Bold", size: 10))
                                }
                                .padding(.horizontal, 8).padding(.vertical, 3)
                                .background(Capsule().fill(filterCategory == cat ? cat.color.opacity(0.3) : Color.Surface.a20.opacity(0.4)))
                                .foregroundColor(filterCategory == cat ? cat.color : Color.Surface.a60)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
            .padding(.horizontal, 14).padding(.vertical, 8)

            // Results
            if filtered.isEmpty {
                Spacer()
                VStack(spacing: 8) {
                    Image(systemName: query.isEmpty ? "magnifyingglass" : "doc.text.magnifyingglass")
                        .font(.system(size: 28)).foregroundColor(Color.Surface.a40)
//                    Text(query.isEmpty ? "Type to search" : "No results for "\(query)"")
                    Text(query.isEmpty ? "Type to search" : "No results for \"\(query)\"")
                        .font(.custom("Montserrat-Regular", size: 13)).foregroundColor(Color.Surface.a50)
                }
                Spacer()
            } else {
                List(filtered, id: \.objectID) { item in
                    Button {
                        onSelect(item)
                        dismiss()
                    } label: {
                        SearchResultRow(item: item, query: query)
                    }
                    .buttonStyle(.plain)
                    .listRowBackground(AppColors.background)
                    .listRowInsets(EdgeInsets(top: 4, leading: 14, bottom: 4, trailing: 14))
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }
        }
        .background(AppColors.background)
        .frame(width: 360, height: 480)
    }
}

struct SearchResultRow: View {
    @ObservedObject var item: Item
    let query: String

    private var categoryColor: Color {
        TaskCategory(rawValue: item.category ?? "")?.color ?? Color.Surface.a40
    }

    var body: some View {
        HStack(spacing: 8) {
            // Priority dot
            Circle()
                .fill(priorityColor)
                .frame(width: 6, height: 6)
                .padding(.leading, 2)

            VStack(alignment: .leading, spacing: 2) {
                Text(item.title ?? "Untitled")
                    .font(.custom("Montserrat-SemiBold", size: 12))
                    .foregroundColor(item.completed ? Color.Surface.a50 : AppColors.textWhite)
                    .strikethrough(item.completed)
                    .lineLimit(1)

                HStack(spacing: 6) {
                    if let cat = item.category {
                        Text(cat)
                            .font(.custom("Montserrat-Regular", size: 9))
                            .padding(.horizontal, 5).padding(.vertical, 1)
                            .background(Capsule().fill(categoryColor.opacity(0.2)))
                            .foregroundColor(categoryColor)
                    }
                    if let dl = item.deadline {
                        let isOverdue = dl < Date() && !item.completed
                        Text(dl, style: .date)
                            .font(.custom("Montserrat-Regular", size: 9))
                            .foregroundColor(isOverdue ? Color.Danger.a10 : Color.Surface.a50)
                    }
                    if item.completed {
                        Text("Done")
                            .font(.custom("Montserrat-Bold", size: 8))
                            .padding(.horizontal, 5).padding(.vertical, 1)
                            .background(Capsule().fill(Color.Success.a20.opacity(0.5)))
                            .foregroundColor(Color.Success.a10)
                    }
                    if let sub = item.subtasks, sub.count > 0 {
                        Text("\(sub.count) subtasks")
                            .font(.custom("Montserrat-Regular", size: 9))
                            .foregroundColor(Color.Surface.a50)
                    }
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 9)).foregroundColor(Color.Surface.a40)
        }
        .padding(.vertical, 6).padding(.horizontal, 10)
        .background(AppColors.card)
        .cornerRadius(8)
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.Surface.a30.opacity(0.35), lineWidth: 0.5))
    }

    private var priorityColor: Color {
        switch TaskPriority(rawValue: item.priority) ?? .low {
        case .high: return Color.Danger.a10
        case .medium: return Color.Warning.a10
        case .low: return Color.Info.a10
        }
    }
}
