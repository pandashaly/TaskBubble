//
//  BatchProductivityView.swift
//  TaskBubble
//
//  Created by Shalyca Sottoriva on 10/04/2026.
//

// ADHD-friendly batch focus mode. Select up to 10 tasks, set a timer, execute in focused mode.
// BatchProductivityView.swift
// TaskBubble
// BatchProductivityView.swift
// TaskBubble

import CoreData
import SwiftUI

// MARK: - Entry / task selector

struct BatchProductivityEntryView: View {
    let items: [Item]
    @ObservedObject var appDetectionService: AppDetectionService
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss

    @State private var selected: Set<NSManagedObjectID> = []
    @State private var timerMinutes: Int = 25
    @State private var showSession = false

    private var available: [Item] {
        items.filter { !$0.completed }
            .sorted { ($0.timestamp ?? .distantPast) > ($1.timestamp ?? .distantPast) }
    }

    private var warningMessage: String? {
        if selected.count > 5 {
            return "More than 5 tasks? Studies show that's a recipe for procrastination. Try 3–5 for best focus."
        }
        return nil
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button { dismiss() } label: {
                    ZStack {
                        Circle().fill(Color.Surface.a20.opacity(0.4)).frame(width: 24, height: 24)
                        Image(systemName: "xmark").font(.system(size: 9, weight: .bold)).foregroundColor(Color.Surface.a60)
                    }
                }.buttonStyle(.plain)

                Spacer()
                VStack(spacing: 1) {
                    Text("Batch Focus")
                        .font(.custom("Montserrat-Bold", size: 15)).foregroundColor(AppColors.textWhite)
                    Text("Select · Time · Execute")
                        .font(.custom("Montserrat-Regular", size: 9)).foregroundColor(Color.Surface.a50)
                }
                Spacer()

                ZStack {
                    Capsule()
                        .fill(selected.isEmpty ? Color.Surface.a20.opacity(0.4) : AppColors.shalyPurple.opacity(0.2))
                        .frame(width: 36, height: 24)
                    Text("\(selected.count)/10")
                        .font(.custom("Montserrat-Bold", size: 10))
                        .foregroundColor(selected.isEmpty ? Color.Surface.a50 : AppColors.shalyPurple)
                }
            }
            .padding(.horizontal, 14).padding(.vertical, 11)
            .background(Color.Surface.a10)

            Divider().background(Color.Surface.a30.opacity(0.4))

            // Timer selection
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("SESSION DURATION")
                        .font(.custom("Montserrat-Bold", size: 9)).foregroundColor(Color.Surface.a50).tracking(0.7)
                    Spacer()
                    Text("\(timerMinutes) min")
                        .font(.custom("Montserrat-Bold", size: 12)).foregroundColor(AppColors.shalyPurple)
                }
                HStack(spacing: 6) {
                    ForEach([15, 25, 45, 60], id: \.self) { m in
                        Button { timerMinutes = m } label: {
                            Text("\(m)m")
                                .font(.custom("Montserrat-Bold", size: 11))
                                .frame(maxWidth: .infinity).padding(.vertical, 6)
                                .background(Capsule().fill(timerMinutes == m ? AppColors.shalyPurple : Color.Surface.a20.opacity(0.4)))
                                .foregroundColor(timerMinutes == m ? .white : Color.Surface.a60)
                        }.buttonStyle(.plain)
                    }
                }
            }
            .padding(.horizontal, 14).padding(.vertical, 10)

            Divider().background(Color.Surface.a30.opacity(0.3))

            // Warning pill
            if let warning = warningMessage {
                HStack(spacing: 6) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 10)).foregroundColor(Color.Warning.a10)
                    Text(warning)
                        .font(.custom("Montserrat-Regular", size: 10)).foregroundColor(Color.Warning.a10)
                        .lineLimit(2)
                }
                .padding(.horizontal, 14).padding(.vertical, 7)
                .background(Color.Warning.a20.opacity(0.2))
                .transition(.opacity.combined(with: .move(edge: .top)))
            }

            // Task list
            ScrollView(showsIndicators: false) {
                LazyVStack(spacing: 4) {
                    if available.isEmpty {
                        Text("No tasks available")
                            .font(.custom("Montserrat-Regular", size: 12)).foregroundColor(Color.Surface.a50)
                            .padding(.top, 20)
                    } else {
                        ForEach(available) { item in
                            BatchSelectRow(
                                item: item,
                                isSelected: selected.contains(item.objectID),
                                canSelect: selected.count < 10 || selected.contains(item.objectID),
                                onTap: { toggle(item) }
                            )
                            .padding(.horizontal, 14)
                        }
                    }
                }
                .padding(.vertical, 6)
            }

            // Start button
            VStack(spacing: 0) {
                Divider().background(Color.Surface.a30.opacity(0.4))
                Button {
                    guard !selected.isEmpty else { return }
                    showSession = true
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "timer").font(.system(size: 13))
                        Text(selected.isEmpty ? "Select at least 1 task" : "Start \(timerMinutes)min focus session")
                            .font(.custom("Montserrat-Bold", size: 12))
                    }
                    .foregroundColor(selected.isEmpty ? Color.Surface.a50 : .white)
                    .frame(maxWidth: .infinity).padding(.vertical, 11)
                    .background(Capsule().fill(selected.isEmpty ? Color.Surface.a20.opacity(0.5) : AppColors.shalyPurple))
                }
                .buttonStyle(.plain).disabled(selected.isEmpty)
                .padding(.horizontal, 14).padding(.vertical, 10)
                .background(AppColors.background)
            }
        }
        .background(AppColors.background)
        .frame(width: 340, height: 480)
        .animation(.easeInOut(duration: 0.2), value: selected.count)
        // ← Use sheet instead of fullScreenCover (macOS doesn't support fullScreenCover)
        .sheet(isPresented: $showSession) {
            BatchSessionView(
                tasks: available.filter { selected.contains($0.objectID) },
                durationSeconds: timerMinutes * 60,
                onDismiss: { showSession = false; dismiss() }
            )
            .environment(\.managedObjectContext, viewContext)
        }
    }

    private func toggle(_ item: Item) {
        if selected.contains(item.objectID) { selected.remove(item.objectID) }
        else if selected.count < 10 { selected.insert(item.objectID) }
    }
}

