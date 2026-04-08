//
//  TBCards.swift
//  TaskBubble
//
//  Created by Shalyca Sottoriva on 08/04/2026.
//

import SwiftUI

struct TBBorderedCard<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding()
            .background(AppColors.background)
            .foregroundColor(AppColors.textWhite)
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(AppColors.border, lineWidth: 1)
            )
            .cornerRadius(18)
    }
}

struct TBBorderlessCard<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding()
            .background(AppColors.card)
            .foregroundColor(AppColors.textWhite)
            .cornerRadius(18)
    }
}

//usage
//TBBorderedCard {
//    VStack(alignment: .leading) {
//        Text("Today")
//
//        Image(systemName: "calendar")
//            .foregroundColor(AppColors.accent)
//    }
//}
//.frame(height: 120)
