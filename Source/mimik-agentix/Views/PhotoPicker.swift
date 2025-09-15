//
//  PhotoPicker.swift
//  mimik-ai-chat
//
//  Created by rb on 2025-03-17.
//

import Foundation
import SwiftUI
import PhotosUI

struct PhotoPicker: UIViewControllerRepresentable {

    @EnvironmentObject private var appState: AppState
    
    @Binding var showImagePicker: Bool
    
    var pickerResult: PHPickerResult?
    var videoThumbnail: UIImage?
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        configuration.selectionLimit = 1
        let picker = PHPickerViewController(configuration: configuration)
        picker.isModalInPresentation = false
        picker.modalPresentationCapturesStatusBarAppearance = false
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        
        var parent: PhotoPicker
        
        init(parent: PhotoPicker) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            guard let result = results.first else {
                print("No photo picker results found.")
                picker.dismiss(animated: true)
                return
            }
            
            if result.itemProvider.canLoadObject(ofClass: UIImage.self) {
                result.itemProvider.loadObject(ofClass: UIImage.self) { image, error in
                    
                    if let error = error {
                        print("⚠️ Photo picker error loading image: \(error.localizedDescription)")
                    }
                    else if let image = image as? UIImage {
                        DispatchQueue.main.async {
                            print("✅ Photo picker results found: \(result)")
                            self.parent.appState.selectedImage = image
                            self.parent.showImagePicker = false
                        }
                    }
                }
            }
        }
    }
}
