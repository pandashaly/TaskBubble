//
//  Notes.swift
//  TaskBubble
//
//  Created by Shalyca Sottoriva on 09/04/2026.
//


//. Pro-Tip for "Task Bubble"
//The design uses Shadows very subtly. To get that "floating" look without it looking messy, use a very light shadow with a high radius:
//.shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
// MARK: rounded text fild
//struct RoundedTextFieldStyle: TextFieldStyle {
//    func _body(configuration: TextField<Self._Label>) -> some View {
//        configuration
//            .padding(.vertical)
//            .padding(.horizontal, 24)
//            .background(
//                Color(UIColor.systemGray6)
//            )
//            .clipShape(Capsule(style: .continuous))
//    }
//}

// MARK: underline text field
//struct UnderlinedTextFieldStyle: TextFieldStyle {
//    func _body(configuration: TextField<Self._Label>) -> some View {
//        configuration
//            .padding(.vertical, 8)
//            .background(
//                VStack {
//                    Spacer()
//                    Color(UIColor.systemGray4)
//                        .frame(height: 2)
//                }
//            )
//    }
//}

// MARK: hover button

//struct BigButtonStyle: ButtonStyle {
//
//    @State var color: Color = .indigo
//
//    func makeBody(configuration: Configuration) -> some View {
//            configuration.label
//            .font(.title.bold())
//            .padding()
//            .frame(maxWidth: .infinity)
//            .foregroundColor(.white)
//            .background(color)
//            .cornerRadius(12)
//            .overlay {
//                if configuration.isPressed {
//                    Color(white: 1.0, opacity: 0.2)
//                        .cornerRadius(12)
//                }
//            }
//    }
//}

//MARK: clicked/not clicked button

//struct BigButtonStyle: ButtonStyle {
//
//    @State var color: Color = .indigo
//    @Environment(\.isEnabled) private var isEnabled: Bool
//    
//    func makeBody(configuration: Configuration) -> some View {
//            configuration.label
//            .font(.title.bold())
//            .padding()
//            .frame(maxWidth: .infinity)
//            .foregroundColor(isEnabled ? .white : Color(UIColor.systemGray3))
//            .background(isEnabled ? color : Color(UIColor.systemGray5))
//            .cornerRadius(12)
//            .overlay {
//                if configuration.isPressed {
//                    Color(white: 1.0, opacity: 0.2)
//                        .cornerRadius(12)
//                }
//            }
//    }
//}
