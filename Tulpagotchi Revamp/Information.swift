//
//  Information.swift
//  Tulpagotchi
//
//  Created by Angela Tarbett on 8/11/25.
//

import SwiftUI
import MessageUI

struct Information: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    
    
    @State private var showMail = false
    
    
    var body: some View {
        GeometryReader {geo in
            ZStack {
                Image(.rainbow1)
                    .resizable()
                    .scaledToFill()
                    .opacity(0.6)
                    .ignoresSafeArea()
                VStack {
                    HStack (alignment: .bottom) {
                        Text("Information")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                    }
                    Spacer(minLength: 450)
                    
                    
                    Button {
                        //TO DO - email cranky@crankydragonenterprises.com
                        if MFMailComposeViewController.canSendMail() {
                            showMail = true
                        } else {
                            // Show an alert or fallback
                            print("Mail services are not available")
                        }
                    } label: {
                        Text("Provide Feedback")
                    }
                    .padding()
                    .background(.purple)
                    .foregroundStyle(.white)
                    .clipShape(.rect(cornerRadius: 20))
                    
                    Spacer()
                    
                    Text("App Version: \(getAppVersion())")
                        .padding(.bottom, 25)
                    
                    Text("Copyright ©2025 Cranky Dragon Enterprises. All rights reserved.")
                        .multilineTextAlignment(.center)
                        .padding()
                    
                    
                    Footer()
                }
                .frame(width: geo.size.width, height: geo.size.height)
                .navigationBarBackButtonHidden(true)
                .sheet(isPresented: $showMail) {
                    MailView(
                        subject: "Tulpagotchi Feedback",
                        body: "Send from the Tulpagotchi app!",
                        toRecipients: ["cranky@crankydragonenterprises.com"]
                    )
                }
            }
            .frame(width: geo.size.width, height: geo.size.height)
            
        }
    }
    
    func getAppVersion() -> String {
        if let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            return appVersion
        }
        return "Unknown"
    }
}

/*
 
 struct ContentView: View {
 @State private var showMail = false
 
 var body: some View {
 VStack {
 Button("Send Email") {
 if MFMailComposeViewController.canSendMail() {
 showMail = true
 } else {
 // Show an alert or fallback
 print("Mail services are not available")
 }
 }
 }
 .sheet(isPresented: $showMail) {
 MailView(
 subject: "Hello from my app",
 body: "This is the body of the email.",
 toRecipients: ["test@example.com"]
 )
 }
 }
 }

 */

#Preview {
    NavigationStack {
        Information()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
