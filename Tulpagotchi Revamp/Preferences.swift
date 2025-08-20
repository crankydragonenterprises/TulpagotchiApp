//
//  Preferences.swift
//  Tulpagotchi
//
//  Created by Angela Tarbett on 8/11/25.
//

import SwiftUI

struct Preferences: View {
    
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
                    Text("Preferences")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Under Construction")
                    
                    Spacer()
                    Footer()
                }
                .frame(width: geo.size.width, height: geo.size.height)
            }
            .frame(width: geo.size.width, height: geo.size.height)
            .navigationBarBackButtonHidden(true)
        }
    }
}

#Preview {
    NavigationStack {
        Preferences().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
