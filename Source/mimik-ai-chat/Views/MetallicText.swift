//
//  MetallicText.swift
//  mimik-ai-chat
//
//  Created by rb on 2025-03-24.
//

import SwiftUI

struct LineLimit {
    var lineLimit: Int
    var reservesSpace: Bool
    var minimumScaleFactor: CGFloat = 1.0
}

struct MetallicText: View {
    
    var text: String
    var fontSize: CGFloat
    var color: MetallicColor
    var lineLimit: LineLimit? = nil
    var icon: String? = nil
    var iconPosition: IconPosition? = nil
    var tapAction: (() -> Void)?
    
    enum IconPosition {
        case before
        case after
    }
    
    enum MetallicColor {
        case gold
        case silver
        case bronze
        case copper
        case roseGold
        case platinum
        case titanium
        case emerald
        case sapphire
        case ruby
        case amethyst
        case obsidian
        
        // Pure solid colors
        case pureBlack
        case pureWhite
        case pureRed
        case pureGreen
        case pureBlue
        case pureYellow
        case pureCyan
        case pureMagenta
    }
  
    @GestureState private var isPressed = false

    var body: some View {
        let pressGesture = DragGesture(minimumDistance: 0)
            .updating($isPressed) { _, state, _ in
                state = true
            }
            .onEnded { _ in
                tapAction?()
            }

        return HStack {
            if iconPosition == .before, let icon = icon {
                Image(systemName: icon)
                    .font(.system(size: fontSize))
                    .foregroundStyle(gradient(for: color))
            }

            formattedText(from: text)
                .font(.system(size: fontSize, weight: .bold, design: .rounded))
                .overlay(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.white.opacity(0.5), Color.clear]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .mask(
                        formattedText(from: text)
                            .font(.system(size: fontSize, weight: .bold, design: .rounded))
                    )
                )
                .shadow(color: Color.black.opacity(0.3), radius: 10, x: 5, y: 5)
                .lineLimit(lineLimit?.lineLimit ?? 0, reservesSpace: lineLimit?.reservesSpace ?? false)
                .minimumScaleFactor(lineLimit?.minimumScaleFactor ?? 1.0)

            if iconPosition == .after, let icon = icon {
                Image(systemName: icon)
                    .font(.system(size: fontSize))
                    .foregroundStyle(gradient(for: color))
            }
        }
        .scaleEffect(isPressed ? 0.8 : 1.0)
        .opacity(isPressed ? 0.8 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.5), value: isPressed)
        .gesture(pressGesture)
    }
    
    private func formattedText(from fullText: String) -> Text {
        guard let regex = try? NSRegularExpression(pattern: "<[^>]*>", options: []) else {
            return Text(fullText).foregroundStyle(gradient(for: color))
        }

        let nsText = fullText as NSString
        let matches = regex.matches(in: fullText, options: [], range: NSRange(location: 0, length: nsText.length))

        var lastIndex = 0
        var result = Text("")

        for match in matches {
            let matchRange = match.range
            let beforeRange = NSRange(location: lastIndex, length: matchRange.location - lastIndex)
            
            if beforeRange.length > 0 {
                let beforeText = nsText.substring(with: beforeRange)
                result = result + Text(beforeText).foregroundStyle(gradient(for: color))
            }

            let matchedText = nsText.substring(with: matchRange)
            result = result + Text(matchedText).foregroundColor(.white)

            lastIndex = matchRange.location + matchRange.length
        }

        if lastIndex < nsText.length {
            let remainingText = nsText.substring(from: lastIndex)
            result = result + Text(remainingText).foregroundStyle(gradient(for: color))
        }

        return result
    }
    
    private func gradient(for color: MetallicColor) -> LinearGradient {
        switch color {
        case .pureBlack:
            return LinearGradient(
                gradient: Gradient(colors: [Color.black, Color.black, Color.black]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .gold:
            return LinearGradient(
                gradient: Gradient(colors: [Color.yellow, Color.orange, Color.red]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .silver:
            return LinearGradient(
                gradient: Gradient(colors: [Color.gray, Color.white, Color.silver]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .bronze:
            return LinearGradient(
                gradient: Gradient(colors: [Color.brown, Color.orange, Color.red]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .copper:
            return LinearGradient(
                gradient: Gradient(colors: [Color.red, Color.orange, Color.brown]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .roseGold:
            return LinearGradient(
                gradient: Gradient(colors: [Color.pink, Color.red, Color.orange]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .platinum:
            return LinearGradient(
                gradient: Gradient(colors: [Color.gray, Color.white, Color.silver]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .titanium:
            return LinearGradient(
                gradient: Gradient(colors: [Color.darkGray, Color.gray, Color.black]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .emerald:
            return LinearGradient(
                gradient: Gradient(colors: [Color.green, Color.teal, Color.blue]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .sapphire:
            return LinearGradient(
                gradient: Gradient(colors: [Color.blue, Color.indigo, Color.purple]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .ruby:
            return LinearGradient(
                gradient: Gradient(colors: [Color.red, Color.pink, Color.orange]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .amethyst:
            return LinearGradient(
                gradient: Gradient(colors: [Color.purple, Color.blue, Color.pink]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .obsidian:
            return LinearGradient(
                gradient: Gradient(colors: [Color.black, Color.gray, Color.darkGray]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .pureRed:
            return LinearGradient(
                gradient: Gradient(colors: [Color.red, Color.red, Color.red]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .pureGreen:
            return LinearGradient(
                gradient: Gradient(colors: [Color.green, Color.green, Color.green]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .pureBlue:
            return LinearGradient(
                gradient: Gradient(colors: [Color.blue, Color.blue, Color.blue]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .pureYellow:
            return LinearGradient(
                gradient: Gradient(colors: [Color.yellow, Color.yellow, Color.yellow]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .pureCyan:
            return LinearGradient(
                gradient: Gradient(colors: [Color(red: 0, green: 1, blue: 1),
                                            Color(red: 0, green: 1, blue: 1),
                                            Color(red: 0, green: 1, blue: 1)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .pureMagenta:
            return LinearGradient(
                gradient: Gradient(colors: [Color(red: 1, green: 0, blue: 1),
                                            Color(red: 1, green: 0, blue: 1),
                                            Color(red: 1, green: 0, blue: 1)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .pureWhite:
            return LinearGradient(
                gradient: Gradient(colors: [Color.white, Color.white, Color.white]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
}
