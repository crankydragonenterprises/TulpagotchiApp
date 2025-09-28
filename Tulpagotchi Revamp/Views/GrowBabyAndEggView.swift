//
//  GrowBabyAndEggView.swift
//  Tulpagotchi Revamp
//
//  Created by Angela Tarbett on 8/15/25.
//

import SwiftUI
import CoreData

struct GrowBabyAndEggView: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    
    @EnvironmentObject private var dragon: Dragon
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \User.id, ascending: true)],
        animation: .default)
    private var user: FetchedResults<User>
    
    @State var returnToDashboard = false
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                Image(.rainbow3)
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                    .opacity(0.6)
                
                VStack {
                    Text("Grow your \(dragon.dragonType ?? "Unknown Type")")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    dragon.dragonImage
                        .resizable()
                        .scaledToFit()
                        .shadow(color: .black, radius: 2)
                        .padding()
                    
                    HStack {
                        
                        var wordsToGrow: Int {
                            (dragon.dragonAge == "Baby") ? 200 : 100
                        }
                        
                        Button {
                            //sell the dragon
                            do {
                                
                                let sellingPrice = dragon.dragonSellingPrice / 4
                                
                                user.first?.coins += Int64(sellingPrice)
                                viewContext.delete(dragon)
                                
                                try viewContext.save()
                                
                            } catch {
                                print(error)
                            }
                            
                            returnToDashboard = true
                            
                        } label: {
                            Text("Sell for \(dragon.dragonSellingPrice / 4) coins")
                            //Text("Sell")
                        }
                        .buttonStyle(.plain)
                        .padding()
                        .background(.orange)
                        .foregroundStyle(.black)
                        .clipShape(.rect(cornerRadius: 10))
                        .navigationDestination(isPresented: $returnToDashboard) {
                            Dashboard().environment(\.managedObjectContext, viewContext)
                        }
                        
                        Spacer()
                        
                        NavigationLink() {
                            //Load the Writing Page
                            WritingPage(dragons: [dragon], wordCountGoal: wordsToGrow)
                            //Text("Writing Page")
                        } label: {
                            Text("Grow for \(wordsToGrow) words")
                            
                        }
                        .buttonStyle(.plain)
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
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            .environmentObject(PersistenceController.previewDragon)
            .environmentObject(PersistenceController.previewUser)
    }
}
