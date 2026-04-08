//import SwiftUI
//
//extension Color {
//    
//    // Main pastels from TinyDesk
//    static let tinyPink = Color(red: 0.96, green: 0.86, blue: 0.90)
//    static let tinyCream = Color(red: 0.96, green: 0.93, blue: 0.82)
//    static let tinyLavender = Color(red: 0.45, green: 0.40, blue: 0.55)
//    static let tinyBorder = Color(red: 0.75, green: 0.70, blue: 0.80)
//
//    // Extra pastel tones
//    static let tinyMint = Color(red: 0.82, green: 0.94, blue: 0.86)
//    static let tinyLime = Color(red: 0.86, green: 0.95, blue: 0.72)
//    static let tinySky = Color(red: 0.82, green: 0.90, blue: 0.97)
//    static let tinyBlue = Color(red: 0.76, green: 0.85, blue: 0.96)
//    static let tinyYellow = Color(red: 0.98, green: 0.94, blue: 0.72)
//
//    // Soft neutrals
//    static let tinyWhite = Color(red: 0.98, green: 0.98, blue: 0.97)
//    static let tinyGray = Color(red: 0.88, green: 0.87, blue: 0.91)
//    
//    // TaskBubble specific colors
//    static let pastelLilac = Color(red: 0.85, green: 0.80, blue: 0.95)
//    static let pastelGreen = Color(red: 0.80, green: 0.95, blue: 0.85)
//    static let pastelBlue = Color(red: 0.80, green: 0.90, blue: 0.98)
//    static let pastelPink = Color(red: 0.95, green: 0.80, blue: 0.90)
//    static let pastelGray = Color(red: 0.90, green: 0.90, blue: 0.90)
//    
//    // Bubble theme specific
//    static let bubbleGlass = Color.white.opacity(0.25)
//    static let bubbleBorder = Color.white.opacity(0.4)
//    static let bubbleShadow = Color.black.opacity(0.05)
//    
//    static let darkBackground = Color(red: 0.15, green: 0.15, blue: 0.20)
//    static let lightBackground = Color(red: 0.98, green: 0.98, blue: 0.97)
//    
//    static let darkText = Color.white
//    static let lightText = Color.black
//}

import SwiftUI

// MARK: - Palette / raw colors (hex / enums)
//optional shorthand
typealias TB = Color
//TB.Surface.a10
//TB.Primary.a0

//hex converter thing
extension Color {
    init(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0

        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else {
            self = .clear
            return
        }

        let r, g, b, a: Double

        switch hexSanitized.count {
        case 6:
            r = Double((rgb & 0xFF0000) >> 16) / 255
            g = Double((rgb & 0x00FF00) >> 8) / 255
            b = Double(rgb & 0x0000FF) / 255
            a = 1

        case 8:
            r = Double((rgb & 0xFF000000) >> 24) / 255
            g = Double((rgb & 0x00FF0000) >> 16) / 255
            b = Double((rgb & 0x0000FF00) >> 8) / 255
            a = Double(rgb & 0x000000FF) / 255

        default:
            self = .clear
            return
        }

        self.init(.sRGB, red: r, green: g, blue: b, opacity: a)
    }
}

//color definitions
//e.g .background(Color.Surface.a10)
//e.g .icon(Color.shalyPurple)
extension Color {

    // MARK: - Brand
//    static let shalyPurple = Color(hex: "#BC6CD9")
    
    enum Basics {
        static let white = Color(hex: "#FFFFFF")
        static let black = Color(hex: "#000000")
    }

    enum Primary {
        //static let shalypurple = Color(hex: "#BC6CD9")
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