// MARK: - Selection row

struct BatchSelectRow: View {
    @ObservedObject var item: Item
    let isSelected: Bool; let canSelect: Bool; let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 9) {
                ZStack {
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(isSelected ? AppColors.shalyPurple : Color.Surface.a30, lineWidth: 1.5)
                        .frame(width: 16, height: 16)
                    if isSelected {
                        RoundedRectangle(cornerRadius: 3).fill(AppColors.shalyPurple).frame(width: 16, height: 16)
                        Image(systemName: "checkmark").font(.system(size: 8, weight: .bold)).foregroundColor(.white)
                    }
                }
                VStack(alignment: .leading, spacing: 1) {
                    Text(item.title ?? "Untitled")
                        .font(.custom("Montserrat-SemiBold", size: 11))
                        .foregroundColor(canSelect || isSelected ? AppColors.textWhite : Color.Surface.a40)
                        .lineLimit(1)
                    HStack(spacing: 5) {
                        if let cat = item.category {
                            Text(cat).font(.custom("Montserrat-Regular", size: 9)).foregroundColor(Color.Surface.a50)
                        }
                        if let dl = item.deadline {
                            Text(dl, style: .date).font(.custom("Montserrat-Regular", size: 9))
                                .foregroundColor(dl < Date() ? Color.Danger.a10 : Color.Surface.a50)
                        }
                    }
                }
                Spacer()
                Circle().fill(priorityColor).frame(width: 6, height: 6)
            }
            .padding(.vertical, 8).padding(.horizontal, 10)
            .background(isSelected ? AppColors.shalyPurple.opacity(0.12) : AppColors.card)
            .cornerRadius(8)
            .overlay(RoundedRectangle(cornerRadius: 8)
                .stroke(isSelected ? AppColors.shalyPurple.opacity(0.4) : Color.Surface.a30.opacity(0.3), lineWidth: 0.5))
            .opacity(canSelect || isSelected ? 1 : 0.4)
        }
        .buttonStyle(.plain)
    }

    private var priorityColor: Color {
        switch TaskPriority(rawValue: item.priority) ?? .low {
        case .high: return Color.Danger.a10
        case .medium: return Color.Warning.a10
        case .low: return Color.Info.a10
        }
    }
}

// MARK: - Active session

struct BatchSessionView: View {
    let tasks: [Item]
    let durationSeconds: Int
    let onDismiss: () -> Void
    @Environment(\.managedObjectContext) private var viewContext

    @State private var secondsLeft: Int
    @State private var completedIDs: Set<NSManagedObjectID> = []
    @State private var isRunning = true
    @State private var showCelebration = false
    let sessionTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    init(tasks: [Item], durationSeconds: Int, onDismiss: @escaping () -> Void) {
        self.tasks = tasks
        self.durationSeconds = durationSeconds
        self.onDismiss = onDismiss
        _secondsLeft = State(initialValue: durationSeconds)
    }

