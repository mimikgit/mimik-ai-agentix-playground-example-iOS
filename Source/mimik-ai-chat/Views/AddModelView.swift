//
//  AddModelView.swift
//  mimik-ai-chat
//
//  Created by rb on 2025-03-17.
//

import SwiftUI
import EdgeCore
import Alamofire
import SwiftyJSON

struct AddModelView: View {
        
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var runtimeService: RuntimeService
    @EnvironmentObject var modelService: ModelService
    @Environment(\.presentationMode) private var presentationMode
    
    @State private var modModel: AddModelView.ModifiedModel = .init(id: "", object: "", url: "", mmprojUrl: "", chatHint: "", ownedBy: "", kind: "", excludeFromBackup: true, expectedDownloadSize: 0)
    
    struct ModifiedModel {
        var id: String
        var object: String
        var url: String
        var mmprojUrl: String
        var chatHint: String
        var ownedBy: String
        var kind: String
        var excludeFromBackup: Bool
        var expectedDownloadSize: Int64
        
        static func readableFileSize(_ bytes: Int64) -> String {
            let units = ["B", "KB", "MB", "GB", "TB"]
            var size = Double(bytes)
            var unitIndex = 0

            while size >= 1000 && unitIndex < units.count - 1 {
                size /= 1000
                unitIndex += 1
            }

            let formatter = NumberFormatter()
            formatter.maximumFractionDigits = (size < 10) ? 2 : (size < 100 ? 1 : 0)
            formatter.minimumFractionDigits = 0
            formatter.numberStyle = .decimal

            let sizeString = formatter.string(from: NSNumber(value: size)) ?? "\(size)"
            return "\(sizeString) \(units[unitIndex])"
        }
    }
    
    var body: some View {
                
        ZStack() {
            
            VStack(spacing: DeviceType.isTablet ? 30 : 40) {
                
                VStack {
                    HStack {
                        Spacer()
                        MetallicText(text: "SELECT A MODEL", fontSize: DeviceType.isTablet ? 25 : 20, color: .silver, icon: "arrow.turn.right.down", iconPosition: .after)
                        Spacer()
                    }
                    .padding()
                    .padding(.top, DeviceType.isTablet ? 20 : 20)
                                        
                    modelScroll
                        .frame(maxWidth: DeviceType.isTablet ? 426 : ScreenSize.screenWidth * 0.9, maxHeight: DeviceType.isTablet ? 240 : 120)
                        .padding([.leading, .trailing])
                }
                
                downloadButton
                                
                textfieldsStack
                    .frame(maxWidth: DeviceType.isTablet ? 460 : ScreenSize.screenWidth * 0.9)
                    .padding(.bottom, DeviceType.isTablet ? 40 : 0)
                    .padding([.leading, .trailing], DeviceType.isTablet ? 40 : 20)
            }
        }
        .task {
            loadPreset(decodedModel: ConfigService.modelPresets().first)
        }
    }
    
    private var downloadButton: some View {
        let isDownloaded = modelService.alreadyDownloadedModel(id: modModel.id)
        let buttonText = isDownloaded ? "ALREADY DOWNLOADED" : "START DOWNLOAD (\(ModifiedModel.readableFileSize(modModel.expectedDownloadSize)))"
        
        let backgroundColor = isDownloaded ? Color(UIColor.gray) : Color(UIColor.systemRed)
        
        let action: () -> Void = isDownloaded ? {} : {
                Task {
                    await nextDownloadStep()
                }
            }

        return ModelButton(buttonText: buttonText, backgroundColor: backgroundColor, foregroundColor: .white, fontSize: DeviceType.isTablet ? 22 : 20, maxWidth: DeviceType.isTablet ? 426 : ScreenSize.screenWidth * 0.8, maxHeight: DeviceType.isTablet ? 60 : 50, action: action
        )
    }
    
