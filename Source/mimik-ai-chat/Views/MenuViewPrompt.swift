//
//  MenuViewPrompt.swift
//  mimik-ai-chat
//
//  Created by rb on 2025-03-18.
//

import Alamofire
import EdgeCore
import SwiftUI

struct MenuViewPrompt: View {

    @EnvironmentObject var appState: AppState
    @EnvironmentObject var authState: AuthState
    @EnvironmentObject var runtimeService: RuntimeService
    @EnvironmentObject var modelService: ModelService
    
    @Binding internal var showAddModelTablet: Bool
    @Binding internal var showAddModelPhone: Bool

    var body: some View {
        VStack(spacing: 10) {
            
            MetallicText(text: infoLabel(), fontSize: DeviceType.isTablet ? 24 : 12, color: infoLabelColour(), lineLimit: DeviceType.isTablet ? nil : .init(lineLimit: 2, reservesSpace: true))
            
            if !modelService.groupedServices(for: .prompt).isEmpty || modelService.selectedPromptService != nil {
                ServiceDropdownPicker(selectedService: $modelService.selectedPromptService, placeholder: "Select Service", serviceType: .prompt)
            }
        }
        .frame(maxWidth: ScreenSize.screenWidth * 0.33)
        .popover(isPresented: $showAddModelTablet) {
            AddModelView()
                .background(
                    Image("Black-Background").opacity(0.8)
                )
                .ignoresSafeArea()
                .environmentObject(appState)
                .environmentObject(runtimeService)
                .environmentObject(modelService)
        }
        .sheet(isPresented: $showAddModelPhone) {
            AddModelView()
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
                .background(
                    Image("Black-Background").opacity(0.9)
                )
                .ignoresSafeArea()
                .environmentObject(appState)
                .environmentObject(runtimeService)
                .environmentObject(modelService)
        }
    }
    
    private func infoLabelColour() -> MetallicText.MetallicColor {
        isPromptReady ? .gold : .obsidian
    }
    
    private var isPromptReady: Bool {
        return modelService.selectedPromptService != nil
    }
    
    private func infoLabel() -> String {
        return isPromptReady ? "PROMPT READY" : "PROMPT"
    }
}
