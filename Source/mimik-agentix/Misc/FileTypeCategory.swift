//
//  FileTypeCategory.swift
//  mimik-ai-chat
//
//  Created by rb on 2025-03-17.
//

import SwiftUI
import UniformTypeIdentifiers

struct FileTypes {
    
    enum FileTypeCategory: String, CaseIterable {
        case image
        case document
        case audio
        case video
        case archive
        case spreadsheet
        case presentation
        case all
    }
 
    static let allAllowedContentTypes: [UTType] = [
        .data,            .item,            .text,            .plainText,       .rtf,             .html,            .pdf,
        .xml,             .json,            .commaSeparatedText,             .spreadsheet,         .presentation,             .image,
        .jpeg,            .png,             .tiff,            .gif,             .heic,            .audio,           .video,
        .mpeg,            .quickTimeMovie,  .avi,             .mp3,             .wav,             .application,     .package,
        .spreadsheet,     .presentation,    .zip,             .gzip,            .archive,
        .svg,             .font,        .vCard,           .calendarEvent
    ]

    static func allowedContentTypes(for categories: Set<FileTypeCategory>) -> [UTType] {
        var selectedTypes: Set<UTType> = []
        
        if categories.contains(.image) {
            selectedTypes.formUnion([.image, .jpeg, .png, .tiff, .gif, .heic])
        }
        if categories.contains(.document) {
            selectedTypes.formUnion([.plainText, .rtf, .html, .pdf, .xml, .json, .commaSeparatedText, .text, .spreadsheet, .presentation])
        }
        if categories.contains(.audio) {
            selectedTypes.formUnion([.audio, .mp3, .wav])
        }
        if categories.contains(.video) {
            selectedTypes.formUnion([.video, .mpeg, .quickTimeMovie, .avi, .mpeg2Video])
        }
        if categories.contains(.archive) {
            selectedTypes.formUnion([.zip, .gzip, .archive])
        }
        if categories.contains(.spreadsheet) {
            selectedTypes.formUnion([.spreadsheet])
        }
        if categories.contains(.presentation) {
            selectedTypes.formUnion([.presentation])
        }
        if categories.contains(.all) {
            selectedTypes.formUnion(allAllowedContentTypes)
        }
        
        return Array(selectedTypes)
    }
}
