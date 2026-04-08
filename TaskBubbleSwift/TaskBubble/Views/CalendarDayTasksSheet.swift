//
//  CalendarDayTasksSheet.swift
//  TaskBubble
//
//  Lists tasks due on a calendar day; reusable from calendar tap.
//

import CoreData
import SwiftUI

struct CalendarDayTasksSheet: View {
    let date: Date
    let tasks: [Item]
    var onSelectTask: (Item) -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(date, format: .dateTime.month(.wide).day().year())
                .font(.headline)
                .foregroundStyle(.secondary)

            Text("Tasks due")
                .font(.title3.bold())

            if tasks.isEmpty {
                Spacer()
                Text("No tasks")
                    .foregroundStyle(.secondary)
                Spacer()
            } else {
                List(tasks, id: \.objectID) { item in
                    Button {
                        dismiss()
                        DispatchQueue.main.async {
                            onSelectTask(item)
                        }
                    } label: {
                        HStack {
                            Text(item.title ?? "Untitled")
                            Spacer()
                            if let cat = item.category {
                                Text(cat)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                }
                .listStyle(.plain)
            }

            HStack {
                Spacer()
                Button("Close") { dismiss() }
                    .buttonStyle(.plain)
            }
        }
        .padding()
        .frame(width: 320, height: 380)
        .background(AppColors.background)
    }
}
