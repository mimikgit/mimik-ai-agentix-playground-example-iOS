//
//  ColourText.swift
//  mimik-ai-chat
//
//  Created by rb on 2025-04-07.
//

import SwiftUI

struct ColourText: View {
    
    var text: String
    var fontSize: CGFloat
    var color: Color
    var lineLimit: LineLimit? = nil
    var icon: String? = nil
    var iconPosition: IconPosition? = nil
    var spacing: CGFloat? = nil
    var tapAction: (() -> Void)?
    
    enum IconPosition {
        case before
        case after
    }
    
    var body: some View {
        HStack(spacing: spacing) {
            if iconPosition == .before, let icon = icon {
                Image(systemName: icon)
                    .font(.system(size: fontSize))
                    .foregroundColor(color)
            }
            
            Text(text)
                .font(.system(size: fontSize, weight: .bold, design: .rounded))
                .foregroundColor(color)
                .lineLimit(lineLimit?.lineLimit ?? 0, reservesSpace: lineLimit?.reservesSpace ?? false)
            
            if iconPosition == .after, let icon = icon {
                Image(systemName: icon)
                    .font(.system(size: fontSize))
                    .foregroundColor(color)
            }
        }
        .onTapGesture {
            tapAction?()
        }
    }
}
