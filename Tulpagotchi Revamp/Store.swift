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
    
    @State private var dragonStructDragonsForStore: [DragonStruct] = []
    @State private var usersCoins: Int = 0
    
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
                            ForEach(dragonStructDragonsForStore) { dragon in
                                let dragonPrice: Int = dragon.dragonSellingPrice
                                let canAffordDragon = dragonPrice <= usersCoins
                                let bg: Color = canAffordDragon ? .green : .gray
                                HStack {
                                    VStack {
                                        AsyncImage(url: dragon.dragonImageLocation) { image in
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
                                    } label : {
                                        Text("Buy for \(dragon.dragonSellingPrice) coins")
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
            }
            .frame(width: geo.size.width, height: geo.size.height)
            .navigationBarBackButtonHidden(true)
        }
        .onAppear {
            usersCoins = Int(users.first?.coins ?? 0)
            print("usersCoins: \(usersCoins)")
            
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
        //print("making the store dragons for display")
        
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
    
    func buyDragon(_ dragon: DragonStruct) {
        
        print("Buying \(dragon)")
        
        
    }
}

#Preview {
    NavigationStack {
        Store()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
