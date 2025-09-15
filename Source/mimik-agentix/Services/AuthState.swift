//
//  AuthState.swift
//  mimik-ai-chat
//
//  Created by rb on 2025-04-15.
//

import SwiftUI
import EdgeCore

class AuthState: ObservableObject {
    
    @Published var geminiAuthenticated: Bool = false
    @Published var mimikAIAuthenticated: Bool = false
    
    static func storageKey(serviceKind: ClientLibrary.AI.ServiceConfiguration.Kind, tokenType: AuthTokenType) -> String {
        return (serviceKind.rawValue + "-" + tokenType.rawValue).lowercased().replacingOccurrences(of: " ", with: "-")
    }
    
    enum AuthTokenType: String, CaseIterable, Identifiable {
        case developerToken = "Developer Token"
        
        var id: String { rawValue }
    }
    
    init() {
        checkAuthenticationStatus(serviceKind: .gemini)
        checkAuthenticationStatus(serviceKind: .mimikAI)
    }
    
    func accessToken(serviceKind: ClientLibrary.AI.ServiceConfiguration.Kind, tokenType: AuthTokenType) -> String? {
        return KeychainService.read(forKey: AuthState.storageKey(serviceKind: serviceKind, tokenType: tokenType))
    }

    func checkAuthenticationStatus(serviceKind: ClientLibrary.AI.ServiceConfiguration.Kind) {
        let developerToken = KeychainService.read(forKey: AuthState.storageKey(serviceKind: serviceKind, tokenType: .developerToken))
        
        switch serviceKind {
        case .gemini:
            geminiAuthenticated = developerToken?.isEmpty == false
        case .mimikAI:
            mimikAIAuthenticated = developerToken?.isEmpty == false
        @unknown default:
            break
        }
    }
    
    func saveToken(token: String, serviceKind: ClientLibrary.AI.ServiceConfiguration.Kind, tokenType: AuthState.AuthTokenType) {
        print(#function, token, serviceKind, tokenType.rawValue)
        let key = AuthState.storageKey(serviceKind: serviceKind, tokenType: tokenType)
        KeychainService.save(token, forKey: key)
        checkAuthenticationStatus(serviceKind: serviceKind)
    }
    
    func deleteAllTokens() {        
        print("⚠️ AuthState", #function)
        deleteServiceToken(serviceKind: .gemini)
        deleteServiceToken(serviceKind: .mimikAI)
        checkAuthenticationStatus(serviceKind: .gemini)
        checkAuthenticationStatus(serviceKind: .mimikAI)
    }

    func deleteServiceToken(serviceKind: ClientLibrary.AI.ServiceConfiguration.Kind) {
        
        print(#function, serviceKind.rawValue)

        for storageType in AuthState.AuthTokenType.allCases {
            let key = AuthState.storageKey(serviceKind: serviceKind, tokenType: storageType)
            KeychainService.delete(forKey: key)
        }
                
        checkAuthenticationStatus(serviceKind: serviceKind)
    }
}
