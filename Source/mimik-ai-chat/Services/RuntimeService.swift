//
//  RuntimeService.swift
//  mimik-ai-chat
//
//  Created by rb on 2025-04-01.
//

import EdgeCore
import Foundation
import EdgeEngine

class RuntimeService: ObservableObject {
    
    private let kAIUseCaseDeployment = "kAIUseCaseDeployment"
    var mimOEClientId: String = ""

    @Published var mimOEAccessToken: String = ""
    @Published var mimOEVersion: String = ""
    @Published internal var developerConsoleAccessToken: String = "" { didSet { updateValidity() } }
    @Published internal var developerConsoleClientId: String = "" { didSet { updateValidity() } }
    @Published private(set) var isAuthorizedForRuntime: Bool = false

    private func updateValidity() {
        isAuthorizedForRuntime = !developerConsoleAccessToken.isEmpty && !developerConsoleClientId.isEmpty
    }
  
    var deployedUseCase: ClientLibrary.UseCase? {
        get {
            // Load the bundled config; if it can't be decoded or has no version, bail out.
            let loadedConfig: ClientLibrary.UseCase
            do {
                loadedConfig = try ConfigService.decodeJsonDataFrom(
                    file: "mimik-ai-use-case-config",
                    type: ClientLibrary.UseCase.self
                )
            } catch {
                print("⚠️ Failed to load bundled use case config:", error.localizedDescription)
                return nil
            }
            guard let loadedVersion = loadedConfig.version else {
                print("⚠️ Bundled mimik AI use case config missing version")
                return nil
            }

            // Try to fetch stored deployment from UserDefaults.
            if let data = UserDefaults.standard.object(forKey: kAIUseCaseDeployment) as? Data,
               let deployment = try? JSONDecoder().decode(ClientLibrary.UseCase.self, from: data),
               let storedVersion = deployment.version {

                // If versions mismatch, clear the stored data (it's outdated).
                guard loadedVersion == storedVersion else {
                    print("⚠️ Outdated stored mimik AI use case info found, removing.",
                          "\nloadedVersion:", loadedVersion, "\nstoredVersion:", storedVersion)
                    UserDefaults.standard.removeObject(forKey: kAIUseCaseDeployment)
                    UserDefaults.standard.synchronize()
                    return nil
                }

                return deployment
            }

            print("⚠️ No stored mimik AI use case deployment found")
            return nil
        }

        set {
            guard let encoded = try? JSONEncoder().encode(newValue) else {
                return
            }

            UserDefaults.standard.set(encoded, forKey: kAIUseCaseDeployment)
            UserDefaults.standard.synchronize()

            print("✅ Success integrating mimik AI use case, saved to UserDefaults")
        }
    }
  
    // Runs the mim OE startup procedure. Authenticates mim OE using a developer id token, saves the access token from the result.
    @MainActor
    func startupProcedure() async throws {
        ClientLibrary.setLoggingLevel(module: .mimikCore,   level: .debug, privacy: .publicAccess, marker: "⚠️")
        ClientLibrary.setLoggingLevel(module: .mimikRuntime, level: .debug, privacy: .publicAccess, marker: "❗️")
        
        try await startRuntime()
        
        let token = try await authenticateMimOE(
            accessToken: developerConsoleAccessToken,
            clientId: developerConsoleClientId
        )
        
        mimOEAccessToken = token
        
        print("✅ mim OE access token:", mimOEAccessToken)
        print("✅ mim OE version:", mimOEVersion)
    }

    
    // Resets mim OE storage, removing all user data from mim OE storage, including downloaded AI models.
    func removeEverything() async throws {
        do {
            print("⚠️ RuntimeService", #function)
            try await resetMimOE()
            await stateReset()
            try await Task.sleep(nanoseconds: 1_000_000_000)
            try await startupProcedure()
        }
        catch {
            throw error
        }
    }
    
    // Starts mim OE.
    private func startRuntime() async throws {
        guard let runtimeLicense = ConfigService.fetchConfig(for: .runtimeLicense) else {
            print("⚠️ mim OE license error")
            throw NSError(domain: "mim OE license error", code: 500)
        }

        let startupParameters = await ClientLibrary.RuntimeParameters(license: runtimeLicense, logLevel: .off)

        do {
            try await ClientLibrary.startRuntime(parameters: startupParameters)
            print("✅ Starting mim OE successful")
        } catch {
            print("⚠️ Starting mim OE error", error.localizedDescription)
            throw error
        }
    }
  
    // Authenticates mim OE using a developer id token, returns the access token from the result.
    private func authenticateMimOE(accessToken: String, clientId: String) async throws -> String {
        let developerIdToken = try await DeveloperConsole.Auth.issueToken(accessToken: accessToken, clientId: clientId)
        
        let authorization = try await DeveloperConsole.Auth.authorizeRuntimeAccess(idToken: developerIdToken)

        guard let accessToken = authorization.token?.accessToken else {
            print("⚠️ mim OE access token error")
            throw NSError(domain: "mim OE access token error", code: 500)
        }

        mimOEClientId = authorization.token?.clientId() ?? ""
        print("✅ mim OE client id: \(mimOEClientId)")

        return accessToken
    }
    
    // Synchronously shuts down mim OE and erases its working directory, stored license and startup parameters. As well as any deployed edge microservices and their data. Essentially creating a brand new mim OE instance.
    private func resetMimOE() async throws {
        do {
            try await ClientLibrary.resetRuntime()
            print("✅ mim OE reset successful")
        } catch {
            print("⚠️ mim OE reset error", error.localizedDescription)
            throw error
        }
    }
    
    @MainActor
    private func stateReset() {
        mimOEVersion = ""
        mimOEAccessToken = ""
        mimOEClientId = ""
        developerConsoleAccessToken = ""
        developerConsoleClientId = ""
        UserDefaults.standard.removeObject(forKey: kAIUseCaseDeployment)
        UserDefaults.standard.synchronize()
        print("⚠️ RuntimeService state reset")
    }
}
