//
//  ContentView.swift
//  Tulpagotchi Revamp
//
//  Created by Angela Tarbett on 8/14/25.
//

import SwiftUI
import CoreData
import Network
import Combine

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \User.id, ascending: true)],
        animation: .default)
    private var users: FetchedResults<User>
    
    @FetchRequest(
        sortDescriptors: [
            NSSortDescriptor(keyPath: \Dragon.id, ascending: true)
        ],
        animation: .default
    )
    private var dragons: FetchedResults<Dragon>
    @State private var userName: String = ""
    
    private let randomDragon: DragonStruct =
        DragonStruct.returnRandomDragon(age: DragonStruct.DragonAge.Baby, highestType: DragonStruct.DragonType.Dragon, highestPattern: DragonStruct.DragonPattern.Basic)

    @EnvironmentObject var net: NetworkMonitor
    
    var body: some View {
        if !net.isConnected {
            ZStack {
                Color (.red)
                    .opacity(0.4)
                    .ignoresSafeArea()
                VStack {
                    Spacer()
                    Text("Tulpagotchi requires\nan internet connection.\nPlease connect to the internet\nand try again later.\n\n\(net.isConnected ? "Connected" : "Not Connected")")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding()
                        .multilineTextAlignment(.center)
                    Spacer()
                    Text("Having a hard time?\nContact us at\ncranky@crankydragonenterprises.com")
                        .multilineTextAlignment(.center)
                    Spacer()
                }
            }
        }
        else {
            if(dragons.count == 0 && users.count == 0) {
                GeometryReader { geo in
                    ZStack {
                        Image(.rainbow1)
                            .resizable()
                            .frame(width: geo.size.width, height: geo.size.height * 1.125)
                            .opacity(0.4)
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
                                    .padding(.horizontal, 50)
                            }
                            .padding()
                        } actions: {
                            if !userName.isEmpty {
                                Button ("Get your first dragons", systemImage: "lizard.fill") {
                                    saveNewUser(newUserName: userName)
                                }
                                .buttonStyle(.plain)
                                .buttonStyle(.borderedProminent)
                            }
                        }
                    }
                }
            }
            else {
                Dashboard()
                    .environment(\.managedObjectContext, viewContext)
            }
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
        newUser.highestTypeAllowed = "Dragon"
        newUser.highestPatternAllowed = "Basic"
        
        let newDragon1 = Dragon(context: viewContext)
        newDragon1.id = Utilities.generateRandomGuid(length: 10)
        newDragon1.dragonType =  DragonStruct.DragonType.Dragon.rawValue
        newDragon1.dragonPattern = DragonStruct.DragonPattern.Basic.rawValue
        newDragon1.dragonMain = DragonStruct.MainColor.Green.rawValue
        newDragon1.dragonSecond = DragonStruct.SecondaryColor.Green.rawValue
        newDragon1.dragonAge = DragonStruct.DragonAge.Adult.rawValue
        newDragon1.dragonImageLocation =  Utilities.returnImageLocation(dragon: newDragon1)
        newDragon1.dragonSellingPrice = Utilities.returnSellingPrice(dragon: newDragon1)
        newDragon1.dragonCloningPrice = Utilities.returnCloningPrice(type: DragonStruct.DragonType(rawValue: newDragon1.dragonType!) ?? DragonStruct.DragonType.Dragon, pattern: DragonStruct.DragonPattern(rawValue: newDragon1.dragonPattern!) ?? DragonStruct.DragonPattern.Basic, color: DragonStruct.MainColor(rawValue: newDragon1.dragonMain!) ?? DragonStruct.MainColor.Black, secondColor: DragonStruct.SecondaryColor(rawValue: newDragon1.dragonSecond!) ?? DragonStruct.SecondaryColor.Black)
        
        let newDragon2 = Dragon(context: viewContext)
        newDragon2.id = Utilities.generateRandomGuid(length: 10)
        newDragon2.dragonType =  DragonStruct.DragonType.Dragon.rawValue
        newDragon2.dragonPattern = DragonStruct.DragonPattern.Basic.rawValue
        newDragon2.dragonMain = DragonStruct.MainColor.Brown.rawValue
        newDragon2.dragonSecond = DragonStruct.SecondaryColor.Brown.rawValue
        newDragon2.dragonAge = DragonStruct.DragonAge.Adult.rawValue
        newDragon2.dragonImageLocation =  Utilities.returnImageLocation(dragon: newDragon2)
        newDragon2.dragonSellingPrice = Utilities.returnSellingPrice(dragon: newDragon2)
        newDragon2.dragonCloningPrice = Utilities.returnCloningPrice(type: DragonStruct.DragonType(rawValue: newDragon2.dragonType!) ?? DragonStruct.DragonType.Dragon, pattern: DragonStruct.DragonPattern(rawValue: newDragon2.dragonPattern!) ?? DragonStruct.DragonPattern.Basic, color: DragonStruct.MainColor(rawValue: newDragon2.dragonMain!) ?? DragonStruct.MainColor.Black, secondColor: DragonStruct.SecondaryColor(rawValue: newDragon2.dragonSecond!) ?? DragonStruct.SecondaryColor.Black)
        
        let dragondexEntry1 = DragondexEntry(context: viewContext)
        dragondexEntry1.id = 1
        dragondexEntry1.type = "Dragon"
        dragondexEntry1.pattern = "Basic"
        dragondexEntry1.mainColor = "Green"
        dragondexEntry1.secondColor = "Green"
        
        let dragondexEntry2 = DragondexEntry(context: viewContext)
        dragondexEntry2.id = 2
        dragondexEntry2.type = "Dragon"
        dragondexEntry2.pattern = "Basic"
        dragondexEntry2.mainColor = "Brown"
        dragondexEntry2.secondColor = "Brown"
        
        let appSettings = AppSettings(context: viewContext)
        appSettings.id = 1
        appSettings.lastFetchedStoreDragons = Calendar.current.date(byAdding: .day, value: -1, to: Date())
        
        do {
            try viewContext.save()
        } catch {
            print(error)
        }
    }
}

@MainActor
final class NetworkMonitor: ObservableObject {
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")
    
    @Published private(set) var status: NWPath.Status = .requiresConnection
    @Published private(set) var interface: NWInterface.InterfaceType?
    @Published private(set) var isExpensive = false
    @Published private(set) var isConstrained = false
    
    var isConnected: Bool { status == .satisfied }
    
    init() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.status = path.status
                self?.isExpensive = path.isExpensive
                self?.isConstrained = path.isConstrained
                self?.interface = [.wifi, .cellular, .wiredEthernet, .other]
                    .first { path.usesInterfaceType($0) }
            }
        }
        monitor.start(queue: queue)
    }
    
    deinit { monitor.cancel() }
}


#Preview {
    ContentView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        .environmentObject(NetworkMonitor())
}
