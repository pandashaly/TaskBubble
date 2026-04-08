//import SwiftUI
//
//struct PastelMenuButtonStyle: ButtonStyle {
//    var fill: Color
//
//    func makeBody(configuration: Configuration) -> some View {
//        configuration.label
//            .font(.system(size: 16, weight: .heavy, design: .rounded))
//            .foregroundStyle(Color.tinyLavender)
//            .frame(minWidth: 118)
//            .padding(.vertical, 10)
//            .padding(.horizontal, 16)
//            .background(
//                RoundedRectangle(cornerRadius: 14, style: .continuous)
//                    .fill(fill)
//            )
//            .overlay(
//                RoundedRectangle(cornerRadius: 14, style: .continuous)
//                    .stroke(Color.tinyLavender.opacity(0.75), lineWidth: 1.5)
//            )
//            .shadow(
//                color: Color.tinyLavender.opacity(configuration.isPressed ? 0.08 : 0.16),
//                radius: configuration.isPressed ? 2 : 5,
//                x: 0,
//                y: configuration.isPressed ? 1 : 3
//            )
//            .scaleEffect(configuration.isPressed ? 0.985 : 1.0)
//            .animation(.easeOut(duration: 0.14), value: configuration.isPressed)
//    }
//}