    private var modelScroll: some View {
        
        ScrollViewReader { proxy in
            
            ScrollView(.vertical, showsIndicators: true) {
                VStack(spacing: 20) {
                    ForEach(ConfigService.modelPresets().indices, id: \.self) { index in
                        
                        if let selection = ConfigService.modelPresets()[index] as ClientLibrary.AI.Model.CreateModelRequest?, selection.id == modModel.id {
                            
                            ModelButton(buttonText: ConfigService.modelPresets()[index].shortDescription, backgroundColor: Color(UIColor.systemBlue).opacity(1.0), foregroundColor: .white, fontSize: DeviceType.isTablet ? 17 : 21, maxWidth: DeviceType.isTablet ? 426 : ScreenSize.screenWidth * 0.8, maxHeight: DeviceType.isTablet ? 60 :50, model: ConfigService.modelPresets()[index]) {
                                Task {
                                    loadPreset(decodedModel: ConfigService.modelPresets()[index])
                                }
                            }
                        }
                        else {
                            ModelButton(buttonText: ConfigService.modelPresets()[index].shortDescription, backgroundColor: Color(UIColor.systemBlue).opacity(0.6), foregroundColor: .white.opacity(0.6), fontSize: DeviceType.isTablet ? 17 : 21, maxWidth: DeviceType.isTablet ? 426 : ScreenSize.screenWidth * 0.8, maxHeight: DeviceType.isTablet ? 60 : 50, model: ConfigService.modelPresets()[index]) {
                                Task {
                                    loadPreset(decodedModel: ConfigService.modelPresets()[index])
                                }
                            }
                        }
                    }
                }
            }
            .onAppear {
                Task {
                    try? await Task.sleep(nanoseconds: 25_000_000)
                    
                    withAnimation {
                          proxy.scrollTo(ConfigService.modelPresets().count - 1, anchor: .bottom)
                    }
                    
                    try? await Task.sleep(nanoseconds: 500_000_000)

                    withAnimation {
                        proxy.scrollTo(0, anchor: .top)
                    }
                }
            }
        }
    }
    
    private var textfieldsStack: some View {
        
        VStack(spacing: 24) {
            LabeledTextField(label: "Model Id", placeholder: "", text: $modModel.id, fontSize:  DeviceType.isTablet ? 15 : 13, labelColor: .silver, textColor: .white, borderColor: .white.opacity(0.7), cornerRadius: 15.0, borderWidth: 3.0, backgroundColor: .clear)
                        
            LabeledTextField(label: "Model Url", placeholder: "", text: $modModel.url, fontSize:  DeviceType.isTablet ? 15 : 13, labelColor: .silver, textColor: .white, borderColor: .white.opacity(0.7), cornerRadius: 15.0, borderWidth: 3.0, backgroundColor: .clear)
            
            LabeledTextField(label: "Model Projection Url (vlm only)", placeholder: "", text: $modModel.mmprojUrl, fontSize:  DeviceType.isTablet ? 15 : 13, labelColor: .silver, textColor: .white, borderColor: .white.opacity(0.7), cornerRadius: 15.0, borderWidth: 3.0, backgroundColor: .clear).disabled(modModel.mmprojUrl.isEmpty).opacity(modModel.mmprojUrl.isEmpty ? 0 : 1)
        }
    }
    
    private func nextDownloadStep() async {

        presentationMode.wrappedValue.dismiss()
        appState.downloadMessage = ""

        do {
            // Deploy or get the UseCase first
            let useCase: ClientLibrary.UseCase
            if let existing = runtimeService.deployedUseCase {
                useCase = existing
            } else {
                useCase = try await deployTask()
            }

            // Make sure we have a mimik AI service to download from
            guard let mimikService = modelService.mimikAiConfiguration else {
                print("⚠️ No mimik ai service is setup")
                appState.downloadMessage = "No mimik ai service is setup"
                return
            }
            
            let clock = ContinuousClock()
            let elapsed = try await clock.measure {
                try await downloadTask(configuration: mimikService, useCase: useCase)
            }

            let format = elapsed.formatted(.time(pattern: .minuteSecond(padMinuteToLength: 2)))
            print("Download completed in: \(format)")
            appState.downloadMessage = "Download completed in: \(format)"
        }
        catch let error as NSError {
            if error.localizedDescription.contains("cancelled") {
                appState.downloadMessage = error.localizedDescription
            } else {
                appState.downloadMessage = error.domain
            }
        }
    }
  
