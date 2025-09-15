//
//  TokenInputStackView.swift
//  mimik-ai-chat
//
//  Created by rb on 2025-07-04.
//

import EdgeCore
import SwiftUI

struct TokenInputStackView: View {
    
    @EnvironmentObject var authState: AuthState
    @EnvironmentObject var modelService: ModelService
    @EnvironmentObject var appState: AppState

    let tokenInputService: ClientLibrary.AI.ServiceConfiguration

    var body: some View {
        ZStack(alignment: .topLeading) {
            Color.mimikBlue
                .ignoresSafeArea()

            Button(action: cancel) {
                Label("", systemImage: "xmark")
                    .font(.system(size: 32, weight: .regular))
            }
            .tint(.red)
            .padding()

            VStack(spacing: 20) {
                TokenInputView(
                    token: $appState.developerToken,
                    title: "🔑 \(tokenInputService.id) Token",
                    placeholder: "Enter your token…",
                    keyboardType: .default,
                    textContentType: .oneTimeCode
                )

                Button("Connect \(tokenInputService.id)", action: connect)
                    .disabled(appState.developerToken.isEmpty)
                    .buttonStyle(.borderedProminent)
            }
            .padding(40)
        }
    }

    private func cancel() {
        appState.developerToken = ""
        appState.tokenInputService = nil
        authState.deleteServiceToken(serviceKind: tokenInputService.kind)
        Task {
            await modelService.updateConfiguredServices()
        }
    }

    private func connect() {
        authState.saveToken(token: appState.developerToken, serviceKind: tokenInputService.kind, tokenType: .developerToken)
        appState.developerToken = ""
        appState.tokenInputService = nil
        Task {
            await modelService.updateConfiguredServices()
        }
    }
}
