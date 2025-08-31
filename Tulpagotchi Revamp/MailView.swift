//
//  MailView.swift
//  Tulpagotchi Revamp
//
//  Created by Angela Tarbett on 8/31/25.
//

import SwiftUI
import MessageUI

// Wrapper to present MFMailComposeViewController in SwiftUI
struct MailView: UIViewControllerRepresentable {
    @Environment(\.dismiss) var dismiss
    
    var subject: String
    var body: String
    var toRecipients: [String]
    
    class Coordinator: NSObject, @preconcurrency MFMailComposeViewControllerDelegate {
        var parent: MailView
        init(parent: MailView) { self.parent = parent }
        
        @MainActor func mailComposeController(_ controller: MFMailComposeViewController,
                                   didFinishWith result: MFMailComposeResult,
                                   error: Error?) {
            controller.dismiss(animated: true) {
                self.parent.dismiss()
            }
        }
    }
    
    func makeCoordinator() -> Coordinator { Coordinator(parent: self) }
    
    func makeUIViewController(context: Context) -> MFMailComposeViewController {
        let vc = MFMailComposeViewController()
        vc.setSubject(subject)
        vc.setMessageBody(body, isHTML: false)
        vc.setToRecipients(toRecipients)
        vc.mailComposeDelegate = context.coordinator
        return vc
    }
    
    func updateUIViewController(_ uiViewController: MFMailComposeViewController,
                                context: Context) {}
}
