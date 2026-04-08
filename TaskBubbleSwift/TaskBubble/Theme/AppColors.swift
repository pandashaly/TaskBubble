//
//  AppColors.swift
//  TaskBubble
//
//  Created by Shalyca Sottoriva on 08/04/2026.
//

//e.g .background(Color.Surface.a10)

import SwiftUI

// MARK: - Palette / raw colors (hex / enums)
//optional shorthand
typealias TB = Color
//TB.Surface.a10
//TB.Primary.a0

//hex converter thing
extension Color {
    init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }

        let r, g, b, a: Double

        switch hexSanitized.count {
        case 6:
            r = Double((rgb & 0xFF0000) >> 16) / 255.0
            g = Double((rgb & 0x00FF00) >> 8) / 255.0
            b = Double(rgb & 0x0000FF) / 255.0
            a = 1.0
        case 8:
            r = Double((rgb & 0xFF000000) >> 24) / 255.0
            g = Double((rgb & 0x00FF0000) >> 16) / 255.0
            b = Double((rgb & 0x0000FF00) >> 8) / 255.0
            a = Double(rgb & 0x000000FF) / 255.0
        default:
            return nil
        }

        self.init(.sRGB, red: r, green: g, blue: b, opacity: a)
    }
}

//color definitions
//e.g .background(Color.Surface.a10)
//e.g .icon(Color.shalyPurple)
extension Color {

    // MARK: - Brand
    static let shalyPurple = Color(hex: "#BC6CD9")
    
    enum Basics {
        static let white = Color(hex: "#FFFFFF")
        static let black = Color(hex: "#000000")
    }

    enum Primary {
        static let shalypurple = Color(hex: "#BC6CD9")
        static let a0 = Color(hex: "#BC6CD9")
        static let a10 = Color(hex: "#C47DDE")
        static let a20 = Color(hex: "#CD8DE2")
        static let a30 = Color(hex: "#D49DE6")
    }

    enum Surface {
        static let a0 = Color(hex: "#25232C")
        static let a10 = Color(hex: "#393840")
        static let a20 = Color(hex: "#4F4D55")
        static let a30 = Color(hex: "#66646B")
        static let a40 = Color(hex: "#7E7C82")
        static let a50 = Color(hex: "#96959A")
        static let a60 = Color(hex: "#AFAEB2")
    }

    enum TonalSurface {
        static let a0 = Color(hex: "#332A3B")
        static let a10 = Color(hex: "#473E4E")
        static let a20 = Color(hex: "#5B5462")
        static let a30 = Color(hex: "#716A77")
    }

    // MARK: - Status Colors
    enum Success {
        static let a0 = Color(hex: "#22AB7D")
        static let a10 = Color(hex: "#56DDB0")
        static let a20 = Color(hex: "#ABEED8")
    }

    enum Warning {
        static let a0 = Color(hex: "#B8872E")
        static let a10 = Color(hex: "#DBB571")
        static let a20 = Color(hex: "#F0E0C2")
    }

    enum Danger {
        static let a0 = Color(hex: "#B02A2A")
        static let a10 = Color(hex: "#DA6666")
        static let a20 = Color(hex: "#EEB8B8")
    }

    enum Info {
        static let a0 = Color(hex: "#21498A")
        static let a10 = Color(hex: "#4077D1")
        static let a20 = Color(hex: "#92B2E5")
    }
    
    //======================================
    // MARK: - Complementary Colors

    enum Purple {
        static let dark = Color(hex: "#856CD9")     // darker shade
        static let normal = Color(hex: "#BC6CD9")   // main shade
        static let light = Color(hex: "#D081E7")    // lighter shade
    }

    enum Pink {
        static let dark = Color(hex: "#C65CA8")
        static let normal = Color(hex: "#D96CC0")
        static let light = Color(hex: "#E889D1")
    }

    enum Gold {
        static let dark = Color(hex: "#c7a959")
        static let normal = Color(hex: "#D9BC6C")
        static let light = Color(hex: "#E7D581")
    }

    enum Green {
        static let dark = Color(hex: "#6BB54F")
        static let normal = Color(hex: "#6CD985")
        static let light = Color(hex: "#9CEEA0")
    }

    enum Teal {
        static let dark = Color(hex: "#4BA89B")
        static let normal = Color(hex: "#6CD9BC")
        static let light = Color(hex: "#9CEFD3")
    }

    enum Orange {
        static let dark = Color(hex: "#C47055")
        static let normal = Color(hex: "#D9856C")
        static let light = Color(hex: "#E8A48B")
    }
}

/*
==========================
Complementary Color Reference
==========================

-- Double Split Complementary --
#856CD9  // Purple, a10, Double Split Complementary
#BC6CD9  // Purple, a20, Double Split Complementary
#D96CC0  // Pink, a30, Double Split Complementary
#C0D96C  // Green-Yellow, a40, Double Split Complementary
#6CD985  // Green, a50, Double Split Complementary

-- Triadic Scheme --
#BC6CD9  // Purple, a10, Triadic
#D9BC6C  // Gold, a20, Triadic
#6CD9BC  // Teal, a30, Triadic

-- Tetradic Scheme --
#BC6CD9  // Purple, a10, Tetradic
#D9856C  // Orange, a20, Tetradic
#89D96C  // Green, a30, Tetradic
#6CC0D9  // Cyan, a40, Tetradic

-- Rectangle Scheme --
#BC6CD9  // Purple, a10, Rectangle
#D96C89  // Pink, a20, Rectangle
#89D96C  // Green, a30, Rectangle
#6CD9BC  // Teal, a40, Rectangle
*/

//=======================================================================

// MARK: - Semantic UI colors (buttons, pills, inputs)
struct AppColors { }

extension AppColors {

    // MARK: - Pills / Status indicators
    static let pillRedBackground = Color.Danger.a20
    static let pillRedText = Color.black
    static let pillRedIcon = Color.Danger.a0

    static let pillGreenBackground = Color.Success.a20
    static let pillGreenText = Color.black
    static let pillGreenIcon = Color.Success.a0

    static let pillBlueBackground = Color.Info.a20
    static let pillBlueText = Color.black
    static let pillBlueIcon = Color.Info.a0

    static let pillAmberBackground = Color.Warning.a20
    static let pillAmberText = Color.black
    static let pillAmberIcon = Color.Warning.a0
}




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
