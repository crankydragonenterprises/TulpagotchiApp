//
//  ExportView.swift
//  Tulpagotchi Revamp
//
//  Created by Angela Tarbett on 8/25/25.
//

import SwiftUI
import UniformTypeIdentifiers

// A tiny Transferable that exports your string as a .txt file
struct TextFile: Transferable {
    let fileName: String
    let text: String
    
    static var transferRepresentation: some TransferRepresentation {
        FileRepresentation(exportedContentType: .plainText) { item in
            let url = FileManager.default.temporaryDirectory
                .appendingPathComponent(item.fileName)
            print("URL: \(url)")
            try item.text.write(to: url, atomically: true, encoding: .utf8)
            return .init(url)
        }
    }
}

struct ExportView: View {
    let fileName: String
    let fileText: String
    
    var body: some View {
        // Tap to share a .txt file made from your string
        ShareLink(
            item: TextFile(fileName: fileName,
                           text: fileText),
            preview: SharePreview(fileName)
        ) {
            Label("Export", systemImage: "square.and.arrow.up")
        }
    }
}

#Preview { ExportView(fileName: "Test.txt", fileText: "This is a test file") }
