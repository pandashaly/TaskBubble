////
////  dashboardView.swift
////  TaskBubble
////
////  Created by Shalyca Sottoriva on 02/04/2026.
//
//import CoreData
//import SwiftUI
//
//struct DashboardView: View {
//    @ObservedObject var waterService: WaterIntakeService
//    let items: [Item]
//    @Binding var calendarScope: TaskCalendarScope
//    var onCalendarDay: (Date, [Item]) -> Void
//    /// True when rendered inside the MenuBarExtra popover; false for the standalone floating window.
//    var isMenuBar: Bool = false
//    
//    var onCategoryTap: (TaskCategory) -> Void
//    var onAddTask: () -> Void
//    var onSearch: () -> Void
//    
//    /// Space below the title row before the scroll area.
//    private let headerToContentSpacing: CGFloat = 12
//    /// Space between category strip, water, calendar, and add button.
//    private let contentSpacing: CGFloat = 14
//    /// Top inset: more room in the menu bar popover so the header isn't clipped.
//    private var topInset: CGFloat { isMenuBar ? 12 : 3 }
//    
//    var body: some View {
//        ZStack {
//            if isMenuBar {
//                // Liquid glass effect: ultra-thin material for maximum translucency,
//                // overlaid with a very subtle purple tint to match the app palette.
//                // On macOS 26+, replace this block with .glassEffect() modifier instead.
//                VisualEffectView(material: .fullScreenUI, blendingMode: .behindWindow)
//                    .ignoresSafeArea()
//                Color.Primary.a0.opacity(0.08)
//                    .ignoresSafeArea()
//            } else {
//                // Standalone floating window: fully opaque dark background.
//                AppColors.background
//                    .ignoresSafeArea()
//            }
//            
//            VStack(spacing: headerToContentSpacing) {
//                // Top Header
//                HStack(alignment: .center) {
////                    Image(systemName: "bubbles.fill")
////                        .foregroundColor(.white)
////                        .font(.title3)
//                    
//                    Text("TaskBubble")
//                        .font(.system(size: 20, weight: .bold))
//                    
//                    Spacer()
//                    
//                    TaskToolbarCircleButtons(onAdd: onAddTask, onSearch: onSearch, diameter: 26)
//                }
//                .padding(.horizontal)
//                
//                ScrollView {
//                    VStack(spacing: contentSpacing) {
//                        // Horizontal Categories
//                        ScrollView(.horizontal, showsIndicators: false) {
//                            HStack(spacing: 14) {
//                                ForEach(TaskCategory.allCases) { category in
//                                    Button(action: {
//                                        onCategoryTap(category)
//                                    }) {
//                                        HStack(spacing: 6) {
//                                            Image(systemName: category.icon)
//                                                .font(.caption)
//                                            
//                                            Text(category.rawValue)
//                                                .font(.system(size: 13))
//                                                .fontWeight(.bold)
//                                        }
//                                        .padding(.horizontal, 12)
//                                        .padding(.vertical, 10)
//                                        .background(category.color.opacity(0.15))
//                                        .cornerRadius(10)
//                                    }
//                                    .buttonStyle(.plain)
//                                }
//                            }
//                            .padding(.horizontal)
//                        }
//                        
//                        WaterTrackerView(waterService: waterService)
//                        
//                        TaskCalendarBlock(
//                            items: items,
//                            scope: $calendarScope,
//                            onSelectDay: onCalendarDay
//                        )
//                        
//                        Button(action: onAddTask) {
//                            Label("Add New Task", systemImage: "plus.circle.fill")
//                                .font(.subheadline.weight(.semibold))
//                                .padding(.vertical, 6)
//                                .padding(.horizontal, 10)
//                                .frame(maxWidth: .infinity)
//                                .background(AppColors.shalyPurple)
//                                .foregroundColor(.white)
//                                .cornerRadius(10)
//                        }
//                        .buttonStyle(.plain)
//                        .padding(.horizontal)
//                    }
//                    .padding(.bottom, contentSpacing)
//                }
//                .scrollContentBackground(.hidden)
//            }
//            .padding(.top, topInset)
//        }
//    }
//    
//    struct VisualEffectView: NSViewRepresentable {
//        var material: NSVisualEffectView.Material
//        var blendingMode: NSVisualEffectView.BlendingMode
//        
//        func makeNSView(context: Context) -> NSVisualEffectView {
//            let view = NSVisualEffectView()
//            view.material = material
//            view.blendingMode = blendingMode
//            view.state = .active
//            return view
//        }
//        
//        func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
//            nsView.material = material
//            nsView.blendingMode = blendingMode
//        }
//    }
//}
//
//
//// dashboardView.swift
//// TaskBubble
//
//import CoreData
//import SwiftUI
//
//struct DashboardView: View {
//    @ObservedObject var waterService: WaterIntakeService
//    let items: [Item]
//    @Binding var calendarScope: TaskCalendarScope
//    var onCalendarDay: (Date, [Item]) -> Void
//    var onCategoryTap: (TaskCategory) -> Void
//    var onAddTask: () -> Void
//    var onSearch: () -> Void
//    var onNavigate: ((TBPage) -> Void)? = nil
//
//    @State private var showNavDrawer = false
//    private let contentSpacing: CGFloat = 13
//
//    var body: some View {
//        ZStack(alignment: .topLeading) {
//            VisualEffectView(material: .hudWindow, blendingMode: .behindWindow).ignoresSafeArea()
//            VStack(spacing: 0) {
//                HStack(alignment: .center) {
//                    TBWindowControls()
//                    Button { withAnimation { showNavDrawer.toggle() } } label: {
//                        ZStack {
//                            Circle().fill(Color.Surface.a20.opacity(0.45)).frame(width: 24, height: 24)
//                            VStack(spacing: 3) {
//                                ForEach(0..<3, id: \.self) { _ in
//                                    Rectangle().fill(Color.Surface.a60).frame(width: 10, height: 1.2).cornerRadius(1)
//                                }
//                            }
//                        }
//                    }.buttonStyle(.plain).padding(.leading, 6)
//                    HStack(spacing: 6) {
//                        Image(systemName: "bubbles.and.sparkles.fill").font(.system(size: 13, weight: .semibold))
//                            .foregroundColor(AppColors.shalyPurple)
//                        Text("TaskBubble").font(.custom("Montserrat-Bold", size: 15)).foregroundColor(AppColors.textWhite)
//                    }.padding(.leading, 6)
//                    Spacer()
//                    TaskToolbarCircleButtons(onAdd: onAddTask, onSearch: onSearch, diameter: 24)
//                }
//                .padding(.horizontal, 13).padding(.vertical, 9)
//                .overlay(Rectangle().frame(height: 0.5).foregroundColor(Color.Surface.a30.opacity(0.4)), alignment: .bottom)
//
//                ScrollView(showsIndicators: false) {
//                    VStack(spacing: contentSpacing) {
//                        ScrollView(.horizontal, showsIndicators: false) {
//                            HStack(spacing: 10) {
//                                ForEach(TaskCategory.allCases) { category in
//                                    Button { onCategoryTap(category) } label: {
//                                        HStack(spacing: 5) {
//                                            Image(systemName: category.icon).font(.system(size: 11))
//                                            Text(category.rawValue).font(.custom("Montserrat-Bold", size: 12))
//                                        }
//                                        .padding(.horizontal, 11).padding(.vertical, 8)
//                                        .background(category.color.opacity(0.13)).cornerRadius(9)
//                                        .overlay(RoundedRectangle(cornerRadius: 9).stroke(category.color.opacity(0.25), lineWidth: 0.5))
//                                        .foregroundColor(category.color)
//                                    }.buttonStyle(.plain)
//                                }
//                            }.padding(.horizontal, 14)
//                        }
//                        WaterTrackerView(waterService: waterService)
//                        TaskCalendarBlock(items: items, scope: $calendarScope, onSelectDay: onCalendarDay)
//                    }
//                    .padding(.top, 10).padding(.bottom, contentSpacing)
//                }.scrollContentBackground(.hidden)
//
//                TBAddFAB(label: "Add new task", action: onAddTask)
//            }
//            if showNavDrawer {
//                TBNavDrawer(isOpen: $showNavDrawer, currentPage: .home) { page in
//                    showNavDrawer = false; onNavigate?(page)
//                }.zIndex(20)
//            }
//        }
//    }
//
//    struct VisualEffectView: NSViewRepresentable {
//        var material: NSVisualEffectView.Material; var blendingMode: NSVisualEffectView.BlendingMode
//        func makeNSView(context: Context) -> NSVisualEffectView {
//            let v = NSVisualEffectView(); v.material = material; v.blendingMode = blendingMode; v.state = .active; return v
//        }
//        func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
//            nsView.material = material; nsView.blendingMode = blendingMode
//        }
//    }
//}

