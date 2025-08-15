//
//  GrowAdultView.swift
//  Tulpagotchi Revamp
//
//  Created by Angela Tarbett on 8/15/25.
//

import SwiftUI

struct GrowAdultView: View {
    
    
    @Environment(\.managedObjectContext) private var viewContext
    
    @EnvironmentObject private var dragon: Dragon
    
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                Image(.rainbow3)
                    .resizable()
                    .frame(width: geo.size.width, height: geo.size.height * 1.125)
                    .ignoresSafeArea()
                    .opacity(0.6)
                
                VStack {
                    Text("Match your \(dragon.dragonType!)")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    AsyncImage (url: dragon.dragonImageLocation) { image in
                        image
                            .resizable()
                            .scaledToFit()
                    } placeholder: {
                        ProgressView()
                    }
                    .padding()
                    
                    //fetch the adult dragons that aren't the target dragon
                    
                    //buttons
                    HStack {
                        
//                        NavigationLink {
//                            //match the dragon
//                            if chosenDragonMate != nil {
//                                WritingPage(dragons: [dragonToMatch, chosenDragonMate!], wordCountGoal: 300)
//                            }
//                        } label : {
//                            Text("Match for 300 words")
//                        }
//                        .padding()
//                        .background(mateChosen ? .orange : .gray)
//                        .foregroundStyle(.black)
//                        .clipShape(.rect(cornerRadius: 10))
//                        .disabled(mateChosen ? false : true)
                        
                        Button {
                            //sell the dragon
                        } label : {
                            Text("Sell for \(dragon.dragonSellingPrice) coins")
                        }
                        .padding()
                        .background(.orange)
                        .foregroundStyle(.black)
                        .clipShape(.rect(cornerRadius: 10))
                    }
                    .padding()
                    
                    NavigationLink {
                        //Match with a random dragon
                        //WritingPage(dragons: [dragonToMatch, Dragon.returnRandomDragon(age: .Adult)], wordCountGoal: 300)
                    } label : {
                        Text("Match Random Dragon")
                    }
                    .padding()
                    .background(.orange)
                    .foregroundStyle(.black)
                    .clipShape(.rect(cornerRadius: 10))
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        GrowAdultView()
            .environmentObject(PersistenceController.previewBabyDragon)
    }
}
