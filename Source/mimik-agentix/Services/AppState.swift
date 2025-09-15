//
//  AppState.swift
//  mimik-ai-chat
//
//  Created by rb on 2025-04-01.
//

import Alamofire
import EdgeCore
import SwiftUI
import Network

class AppState: ObservableObject {
    
    // Track which service was selected for token input
    @Published var tokenInputService: ClientLibrary.AI.ServiceConfiguration?
    
    // Holds the token input the user types in
    @Published var developerToken: String = ""
    
    @Published var postedMessages: [ClientLibrary.AI.Model.Message] = []
    @Published var justDownloadedModelId: String = ""
    @Published var generalMessage: String = ""
    @Published var downloadMessage: String = ""
    @Published var tokenUsage: [String: ClientLibrary.AI.Model.Usage] = [:]
    @Published var newResponse: String = ""

    // Active protocol streams
    @Published var activeProtocolStream: ClientLibrary.AI.CancellableStream<ClientLibrary.AI.Model.CompletionResponse>?
    @Published var activeProtocolDownload: ClientLibrary.AI.CancellableStream<ClientLibrary.AI.DownloadAIEvent>?
    
    // Photo Picker selection
    @Published var selectedImage: UIImage?
    
    // File Picker selection
    @Published var selectedFileURL: URL? = nil
    
    func stateReset() {
        print("⚠️ AppState", #function)
        postedMessages = []
        justDownloadedModelId = ""
        generalMessage = ""
        downloadMessage = ""
        tokenUsage = [:]
        selectedImage = nil
        selectedFileURL = nil
        activeProtocolStream.map { $0.cancel() }
        activeProtocolDownload.map { $0.cancel() }
    }
    
    public func messagesForCopying(includePrompt: Bool = true) -> String {
        var result: [String] = []
        for message in postedMessages {
            if let content = message.content {
                if message.isUserType, includePrompt {
                    result.append("\nPrompt: \(content)")
                } else if message.isAiType {
                    result.append("Response: \(content)")
                }
            }
        }
        return result.joined(separator: "\n")
    }
}
