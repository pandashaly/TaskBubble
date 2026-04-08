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
    static let body = Font.custom("Montserrat-Regular", size: 14)
    static let bodyBold = Font.custom("Montserrat-Bold", size: 14)
    static let headline = Font.custom("Montserrat-SemiBold", size: 18)
    //static let title = Font.custom("Montserrat-Bold", size: 20)
    static let caption = Font.custom("Montserrat-Light", size: 12)
    static let numbers = Font.custom("Montserrat-SemiBold", size: 12)
}

