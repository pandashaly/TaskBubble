//
//  dashboardView.swift
//  TaskBubble
//
//  Created by Shalyca Sottoriva on 02/04/2026.
//

import CoreData
import SwiftUI

struct DashboardView: View {
    @ObservedObject var waterService: WaterIntakeService
    let items: [Item]
    @Binding var calendarScope: TaskCalendarScope
    var onCalendarDay: (Date, [Item]) -> Void

    var onCategoryTap: (TaskCategory) -> Void
    var onAddTask: () -> Void
    var onSearch: () -> Void

    /// Space below the title row before the scroll area.
    private let headerToContentSpacing: CGFloat = 12
    /// Space between category strip, water, calendar, and add button.
    private let contentSpacing: CGFloat = 14
    /// Inset from the window top for the header.
    private let topInset: CGFloat = 3

    var body: some View {
        VStack(spacing: headerToContentSpacing) {
            // Top Header
            HStack(alignment: .center) {
                Image(systemName: "bubbles.fill")
                    .foregroundColor(.white)
                    .font(.title3)

                Text("TaskBubble")
                    .font(.system(size: 20, weight: .bold))

                Spacer()

                TaskToolbarCircleButtons(onAdd: onAddTask, onSearch: onSearch, diameter: 26)
            }
            .padding(.horizontal)

            ScrollView {
                VStack(spacing: contentSpacing) {
                    // Horizontal Categories
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 14) {
                            ForEach(TaskCategory.allCases) { category in
                                Button(action: {
                                    onCategoryTap(category)
                                }) {
                                    HStack(spacing: 6) {
                                        Image(systemName: category.icon)
                                            .font(.caption)

                                        Text(category.rawValue)
                                            .font(.system(size: 13))
                                            .fontWeight(.bold)
                                    }
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 10)
                                    .background(category.color.opacity(0.15))
                                    .cornerRadius(10)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal)
                    }

                    WaterTrackerView(waterService: waterService)

                    TaskCalendarBlock(
                        items: items,
                        scope: $calendarScope,
                        onSelectDay: onCalendarDay
                    )

                    Button(action: onAddTask) {
                        Label("Add New Task", systemImage: "plus.circle.fill")
                            .font(.subheadline.weight(.semibold))
                            .padding(.vertical, 6)
                            .padding(.horizontal, 10)
                            .frame(maxWidth: .infinity)
                            .background(AppColors.shalyPurple)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal)
                }
                .padding(.bottom, contentSpacing)
            }
        }
        .padding(.top, topInset)
    }
}
