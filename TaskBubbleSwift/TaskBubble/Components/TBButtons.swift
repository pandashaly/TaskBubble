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
