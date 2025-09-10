import SwiftUI
import UniformTypeIdentifiers

struct ExportView: View {
    let fileName: String
    let text: String
    
    @State private var showingExporter = false
    
    var body: some View {
        Button("Export") {
            // Only trigger the exporter — no manual file write needed
            print("Exporting text length:", text.count)
            showingExporter = true
        }
        .fileExporter(
            isPresented: $showingExporter,
            document: TextDocument(text: text),
            contentType: .plainText,
            defaultFilename: fileName.hasSuffix(".txt") ? String(fileName.dropLast(4)) : fileName
        ) { result in
            switch result {
            case .success(let url):
                print("Saved to \(url)")
            case .failure(let error):
                print("Export failed:", error.localizedDescription)
            }
        }
    }
}

// Minimal FileDocument for plain text
struct TextDocument: FileDocument {
    // Being explicit about writable types avoids odd edge cases
    static var readableContentTypes: [UTType] { [.plainText] }
    static var writableContentTypes: [UTType] { [.plainText] }
    
    var text: String
    
    init(text: String) {
        self.text = text
        
        print("text: \(text)")
    }
    
    init(configuration: ReadConfiguration) throws {
        if let data = configuration.file.regularFileContents {
            self.text = String(decoding: data, as: UTF8.self)
        } else {
            self.text = ""
        }
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        FileWrapper(regularFileWithContents: Data(text.utf8))
    }
}

#Preview {
    ExportView(fileName: "Test.txt", text: "This is a test file")
}
