//
//  ContentView.swift
//  mimik-ai-chat
//
//  Created by rb on 2025-03-17.
//

import SwiftUI
import PhotosUI
import EdgeCore
import Alamofire
import SwiftyJSON

struct ContentView: View {
    
    @Environment(\.scenePhase) private var scenePhase
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var runtimeService: RuntimeService
    @EnvironmentObject private var modelService: ModelService
    @EnvironmentObject var authState: AuthState
    
    @FocusState private var isFocused: Bool
    @State private var showLoading: Bool = false
    @State private var loadingMessage: String = ""
    
    var body: some View {
        
        ZStack {
            Image("Full Background")
                .resizable()
                .edgesIgnoringSafeArea([.bottom, .top])
            
            VStack() {
                
                TopTitleStackView()
                    .customBackground(backgroundColor: Color(UIColor.systemFill), cornerRadius: 15.0)
                    .padding()
                    .padding(.top)
                    .frame(maxWidth: ScreenSize.screenWidth, maxHeight: DeviceType.isTablet ? 200 : 300)
                    .zIndex(1)
                
                if modelService.selectedPromptService != nil {
                    ChatMessagesView()
                        .frame(maxWidth: ScreenSize.screenWidth, maxHeight: ScreenSize.screenHeight * 0.7)
                        .customBackground(backgroundColor: modelService.selectedPromptService != nil ? Color(UIColor.systemFill) : .clear, cornerRadius: 15.0)
                        .padding()
                    
                    BottomChatView()
                        .customBackground(backgroundColor: modelService.selectedPromptService != nil ? Color(UIColor.systemFill) : .clear, cornerRadius: 15.0)
                        .padding()
                }
            }
        }
        .keyboardAdaptive()
        .edgesIgnoringSafeArea(.all)
        .task {
            Task {
                await startupTask()
                updateConfiguredServices()
            }
        }
        .onChange(of: modelService.selectedPromptService) { oldModel, newNewModel in
            updateConfiguredServices()
        }
        .onChange(of: scenePhase) { oldPhase, newPhase in
            if newPhase == .background {
                // application went to the background, cancelling active streams
                appState.activeProtocolStream.map { $0.cancel() }
                appState.activeProtocolDownload.map { $0.cancel() }
            }
        }
        .sheet(item: $appState.tokenInputService) { service in
            TokenInputStackView(tokenInputService: service)
                .environmentObject(appState)
                .environmentObject(runtimeService)
                .environmentObject(modelService)
                .environmentObject(authState)
        }
    }
    
    private func updateConfiguredServices() {
        Task {
            await modelService.updateConfiguredServices()
        }
    }
    
    private func startupTask() async {
        do {
            try await runtimeService.startupProcedure()
            await modelService.updateConfiguredServices()
        }
        catch {
            print("Error during startup procedure: \(error)")
            if runtimeService.isAuthorizedForRuntime {
                appState.generalMessage = error.localizedDescription
            }
            else {
                appState.generalMessage = "Missing developer console runtime authorization"
            }
        }
    }
}
