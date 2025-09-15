//
//  GradientMessageView.swift
//  mimik-ai-chat
//
//  Created by rb on 2025-03-21.
//

import SwiftUI

struct GradientMessageView: View {
    
    var message: String
    var alignment: Alignment
    var foregroundColor: Color
    var gradientStyle: GradientStyle

    enum GradientStyle {
        case blueToLightBlue
        case blackToBlack
        
        var gradient: LinearGradient {
            switch self {
            case .blueToLightBlue:
                return LinearGradient(
                    stops: [
                        Gradient.Stop(color: Color(red: 0, green: 0.6, blue: 0.97), location: 0.00),
                        Gradient.Stop(color: Color(red: 0.47, green: 0.83, blue: 1), location: 1.00),
                    ],
                    startPoint: UnitPoint(x: 0, y: 1),
                    endPoint: UnitPoint(x: 1, y: 1)
                )
            case .blackToBlack:
                return LinearGradient(
                    stops: [
                        Gradient.Stop(color: Color(red: 0.15, green: 0.15, blue: 0.15), location: 0.00),
                        Gradient.Stop(color: Color(red: 0, green: 0.01, blue: 0.04), location: 1.00),
                    ],
                    startPoint: UnitPoint(x: 0, y: 1),
                    endPoint: UnitPoint(x: 1, y: 1)
                )
            }
        }
    }

    var body: some View {
        Text(message)
            .padding()
            .background(gradientStyle.gradient)
            .foregroundColor(foregroundColor)
            .cornerRadius(10)
            .frame(maxWidth: .infinity, alignment: alignment)
    }
}
