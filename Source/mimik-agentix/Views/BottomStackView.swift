//
//  BottomStackView.swift
//  mimik-ai-chat
//
//  Created by rb on 2025-03-19.
//

import Alamofire
import EdgeCore
import SwiftUI

struct BottomChatView: View {
    
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var modelService: ModelService
    
    @State private var userInput: String = ""
    @State private var question: String = ""
    @State private var showImagePicker: Bool = false
    @State private var showAddModel: Bool = false
    @State private var showFileImporter: Bool = false
    
    var body: some View {
        VStack(spacing: 20) {
            if modelService.selectedPromptService != nil {
                BottomChatInputView(userInput: $userInput, prompt: $question, showImagePicker: $showImagePicker, showFileImporter: $showFileImporter)
                    .textFieldModifier(borderColor: userInputColour(), lineWidth: 2)
                    .fileImporter(
                        isPresented: $showFileImporter,
                        allowedContentTypes: FileTypes.allowedContentTypes(for: [.image]),
                        allowsMultipleSelection: false
                    ) { result in
                        handleFileSelection(result: result)
                    }
            }
        }
        .sheet(isPresented: $showImagePicker) {
            PhotoPicker(showImagePicker: $showImagePicker)
        }
    }
    
    private func handleFileSelection(result: (Result<[URL], any Error>)) -> Void {
        switch result {
        case .success(let urls):
            print("File selection: \(urls)")
            appState.selectedFileURL = urls.first
            
            if let path = urls.first?.path(), let image = UIImage.init(contentsOfFile: path) {
                appState.selectedImage = image
            }
            
        case .failure(let error):
            print("File selection failed: \(error.localizedDescription)")
        }
    }
    
    private func userInputColour() -> Color {
        
        if appState.activeProtocolStream != nil {
            return .gray
        }
        
        return modelService.selectedPromptService != nil ? Color(UIColor.white) : .clear
    }
}
