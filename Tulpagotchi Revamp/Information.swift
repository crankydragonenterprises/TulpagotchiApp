//
//  Information.swift
//  Tulpagotchi
//
//  Created by Angela Tarbett on 8/11/25.
//

import SwiftUI

struct Information: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    
    var body: some View {
        GeometryReader {geo in
            ZStack {
                Image(.rainbow6)
                    .resizable()
                    .scaledToFill()
                    .opacity(0.6)
                    .ignoresSafeArea()
                VStack {
                    HStack (alignment: .bottom) {
                        Text("Information")
                            .font(.largeTitle)
                    }
                    Spacer(minLength: 450)
                    
                    
                    Button {
                        
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

#Preview {
    NavigationStack {
        Information()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
