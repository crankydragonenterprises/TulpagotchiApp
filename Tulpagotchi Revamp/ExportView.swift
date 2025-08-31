//
//  ExportView.swift
//  Tulpagotchi Revamp
//
//  Created by Angela Tarbett on 8/25/25.
//

import SwiftUI
import UIKit

// 1) Write text -> temp .txt
func writeTextFile(named: String, contents: String) throws -> URL {
    let name = named.lowercased().hasSuffix(".txt") ? named : named + ".txt"
    let dir = FileManager.default.temporaryDirectory
        .appendingPathComponent("Export-\(UUID().uuidString)", isDirectory: true)
    try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
    let url = dir.appendingPathComponent(name)
    try contents.write(to: url, atomically: true, encoding: .utf8)
    return url
}

// 2) Simple share sheet
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    func updateUIViewController(_: UIActivityViewController, context: Context) {}
}

// 3) Use `.sheet(item:)` so it can't present while URL is nil
private struct ShareFile: Identifiable { let id = UUID(); let url: URL }

struct ExportView: View {
    let fileName: String
    let text: String
    @State private var shareFile: ShareFile?
    
    var body: some View {
        Button("Export") {
            do {
                print("text: \(text)")
                let url = try writeTextFile(named: fileName, contents: text)
                
                // sanity check—helps catch silent failures
                let size = (try? Data(contentsOf: url).count) ?? 0
                guard size > 0 else { print("Empty file at \(url)"); return }
                
                shareFile = ShareFile(url: url)   // <-- setting this triggers the sheet
            } catch {
                print("Export failed:", error)
            }
        }
        .sheet(item: $shareFile, onDismiss: { shareFile = nil }) { share in
            ShareSheet(items: [share.url])       // IMPORTANT: pass the URL, not a String
        }
    }
}

// Usage:
// ExportButton(fileName: "Notes.txt", text: "Hello, world!")

#Preview { ExportView(fileName: "Test.txt", text: "This is a test file") }
