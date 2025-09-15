//
//  ModelService.swift
//  mimik-ai-chat
//
//  Created by rb on 2025-04-02.
//

import EdgeCore
import SwiftUI

extension ModelService {
        
    // Sends a prompt to the AI assistant using the specified service configuration.
    @MainActor
    func assistantPrompt(configuration: ClientLibrary.AI.ServiceConfiguration, prompt: String, isValidation: Bool) async throws {
        appState.generalMessage = "Contacting \(configuration.id) with a prompt. Please wait…"

        let (managedPrompt, userChatPost) = preparePrompt(originalPrompt: prompt, configuration: configuration, isValidation: isValidation)

        postUserPrompt(
            message: .init(role: "user", content: userChatPost, modelId: configuration.modelId)
        )

        let client = ClientLibrary.AI.HybridClient(configuration: configuration)
        let cancellable = try await client.assistantPrompt(prompt: .init(role: "user", content: managedPrompt))
        appState.activeProtocolStream = cancellable

        defer {
            appState.newResponse = ""
            appState.activeProtocolStream = nil
            appState.generalMessage = ""
        }

        do {
            for try await chunk in cancellable.stream {
                processUniversal(stream: chunk)
            }
        } catch {
            ClientLibrary.Log.logDebug(function: #function, line: #line, items: "Streaming error: \(error)", module: .mimikApps)
            showError(text: "Streaming error: \(error)")
        }
    }

    // Builds the managed and display prompts based on validation mode.
    private func preparePrompt(originalPrompt: String, configuration: ClientLibrary.AI.ServiceConfiguration, isValidation: Bool) -> (managedPrompt: String, userChatPost: String) {
        
        let contextLines = appState.postedMessages.map { msg in
            if msg.isUserType {
                return "User: \(msg.content ?? "")"
            } else {
                return "Assistant: \(msg.content ?? "")"
            }
        }
        
        if !isValidation {
            let contextString = contextLines.joined(separator: "\n")
            let managed = """
            \(contextString)
            User: \(originalPrompt)
            """
            return (managed, originalPrompt)
        }

        let validationContext = appState.postedMessages.map { msg in
            msg.isUserType ? ["prompt": msg.content ?? ""] : ["assistant": msg.content ?? ""]
        }
        let managed = "Validate alternative AI assistant's response: \(validationContext) to the user's prompt."
        let userPost = "Validate with \(configuration.modelId ?? "")"
        return (managed, userPost)
    }
    
    // Starts an asynchronous stream with the specified vision service.
    @MainActor
    func assistantVisionPrompt(configuration: ClientLibrary.AI.ServiceConfiguration, prompt: String, image: UIImage) async throws {
                
        appState.generalMessage = "Contacting \(configuration.id) with a prompt. Please Wait..."
        
        let userMessage = ClientLibrary.AI.Model.Message(role: "user", content: prompt, modelId: configuration.modelId)
        postUserPrompt(message: userMessage)
        let resizeImgOptions = ClientLibrary.ImageResizeOptions(size: CGSize.init(width: 500, height: 500), compressionQuality: 0.5, bytesLimit: 100_000)
        
        let client: any ClientLibrary.AI.ServiceInterface = ClientLibrary.AI.HybridClient(configuration: configuration)
        let cancellable = try await client.assistantVisionPrompt(prompt: userMessage, image: image, resizeImgOptions: resizeImgOptions)
        appState.activeProtocolStream = cancellable

        do {
            for try await chunk in cancellable.stream {
                processUniversal(stream: chunk)
            }
        } catch {
            ClientLibrary.Log.logDebug(function: #function, line: #line, items: "Streaming error: \(error)", module: .mimikApps)
            showError(text: "Streaming error: \(error)")
        }

        appState.newResponse = ""
        appState.activeProtocolStream = nil
        appState.generalMessage = ""
    }
}
