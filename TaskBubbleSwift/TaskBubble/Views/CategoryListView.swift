//
//  CategoryListView.swift
//  TaskBubble
//

import CoreData
import SwiftUI

struct CategoryListView: View {
    @Environment(\.managedObjectContext) private var viewContext

    let category: TaskCategory
    let items: [Item]
    @Binding var sortOption: TaskSortOption
    @ObservedObject var appDetectionService: AppDetectionService

    var onBack: () -> Void
    var onAddTask: () -> Void
    var onSelectTask: (Item) -> Void
    var onTaskComplete: (Item, CGPoint) -> Void

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button(action: onBack) {
                    Image(systemName: "chevron.left").font(.headline)
                }
                .buttonStyle(.plain)
                Spacer()
                Text(category.rawValue).font(.headline)
                Spacer()
                Menu {
                    Picker("Sort By", selection: $sortOption) {
                        ForEach(TaskSortOption.allCases) { option in
                            Text(option.rawValue).tag(option)
                        }
                    }
                } label: {
                    Image(systemName: "arrow.up.arrow.down").font(.headline)
                }
                .menuStyle(.borderlessButton)
                .fixedSize()

                Button(action: onAddTask) {
                    Image(systemName: "plus").font(.headline)
                }
                .buttonStyle(.plain)
                .padding(.leading, 8)
            }
            .padding()
            .background(category.color.opacity(0.1))

            List {
                let categoryTasks = sortedTasks(items.filter { $0.category == category.rawValue })
                if categoryTasks.isEmpty {
                    Text("No tasks yet!").foregroundColor(.secondary).padding()
                } else {
                    ForEach(categoryTasks) { item in
                        TaskRow(item: item, onSelect: { onSelectTask(item) }, onComplete: { location in
                            onTaskComplete(item, location)
                        }, appDetectionService: appDetectionService)
                    }
                    .onDelete { offsets in
                        offsets.map { categoryTasks[$0] }.forEach(viewContext.delete)
                        saveContext()
                    }
                }
            }
            .listStyle(.plain)
        }
    }

    private func sortedTasks(_ tasks: [Item]) -> [Item] {
        switch sortOption {
        case .alphabetical:
            return tasks.sorted { ($0.title ?? "") < ($1.title ?? "") }
        case .dueDate:
            return tasks.sorted {
                let d1 = $0.deadline ?? Date.distantFuture
                let d2 = $1.deadline ?? Date.distantFuture
                return d1 < d2
            }
        case .priority:
            return tasks.sorted { $0.priority > $1.priority }
        case .timestamp:
            return tasks.sorted { ($0.timestamp ?? Date.distantPast) < ($1.timestamp ?? Date.distantPast) }
        }
    }

    private func saveContext() {
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            print("Unresolved error \(nsError), \(nsError.userInfo)")
            viewContext.rollback()
        }
    }
}