    private var elapsed: CGFloat {
        guard durationSeconds > 0 else { return 0 }
        return CGFloat(durationSeconds - secondsLeft) / CGFloat(durationSeconds)
    }
    private var timeString: String {
        String(format: "%02d:%02d", secondsLeft / 60, secondsLeft % 60)
    }
    private var currentTask: Item? {
        tasks.first { !completedIDs.contains($0.objectID) }
    }
    private var taskProgress: CGFloat {
        guard !tasks.isEmpty else { return 0 }
        return CGFloat(completedIDs.count) / CGFloat(tasks.count)
    }

    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 1) {
                        Text("Focus Session")
                            .font(.custom("Montserrat-Bold", size: 14)).foregroundColor(AppColors.textWhite)
                        Text("\(tasks.count) tasks · \(durationSeconds / 60)min")
                            .font(.custom("Montserrat-Regular", size: 10)).foregroundColor(Color.Surface.a50)
                    }
                    Spacer()
                    Button(action: onDismiss) {
                        Text("End session")
                            .font(.custom("Montserrat-SemiBold", size: 11)).foregroundColor(Color.Danger.a10)
                            .padding(.horizontal, 10).padding(.vertical, 5)
                            .background(Capsule().fill(Color.Danger.a20.opacity(0.4)))
                            .overlay(Capsule().stroke(Color.Danger.a10.opacity(0.4), lineWidth: 0.5))
                    }.buttonStyle(.plain)
                }
                .padding(.horizontal, 14).padding(.vertical, 12)
                .background(Color.Surface.a10)

                Divider().background(Color.Surface.a30.opacity(0.4))

                // Timer + task progress hero
                HStack(spacing: 16) {
                    // Timer ring
                    ZStack {
                        Circle().stroke(Color.Surface.a20.opacity(0.4), lineWidth: 7).frame(width: 90, height: 90)
                        Circle()
                            .trim(from: 0, to: 1 - elapsed)
                            .stroke(
                                secondsLeft < 60 ? Color.Danger.a0 : AppColors.shalyPurple,
                                style: StrokeStyle(lineWidth: 7, lineCap: .round)
                            )
                            .frame(width: 90, height: 90)
                            .rotationEffect(.degrees(-90))
                            .animation(.linear(duration: 0.5), value: elapsed)
                        VStack(spacing: 1) {
                            Text(timeString)
                                .font(.custom("Montserrat-Bold", size: 22))
                                .foregroundColor(secondsLeft < 60 ? Color.Danger.a0 : AppColors.textWhite)
                                .monospacedDigit()
                            Text(isRunning ? "focusing" : "paused")
                                .font(.custom("Montserrat-Regular", size: 9)).foregroundColor(Color.Surface.a50)
                        }
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text("\(completedIDs.count)/\(tasks.count) done")
                                    .font(.custom("Montserrat-SemiBold", size: 11)).foregroundColor(AppColors.textWhite)
                                Spacer()
                                Text("\(Int(taskProgress * 100))%")
                                    .font(.custom("Montserrat-Bold", size: 11)).foregroundColor(Color.Success.a0)
                            }
                            GeometryReader { geo in
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 99).fill(Color.Surface.a20.opacity(0.4)).frame(height: 4)
                                    RoundedRectangle(cornerRadius: 99).fill(Color.Success.a0)
                                        .frame(width: geo.size.width * taskProgress, height: 4)
                                        .animation(.spring(), value: taskProgress)
                                }
                            }.frame(height: 4)
                        }

                        Button { isRunning.toggle() } label: {
                            HStack(spacing: 4) {
                                Image(systemName: isRunning ? "pause.fill" : "play.fill").font(.system(size: 10))
                                Text(isRunning ? "Pause" : "Resume").font(.custom("Montserrat-SemiBold", size: 11))
                            }
                            .foregroundColor(AppColors.shalyPurple)
                            .padding(.horizontal, 12).padding(.vertical, 5)
                            .background(Capsule().fill(AppColors.shalyPurple.opacity(0.12)))
                            .overlay(Capsule().stroke(AppColors.shalyPurple.opacity(0.3), lineWidth: 0.5))
                        }.buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 16).padding(.vertical, 14)
                .background(AppColors.shalyPurple.opacity(0.06))

                Divider().background(Color.Surface.a30.opacity(0.3))

                // Task list
                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: 4) {
                        ForEach(tasks) { item in
                            let isDone = completedIDs.contains(item.objectID)
                            let isCurrent = item.objectID == currentTask?.objectID
                            SessionTaskRow(
                                item: item,
                                isDone: isDone,
                                isCurrent: isCurrent,
                                onComplete: { markDone(item) }
                            )
                            .padding(.horizontal, 14)
                        }
                    }.padding(.vertical, 8)
                }

                // Mark done FAB
                VStack(spacing: 0) {
                    Divider().background(Color.Surface.a30.opacity(0.4))
                    if let curr = currentTask {
                        let taskTitle = curr.title ?? "task"
                        Button { markDone(curr) } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "checkmark.circle.fill").font(.system(size: 13))
                                Text("Done with \"\(taskTitle)\"")
                                    .font(.custom("Montserrat-Bold", size: 11)).lineLimit(1)
                            }
                            .foregroundColor(.white).frame(maxWidth: .infinity).padding(.vertical, 10)
                            .background(Capsule().fill(Color.Success.a0))
                        }
                        .buttonStyle(.plain)
                        .padding(.horizontal, 14).padding(.vertical, 9)
                        .background(AppColors.background)
                    }
                }
            }

            if showCelebration {
                CelebrationOverlay {
                    showCelebration = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { onDismiss() }
                }
            }
        }
        .frame(width: 340, height: 480)
        .onReceive(sessionTimer) { _ in
            guard isRunning, secondsLeft > 0 else { return }
            secondsLeft -= 1
            if secondsLeft == 0 { isRunning = false }
        }
        .onChange(of: completedIDs.count) { _, count in
            if count == tasks.count && count > 0 {
                withAnimation { showCelebration = true }
            }
        }
    }

    private func markDone(_ item: Item) {
        guard !completedIDs.contains(item.objectID) else { return }
        withAnimation { _ = completedIDs.insert(item.objectID) }
        item.completed = true
        try? viewContext.save()
    }
}

