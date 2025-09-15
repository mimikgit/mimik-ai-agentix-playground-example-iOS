//
//  ModelButton.swift
//  mimik-ai-chat
//
//  Created by rb on 2025-04-07.
//

import SwiftUI
import EdgeCore

struct ModelButton: View {
    
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var modelService: ModelService
    
    var buttonText: String
    var backgroundColor: Color
    var foregroundColor: Color
    var fontSize: CGFloat
    var maxWidth: CGFloat
    var maxHeight: CGFloat
    var model: ClientLibrary.AI.Model.CreateModelRequest?
    var action: () -> Void

    var body: some View {
        ZStack {

            Button(action: action) {
                
                HStack {
                    if model != nil {
                        Spacer()
                    }
                    
                    Text(buttonText)
                        .foregroundColor(foregroundColor)
                        .font(.system(size: fontSize, weight: .semibold))
                    
                    if let model = model, let kind = model.kind {
                        Spacer()
                        if modelService.alreadyDownloadedModel(id: model.id) {
                            MetallicText(text: "", fontSize: 15, color: .gold, icon: "checkmark.circle.fill", iconPosition: .after)
                        }
                        
                        VStack(alignment: .trailing) {
                            HStack {
                                ColourText(text: modelType(for: model), fontSize: DeviceType.isTablet ? 10 : 13, color: modelTypeColour(kind: kind), icon: kind == .llm ? nil : modelTypeIcon(for: model), iconPosition: .after, spacing: 5)
                            }
                            if let hint = model.chatTemplateHint {
                                HStack {
                                    ColourText(text: hint.rawValue, fontSize: DeviceType.isTablet ? 10 : 13, color: foregroundColor)
                                }
                            }
                            HStack {
                                ColourText(text: AddModelView.ModifiedModel.readableFileSize(model.expectedDownloadSize) , fontSize: DeviceType.isTablet ? 10 : 13, color: foregroundColor)
                            }
                        }
                    }
                }
                .padding()
                .frame(maxWidth: maxWidth, maxHeight: maxHeight)
                .background(backgroundColor)
                .cornerRadius(12)
            }
        }
    }
    
    private func modelTypeIcon(for request: ClientLibrary.AI.Model.CreateModelRequest) -> String? {
        let kind = request.kind ?? .llm
        switch kind {
        case .vlm:
            return "eye.fill"
        default:
            return nil
        }
    }
    
    private func modelTypeColour(kind: ClientLibrary.AI.Model.Kind) -> Color {
        switch kind {
        case .llm:
            return foregroundColor
        case .vlm:
            return .gold
        @unknown default:
            return foregroundColor
        }
    }
    
    // Returns a human-readable identifier for the given model request.
    private func modelType(for request: ClientLibrary.AI.Model.CreateModelRequest) -> String {
        let kind = request.kind ?? .llm
        switch kind {
        case .llm:
            return "llm"
        case .vlm:
            return "vision"
        @unknown default:
            return "unknown"
        }
    }
}
