//
//  TBHeader.swift
//  TaskBubble
//
//  Created by Shalyca Sottoriva on 10/04/2026.
//

// TBHeader.swift
// TaskBubble

import SwiftUI
import AppKit

// MARK: - Subtle window controls

struct TBWindowControls: View {
    var body: some View {
        HStack(spacing: 6) {
            windowBtn(color: Color(hex: "#FF5F57")) { NSApp.terminate(nil) }
            windowBtn(color: Color(hex: "#FFBD2E")) { NSApp.windows.first?.miniaturize(nil) }
        }
    }
    private func windowBtn(color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Circle().fill(color.opacity(0.85)).frame(width: 10, height: 10)
                .overlay(Circle().stroke(color.opacity(0.4), lineWidth: 0.5))
        }
        .buttonStyle(.plain).contentShape(Circle())
    }
}

// MARK: - Page enum

enum TBPage: String, CaseIterable, Identifiable {
    case home = "Home", today = "Today", goals = "Goals", routine = "Routine"
    case projects = "Projects", allTasks = "All Tasks", done = "Done"
    var id: String { rawValue }
    var label: String { rawValue }
    var icon: String {
        switch self {
        case .home: return "house.fill"
        case .today: return "sun.max.fill"
        case .goals: return "target"
        case .routine: return "repeat"
        case .projects: return "folder.fill"
        case .allTasks: return "tray.full"
        case .done: return "checkmark.circle.fill"
        }
    }
    var taskCategory: TaskCategory? {
        switch self {
        case .today: return .today
        case .goals: return .goals
        case .routine: return .routine
        case .allTasks: return .allTasks
        default: return nil
        }
    }
}

// MARK: - Nav drawer

struct TBNavDrawer: View {
    @Binding var isOpen: Bool
    var currentPage: TBPage
    var onNavigate: (TBPage) -> Void

    var body: some View {
        ZStack(alignment: .topLeading) {
            if isOpen {
                Color.black.opacity(0.35).ignoresSafeArea()
                    .onTapGesture { withAnimation(.easeOut(duration: 0.2)) { isOpen = false } }
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 8) {
                        Image(systemName: "bubbles.and.sparkles.fill").font(.system(size: 13)).foregroundColor(AppColors.shalyPurple)
                        Text("TaskBubble").font(.custom("Montserrat-Bold", size: 14)).foregroundColor(AppColors.textWhite)
                    }
                    .padding(.horizontal, 16).padding(.top, 16).padding(.bottom, 10)
                    Divider().background(Color.Surface.a30.opacity(0.4)).padding(.horizontal, 10)
                    ForEach(TBPage.allCases) { page in
                        let isActive = page == currentPage
                        Button {
                            withAnimation(.easeOut(duration: 0.2)) { isOpen = false }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) { onNavigate(page) }
                        } label: {
                            HStack(spacing: 10) {
                                Image(systemName: page.icon).font(.system(size: 13, weight: .medium))
                                    .foregroundColor(isActive ? AppColors.shalyPurple : Color.Surface.a50).frame(width: 18)
                                Text(page.label).font(.custom(isActive ? "Montserrat-Bold" : "Montserrat-Medium", size: 12))
                                    .foregroundColor(isActive ? AppColors.textWhite : Color.Surface.a60)
                                Spacer()
                                if isActive { Circle().fill(AppColors.shalyPurple).frame(width: 5, height: 5) }
                            }
                            .padding(.horizontal, 14).padding(.vertical, 9)
                            .background(RoundedRectangle(cornerRadius: 8)
                                .fill(isActive ? AppColors.shalyPurple.opacity(0.12) : Color.clear).padding(.horizontal, 6))
                        }
                        .buttonStyle(.plain)
                    }
                    Spacer()
                }
                .frame(width: 190).background(Color.Surface.a10)
                .overlay(Rectangle().frame(width: 0.5).foregroundColor(Color.Surface.a30.opacity(0.5)), alignment: .trailing)
                .transition(.move(edge: .leading).combined(with: .opacity))
            }
        }
        .animation(.easeOut(duration: 0.2), value: isOpen)
    }
}

