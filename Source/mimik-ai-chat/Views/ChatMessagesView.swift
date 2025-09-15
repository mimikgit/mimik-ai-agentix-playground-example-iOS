//
//  ChatMessagesView.swift
//  mimik-ai-chat
//
//  Created by rb on 2025-01-24.
//

import SwiftUI
import EdgeCore

struct ChatMessagesView: View {
    
    @EnvironmentObject private var appState: AppState
    @State private var position = ScrollPosition(edge: .top)
    
    var body: some View {
        
        ScrollViewReader { proxy in
            
            ScrollView {
                
                ForEach(appState.postedMessages.indices, id: \.self) { index in
                    
                    VStack {
                        HStack(spacing: 0) {
                            
                            if let selection = appState.postedMessages[index] as ClientLibrary.AI.Model.Message?, selection.isUserType {
                                userMessage(message: selection)
                            }
          
                            if let selection = appState.postedMessages[index] as ClientLibrary.AI.Model.Message?, selection.isAiType {
                                aiMessage(message: selection)
                            }
                        }

                        performanceText(message: appState.postedMessages[index])
                    }
                }
            }
            .contentMargins(.top, 20, for: .scrollContent)
            .scrollPosition($position)
            .onChange(of: appState.postedMessages, { oldValue, newValue in
                
                if let lastIndex = appState.postedMessages.indices.last {
                    withAnimation {
                        proxy.scrollTo(lastIndex, anchor: .bottom)
                    }
                }
            })
        }
    }
    
    private func performanceText(message: ClientLibrary.AI.Model.Message) -> some View {

        let hAlignment: HorizontalAlignment = message.isUserType ? .trailing : .leading
        let frameAlignment: Alignment = message.isUserType ? .trailing : .leading
        
        let usageLine: String? = {
            guard let usage = appState.tokenUsage[message.modelId ?? "unknown"] else {
                return ""
            }
            
            var line = ""
            if let tokenPerSecond = usage.tokenPerSecond,
               tokenPerSecond.rounded(.awayFromZero) != 0
            {
                let perf = Int(tokenPerSecond.rounded(.awayFromZero))
                line += "Performance: \(perf) tokens/sec. "
            }
            
            line +=
            "Tokens: \(usage.totalTokens ?? 0) " +
            "(prompt: \(usage.promptTokens ?? 0) + " +
            "completion: \(usage.completionTokens ?? 0))"
            
            return line
        }()
        
        return VStack(alignment: hAlignment, spacing: 4) {
            Text(Date().formattedTodayDate())
            
            if message.isAiType, let modelId = message.modelId {
                Text(modelId)
                
                if let line = usageLine {
                    Text(line)
                }
            }
        }
        .font(.callout)
        .foregroundColor(.gray)
        .frame(maxWidth: .infinity, alignment: frameAlignment)
        .padding(.horizontal, 16)
    }
    
    private func aiMessage(message: ClientLibrary.AI.Model.Message) -> some View {
        ZStack(alignment: .bottomLeading) {
            GradientMessageView(message: message.content ?? "", alignment: .leading, foregroundColor: .white, gradientStyle: .blackToBlack)
        }
    }
    
    private func userMessage(message: ClientLibrary.AI.Model.Message) -> some View {
        ZStack(alignment: .bottomTrailing) {
            
            VStack {
                if let thumbnail = message.thumbnailBase64?.decodeBase64StringToImage() {
                    HStack {
                        Spacer()
                        Image(uiImage: thumbnail)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 50)
                    }
                }

                GradientMessageView(message: message.content ?? "", alignment: .trailing, foregroundColor: .black, gradientStyle: .blueToLightBlue)
            }
        }
    }
}