    private func deployTask() async throws -> ClientLibrary.UseCase {
        do {
            let config = try ConfigService.decodeJsonDataFrom(
                file: "mimik-ai-use-case-config",
                type: ClientLibrary.UseCase.self
            )
            
            try await modelService.integrateAIService(useCase: config)
            print("✅ mimik AI integration successful")
            return config
        } catch let error as NSError {
            appState.generalMessage = error.domain
            throw error
        }
    }

    private func downloadTask(configuration: ClientLibrary.AI.ServiceConfiguration, useCase: ClientLibrary.UseCase) async throws {
        
        guard let model = currentPreset(), let apiKey = ConfigService.fetchConfig(for: .developerApiKey) else {
            return
        }
        
        let client: any ClientLibrary.AI.ServiceInterface = ClientLibrary.AI.HybridClient(configuration: configuration)
        let cancellable = await client.downloadAI(model: model, accessToken: runtimeService.mimOEAccessToken, apiKey: apiKey, useCase: useCase)
        
        appState.activeProtocolDownload = cancellable

        defer {
            appState.newResponse = ""
            appState.activeProtocolDownload = nil
            appState.downloadMessage = ""
        }

        do {
            for try await chunk in cancellable.stream {
                switch chunk {
                case .request(let request):
                    print("✅ STREAM emmited request:", request)
                                        
                case .progress(let progress):
                    
                    let percent = String(format: "%.2f", ceil( (progress.size / progress.totalSize) * 10_000) / 100)
                    let line = "Model download: " + "\(percent)％ Don't lock your device. Keep this app open."
                    print("✅ STREAM emmited progress:", line)
                    
                    if line.contains("100.00") {
                        appState.justDownloadedModelId = model.id
                    }
                    else {
                        appState.downloadMessage = line
                        appState.justDownloadedModelId = ""
                    }
                    
                case .completed(let model):
                    print("✅ STREAM emmited completed:", model)
                    appState.justDownloadedModelId = model.id ?? ""
                    
                    appState.downloadMessage = "Download successful, please wait."
                    appState.activeProtocolDownload = nil
                    
                    Task {
                        try? await Task.sleep(nanoseconds: 1_000_000_000)
                        await modelService.updateConfiguredServices()
                        appState.downloadMessage = "Download successful, model added."
                        try? await Task.sleep(nanoseconds: 1_000_000_000)
                        appState.downloadMessage = ""
                    }
                    
                @unknown default:
                    print("✅ STREAM emmited @unknown:", chunk)
                }
            }
        } catch {
            ClientLibrary.Log.logDebug(function: #function, line: #line, items: "Streaming error: \(error)", module: .mimikApps)
            throw error
        }
    }
    
    private func currentPreset() -> ClientLibrary.AI.Model.CreateModelRequest? {
        
        guard !modModel.id.isEmpty, !modModel.object.isEmpty, !modModel.url.isEmpty else {
            return nil
        }
        
        let template = ClientLibrary.AI.Model.CreateModelRequest.ChatTemplateHint.init(rawValue: modModel.chatHint)
        
        let preset = ClientLibrary.AI.Model.CreateModelRequest(id: modModel.id, object: modModel.object, url: modModel.url, expectedDownloadSize: modModel.expectedDownloadSize, kind: ClientLibrary.AI.Model.Kind(rawValue: modModel.kind) ?? .llm, chatTemplateHint: template, mmprojUrl: modModel.mmprojUrl, ownedBy: modModel.ownedBy, excludeFromBackup: modModel.excludeFromBackup)
        return preset
    }
    
    private func loadPreset(decodedModel: ClientLibrary.AI.Model.CreateModelRequest?) {
        
        guard let decodedModel = decodedModel else {
            print("⚠️ Decoded model missing")
            return
        }
        
        let model: AddModelView.ModifiedModel = AddModelView.ModifiedModel.init(id: decodedModel.id, object: decodedModel.object, url: decodedModel.url, mmprojUrl: decodedModel.mmprojUrl ?? "", chatHint: decodedModel.chatTemplateHint?.rawValue ?? "", ownedBy: decodedModel.ownedBy ?? "", kind: decodedModel.kind?.rawValue ?? "llm", excludeFromBackup: decodedModel.excludeFromBackup ?? true, expectedDownloadSize: decodedModel.expectedDownloadSize)
        modModel = model
    }
}
