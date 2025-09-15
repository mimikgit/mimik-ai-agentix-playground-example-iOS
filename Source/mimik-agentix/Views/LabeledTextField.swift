//
//  LabeledTextField.swift
//  mimik-ai-chat
//
//  Created by rb on 2025-04-07.
//

import SwiftUI

struct LabeledTextField: View {
    var label: String
    var placeholder: String
    @Binding var text: String
    var fontSize: CGFloat = 16
    var labelColor: Color = .gray
    var textColor: Color = .primary
    var borderColor: Color = .gray
    var cornerRadius: CGFloat = 10
    var borderWidth: CGFloat = 1
    var backgroundColor: Color = .clear

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.system(size: fontSize, weight: .semibold))
                .foregroundColor(labelColor)

            TextField(placeholder, text: $text)
                .padding(15)
                .font(.system(size: fontSize))
                .foregroundColor(textColor)
                .background(backgroundColor)
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .stroke(borderColor, lineWidth: borderWidth)
                )
                .cornerRadius(cornerRadius)
        }
        .padding(.horizontal)
    }
}
