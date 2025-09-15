//
//  ModelService.swift
//  mimik-ai-chat
//
//  Created by rb on 2025-04-02.
//

import EdgeCore
import SwiftUI

extension ModelService {
    
    func alreadyDownloadedModel(id: String) -> Bool {
        for model in downloadedModels {
            if let modelId = model.id, modelId == id {
                return true
            }
        }
        return false
    }
    
    @MainActor
    func updateDownloadedModels() async throws {
        guard let configuration = mimikAiConfiguration, runtimeService.deployedUseCase != nil else {
            print("❌ downloadedModels Error: missing configuration")
            return
        }

        let client: any ClientLibrary.AI.ServiceInterface = ClientLibrary.AI.HybridClient(configuration: configuration)

        do {
            let response = try await client.availableModels()
            let readyModels = response.filter { $0.readyToUse ?? true }
            downloadedModels = readyModels
            print("✅", #function, downloadedModels)
        } catch {
            print("❌ downloadedModels Error:", error.localizedDescription)
            throw error
        }
    }
    
    @MainActor
    func availableModels(configuration: ClientLibrary.AI.ServiceConfiguration) async throws {
        appState.generalMessage = "Contacting \(configuration.id) for available models. Please Wait..."
        
        let promptMessage = ClientLibrary.AI.Model.Message(
            role: "user",
            content: "\(configuration.kind.rawValue): List available models",
            modelId: configuration.modelId
        )
        postUserPrompt(message: promptMessage)
        
        let client: any ClientLibrary.AI.ServiceInterface = ClientLibrary.AI.HybridClient(configuration: configuration)
        
        do {
            let response = try await client.availableModelsMessage()
            print("✅ \(configuration.id) Response:\n\(response)")
            ongoingStreamResponse(message: response)
            
            appState.newResponse = ""
            appState.generalMessage = ""
        } catch {
            print("❌ Error: \(error.localizedDescription)")
            showError(text: (error as NSError).domain)
            throw error
        }
    }
    
    @MainActor
    func deleteAIModel(id: String) async throws {
        
        guard let apiKey = ConfigService.fetchConfig(for: .developerApiKey), let useCase = runtimeService.deployedUseCase else {
            print("⚠️ API key error")
            showError(text: "API key error")
            throw NSError(domain: "API key error", code: 500)
        }
                
        switch await ClientLibrary.deleteAIModel(id: id, accessToken: runtimeService.mimOEAccessToken, apiKey: apiKey, useCase: useCase) {
            
        case .success:
            appState.generalMessage = "\(id) deleted"
            await updateConfiguredServices()
            clearSelectionIfNeeded(matching: id)
            print("✅", #function, id)
        case .failure(let error):
            showError(text: error.domain)
            await updateConfiguredServices()
            clearSelectionIfNeeded(matching: id)
            print("⚠️ error: \(error.localizedDescription)")
            throw error
        }
    }
    
    private func clearSelectionIfNeeded(matching id: String) {
        if selectedPromptService?.model?.id == id {
            selectedPromptService = nil
        }
        if selectedValidateService?.model?.id == id {
            selectedValidateService = nil
        }
    }
}
