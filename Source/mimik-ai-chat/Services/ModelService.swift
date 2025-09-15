//
//  ModelService.swift
//  mimik-ai-chat
//
//  Created by rb on 2025-04-02.
//

import EdgeCore
import SwiftUI

class ModelService: ObservableObject {
    
    @ObservedObject var runtimeService: RuntimeService
    @ObservedObject var appState: AppState
    @ObservedObject var authState: AuthState
    
    @Published var downloadedModels: [ClientLibrary.AI.Model] = []
    
    enum ServiceType {
        case prompt
        case validation
    }
    
    var mimikAiConfiguration: ClientLibrary.AI.ServiceConfiguration? {
        guard let developerApiKey = ConfigService.fetchConfig(for: .developerApiKey), let mimOEPort = ClientLibrary.runtimeFullPathUrl().port else {
            return nil
        }
        return ClientLibrary.AI.ServiceConfiguration(kind: .mimikAI, model: nil, apiKey: developerApiKey, mimOEPort: mimOEPort, mimOEClientId: runtimeService.mimOEClientId)
    }

    var geminiAiConfiguration: ClientLibrary.AI.ServiceConfiguration? {
        let model = ClientLibrary.AI.Model.init(id: "gemini-2.0-flash", kind: .llm)
        return ClientLibrary.AI.ServiceConfiguration(kind: .gemini, model: model, apiKey: nil, mimOEPort: nil, mimOEClientId: nil)
    }
    
    @Published var configuredServices: [ClientLibrary.AI.ServiceConfiguration] = []
    @Published var selectedPromptService: ClientLibrary.AI.ServiceConfiguration? = nil
    @Published var selectedValidateService: ClientLibrary.AI.ServiceConfiguration? = nil
                
    init(runtimeService: RuntimeService, appState: AppState, authState: AuthState) {
        self.runtimeService = runtimeService
        self.appState = appState
        self.authState = authState
    }
    
    // Integrates mimik AI service from a configuration object.
    @MainActor
    func integrateAIService(useCase: ClientLibrary.UseCase) async throws {
        guard let apiKey = ConfigService.fetchConfig(for: .developerApiKey) else {
            print("⚠️ API key error")
            showError(text: "API key error")
            throw NSError(domain: "API key error", code: 500)
        }

        defer { Task { await updateConfiguredServices() } }

        do {
            let deployResult = try await ClientLibrary.integrateAIService(
                accessToken: runtimeService.mimOEAccessToken,
                apiKey: apiKey,
                useCase: .inline(useCase)
            )

            print("✅ Integrate AI service success", deployResult)
            runtimeService.deployedUseCase = deployResult.useCase
            authState.saveToken(token: apiKey, serviceKind: .mimikAI, tokenType: .developerToken)

        } catch {
            print("⚠️ Integrate AI service error", error.localizedDescription)
            appState.generalMessage = error.localizedDescription
            throw error
        }
    }
    
    var infoMessage: String {
        guard appState.generalMessage.isEmpty else {
            return appState.generalMessage
        }
        return defaultMessage
    }
    
    func stateReset() {
        print("⚠️ ModelService", #function)
        selectedPromptService = nil
        selectedValidateService = nil
        configuredServices.removeAll()
    }

    func resetGeneralMessage() {
        guard selectedPromptService != nil else {
            appState.generalMessage = ""
            return
        }
        appState.generalMessage = defaultMessage
    }
    
    func showError(text: String) {
        appState.stateReset()
        print("⚠️ Show error:", text)
    }

    private var defaultMessage: String {
        
        guard let kind = selectedPromptService?.model?.kind, let modelId = selectedPromptService?.model?.id else {
            return ""
        }
        
        switch kind {
        case .llm:
            let question = "Ask <\(modelId)> a question"
            if let modelId = selectedValidateService?.modelId {
                return "\(question).\n<\(modelId)> will validate it."
            } else {
                return "\(question). You can follow up in the same context."
            }

        case .vlm:
            return "Attach an image and ask <\(modelId)> to describe it."
        @unknown default:
            return ""
        }
    }
}
