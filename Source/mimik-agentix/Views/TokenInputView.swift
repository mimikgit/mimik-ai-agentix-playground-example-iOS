//
//  TokenInputView.swift
//  mimik-ai-chat
//
//  Created by rb on 2025-06-18.
//

import SwiftUI

struct TokenInputView: View {
    
    @Binding var token: String
    
    var title: String?
    var placeholder: String = ""
    var keyboardType: UIKeyboardType = .asciiCapable
    var textContentType: UITextContentType? = nil
    
    @FocusState private var isFocused: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            if let title = title {
                Text(title)
                    .font(.headline)
            }
            
            TextField(placeholder, text: $token)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(keyboardType)
                .textContentType(textContentType)
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .focused($isFocused)
                .onAppear {
                    // delay slightly to ensure keyboard shows
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        isFocused = true
                    }
                }
        }
        .padding()
    }
}