// dashboardView.swift
// TaskBubble

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
    var onNavigate: ((TBPage) -> Void)? = nil

    @State private var showNavDrawer = false
    private let contentSpacing: CGFloat = 12

    // Urgent = high priority incomplete OR deadline ≤14 days
    private var urgentItems: [Item] {
        let now = Date()
        let twoWeeks = Calendar.current.date(byAdding: .day, value: 14, to: now) ?? now
        return items.filter { item in
            guard !item.completed else { return false }
            let highPriority = item.priority >= 2
            let soonDeadline = (item.deadline.map { $0 <= twoWeeks }) ?? false
            return highPriority || soonDeadline
        }
        .sorted {
            let d0 = $0.deadline ?? .distantFuture
            let d1 = $1.deadline ?? .distantFuture
            if d0 != d1 { return d0 < d1 }
            return $0.priority > $1.priority
        }
        .prefix(5)
        .map { $0 }
    }

    var body: some View {
        ZStack(alignment: .topLeading) {
            VisualEffectView(material: .hudWindow, blendingMode: .behindWindow).ignoresSafeArea()

            VStack(spacing: 0) {
                // Dashboard header
                HStack(alignment: .center) {
                    TBWindowControls()
                    Button { withAnimation { showNavDrawer.toggle() } } label: {
                        ZStack {
                            Circle().fill(Color.Surface.a20.opacity(0.45)).frame(width: 24, height: 24)
                            VStack(spacing: 3) {
                                ForEach(0..<3, id: \.self) { _ in
                                    Rectangle().fill(Color.Surface.a60).frame(width: 10, height: 1.2).cornerRadius(1)
                                }
                            }
                        }
                    }.buttonStyle(.plain).padding(.leading, 6)
                    HStack(spacing: 6) {
                        Image(systemName: "bubbles.and.sparkles.fill")
                            .font(.system(size: 13, weight: .semibold)).foregroundColor(AppColors.shalyPurple)
                        Text("TaskBubble")
                            .font(.custom("Montserrat-Bold", size: 15)).foregroundColor(AppColors.textWhite)
                    }.padding(.leading, 6)
                    Spacer()
                    TaskToolbarCircleButtons(onAdd: onAddTask, onSearch: onSearch, diameter: 24)
                }
                .padding(.horizontal, 13).padding(.vertical, 9)
                .overlay(Rectangle().frame(height: 0.5).foregroundColor(Color.Surface.a30.opacity(0.4)), alignment: .bottom)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: contentSpacing) {
                        // Category pills
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                ForEach(TaskCategory.allCases) { category in
                                    Button { onCategoryTap(category) } label: {
                                        HStack(spacing: 5) {
                                            Image(systemName: category.icon).font(.system(size: 11))
                                            Text(category.rawValue).font(.custom("Montserrat-Bold", size: 12))
                                        }
                                        .padding(.horizontal, 11).padding(.vertical, 8)
                                        .background(category.color.opacity(0.13)).cornerRadius(9)
                                        .overlay(RoundedRectangle(cornerRadius: 9).stroke(category.color.opacity(0.25), lineWidth: 0.5))
                                        .foregroundColor(category.color)
                                    }.buttonStyle(.plain)
                                }
                            }.padding(.horizontal, 14)
                        }

                        // Urgent / upcoming tasks strip
                        if !urgentItems.isEmpty {
                            urgentStrip
                        }

                        WaterTrackerView(waterService: waterService)

                        TaskCalendarBlock(
                            items: items,
                            scope: $calendarScope,
                            onSelectDay: onCalendarDay
                        )
                    }
                    // ← No bottom padding here — FAB handles the spacing
                    .padding(.top, 10)
                }
                .scrollContentBackground(.hidden)

                // FAB sits flush at the bottom with no extra gap
                TBAddFAB(label: "Add new task", action: onAddTask)
            }

            if showNavDrawer {
                TBNavDrawer(isOpen: $showNavDrawer, currentPage: .home) { page in
                    showNavDrawer = false; onNavigate?(page)
                }.zIndex(20)
            }
        }
    }

    // MARK: - Urgent strip

    private var urgentStrip: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 5) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 10)).foregroundColor(Color.Danger.a10)
                Text("URGENT / UPCOMING")
                    .font(.custom("Montserrat-Bold", size: 9))
                    .foregroundColor(Color.Danger.a10).tracking(0.8)
                Spacer()
            }
            .padding(.horizontal, 14)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(urgentItems) { item in
                        UrgentTaskCard(item: item)
                    }
                }
                .padding(.horizontal, 14)
            }
        }
    }

    struct VisualEffectView: NSViewRepresentable {
        var material: NSVisualEffectView.Material; var blendingMode: NSVisualEffectView.BlendingMode
        func makeNSView(context: Context) -> NSVisualEffectView {
            let v = NSVisualEffectView(); v.material = material; v.blendingMode = blendingMode; v.state = .active; return v
        }
        func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
            nsView.material = material; nsView.blendingMode = blendingMode
        }
    }
}

