//
//  TaskSearchView.swift
//  TaskBubble
//

import SwiftUI
import CoreData

struct TaskSearchView: View {
    let items: [Item]
    var onSelect: (Item) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var query: String = ""

    private var filtered: [Item] {
        let q = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !q.isEmpty else { return [] }
        return items.filter { ($0.title ?? "").localizedCaseInsensitiveContains(q) }
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Search")
                    .font(.headline)
                Spacer()
                Button("Done") { dismiss() }
                    .buttonStyle(.plain)
            }
            .padding(.horizontal)
            .padding(.top, 12)

            TextField("Search tasks…", text: $query)
                .textFieldStyle(.roundedBorder)
                .padding()

            if query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                Spacer()
                Text("Type to search your tasks")
                    .foregroundStyle(.secondary)
                Spacer()
            } else if filtered.isEmpty {
                Spacer()
                Text("No matches")
                    .foregroundStyle(.secondary)
                Spacer()
            } else {
                List(filtered, id: \.objectID) { item in
                    Button {
                        onSelect(item)
                    } label: {
                        HStack {
                            Text(item.title ?? "Untitled")
                                .lineLimit(1)
                            Spacer()
                            Text(item.category ?? "")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .buttonStyle(.plain)
                }
                .listStyle(.plain)
            }
        }
        .frame(width: 340, height: 400)
    }
}
