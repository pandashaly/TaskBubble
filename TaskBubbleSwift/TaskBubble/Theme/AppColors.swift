//
//  AppColors.swift
//  TaskBubble
//
//  Created by Shalyca Sottoriva on 08/04/2026.
//

//e.g .background(Color.Surface.a10)

import SwiftUI
// MARK: - Semantic UI colors (buttons, pills, inputs)
struct AppColors { }

extension AppColors {

    static let shalyPurple = Color.Primary.a0
    // MARK: - Pills / Status indicators
    static let pillRedBg = Color.Danger.a20
    static let pillRedText = Color.Basics.black
    static let pillRedIcon = Color.Danger.a0

    static let pillGreenBg = Color.Success.a20
    static let pillGreenText = Color.Basics.black
    static let pillGreenIcon = Color.Success.a0

    static let pillBlueBg = Color.Info.a20
    static let pillBlueText = Color.Basics.black
    static let pillBlueIcon = Color.Info.a0

    static let pillAmberBg = Color.Warning.a20
    static let pillAmberText = Color.Basics.black
    static let pillAmberIcon = Color.Warning.a0
    //===================================
    //Semantics
    static let background = Color.Surface.a0
    static let card = Color.Surface.a10
    static let border = Color.Surface.a30
    static let textWhite = Color.Basics.white
    static let textBlack = Color.Basics.black
    static let accent = Color.Primary.a30
    
}

//Dynamic initializer for ligh/dark mode colors (alternative to Assets)
//Dynamic Color Initializer
//Light and dark mode shouldn’t mean duplicate properties. I add a small Color initializer that resolves the right value for the current appearance, so each token stays a single source of truth.

//import SwiftUI
//
//extension Color {
//    init(dark: Color, light: Color) {
//        self = Color(UIColor { traitCollection in
//            traitCollection.userInterfaceStyle == .dark
//                ? UIColor(dark)
//                : UIColor(light)
//        })
//    }
//}


//
//import SwiftUI
//
//extension Color {
//
//    // MARK: - Brand
//    static let shalyPurple = Color(hex: "#BC6CD9")
//
//    // MARK: - Dark Mode Base
//    static let appBackground = Color(hex: "#25232C")
//    static let baseDark = Color(hex: "#2A292B")
//
//    // MARK: - Surfaces
//    static let surface = Color(hex: "#25232C")
//    static let surfaceElevated = Color(hex: "#393840")
//    static let surfaceMuted = Color(hex: "#4F4D55")
//
//    // MARK: - Borders
//    static let border = Color(hex: "#66646B")
//    static let borderSoft = Color(hex: "#4F4D55")
//
//    // MARK: - Primary
//    static let accentPrimary = Color(hex: "#BC6CD9")
//    static let accentSoft = Color(hex: "#C47DDE")
//    static let accentMuted = Color(hex: "#D49DE6")
//
//    // MARK: - Text
//    static let textPrimary = Color.white
//    static let textSecondary = Color(hex: "#96959A")
//    static let textMuted = Color(hex: "#AFAEB2")
//
//    // MARK: - Status Colors
//    static let success = Color(hex: "#22AB7D")
//    static let successSoft = Color(hex: "#ABEED8")
//
//    static let warning = Color(hex: "#B8872E")
//    static let warningSoft = Color(hex: "#F0E0C2")
//
//    static let danger = Color(hex: "#B02A2A")
//    static let dangerSoft = Color(hex: "#EEB8B8")
//
//    static let info = Color(hex: "#21498A")
//    static let infoSoft = Color(hex: "#92B2E5")
//}
