//
//  Footer.swift
//  Tulpagotchi
//
//  Created by Angela Tarbett on 8/10/25.
//

import SwiftUI

struct Footer: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.colorScheme) var colorScheme
    
    private var darkMode: Bool {
        colorScheme == .dark
    }
    
    var body: some View {
        VStack (alignment: .trailing){
            HStack {
                NavigationLink {
                    Dashboard().environment(\.managedObjectContext, viewContext)
                } label: {
                    FooterIcon(imageName: "house.fill", darkMode: darkMode)
                }
                Spacer()
                NavigationLink {
                    Dragondex().environment(\.managedObjectContext, viewContext)
                } label : {
                    FooterIcon(imageName: "lizard.fill", darkMode: darkMode)
                }
                Spacer()
                NavigationLink {
                    Store().environment(\.managedObjectContext, viewContext)
                } label: {
                    FooterIcon(imageName: "cart.fill", darkMode: darkMode)
                }
//                Spacer()
//                NavigationLink {
//                    Preferences()
//                } label : {
//                    FooterIcon(imageName: "person.fill")
//                }
                Spacer()
                NavigationLink {
                    Information().environment(\.managedObjectContext, viewContext)
                } label : {
                    FooterIcon(imageName: "info.circle.fill", darkMode: darkMode)
                }
            }
            .background(.clear)
            .padding()
            //.border(.blue)
        }
    }
}

#Preview {
    NavigationStack {
        Footer()
    }
}

struct FooterIcon: View {
    let imageName: String
    let darkMode: Bool
    
    var body: some View {
            Image(systemName: imageName)
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundStyle(darkMode ? .white : .black)
        
    }
}
