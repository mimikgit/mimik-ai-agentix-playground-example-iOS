//
//  ServiceDropdownPicker.swift
//  mimik-ai-chat
//
//  Created by rb on 2025-07-15.
//

import SwiftUI
import EdgeCore

struct ServiceDropdownPicker: View {
    
    @EnvironmentObject var modelService: ModelService
    @EnvironmentObject var authState: AuthState
    
    @Binding var selectedService: ClientLibrary.AI.ServiceConfiguration?
    @State private var isExpanded = false
            
    let placeholder: String
    let serviceType: ModelService.ServiceType
    
    private var rowHeight: CGFloat { DeviceType.isTablet ? 34 : 54 }
    private let maxListHeight: CGFloat = 106
    
    private var controlColour: Color {
        selectedService == nil ? .white : .gold
    }
  
    private func mainTitle(for service: ClientLibrary.AI.ServiceConfiguration, shortened: Bool) -> String {
        let provider = service.kind.rawValue
        let isVLM = (service.model?.kind ?? .llm) == .vlm
        let prefix = isVLM ? "👁️‍🗨️ " : ""
        if let modelId = service.modelId {
            return shortened ? modelId : "\(provider) — \(prefix)\(modelId)"
        } else {
            return provider
        }
    }

    private func modelTitle(service: ClientLibrary.AI.ServiceConfiguration) -> String {
        let isVLM = (service.model?.kind ?? .llm) == .vlm
        let prefix = isVLM ? "👁️‍🗨️ " : ""
        let id = service.model?.id ?? "Unknown"
        return "\(prefix)\(id)"
    }
    
    private var totalRowCount: Int {
        modelService.groupedServices(for: serviceType)
            .reduce(0) { $0 + 1 + $1.models.count }
    }
    private var listHeight: CGFloat {
        min(CGFloat(totalRowCount) * rowHeight, maxListHeight)
    }
    
    var body: some View {
        ZStack {

            if isExpanded {
                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture {
                        withAnimation(.easeInOut) { isExpanded = false }
                    }
            }
            
            VStack(spacing: 0) {
                
                // Main dropdown button
                Button {
                    withAnimation(.easeInOut) { isExpanded.toggle() }
                } label: {
                    HStack {
                        Text(selectedService.map { mainTitle(for: $0, shortened: !DeviceType.isTablet) }
                              ?? placeholder)
                            .foregroundColor(controlColour)
                            .minimumScaleFactor(0.5)
                        if DeviceType.isTablet {
                            Spacer()
                            Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                                .foregroundColor(controlColour)
                        }
                    }
                    .padding(.horizontal)
                    .frame(height: DeviceType.isTablet ? 44: rowHeight)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .strokeBorder(controlColour, lineWidth: 1)
                    )
                }
                
                // Expanding list
                ScrollView {
                    LazyVStack(spacing: 0) {
                        
                        ForEach(modelService.groupedServices(for: serviceType), id: \.provider) { group in
                            // Section header
                            Text(group.provider)
                                .font(.headline)
                                .padding(.horizontal)
                                .frame(height: rowHeight)
                                .lineLimit(2)
                                .minimumScaleFactor(0.75)
                            
                            Divider()
                            
                            // Model rows
                            ForEach(group.models) { service in
                                Button {
                                    selectedService = service
                                    if selectedService?.model?.kind == .vlm,
                                       serviceType == .prompt {
                                        modelService.selectedValidateService = nil
                                    }
                                    withAnimation(.easeInOut) { isExpanded = false }
                                } label: {
                                    HStack(alignment: .top) {
                                        Text(modelTitle(service: service))
                                            .font(DeviceType.isTablet ? .subheadline : .footnote)
                                            .fixedSize(horizontal: false, vertical: true)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .lineLimit(10)
                                            .minimumScaleFactor(0.75)
                                        Spacer()
                                    }
                                    .padding(.horizontal)
                                    .padding(.vertical, 8)
                                    .frame(minHeight: rowHeight)
                                    .background(service == selectedService ? Color.blue.opacity(0.1): Color.clear)
                                }
                                .buttonStyle(PlainButtonStyle())
                                
                                if service.id != group.models.last?.id {
                                    Divider()
                                }
                            }
                            
                            // Divider between provider blocks
                            if group.provider != modelService.groupedServices(for: serviceType).last?.provider {
                                Divider().padding(.vertical, 4)
                            }
                        }
                    }
                }
                .frame(height: isExpanded ? listHeight : 0)
                .background( RoundedRectangle(cornerRadius: 8).fill(Color(.systemBackground)))
                .shadow(color: Color.black.opacity(0.15), radius: 4, x: 0, y: 2)
                .clipped()
                .animation(.easeInOut, value: isExpanded)
            }
            .if(DeviceType.isTablet) { $0.padding(.horizontal) }
            .zIndex(1)
        }
        .task {
            if modelService.selectedPromptService == nil {
                isExpanded = true
            }
        }
    }
}

