//
//  TopTitleStackView.swift
//  mimik-ai-chat
//
//  Created by rb on 2025-03-21.
//

import Alamofire
import EdgeCore
import SwiftUI

struct TopTitleStackView: View {
    
    @EnvironmentObject var authState: AuthState
    @EnvironmentObject var runtimeService: RuntimeService
    @EnvironmentObject var modelService: ModelService
    @EnvironmentObject private var appState: AppState
    @State private var showAddModelTablet: Bool = false
    @State private var showAddModelPhone: Bool = false
    @State private var validationSelections: Set<ClientLibrary.AI.ServiceConfiguration> = []
    
    var body: some View {
        
        ZStack {
            if runtimeService.deployedUseCase != nil {
                VStack {
                    if DeviceType.isTablet {
                        deployedAlreadyMenuTablet
                    }
                    else {
                        deployedAlreadyMenuPhone
                    }
                                        
                    if !appState.downloadMessage.isEmpty {
                        HStack {
                            MetallicText(text: appState.downloadMessage, fontSize: DeviceType.isTablet ? 23 : 17, color: .silver, lineLimit: .init(lineLimit: DeviceType.isTablet ? 1 : 2, reservesSpace: true, minimumScaleFactor: 0.75))
                            MetallicText(text: "", fontSize: DeviceType.isTablet ? 23 : 17, color: .gold, icon: "trash", iconPosition: .after) { appState.stateReset() }
                            Spacer()
                        }
                    }
                }
            }
            else {
                notDeployedYetMenu
            }
        }
    }
  
    private var notDeployedYetMenu: some View {
        VStack {
            Image("mimik-ai-logo-white")
            MetallicText(text: "agentix playground", fontSize: 18, color: .amethyst)

            MetallicText(text: "START HERE", fontSize: DeviceType.isTablet ? 32 : 12, color: .gold, icon: "gear.badge", iconPosition: .after) {
                Task {
                    appState.generalMessage = "Deploying..."
                    do {
                        let config: ClientLibrary.UseCase = try ConfigService.decodeJsonDataFrom(
                            file: "mimik-ai-use-case-config",
                            type: ClientLibrary.UseCase.self
                        )

                        try? await Task.sleep(nanoseconds: 750_000_000)
                        try await modelService.integrateAIService(useCase: config)

                        appState.generalMessage = ""
                        print("✅ mimik AI integration successful")
                    } catch {
                        print("⚠️ mimik AI integration failed:", error.localizedDescription)
                        let nsError = error as NSError
                        appState.generalMessage = nsError.domain
                    }
                }
            }

            if !appState.generalMessage.isEmpty {
                Spacer()
                HStack {
                    if appState.activeProtocolStream != nil {
                        MetallicText(text: "", fontSize: DeviceType.isTablet ? 25 : 16, color: .ruby, icon: "xmark", iconPosition: .after) {
                            appState.stateReset()
                        }
                    }
                    let missing = appState.generalMessage.contains("Missing")
                    MetallicText(text: appState.generalMessage, fontSize: DeviceType.isTablet ? 23 : 23, color: missing ? .pureRed : .silver, lineLimit: .init(lineLimit: DeviceType.isTablet ? 2 : 4, reservesSpace: DeviceType.isTablet ? false : true))
                }
            }
        }
    }
    
    private var deployedAlreadyMenuPhone: some View {
        VStack() {
            
            VStack {
                Image("mimik-ai-logo-white")
                MetallicText(text: "agentix", fontSize: 10, color: .amethyst)
                MetallicText(text: "playground", fontSize: 10, color: .amethyst)
                
                HStack {
                    optionsMenu
                    
                    if modelService.selectedValidateService != nil, modelService.selectedPromptService != nil {
                        MetallicText(text: "", fontSize: 17, color: .gold, icon: "rectangle.2.swap", iconPosition: .after) {
                            let selectedPromptService = modelService.selectedPromptService
                            modelService.selectedPromptService = modelService.selectedValidateService
                            modelService.selectedValidateService = selectedPromptService
                        }
                    }
                    
                    if modelService.selectedPromptService != nil || modelService.selectedValidateService != nil {
                        MetallicText(text: "", fontSize: 17, color: .gold, icon: "arrow.3.trianglepath", iconPosition: .after) {
                            modelService.selectedPromptService = nil
                            modelService.selectedValidateService = nil
                        }
                    }
                }
            }
            
            HStack {
                MenuViewPrompt(showAddModelTablet: $showAddModelTablet, showAddModelPhone: $showAddModelPhone)
                    .customBackground(backgroundColor: Color(UIColor.systemFill), cornerRadius: 15)
                Spacer()
                Spacer()
                
                MenuViewValidation()
                    .customBackground(backgroundColor: Color(UIColor.systemFill), cornerRadius: 15)
            }
        }
    }
    
