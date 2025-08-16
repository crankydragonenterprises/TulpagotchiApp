//
//  GrowBabyAndEggView.swift
//  Tulpagotchi Revamp
//
//  Created by Angela Tarbett on 8/15/25.
//

import SwiftUI

struct GrowBabyAndEggView: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    
    @EnvironmentObject private var dragon: Dragon
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                Image(.rainbow3)
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                    .opacity(0.6)
                
                VStack {
                    Text("Grow your \(dragon.dragonType!)")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    AsyncImage(url: dragon.dragonImageLocation) { image in
                        image
                            .resizable()
                            .scaledToFit()
                    } placeholder : {
                        ProgressView()
                    }
                    .padding()
                    
                    HStack {
                        
                        var wordsToGrow: Int {
                            (dragon.dragonAge == "Baby") ? 200 : 100
                        }
                        
                        Button {
                            //sell the dragon
                        } label: {
                            Text("Sell for \(dragon.dragonSellingPrice / 4) coins")
                        }
                        .padding()
                        .background(.orange)
                        .foregroundStyle(.black)
                        .clipShape(.rect(cornerRadius: 10))
                        
                        Spacer()
                        
                        NavigationLink() {
                            //Load the Writing Page
                            WritingPage(dragons: [dragon], wordCountGoal: wordsToGrow)
                            //Text("Writing Page")
                        } label: {
                            Text("Grow for \(wordsToGrow) words")
                            
                        }
                        .padding()
                        .background(.orange)
                        .foregroundStyle(.black)
                        .clipShape(.rect(cornerRadius: 10))
                    }
                }
                .padding()
                .frame(width: geo.size.width, height: geo.size.height)
                
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
    }
}

#Preview {
    NavigationStack {
        GrowBabyAndEggView()
            .environmentObject(PersistenceController.previewDragon)
    }
}
