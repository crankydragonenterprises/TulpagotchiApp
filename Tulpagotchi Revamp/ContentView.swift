//
//  ContentView.swift
//  Tulpagotchi Revamp
//
//  Created by Angela Tarbett on 8/14/25.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \User.id, ascending: true)],
        animation: .default)
    private var user: FetchedResults<User>
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Dragon.id, ascending: true)],
        animation: .default
    )
    private var dragons: FetchedResults<Dragon>
    @State private var userName: String = ""
    
    private let randomDragon: DragonStruct = DragonStruct.returnRandomDragon(age: DragonStruct.DragonAge.Baby)

    var body: some View {
        if(dragons.count == 0) {
            
            ZStack {
                Color(.blue)
                    .opacity(0.2)
                    .ignoresSafeArea()
                ContentUnavailableView {
                    Label("What is your name", systemImage: "questionmark.circle.fill")
                } description: {
                    VStack {
                        AsyncImage(url: randomDragon.dragonImageLocation)
                        { image in
                            image
                                .resizable()
                                .scaledToFit()
                                .padding()
                                .shadow(color: .white, radius: 2)
                        } placeholder: {
                            ProgressView()
                        }
                        
                        TextField("Enter name here", text: $userName)
                            .textFieldStyle(.roundedBorder)        // modern style
                            .textInputAutocapitalization(.never)   // optional customization
                            .autocorrectionDisabled(true)
                            .padding()
                    }
                } actions: {
                    if !userName.isEmpty {
                        Button ("Get your first dragons", systemImage: "lizard.fill") {
                            saveNewUser(newUserName: userName)
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
            }
        }
        else {
            Dashboard()
//            NavigationView() {
//                List {
//                    ForEach(user) { user in
//                        NavigationLink {
//                            UserAndDragonView(user: user, dragons: dragons)
//                            
//                            
//                        } label: {
//                            Text("Go to \(user.id!)'s Dashboard")
//                        }
//                    }
//                }
////                .toolbar {
////                    ToolbarItem {
////                        Button("Add Item", systemImage: "plus") {
////                            saveNewUser(newUserName: userName)
////                        }
////                    }
////                }
//            }
        }
    }
    
    func saveNewUser(newUserName: String) {
        
        let newUser = User(context: viewContext)
        newUser.id = newUserName
        newUser.level = 1
        newUser.levelFloor = 0
        newUser.levelCeiling = 500
        newUser.currentLevel = 0
        newUser.dailyGoal = 200
        newUser.dailyProgress = 0
        newUser.coins = 0
        
        let newDragon1 = Dragon(context: viewContext)
        newDragon1.id = Utilities.generateRandomGuid(length: 10)
        newDragon1.dragonType =  DragonStruct.DragonType.Dragon.rawValue
        newDragon1.dragonPattern = DragonStruct.DragonPattern.Basic.rawValue
        newDragon1.dragonMain = DragonStruct.MainColor.Green.rawValue
        newDragon1.dragonSecond = DragonStruct.SecondaryColor.Green.rawValue
        newDragon1.dragonImageLocation =  Utilities.returnImageLocation(dragon: newDragon1)
        newDragon1.dragonSellingPrice = Utilities.returnSellingPrice(dragon: newDragon1)
        newDragon1.dragonCloningPrice = Utilities.returnCloningPrice(type: DragonStruct.DragonType(rawValue: newDragon1.dragonType!) ?? DragonStruct.DragonType.Dragon, pattern: DragonStruct.DragonPattern(rawValue: newDragon1.dragonPattern!) ?? DragonStruct.DragonPattern.Basic, color: DragonStruct.MainColor(rawValue: newDragon1.dragonMain!) ?? DragonStruct.MainColor.Black, secondColor: DragonStruct.SecondaryColor(rawValue: newDragon1.dragonSecond!) ?? DragonStruct.SecondaryColor.Black)
        
        
        let newDragon2 = Dragon(context: viewContext)
        newDragon2.id = Utilities.generateRandomGuid(length: 10)
        newDragon2.dragonType =  DragonStruct.DragonType.Dragon.rawValue
        newDragon2.dragonPattern = DragonStruct.DragonPattern.Basic.rawValue
        newDragon2.dragonMain = DragonStruct.MainColor.Brown.rawValue
        newDragon2.dragonSecond = DragonStruct.SecondaryColor.Brown.rawValue
        newDragon2.dragonImageLocation =  Utilities.returnImageLocation(dragon: newDragon1)
        newDragon2.dragonSellingPrice = Utilities.returnSellingPrice(dragon: newDragon1)
        newDragon2.dragonCloningPrice = Utilities.returnCloningPrice(type: DragonStruct.DragonType(rawValue: newDragon2.dragonType!) ?? DragonStruct.DragonType.Dragon, pattern: DragonStruct.DragonPattern(rawValue: newDragon2.dragonPattern!) ?? DragonStruct.DragonPattern.Basic, color: DragonStruct.MainColor(rawValue: newDragon2.dragonMain!) ?? DragonStruct.MainColor.Black, secondColor: DragonStruct.SecondaryColor(rawValue: newDragon2.dragonSecond!) ?? DragonStruct.SecondaryColor.Black)
        
        do {
            try viewContext.save()
        } catch {
            
        }
    }
}

#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}

//struct UserAndDragonView: View {
//    let user: User
//    let dragons: FetchedResults<Dragon>
//    
//    var body: some View {
//        VStack {
//            Text("User ID: \(user.id ?? "Unknown User")")
//            
//            ForEach(dragons) {dragon in
//                Text("Dragon ID: \(dragon.id ?? "Unknown Dragon")")
//            }
//        }
//    }
//}
