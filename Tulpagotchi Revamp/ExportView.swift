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
        DataRepresentation(exportedContentType: .plainText) { item in
            Data(item.text.utf8)
        }
        // Tell the share sheet what to name the attachment
        .suggestedFileName { item in
            item.fileName.hasSuffix(".txt") ? item.fileName : item.fileName + ".txt"
        }
    }
}

struct ExportView: View {
    let fileName: String
    let fileText: String
    
    var body: some View {
        ShareLink(
            item: TextFile(fileName: fileName, text: fileText),
            preview: SharePreview(fileName)
        ) {
            Label("Export", systemImage: "square.and.arrow.up")
        }
        .buttonStyle(.plain)
    }
}

#Preview { ExportView(fileName: "Test.txt", fileText: "This is a test file") }
