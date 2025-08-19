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
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Dragon.id, ascending: true)]) private var potentialMates: FetchedResults<Dragon>
    
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \User.id, ascending: true)],
        animation: .default) private var users: FetchedResults<User>
    
    @State private var mateChosen = false
    @State private var selectedMate: Dragon? = nil
    
    
    //get the user's highest type & pattern
    private var highestDragonType: DragonStruct.DragonType {
        return DragonStruct.DragonType(rawValue: DragonStruct.DragonType.RawValue( users[0].highestTypeAllowed!)) ?? .Dragon
    }
    private var highestDragonPattern: DragonStruct.DragonPattern{
        return DragonStruct.DragonPattern(rawValue: DragonStruct.DragonPattern.RawValue( users[0].highestPatternAllowed!)) ?? .Basic
    }
    
    private var randomDragon: Dragon { DragonStruct.returnCoreDataDragonFromDragonStruct(dragon: DragonStruct.returnRandomDragon(age: .Adult, highestType: highestDragonType, highestPattern: highestDragonPattern), in: PersistenceController.shared.container.viewContext)
    }

    @State private var showWritingPage = false
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
                    Text("Match your \(dragon.dragonType ?? "Dragon")")
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
                                WritingPage(dragons: [dragon, selectedMate!], wordCountGoal: 300)
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
                            do {
                                
                                let sellingPrice = dragon.dragonSellingPrice / 4
                                
                                users.first?.coins += Int64(sellingPrice)
                                viewContext.delete(dragon)
                                
                                try viewContext.save()
                                
                                
                                returnToDashboard = true
                                
                            } catch {
                                print(error)
                            }
                        } label : {
                            Text("Sell for \(dragon.dragonSellingPrice) coins")
                        }
                        .padding()
                        .background(.orange)
                        .foregroundStyle(.black)
                        .clipShape(.rect(cornerRadius: 10))
                        .navigationDestination(isPresented: $returnToDashboard) {
                            Dashboard().environment(\.managedObjectContext, viewContext)
                        }
                    }
                    .padding()
                    
                    Button {
                        showWritingPage = true
                        
                        //Match with a random dragon
                        
                    } label : {
                        Text("Match Random Dragon")
                    }
                    .padding()
                    .background(.orange)
                    .foregroundStyle(.black)
                    .clipShape(.rect(cornerRadius: 10))
                    .navigationDestination(isPresented: $showWritingPage) {
                        WritingPage(dragons: [dragon, randomDragon],
                                    wordCountGoal: 300)
                        
                    }
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
