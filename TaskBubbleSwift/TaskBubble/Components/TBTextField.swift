//
//  TBTextField.swift
//  TaskBubble
//
//  Created by Shalyca Sottoriva on 08/04/2026.
//

//usage
//TBTextField(
//    placeholder: "Task title",
//    text: $taskTitle
//)

import SwiftUI

struct TBTextField: View {
    let placeholder: String
    @Binding var text: String

    var body: some View {
        TextField(
            "",
            text: $text,
            prompt: Text(placeholder)
                .foregroundColor(Color.Surface.a50)
        )
        .padding()
        .background(AppColors.card)
        .foregroundColor(AppColors.textWhite)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(AppColors.border, lineWidth: 1)
        )
    }
}