// MARK: - Shared page header

struct TBPageHeader: View {
    var title: String
    var icon: String
    var showWindowControls: Bool = false
    var onBack: (() -> Void)? = nil
    var onNavDrawer: (() -> Void)? = nil
    var onSort: (() -> Void)? = nil
    var onSearch: (() -> Void)? = nil
    var onAdd: (() -> Void)? = nil
    var accentColor: Color = AppColors.shalyPurple

    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            HStack(spacing: 7) {
                if showWindowControls { TBWindowControls().padding(.trailing, 2) }
                if let back = onBack { backBtn(back) }
                else if let nav = onNavDrawer { hamburgerBtn(nav) }
            }
            HStack(spacing: 7) {
                Image(systemName: icon).font(.system(size: 13, weight: .semibold)).foregroundColor(accentColor)
                Text(title).font(.custom("Montserrat-Bold", size: 15)).foregroundColor(AppColors.textWhite).lineLimit(1)
            }
            .frame(maxWidth: .infinity, alignment: .leading).padding(.leading, 8)
            HStack(spacing: 0) {
                if let sort = onSort { circleBtn("arrow.up.arrow.down", action: sort) }
                if let search = onSearch { circleBtn("magnifyingglass", action: search) }
                if let add = onAdd { circleBtn("plus", action: add, filled: true) }
            }
        }
        .padding(.horizontal, 13).padding(.vertical, 9)
        .background(AppColors.background)
        .overlay(Rectangle().frame(height: 0.5).foregroundColor(Color.Surface.a30.opacity(0.4)), alignment: .bottom)
    }

    private func backBtn(_ action: @escaping () -> Void) -> some View {
        Button(action: action) {
            ZStack {
                Circle().fill(Color.Surface.a20.opacity(0.45)).frame(width: 24, height: 24)
                Image(systemName: "chevron.left").font(.system(size: 9, weight: .bold)).foregroundColor(Color.Surface.a60)
            }
        }.buttonStyle(.plain)
    }

    private func hamburgerBtn(_ action: @escaping () -> Void) -> some View {
        Button(action: action) {
            ZStack {
                Circle().fill(Color.Surface.a20.opacity(0.45)).frame(width: 24, height: 24)
                VStack(spacing: 3) {
                    ForEach(0..<3, id: \.self) { _ in
                        Rectangle().fill(Color.Surface.a60).frame(width: 10, height: 1.2).cornerRadius(1)
                    }
                }
            }
        }.buttonStyle(.plain)
    }

    private func circleBtn(_ icon: String, action: @escaping () -> Void, filled: Bool = false) -> some View {
        Button(action: action) {
            ZStack {
                Circle().fill(filled ? Color(nsColor: .textBackgroundColor) : Color(nsColor: .controlBackgroundColor))
                    .frame(width: 22, height: 22).overlay(Circle().strokeBorder(Color.gray.opacity(0.32), lineWidth: 0.5))
                Image(systemName: icon).font(.system(size: 9, weight: .medium))
                    .foregroundColor(Color(red: 0.32, green: 0.38, blue: 0.47))
            }
        }.buttonStyle(.plain).padding(.leading, -4)
    }
}

// MARK: - Shared floating add button

struct TBAddFAB: View {
    var label: String
    var action: () -> Void
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: "plus").font(.system(size: 11, weight: .bold))
                Text(label).font(.custom("Montserrat-Bold", size: 11))
            }
            .foregroundColor(AppColors.shalyPurple).frame(maxWidth: .infinity).padding(.vertical, 10)
            .background(Capsule().fill(Color.Primary.a0.opacity(0.12)))
            .overlay(Capsule().stroke(Color.Primary.a0.opacity(0.4), lineWidth: 0.5))
        }
        .buttonStyle(.plain).padding(.horizontal, 14).padding(.vertical, 10)
        .background(AppColors.background)
        .overlay(Rectangle().frame(height: 0.5).foregroundColor(Color.Surface.a30.opacity(0.4)), alignment: .top)
    }
}
