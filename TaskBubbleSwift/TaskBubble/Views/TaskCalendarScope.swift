//
//  TaskCalendarScope.swift
//  TaskBubble
//

import Foundation

enum TaskCalendarScope: String, CaseIterable, Identifiable {
    case week
    case month

    var id: String { rawValue }

    var label: String {
        switch self {
        case .week: return "Week"
        case .month: return "Month"
        }
    }
}