// MARK: - Urgent task card

struct UrgentTaskCard: View {
    @ObservedObject var item: Item

    private var isOverdue: Bool {
        (item.deadline.map { $0 < Date() }) ?? false
    }

    private var deadlineLabel: String {
        guard let dl = item.deadline else { return "High priority" }
        if isOverdue { return "Overdue" }
        return dl.formatted(.dateTime.month(.abbreviated).day())
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack(spacing: 4) {
                Circle()
                    .fill(isOverdue ? Color.Danger.a10 : Color.Warning.a10)
                    .frame(width: 5, height: 5)
                Text(deadlineLabel)
                    .font(.custom("Montserrat-Bold", size: 9))
                    .foregroundColor(isOverdue ? Color.Danger.a10 : Color.Warning.a10)
            }
            Text(item.title ?? "Untitled")
                .font(.custom("Montserrat-SemiBold", size: 11))
                .foregroundColor(AppColors.textWhite)
                .lineLimit(2)
                .frame(width: 120, alignment: .leading)
            if let cat = item.category {
                Text(cat)
                    .font(.custom("Montserrat-Regular", size: 9))
                    .foregroundColor(Color.Surface.a50)
            }
        }
        .padding(.horizontal, 10).padding(.vertical, 8)
        .background(isOverdue
            ? Color.Danger.a20.opacity(0.25)
            : Color.Warning.a20.opacity(0.2))
        .cornerRadius(9)
        .overlay(RoundedRectangle(cornerRadius: 9)
            .stroke(isOverdue ? Color.Danger.a10.opacity(0.3) : Color.Warning.a10.opacity(0.3), lineWidth: 0.5))
    }
}
