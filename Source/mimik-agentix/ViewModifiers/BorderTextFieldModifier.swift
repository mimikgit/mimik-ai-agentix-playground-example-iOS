//
//  BorderTextFieldModifier.swift
//  mimik-ai-chat
//
//  Created by rb on 2025-03-17.
//

import Foundation
import SwiftUI

struct BorderTextFieldModifier: ViewModifier {
    let minWidth: CGFloat
    let minHeight: CGFloat
    let borderColor: Color
    let lineWidth: CGFloat

    func body(content: Content) -> some View {
        content
            .fontWeight(.regular)
            .font(.body)
            .disableAutocorrection(true)
            .autocapitalization(.none)
            .textFieldStyle(WhiteBorderTextFieldStyle(borderColor: borderColor, lineWidth: lineWidth))
            .frame(minWidth: minWidth, maxWidth: .infinity, minHeight: minHeight)
    }
    
    struct WhiteBorderTextFieldStyle: TextFieldStyle {
        
        let borderColor: Color
        let lineWidth: CGFloat
        
        func _body(configuration: TextField<Self._Label>) -> some View {
            configuration
                .padding(15)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(borderColor, lineWidth: lineWidth)
                )
        }
    }
}
