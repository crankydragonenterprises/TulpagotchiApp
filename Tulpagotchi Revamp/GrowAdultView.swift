//
//  GrowAdultView.swift
//  Tulpagotchi Revamp
//
//  Created by Angela Tarbett on 8/15/25.
//

import SwiftUI
import CoreData

struct GrowAdultView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @EnvironmentObject private var dragon: Dragon
    
    //pull all the other dragons
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Dragon.id, ascending: true)]
    ) private var potentialMates: FetchedResults<Dragon>
    
    @State private var mateChosen = false
    @State private var selectedMate: Dragon? = nil
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                Image(.rainbow3)
                    .resizable()
                    .scaledToFill()
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
                    ScrollView {
                        HStack {
                            ForEach(potentialMates) {mate in
                                if (mate.id != dragon.id && mate.dragonAge == "Adult")
                                {
                                    AsyncImage (url: mate.dragonImageLocation) { image in
                                        image
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 100, height: 100)
                                    } placeholder: {
                                        ProgressView()
                                    }
                                    .padding()
                                    .background(selectedMate?.id == mate.id ? .blue.opacity(0.2) : .clear)
                                    .clipShape(.rect(cornerRadius: 50))
                                    .onTapGesture {
                                        selectedMate = mate
                                        if selectedMate != nil
                                        {
                                            mateChosen = true
                                            
                                        }
                                        else  {
                                            mateChosen = false
                                        }
                                    }
                                }
                            }
                            //Text("\(potentialMates.count)")
                        }
                    }
                    .frame(width: geo.size.width)
                    
                    //buttons
                    HStack {
                        
                        NavigationLink {
                            //match the dragon
                            if selectedMate != nil {
                                //WritingPage(dragons: [dragonToMatch, chosenDragonMate!], wordCountGoal: 300)
                            }
                        } label : {
                            Text("Match for 300 words")
                        }
                        .padding()
                        .background(mateChosen ? .orange : .gray)
                        .foregroundStyle(.black)
                        .clipShape(.rect(cornerRadius: 10))
                        .disabled(mateChosen ? false : true)
                        
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
                .frame(width: geo.size.width, height: geo.size.height)
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
    }
}

#Preview {
    NavigationStack {
        GrowAdultView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)            .environmentObject(PersistenceController.previewDragon)
    }

}
