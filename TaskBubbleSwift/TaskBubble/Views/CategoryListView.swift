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
    @StateObject private var motivationalService = MotivationalService()
    @State private var completedTaskIDs: Set<NSManagedObjectID> = Set<NSManagedObjectID>()

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

            if category == .allTasks {
                achievementBlock
            }

            let categoryTasks = sortedTasks(items.filter { item in
                if category == .allTasks {
                    // Include tasks that are not completed OR were just completed (within 2s)
                    return !item.completed || completedTaskIDs.contains(item.objectID)
                } else {
                    return item.category == category.rawValue
                }
            })
            
            List {
                if categoryTasks.isEmpty {
                    Text("No tasks yet!").foregroundColor(.secondary).padding()
                } else {
                    ForEach(categoryTasks) { item in
                        TaskRow(
                            item: item,
                            onSelect: { onSelectTask(item) },
                            onComplete: { location in
                                if category == .allTasks {
                                    handleTaskCompletion(item, location: location)
                                } else {
                                    onTaskComplete(item, location)
                                }
                            },
                            appDetectionService: appDetectionService,
                            isTemporarilyCompleted: completedTaskIDs.contains(item.objectID)
                        )
                    }
                    .onDelete { offsets in
                        offsets.map { categoryTasks[$0] }.forEach(viewContext.delete)
                        saveContext()
                    }
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
        }
        .background(AppColors.background)
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

    private var achievementBlock: some View {
        let completedCount = items.filter { $0.completed }.count
        return VStack(spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("You have completed \(completedCount) tasks!")
                        .font(.subheadline.weight(.bold))
                    
                    Text(motivationalService.currentMessage)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .transition(.opacity)
                        .id(motivationalService.currentMessage)
                }
                Spacer()
                Image(systemName: "trophy.fill")
                    .font(.title2)
                    .foregroundColor(.yellow)
            }
            .padding(12)
            .background(Color.yellow.opacity(0.1))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.yellow.opacity(0.2), lineWidth: 1)
            )
        }
        .padding(.horizontal)
        .padding(.top, 12)
        .onAppear {
            updateMotivation()
        }
    }

    private func updateMotivation() {
        let completedToday = items.filter { $0.completed }.count
        let remainingToday = items.filter { !$0.completed }.count
        motivationalService.updateMessage(completed: completedToday, remaining: remainingToday)
    }

    private func handleTaskCompletion(_ item: Item, location: CGPoint) {
        // Mark as completed in UI immediately
        withAnimation {
            _ = completedTaskIDs.insert(item.objectID)
        }
        
        // Trigger the confetti and actual completion
        onTaskComplete(item, location)
        updateMotivation()
        
        // Remove from list after 2 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation {
                _ = completedTaskIDs.remove(item.objectID)
            }
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