// MARK: - Session task row

struct SessionTaskRow: View {
    @ObservedObject var item: Item
    let isDone: Bool
    let isCurrent: Bool
    let onComplete: () -> Void

    var body: some View {
        HStack(spacing: 9) {
            Button(action: onComplete) {
                ZStack {
                    Circle()
                        .stroke(
                            isDone ? Color.Success.a0 : (isCurrent ? AppColors.shalyPurple : Color.Surface.a30),
                            lineWidth: 1.5
                        )
                        .frame(width: 17, height: 17)
                    if isDone {
                        Circle().fill(Color.Success.a0.opacity(0.15)).frame(width: 17, height: 17)
                        Image(systemName: "checkmark").font(.system(size: 8, weight: .bold)).foregroundColor(Color.Success.a0)
                    }
                }
            }.buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 1) {
                Text(item.title ?? "Untitled")
                    .font(.custom("Montserrat-SemiBold", size: 11))
                    .foregroundColor(isDone ? Color.Surface.a50 : AppColors.textWhite)
                    .strikethrough(isDone).lineLimit(1)
                if let cat = item.category {
                    Text(cat).font(.custom("Montserrat-Regular", size: 9)).foregroundColor(Color.Surface.a50)
                }
            }
            Spacer()

            if isCurrent && !isDone {
                Text("NOW")
                    .font(.custom("Montserrat-Bold", size: 8)).foregroundColor(AppColors.shalyPurple)
                    .padding(.horizontal, 5).padding(.vertical, 2)
                    .background(Capsule().fill(AppColors.shalyPurple.opacity(0.15)))
            }
            if isDone {
                Image(systemName: "checkmark.circle.fill").font(.system(size: 13)).foregroundColor(Color.Success.a0)
            }
        }
        .padding(.vertical, 9).padding(.horizontal, 12)
        .background(
            isCurrent && !isDone
                ? AppColors.shalyPurple.opacity(0.09)
                : (isDone ? Color.Success.a20.opacity(0.1) : AppColors.card)
        )
        .cornerRadius(9)
        .overlay(RoundedRectangle(cornerRadius: 9)
            .stroke(
                isCurrent && !isDone
                    ? AppColors.shalyPurple.opacity(0.3)
                    : (isDone ? Color.Success.a0.opacity(0.2) : Color.Surface.a30.opacity(0.35)),
                lineWidth: 0.5
            )
        )
        .animation(.easeInOut(duration: 0.2), value: isDone)
    }
}

// MARK: - Celebration overlay

struct CelebrationOverlay: View {
    let onDismiss: () -> Void
    var body: some View {
        ZStack {
            Color.black.opacity(0.6).ignoresSafeArea()
            VStack(spacing: 12) {
                Text("🎉").font(.system(size: 44))
                Text("Session complete!")
                    .font(.custom("Montserrat-Bold", size: 17)).foregroundColor(AppColors.textWhite)
                Text("You crushed it. Every task done.")
                    .font(.custom("Montserrat-Regular", size: 12)).foregroundColor(Color.Surface.a60)
                Button(action: onDismiss) {
                    Text("Done")
                        .font(.custom("Montserrat-Bold", size: 12)).foregroundColor(.white)
                        .padding(.horizontal, 28).padding(.vertical, 10)
                        .background(Capsule().fill(AppColors.shalyPurple))
                }
                .buttonStyle(.plain).padding(.top, 4)
            }
            .padding(24).background(Color.Surface.a10).cornerRadius(16)
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(AppColors.shalyPurple.opacity(0.3), lineWidth: 0.5))
        }
    }
}
