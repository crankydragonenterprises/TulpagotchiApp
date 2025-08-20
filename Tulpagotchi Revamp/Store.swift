//
//  Store.swift
//  Tulpagotchi Revamp
//
//  Created by Angela Tarbett on 8/19/25.
//

import SwiftUI

struct Store: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \AppSettings.id, ascending: true)],
        animation: .default)
    private var appSettings: FetchedResults<AppSettings>
    private var lastUpdatedStore : Date? {
        appSettings.first?.lastFetchedStoreDragons
    }
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \User.id, ascending: true)],
        animation: .default)
    private var users: FetchedResults<User>
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \StoreDragon.id, ascending: true)],
        animation: .default)
    private var storeDragons: FetchedResults<StoreDragon>
    
    //pull all the other dragons
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \DragondexEntry.id, ascending: true)])
    private var allDragondexEntries: FetchedResults<DragondexEntry>
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \DragondexEntry.id, ascending: true)])
    private var filteredDragondexEntries: FetchedResults<DragondexEntry>
    
    @State private var dragonStructDragonsForStore: [DragonStruct] = []
    @State private var usersCoins: Int = 0
    @State private var returnToDashboard = false
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                Image(.rainbow7)
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                    .rotationEffect(.degrees(90))
                    .opacity(0.6)
                VStack {
                    Text("Store")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    ZStack {
                        Color (.white).opacity(0.6)
                        VStack {
                            //three random dragons per day
                            ForEach(dragonStructDragonsForStore, id: \.id) { dragon in
                                let dragonPrice: Int = dragon.dragonSellingPrice
                                let canAffordDragon = dragonPrice <= usersCoins
                                let bg: Color = canAffordDragon ? .green : .gray
                                let imageURL = dragon.dragonImageLocation
                                let buttonLabel = "Buy for \(dragon.dragonSellingPrice) coins"
                                
                                HStack {
                                    VStack {
                                        AsyncImage(url: imageURL) { image in
                                            image
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 150, height: 150)
                                                
                                        } placeholder: {
                                            ProgressView()
                                        }
                                    }
                                    Spacer()
                                    Button {
                                        //buy the dragon
                                        buyDragon(dragon)
                                        returnToDashboard = true
                                    } label : {
                                        Text(buttonLabel)
                                    }
                                    .padding()
                                    .background(bg)
                                    .foregroundColor(.white)
                                    .clipShape(.capsule)
                                    .disabled(!canAffordDragon)
                                }
                                
                            }
                        }
                        .padding()
                    }
                    .padding()
                    Footer()
                }
                .frame(width: geo.size.width, height: geo.size.height)
                .navigationDestination(isPresented: $returnToDashboard) {
                    Dashboard().environment(\.managedObjectContext, viewContext)
                }
            }
            .frame(width: geo.size.width, height: geo.size.height)
            .navigationBarBackButtonHidden(true)
        }
        .onAppear {
            usersCoins = Int(users.first?.coins ?? 0)
            
            let today = Calendar.current.startOfDay(for: Date())
            
            if let lastUpdated = lastUpdatedStore {
                if lastUpdated < today {
                    // Store not updated today → refresh
                    updateStoreDragons()
                } else {
                    // Already updated today
                    dragonStructDragonsForStore = makeDragonStructsFromCoreDataStoreDragon()
                }
            } else {
                // No stored date yet → treat as "needs update"
                updateStoreDragons()
            }

        }
    }
    
    func makeDragonStructsFromCoreDataStoreDragon () -> [DragonStruct] {
        var dragons : [DragonStruct] = []
        
        for dragon in storeDragons {
            print("\(dragon)")
            var d = DragonStruct(
                dragonType: DragonStruct.DragonType(rawValue: dragon.type ?? "Dragon")!,
                dragonPattern: DragonStruct.DragonPattern(rawValue: dragon.pattern ?? "Basic")!,
                dragonMain: DragonStruct.MainColor(rawValue: dragon.color ?? "Black")!,
                dragonSecond: DragonStruct.SecondaryColor(rawValue: dragon.secondColor ?? "Black")!,
                dragonAge: .Baby,
                dragonSellingPrice: 0,
                dragonImageLocation: URL( string: "https://www.crankydragonenterprises.com")!,
                id: Utilities.generateRandomGuid(length: 10)
            )
            d.dragonSellingPrice = DragonStruct.returnSellingPrice(dragon: d)
            d.dragonImageLocation = DragonStruct.returnImageLocation(dragon: d)
            
            
            dragons.append(d)
        }
        
        return dragons
    }
        
    func updateStoreDragons() {
        
        for dragon in storeDragons {
            viewContext.delete(dragon)
        }
        
        for i in 0..<3 {
            let dragon = DragonStruct.returnRandomDragon(age: .Baby, highestType: .Dragon, highestPattern: .Basic)
            dragonStructDragonsForStore.append(dragon)
            
            let storeDragon = StoreDragon(context: viewContext)
            storeDragon.id = Int16(i+1)
            storeDragon.type = dragon.dragonType.rawValue
            storeDragon.pattern = dragon.dragonPattern.rawValue
            storeDragon.color = dragon.dragonMain.rawValue
            storeDragon.secondColor = dragon.dragonSecond.rawValue
            storeDragon.purchased = false
            
            
        }
        
        //set the lastUpdated Date in the Database
        appSettings.first?.lastFetchedStoreDragons = Calendar.current.startOfDay(for: Date())
        
        do {
            try viewContext.save()
        } catch {
            print(error)
        }
        
    }
    
    func dragonPresentInDragondex(type dragonType: String, pattern dragonPattern: String, color dragonColor: String, secondColor dragonSecondary: String) -> Bool {
        var dynamicPredicate: NSPredicate {
            var predicates : [NSPredicate] = []
            
            //search predicate
            predicates.append(NSPredicate(format: "type contains[c] %@", dragonType))
            predicates.append(NSPredicate(format: "pattern contains[c] %@", dragonPattern))
            predicates.append(NSPredicate(format: "mainColor contains[c] %@", dragonColor))
            predicates.append(NSPredicate(format: "secondColor contains[c] %@", dragonSecondary))
            
            //combine predicate and return
            return NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        }
        
        filteredDragondexEntries.nsPredicate = dynamicPredicate
        
        if filteredDragondexEntries.count > 0 { return true }
        else { return false }
    }
    
    func buyDragon(_ dragon: DragonStruct) {
        
        //make a new Dragon
        let newDragon = Dragon(context: viewContext)
        newDragon.id = Utilities.generateRandomGuid(length: 10)
        newDragon.dragonType = dragon.dragonType.rawValue
        newDragon.dragonPattern = dragon.dragonPattern.rawValue
        newDragon.dragonMain = dragon.dragonMain.rawValue
        newDragon.dragonSecond = dragon.dragonSecond.rawValue
        newDragon.dragonAge = "Egg"
        newDragon.dragonImageLocation = Utilities.returnImageLocation(dragon: newDragon)
        newDragon.dragonSellingPrice = Utilities.returnSellingPrice(dragon: newDragon)
        newDragon.dragonCloningPrice = Int16(DragonStruct.returnCloningPrice(type: dragon.dragonType, pattern: dragon.dragonPattern, color: dragon.dragonMain, secondColor: dragon.dragonSecond))
        
        //remove the dragon's price from the user's coins
        users.first!.coins -= Int64(dragon.dragonSellingPrice)
        
        //check the dragondex for the new dragon and add it if not
        if !dragonPresentInDragondex(type: newDragon.dragonType!, pattern: newDragon.dragonPattern!, color: newDragon.dragonMain!, secondColor: newDragon.dragonSecond!) {
            
            let newDragondexEntry = DragondexEntry(context: viewContext)
            newDragondexEntry.id = Int16(allDragondexEntries.count + 1)
            newDragondexEntry.type = newDragon.dragonType!
            newDragondexEntry.pattern = newDragon.dragonPattern!
            newDragondexEntry.mainColor = newDragon.dragonMain!
            newDragondexEntry.secondColor = newDragon.dragonSecond!
            
        }
        
        //save the context
        do {
            try viewContext.save()
        } catch {
            print(error)
        }
    }
}

#Preview {
    NavigationStack {
        Store()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
