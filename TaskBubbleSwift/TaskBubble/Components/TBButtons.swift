//
//  TBButtons.swift
//  TaskBubble
//
//  Created by Shalyca Sottoriva on 08/04/2026.
//

import SwiftUI

// MARK: - Purple Button
//TBPrimaryButton(title: "Add New Task") {
//    addTask()
//}
struct TBPrimaryButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundColor(AppColors.background)
                .padding(.vertical, 10)
                .padding(.horizontal, 14)
                .frame(maxWidth: .infinity)
                .background(AppColors.accent)
                .cornerRadius(12)
        }
        .buttonStyle(.plain)
    }
}

//MARK: - Border Button
//TBBorderButton(
//    title: "Filter",
//    icon: "slider.horizontal.3"
//) {
//}
struct TBBorderButton: View {
    let title: String
    let icon: String?
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                if let icon = icon {
                    Image(systemName: icon)
                        .foregroundColor(AppColors.accent)
                }

                Text(title)
                    .foregroundColor(AppColors.textWhite)
            }
            .font(.subheadline.weight(.medium))
            .padding(.vertical, 10)
            .padding(.horizontal, 14)
            .frame(maxWidth: .infinity)
            .background(AppColors.card)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(AppColors.border, lineWidth: 1)
            )
            .cornerRadius(12)
        }
        .buttonStyle(.plain)
    }
}


//MARK: - Gray button
struct TBGrayButton: View {
    let title: String
    let icon: String?
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                if let icon = icon {
                    Image(systemName: icon)
                        .foregroundColor(AppColors.accent)
                }

                Text(title)
                    .foregroundColor(AppColors.textWhite)
            }
            .font(.subheadline)
            .padding(.vertical, 10)
            .padding(.horizontal, 14)
            .background(Color.Surface.a20)
            .cornerRadius(12)
        }
        .buttonStyle(.plain)
    }
}

//MARK: - Icon Button
//TBIconButton(icon: "plus") {
//}

struct TBIconButton: View {
    let icon: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(AppColors.accent)
                .frame(width: 34, height: 34)
                .background(AppColors.card)
                .overlay(
                    Circle()
                        .stroke(AppColors.border, lineWidth: 1)
                )
                .clipShape(Circle())
        }
        .buttonStyle(.plain)
    }
}

//MARK: - Pill Button
//TBStatusPillButton(
//    title: "Done",
//    icon: "checkmark",
//    bg: AppColors.pillGreenBg,
//    textColor: AppColors.pillGreenText,
//    iconColor: AppColors.pillGreenIcon
//) {
//}

struct TBStatusPillButton: View {
    let title: String
    let icon: String
    let bg: Color
    let textColor: Color
    let iconColor: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .foregroundColor(iconColor)

                Text(title)
                    .foregroundColor(textColor)
            }
            .font(.caption.weight(.medium))
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(bg)
            .cornerRadius(999)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Expandable Button (Advanced)
struct TBExpandableButton: View {
    let title: String
    let icon: String
    let action: () -> Void
    var fontSize: CGFloat = 13
    var horizontalPadding: CGFloat = 16
    var verticalPadding: CGFloat = 6
    
    @State private var isHovering = false
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Text(title)
                Image(systemName: icon)
            }
            .font(.system(size: fontSize, weight: .semibold))
            .foregroundColor(isHovering ? .white : .secondary)
            .padding(.vertical, verticalPadding)
            .padding(.horizontal, horizontalPadding)
            .frame(maxWidth: .infinity)
            .background(isHovering ? AppColors.shalyPurple.opacity(0.5) : Color.clear)
            .cornerRadius(6)
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.2)) {
                isHovering = hovering
            }
        }
    }
}

// MARK: - Circle Icon Button
struct TBCircleIconButton: View {
    let icon: String
    let action: () -> Void
    var diameter: CGFloat = 24
    var iconSize: CGFloat = 11
    var color: Color = AppColors.shalyPurple
    var filled: Bool = false
    
    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(filled ? Color(nsColor: .textBackgroundColor) : Color(nsColor: .controlBackgroundColor))
                    .frame(width: diameter, height: diameter)
                    .overlay(Circle().strokeBorder(Color.gray.opacity(0.32), lineWidth: 0.5))
                
                Image(systemName: icon)
                    .font(.system(size: iconSize, weight: .medium))
                    .foregroundColor(color)
            }
        }
        .buttonStyle(.plain)
    }
}
