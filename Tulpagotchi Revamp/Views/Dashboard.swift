//
//  Dashboard.swift
//  Tulpagotchi Revamp
//
//  Created by Angela Tarbett on 8/15/25.
//

import SwiftUI
import CoreData

struct Dashboard: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.colorScheme) private var scheme
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \User.id, ascending: true)],
        animation: .default)
    private var user: FetchedResults<User>
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \AppSettings.id, ascending: true)],
        animation: .default)
    private var appSettings: FetchedResults<AppSettings>
    private var lastUpdatedDashboard : Date? {
        appSettings.first?.lastUpdatedDashboard
    }
    
    @FetchRequest(
        sortDescriptors: [
            NSSortDescriptor(keyPath: \Dragon.dragonAge, ascending: true),
            NSSortDescriptor(keyPath: \Dragon.dragonPattern, ascending: true),
            NSSortDescriptor(keyPath: \Dragon.dragonMain, ascending: true),
            NSSortDescriptor(keyPath: \Dragon.dragonSecond, ascending: true)
        ],
        animation: .default
    )
    private var dragons: FetchedResults<Dragon>
    
    //filters
    private var dynamicPredicate: NSPredicate {
        var predicates : [NSPredicate] = []
        
        //search predicate
        if selectedType != "All" {
            predicates.append(NSPredicate(format: "dragonType contains[c] %@", selectedType))
        }
        if selectedPattern != "All" {
            predicates.append(NSPredicate(format: "dragonPattern contains[c] %@", selectedPattern))
        }
        if selectedColor != "All" {
            predicates.append(NSPredicate(format: "dragonMain contains[c] %@", selectedColor))
        }
        if selectedAge != "All" {
            predicates.append(NSPredicate(format: "dragonAge contains[c] %@", selectedAge))
        }
        
        //combine predicate and return
        return NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
    }
    
    //progress
    var progressLevel: Double {
        guard let u = user.first else { return 0 } // no user yet
        let denom = Double(u.levelCeiling) - Double(u.levelFloor)
        guard denom > 0 else { return 0 }
        return Double(u.currentLevel) / denom
    }
    
    var dailyProgressPercentage: Double {
        guard let u = user.first else { return 0 }
        let goal = Double(u.dailyGoal)
        guard goal > 0 else { return 0 }
        return Double(u.dailyProgress) / goal
    }
    
    var userName: String {
        guard let u = user.first else { return "Unknown User"}
        return u.id ?? "No user ID"
    }
    var userLevel: String {
        guard let u = user.first else { return "Unknown User"}
        return "\(u.level)"
    }
    var userCoins: String {
        guard let u = user.first else { return "Unknown User"}
        return "\(u.coins)"
    }

    
    //Filters
    @State var selectedType: String = "All"
    @State var selectedPattern: String = "All"
    @State var selectedColor: String = "All"
    @State var selectedAge: String = "All"
    
    var black: Color = Color(.black)
    var white: Color = Color(.white)
    
    var body: some View {
        NavigationStack {
            ZStack {
                Image(.rainbow2)
                    .resizable()
                    .opacity(0.7)
                    .ignoresSafeArea()
                VStack (alignment: .leading) {
                    Text("Hello, \(userName)")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    //level progress view
                    VStack (alignment: .leading) {
                        DashboardProgressView(
                            title: "Level Progress",
                            progressCeiling: Int(user.first?.levelCeiling ?? 0),
                            progressFloor: Int(user.first?.levelFloor ?? 0),
                            progress: Int(user.first?.currentLevel ?? 0),
                            progressLevel: progressLevel)
                        Text("Level \(userLevel)")
                        
                        //daily progress view
                        DashboardProgressView(
                            title: "Daily Progress",
                            progressCeiling: Int(user.first?.dailyGoal ?? 0),
                            progressFloor: 0,
                            progress: Int(user.first?.dailyProgress ?? 0),
                            progressLevel: dailyProgressPercentage)
                        
                        //coins
                        Text("Coins: \(userCoins)")
                    }
                    .padding()
                    .background(scheme == .dark ? black.opacity(0.5) : white.opacity(0.5))
                    
                    //Filters
                    HStack
                    {
                        Menu {
                            Picker("Type", selection: $selectedType) {
                                ForEach(DragonStruct.DragonType.allCases) { type in
                                    Text(type.rawValue).tag(type.rawValue)
                                }
                            }
                        } label: {
                            Text("Type")
                                .fontWeight(.bold)
                        }
                        .buttonStyle(.plain)
                        .onChange(of: selectedType) {
                            dragons.nsPredicate = dynamicPredicate
                        }
                        Spacer()
                        Menu {
                            Picker("Pattern", selection: $selectedPattern) {
                                ForEach(DragonStruct.DragonPattern.allCases) { type in
                                    Text(type.rawValue).tag(type.rawValue)
                                }
                            }
                        } label: {
                            Text("Pattern")
                                .fontWeight(.bold)
                        }
                        .buttonStyle(.plain)
                        .onChange(of: selectedPattern) {
                            dragons.nsPredicate = dynamicPredicate
                        }
                        Spacer()
                        Menu {
                            Picker("Color", selection: $selectedColor) {
                                ForEach(DragonStruct.MainColor.allCases) { color in
                                    Text(color.rawValue).tag(color.rawValue)
                                }
                            }
                        } label: {
                            Text("Color")
                                .fontWeight(.bold)
                        }
                        .buttonStyle(.plain)
                        .onChange(of: selectedColor) {
                            dragons.nsPredicate = dynamicPredicate
                        }
                        Spacer()
                        Menu {
                            Picker("Age", selection: $selectedAge) {
                                ForEach(DragonStruct.DragonAge.allCases) { age in
                                    Text(age.rawValue).tag(age.rawValue)
                                }
                            }
                        } label: {
                            Text("Age")
                                .fontWeight(.bold)
                        }
                        .buttonStyle(.plain)
                        .onChange(of: selectedAge) {
                            dragons.nsPredicate = dynamicPredicate
                        }
                    }
                    .padding()
                    .background(scheme == .dark ? black : white)
                    .foregroundStyle(scheme == .dark ? white : black)
                    .opacity(0.50)
                    
                    //Dragon Area
                    ZStack {
                        Color(scheme == .dark ? .gray : .white).opacity(0.5)
                        ScrollView {
                            LazyVGrid(columns: [GridItem(), GridItem(), GridItem()])
                            {
                                ForEach(dragons) { dragon in
                                    NavigationLink {
                                        GrowDragonView()
                                            .environmentObject(dragon)
                                    } label: {
                                        ZStack {
//                                            if(dragon.dragonImageBinary == nil) {
//                                                DragonThumbnailFromURL(dragonImageLocation: dragon.dragonImageLocation!)
//                                            } else {
                                                // show the downloaded image
                                                DragonThumbnailFromImage(thumbnail: dragon.dragonImage)
//                                            }
                                        }
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                        .padding()
                    }
                    Footer()
                }
                .padding()
            }
            .onAppear() {
                updateDate()
            }
            .task {
                await storeImages()
            }
            
        }
        .navigationBarBackButtonHidden(true)
    }
    func updateDate() {
        //get the current date
        let today = Calendar.current.startOfDay(for: Date())
        
        //check if the lastUpdatedDashboard variable exists
        if let lastUpdated = lastUpdatedDashboard {
            //if it exists and it is before today
            if lastUpdated < today {
                //reset the daily progress
                user.first!.dailyProgress = 0
                //reset the lastUpdatedDashboard in the app settings
                appSettings.first?.lastUpdatedDashboard = today
                
                //save the view context
                do {
                    try viewContext.save()
                } catch {
                    print(error.localizedDescription)
                }
            }
            //if not, proceed as normal
        } else {
            //no dashboard date, set the date
            appSettings.first?.lastUpdatedDashboard = today
            user.first?.dailyProgress = 0
            
            //save
            do {
                try viewContext.save()
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    @MainActor
    func storeImages() async {
        for dragon in dragons {
            if(dragon.dragonImageBinary == nil) {
                await dragon.storeImageData(from: dragon.dragonImageLocation!, context: viewContext)
            }
        }
    }
    
    struct DashboardProgressView: View {
        let title: String
        let progressCeiling: Int // the top of the current stage
        let progressFloor: Int // the bottom of current stage
        let progress: Int // the number of words/minutes that the user has written
        @State var progressLevel: Double
        var value : Double {
            (Double(progress - progressFloor)/Double(progressCeiling - progressFloor)) * 100
        }
        
        var body: some View {
            HStack {
                Text(title)
                ZStack {
                    ProgressView(value: value, total: 100)
                        .border(.black, width: 0.1)
                        .scaleEffect(y:6)
                        .tint(.green)
                    Text("\(progress) / \(progressCeiling)")
                }
            }
        }
    }
    
    struct DragonThumbnailFromURL: View {
        var dragonImageLocation: URL
        
        var body: some View {
            AsyncImage(url: dragonImageLocation) { image in
                image
                    .resizable()
                    .scaledToFit()
                    .shadow(color: .white, radius: 2)
            } placeholder : {
                ProgressView()
            }
        }
    }
    struct DragonThumbnailFromImage: View {
        var thumbnail: Image
        
        var body: some View {
            thumbnail
                .resizable()
                .scaledToFit()
                .shadow(color: .white, radius: 2)
        }
    }
}

#Preview {
    Dashboard()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}


