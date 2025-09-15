//
//  ModelService.swift
//  mimik-ai-chat
//
//  Created by rb on 2025-04-02.
//

import EdgeCore
import SwiftUI

extension ModelService {
    
    // Posts a user message to the app state, optionally with a resized image.
    internal func postUserPrompt(message: ClientLibrary.AI.Model.Message, image: UIImage? = nil, resizeImgOptions: ClientLibrary.ImageResizeOptions? = nil) {
        
        if let image = image, let resizeImgOptions = resizeImgOptions, let resizedImage = image.resizeImage(targetSize: resizeImgOptions.size, bytesLimit: resizeImgOptions.bytesLimit, compressionQuality: resizeImgOptions.compressionQuality), let imageBase64String = resizedImage.base64FromJpeg(compressionQuality: 0.5) {
            let newMessageWithImage = ClientLibrary.AI.Model.Message(role: message.role, content: message.content, thumbnailBase64: imageBase64String, modelId: message.modelId)
            appState.postedMessages.append(newMessageWithImage)
        }
        else {
            appState.postedMessages.append(message)
        }
    }

    // Updates the posted messages array with an incoming AI stream chunk.
    internal func ongoingStreamResponse(message: ClientLibrary.AI.Model.Message) {
        
        guard let role = message.role, let content = message.content, let previousMessage = appState.postedMessages.last else {
            return
        }
        
        if previousMessage.isUserType {
            
            // Last message was from the user: start a new assistant message
            appState.postedMessages.append(message)
            
        } else if previousMessage.isAiType {
            
            // Last message was from the assistant: merge content into it
            let existingContent = previousMessage.content ?? ""
            let mergedContent = existingContent + content
            
            let mergedMessage = ClientLibrary.AI.Model.Message(
                role: role,
                content: mergedContent,
                thumbnailBase64: message.thumbnailBase64,
                modelId: message.modelId
            )
            
            // Replace the last message with the merged one
            appState.postedMessages[appState.postedMessages.count - 1] = mergedMessage
            
        } else {
            // Unexpected case: neither user nor assistant
            print("⚠️ Unsupported message sequence: lastMessage=\(previousMessage)")
        }
    }
    
    // Processes a single chunk of streaming AI completion and updates UI state and token usage.
    func processUniversal(stream: ClientLibrary.AI.Model.CompletionResponse) {
        
        if let modelId = stream.model, stream.finished() {
            return handleEndOfStream(stream: stream, modelId: modelId)
        }

        guard let message = stream.contentMessage(), let contentText = stream.contentText() else {
            return
        }

        let skipSubstrings = [
            "[DONE]",
            "Model loaded successfully",
            "<|loading_model|>",
            "Loading the model",
            "<|processing_prompt|>"
        ]
        
        guard !skipSubstrings.contains(where: contentText.contains) else {
            return
        }

        if let modelId = stream.model, stream.finished() {
            let usage = ClientLibrary.AI.Model.Usage(promptTokens: stream.usage?.promptTokens, completionTokens: stream.usage?.completionTokens, totalTokens: stream.usage?.totalTokens, tokenPerSecond: stream.usage?.tokenPerSecond)
            appState.tokenUsage[modelId] = usage
        }

        ongoingStreamResponse(message: message)
        appState.newResponse += contentText
    }
  
    // Handles the final chunk of an AI streaming response by recording usage metrics
    // and emitting the last assistant message (or a placeholder) to the UI.
    internal func handleEndOfStream(stream: ClientLibrary.AI.Model.CompletionResponse, modelId: String) {
        
        // Record token usage for the completed stream
        let usage = ClientLibrary.AI.Model.Usage(promptTokens: stream.usage?.promptTokens, completionTokens: stream.usage?.completionTokens, totalTokens: stream.usage?.totalTokens, tokenPerSecond: stream.usage?.tokenPerSecond)
        appState.tokenUsage[modelId] = usage

        // Determine the final assistant message and associated text
        let (finalMessage, finalText): (ClientLibrary.AI.Model.Message, String) = {
            if let contentMessage = stream.contentMessage(), let text = stream.contentText() {
                return (contentMessage, text)
            } else {
                // Fallback: emit an empty assistant message to signal end of stream
                let emptyMsg = ClientLibrary.AI.Model.Message(role: "assistant", content: "", thumbnailBase64: nil, modelId: modelId)
                return (emptyMsg, "")
            }
        }()

        // Emit the message and append its text to the ongoing response buffer
        ongoingStreamResponse(message: finalMessage)
        appState.newResponse += finalText
    }
}
