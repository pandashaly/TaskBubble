//
//  AppFonts.swift
//  TaskBubble
//
//  Created by Shalyca Sottoriva on 08/04/2026.
//

import SwiftUI

struct AppFonts {

    static func title() -> Font {
        .custom("Montserrat-SemiBold", size: 24)
    }

    static func cardTitle() -> Font {
        .custom("Montserrat-Medium", size: 18)
    }

    static func taskText() -> Font {
        .custom("Montserrat-Regular", size: 16)
    }

    static func label() -> Font {
        .custom("Montserrat-Regular", size: 13)
    }

    static func button() -> Font {
        .custom("Montserrat-Medium", size: 16)
    }

    static func pillText() -> Font {
        .custom("Montserrat-Medium", size: 12)
    }
}
