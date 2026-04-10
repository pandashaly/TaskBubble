import SwiftUI
import AppKit

struct TBAppPickerButton: View {
    let selectedApp: DetectedApp?
    let linkURL: String
    let action: () -> Void
    
    @State private var isHovering = false
    
    var body: some View {
        Button(action: action) {
            ZStack {
                if let app = selectedApp {
                    Image(nsImage: app.icon)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                } else if !linkURL.isEmpty {
                    LinkIconView(link: linkURL)
                        .frame(width: 24, height: 24)
                } else {
                    Image(systemName: "app.badge")
                        .font(.title3)
                        .foregroundColor(AppColors.shalyPurple)
                }
            }
            .frame(width: 36, height: 36)
            .background(isHovering ? Color.Surface.a20 : Color.clear)
            .cornerRadius(8)
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.2)) {
                isHovering = hovering
            }
        }
    }
}
