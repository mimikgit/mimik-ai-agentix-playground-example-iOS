//
//  KeyboardAdaptive.swift
//  mimik-ai-chat
//
//  Created by rb on 2025-06-26.
//

import SwiftUI
import UIKit
import Combine

extension Publishers {
    
    // Emits the keyboard’s height when shown, or 0 when hidden.
    static var keyboardHeight: AnyPublisher<CGFloat, Never> {
        let willShow = NotificationCenter.default
            .publisher(for: UIResponder.keyboardWillShowNotification)
            .compactMap { $0.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect }
            .map { $0.height }

        let willHide = NotificationCenter.default
            .publisher(for: UIResponder.keyboardWillHideNotification)
            .map { _ in CGFloat(0) }
        return Publishers
            .Merge(willShow, willHide)
            .eraseToAnyPublisher()
    }
}

// ViewModifier that applies bottom padding equal to keyboard height
struct KeyboardAdaptive: ViewModifier {
    @State private var keyboardHeight: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .padding(.bottom, keyboardHeight)
            .onReceive(Publishers.keyboardHeight) { self.keyboardHeight = $0 }
            .animation(.easeOut(duration: 0.16), value: keyboardHeight)
    }
}

extension View {
    // Shifts this view up/down as the keyboard appears/disappears.
    func keyboardAdaptive() -> some View {
        self.modifier(KeyboardAdaptive())
    }
}