    private var deployedAlreadyMenuTablet: some View {
        HStack() {
            MenuViewPrompt(showAddModelTablet: $showAddModelTablet, showAddModelPhone: $showAddModelPhone)
                .customBackground(backgroundColor: Color(UIColor.systemFill), cornerRadius: 15)
            
            Spacer()
            
            VStack {
                Image("mimik-ai-logo-white")
                MetallicText(text: "agentix", fontSize: 18, color: .amethyst)
                MetallicText(text: "playground", fontSize: 18, color: .amethyst)
                
                HStack {
                    optionsMenu
                    
                    if modelService.selectedValidateService != nil, modelService.selectedPromptService != nil {
                        MetallicText(text: "", fontSize: 22, color: .gold, icon: "rectangle.2.swap", iconPosition: .after) {
                            let selectedPromptService = modelService.selectedPromptService
                            modelService.selectedPromptService = modelService.selectedValidateService
                            modelService.selectedValidateService = selectedPromptService
                        }
                    }
                    
                    if modelService.selectedPromptService != nil || modelService.selectedValidateService != nil {
                        MetallicText(text: "", fontSize: 22, color: .gold, icon: "arrow.3.trianglepath", iconPosition: .after) {
                            modelService.selectedPromptService = nil
                            modelService.selectedValidateService = nil
                        }
                    }
                }
            }
            
            Spacer()
            
            MenuViewValidation()
                .customBackground(backgroundColor: Color(UIColor.systemFill), cornerRadius: 15)
        }
    }
    
    private var optionsMenu: some View {
        Menu {
            Button("Add On-Device Models", systemImage: "plus") {
                if DeviceType.isTablet {
                    showAddModelTablet = true
                }
                else {
                    showAddModelPhone = true
                }
            }
            
            if !modelService.downloadedModels.isEmpty {
                Menu("Remove On-Device Models") {
                    ForEach(modelService.downloadedModels, id: \.self) { model in
                        
                        Button("Remove \(model.kind == .vlm ? "<vision>" : "") \(model.id ?? "")", systemImage: "trash", role: .destructive) {
                            Task {
                                try await modelService.deleteAIModel(id: model.id ?? "N/A")
                                appState.generalMessage = "<\(model.id ?? "")> model removed."
                                try await Task.sleep(nanoseconds: 2_000_000_000)
                                modelService.resetGeneralMessage()
                            }
                        }.disabled(modelService.downloadedModels.isEmpty)
                    }
                }
            }
            
            Divider()
            
            let unauthorizedServices = modelService.configuredServices(uniqueByKindWithPreferred: .gemini).filter { service in
                authState.accessToken(serviceKind: service.kind, tokenType: .developerToken) == nil
            }
            
            if !unauthorizedServices.isEmpty {
                Menu("Activate Services") {
                    ForEach(unauthorizedServices, id: \.modelId) { service in
                        
                        Button("\(service.kind.rawValue)", systemImage: "plus") {
                            Task {
                                print("\(service.id) activation")
                                appState.tokenInputService = service
                            }
                        }
                    }
                }
            }
            
            let authorizedServices = modelService.configuredServices(uniqueByKindWithPreferred: .gemini).filter { service in
                authState.accessToken(serviceKind: service.kind, tokenType: .developerToken) != nil
            }
            
            if !authorizedServices.isEmpty {
                
                Menu("Deactivate Services") {
                    
                    ForEach(authorizedServices, id: \.modelId) { service in
                        
                        Button("\(service.kind.rawValue)", systemImage: "trash", role: .destructive) {
                            Task {
                                print("\(service.id) de-activation")
                                appState.tokenInputService = nil
                                authState.deleteServiceToken(serviceKind: service.kind)
                                
                                if modelService.selectedValidateService?.kind == service.kind {
                                    modelService.selectedValidateService = nil
                                }
                                
                                if modelService.selectedPromptService?.kind == service.kind {
                                    modelService.selectedPromptService = nil
                                }
                                
                                await modelService.updateConfiguredServices()
                            }
                        }
                    }
                }
            }
            
            Divider()
            
            if modelService.selectedValidateService != nil, modelService.selectedPromptService != nil {
                Button("Swap Selection", systemImage: "rectangle.2.swap", role: .destructive) {
                    let selectedPromptService = modelService.selectedPromptService
                    modelService.selectedPromptService = modelService.selectedValidateService
                    modelService.selectedValidateService = selectedPromptService
                }
            }
            
            if modelService.selectedPromptService != nil || modelService.selectedValidateService != nil {
                Button("Reset Selection", systemImage: "arrow.3.trianglepath", role: .destructive) {
                    modelService.selectedPromptService = nil
                    modelService.selectedValidateService = nil
                }
            }
            
            Divider()
            
            Button("Erase All Content", systemImage: "trash.fill", role: .destructive) {
                Task {
                    try await runtimeService.removeEverything()
                    modelService.stateReset()
                    appState.stateReset()
                    authState.deleteAllTokens()
                    appState.generalMessage = ""
                }
            }
            
            Text("App: \(ConfigService.versionBuild()), mim OE: \(runtimeService.mimOEVersion)")
            Text("Token expires on: \(ConfigService.tokenExpiration(token: runtimeService.developerConsoleAccessToken))")
            
        } label: {
            HStack {
                MetallicText(text: "", fontSize: DeviceType.isTablet ? 22 : 17, color: .gold, icon: "gear.badge", iconPosition: .after)
            }
        }
        .font(.title)
    }
}
