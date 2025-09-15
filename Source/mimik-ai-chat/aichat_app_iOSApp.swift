//
//  aichat_app_iOSApp.swift
//  mimik-ai-chat
//
//  Created by rb on 2025-04-01.
//

import EdgeCore
import SwiftUI

@main
struct aichat_app_iOSApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    @StateObject private var appState : AppState
    @StateObject private var runtimeService: RuntimeService
    @StateObject private var modelService: ModelService
    @StateObject private var authState: AuthState
    
    init() {
        let appState = AppState()
        _appState = StateObject(wrappedValue: appState)
        let engine = RuntimeService()
        _runtimeService = StateObject(wrappedValue: engine)
        let authState = AuthState()
        _authState = StateObject(wrappedValue: authState)
        let model = ModelService(runtimeService: engine, appState: appState, authState: authState)
        _modelService = StateObject(wrappedValue: model)
    }

    var body: some Scene {
        WindowGroup {
            if runtimeService.isAuthorizedForRuntime {
                ContentView()
            } else {
                let appName = "Agentix Playground"
                DeveloperConsole.AuthenticationView(
                    appInfo: .init(name: appName, logoName: "App-marketing-Logo", footer: "1.1"),
                    onSuccess: { developer in
                        
                        Task {
                            guard let accessToken = developer.authorization.token?.accessToken else {
                                print("⚠️ Missing access token")
                                return
                            }
                            
                            runtimeService.developerConsoleAccessToken = accessToken
                            
                            if let agentixApp = try await DeveloperConsole.Apps.find(accessToken: accessToken, name: appName) {
                                print("✅ Found the app")
                                runtimeService.developerConsoleClientId = agentixApp.clientId
                            }
                            else {
                                print("⚠️ App does not exist")
                            }
                        }
                    }
                )
            }
        }
        .environmentObject(appState)
        .environmentObject(runtimeService)
        .environmentObject(modelService)
        .environmentObject(authState)
    }
}
