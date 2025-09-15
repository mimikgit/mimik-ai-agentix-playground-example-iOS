//
//  InputOptionsView.swift
//  mimik-ai-chat
//
//  Created by rb on 2025-03-18.
//

import SwiftUI

struct InputOptionsView: View {
    
    @EnvironmentObject private var appState: AppState
    
    @Binding var showImagePicker: Bool
    @Binding var showInputOptions: Bool
    @Binding var showFileImporter: Bool
    
    @State var fontSize: CGFloat
    
    var body: some View {
        HStack(alignment: .center) {
            if let image = appState.selectedImage {
                HStack {
                    MetallicText(text: "", fontSize: DeviceType.isTablet ? 25 : 16, color: .ruby, icon: "xmark", iconPosition: .after) { appState.selectedImage = nil }
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: 100, maxHeight: 100)
                        .onTapGesture {
                            showImagePicker = true
                        }
                }
            } else {
                HStack {
                    MetallicText(text: "", fontSize: DeviceType.isTablet ? 25 : 16, color: .ruby, icon: "xmark", iconPosition: .after) { showInputOptions=false }
                    MetallicText(text: "", fontSize: fontSize, color: .roseGold, icon: "photo.badge.plus", iconPosition: .after) { showImagePicker = true }
                    MetallicText(text: "", fontSize: fontSize, color: .roseGold, icon: "filemenu.and.cursorarrow", iconPosition: .after) { showFileImporter.toggle() }
                }
            }
        }
    }
}
