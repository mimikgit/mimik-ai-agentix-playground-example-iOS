//
//  ModelService.swift
//  mimik-ai-chat
//
//  Created by rb on 2025-04-02.
//

import EdgeCore
import SwiftUI

extension ModelService {
    
    func groupedServices(for serviceType: ServiceType) -> [(provider: String, models: [ClientLibrary.AI.ServiceConfiguration])] {
        
        // if prompt is using a VLM model, or if it was not set yet, offer no validation services
        if serviceType == .validation,
           (selectedPromptService == nil || selectedPromptService?.model?.kind == .vlm) {
            return []
        }
        
        // keep only the services we’re actually authorized to use
        let authorized = configuredServices.filter { service in
            authState.accessToken(
                serviceKind: service.kind,
                tokenType: .developerToken
            ) != nil
        }
        
        // don't included any services already assigned to either picker
        let excludedServices = [selectedPromptService, selectedValidateService]
            .compactMap { $0 }
        
        // start with authorized & not‐already‐selected
        var eligible = authorized.filter { service in
            !excludedServices.contains(service)
        }
        
        // drop any models explicitly marked readyToUse == false
        eligible = eligible.filter { config in
            // if readyToUse is nil or true, keep it; if false, drop it
            return config.model?.readyToUse ?? true
        }
        
        // if we’re building the validation list, drop all .vlm‐model services
        if serviceType == .validation {
            eligible = eligible.filter { config in
                config.model?.kind != .vlm
            }
        }
        
        let grouped = Dictionary(grouping: eligible) { $0.kind.rawValue }
        
        return grouped
            .map { provider, models in
                ( provider: provider,
                  models: models.sorted {
                    ($0.modelId ?? "") < ($1.modelId ?? "")
                  }
                )
            }
            .sorted { $0.provider < $1.provider }
    }
  
    @MainActor
    func updateConfiguredServices() async {
        configuredServices.removeAll()
        try? await Task.sleep(nanoseconds: 250_000_000)

        if let config = mimikAiConfiguration, runtimeService.deployedUseCase != nil {
            let client = ClientLibrary.AI.HybridClient(configuration: config)

            do {
                let models = try await client.availableModels()
                let readyModels = models.filter { $0.readyToUse ?? true }

                for model in readyModels {
                    configuredServices.addOrReplace(.init(kind: .mimikAI, model: model, apiKey: authState.accessToken(serviceKind: .mimikAI, tokenType: .developerToken), mimOEPort: ClientLibrary.runtimeFullPathUrl().port, mimOEClientId: runtimeService.mimOEClientId))
                }
            } catch {
                print("⚠️ No Models Found", error.localizedDescription)
                appState.generalMessage = "No Models Found"
            }
        }

        let model = ClientLibrary.AI.Model(id: "gemini-2.0-flash", kind: .llm)
        configuredServices.addOrReplace(.init(kind: .gemini, model: model, apiKey: authState.accessToken(serviceKind: .gemini, tokenType: .developerToken), mimOEPort: nil, mimOEClientId: nil))

        try? await updateDownloadedModels()

        for service in configuredServices {
            print("✅ \(service.kind.rawValue): \(service.model?.id ?? "⚠️") : \(service.apiKey ?? "⚠️")")
        }
    }
    
    func configuredServices(sortedFirstBy preferredKind: ClientLibrary.AI.ServiceConfiguration.Kind) -> [ClientLibrary.AI.ServiceConfiguration] {
        return configuredServices.sorted { lhs, rhs in
            if lhs.kind == preferredKind && rhs.kind != preferredKind { return true }
            if lhs.kind != preferredKind && rhs.kind == preferredKind { return false }
            return lhs.id < rhs.id
        }
    }
    
    func configuredServices(uniqueByKindWithPreferred preferredKind: ClientLibrary.AI.ServiceConfiguration.Kind) -> [ClientLibrary.AI.ServiceConfiguration] {
        let sorted = configuredServices(sortedFirstBy: preferredKind)
        var seenKinds = Set<ClientLibrary.AI.ServiceConfiguration.Kind>()
        return sorted.filter { config in
            seenKinds.insert(config.kind).inserted
        }
    }
    
    func configuredServicesByKind() -> [ClientLibrary.AI.ServiceConfiguration] {
        var seenKinds = Set<ClientLibrary.AI.ServiceConfiguration.Kind>()
        return configuredServices.filter { seenKinds.insert($0.kind).inserted }
    }
}
