import SwiftUI

struct TBFooterActionButton: View {
    let title: String
    let icon: String
    let action: () -> Void
    var color: Color = AppColors.shalyPurple
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 11, weight: .bold))
                Text(title)
                    .font(.custom("Montserrat-Bold", size: 11))
            }
            .foregroundColor(color)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(Capsule().fill(color.opacity(0.12)))
            .overlay(Capsule().stroke(color.opacity(0.4), lineWidth: 0.5))
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(AppColors.background)
        .overlay(Rectangle().frame(height: 0.5).foregroundColor(Color.Surface.a30.opacity(0.4)), alignment: .top)
    }
}
