//
//  MenuViewValidation.swift
//  mimik-ai-chat
//
//  Created by rb on 2025-07-07.
//

import Alamofire
import EdgeCore
import SwiftUI

struct MenuViewValidation: View {

    @EnvironmentObject var appState: AppState
    @EnvironmentObject var authState: AuthState
    @EnvironmentObject var runtimeService: RuntimeService
    @EnvironmentObject var modelService: ModelService
    
    var body: some View {
        VStack(spacing: 10) {
            
            MetallicText(text: infoLabel(), fontSize: DeviceType.isTablet ? 24 : 12, color: infoLabelColour(), lineLimit: DeviceType.isTablet ? nil : .init(lineLimit: 2, reservesSpace: true))
                        
            if !modelService.groupedServices(for: .validation).isEmpty || (modelService.selectedPromptService != nil && modelService.selectedValidateService != nil)  {
                ServiceDropdownPicker(selectedService: $modelService.selectedValidateService, placeholder: "Select Service", serviceType: .validation)
            }
        }
        .frame(maxWidth: ScreenSize.screenWidth * 0.33)
    }
    
    private var isValidationReady: Bool {
        guard let service = modelService.selectedValidateService else {
            return false
        }
        return authState
            .accessToken(serviceKind: service.kind, tokenType: .developerToken) != nil
    }
    
    private var validationServiceName: String {
        guard let service = modelService.selectedValidateService else {
            return ""
        }
        return service.kind.rawValue
    }
    
    private func infoLabel() -> String {
        isValidationReady ? "VALIDATION READY" : "VALIDATION"
    }
    
    private func infoLabelColour() -> MetallicText.MetallicColor {
        isValidationReady ? .gold : .obsidian
    }
}
