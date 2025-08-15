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
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \User.id, ascending: true)],
        animation: .default)
    private var user: FetchedResults<User>
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Dragon.id, ascending: true)],
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
        return (Double(user[0].level) / (Double(user[0].levelCeiling) - Double(user[0].levelFloor)))
    }
    var dailyProgressPercentage : Double {
        return (Double(user[0].dailyProgress) / Double(user[0].dailyGoal))
    }
    
    //Filters
    @State var selectedType: String = "All"
    @State var selectedPattern: String = "All"
    @State var selectedColor: String = "All"
    @State var selectedAge: String = "All"
    
    var body: some View {
        NavigationStack {
            ZStack {
                Image(.rainbow2)
                    .resizable()
                    .opacity(0.7)
                    .ignoresSafeArea()
                VStack (alignment: .leading) {
                    Text("Hello, \(user[0].id!)")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    //level progress view
                    VStack (alignment: .leading) {
                        DashboardProgressView(title: "Level Progress", progressLevel: progressLevel)
                        
                        Text("Level \(user[0].level)")
                        
                        //daily progress view
                        DashboardProgressView(title: "Daily Progress", progressLevel: dailyProgressPercentage)
                        
                        //coins
                        Text("Coins: \(user[0].coins)")
                    }
                    .padding()
                    .background(.white.opacity(0.5))
                    
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
                        }
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
                        }
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
                        }
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
                        }
                        .onChange(of: selectedAge) {
                            dragons.nsPredicate = dynamicPredicate
                        }
                    }
                    .padding()
                    .background(.white)
                    .foregroundStyle(.black)
                    .opacity(0.50)
                    
                    //Dragon Area
                    ZStack {
                        Color(.white).opacity(0.5)
                        ScrollView {
                            LazyVGrid(columns: [GridItem(), GridItem(), GridItem()])
                            {
                                ForEach(dragons) { dragon in
                                    NavigationLink {
                                        GrowDragonView()
                                        //Text( dragon.dragonMain ?? "No Dragon" )
                                    } label: {
                                        AsyncImage(url: dragon.dragonImageLocation) { image in
                                            image
                                                .resizable()
                                                .scaledToFit()
                                        } placeholder : {
                                            ProgressView()
                                        }
                                    }
                                    
                                }
                            }
                        }
                        .padding()
                    }
                    
                    Text("")
                }
                .padding()
            }
        }
    }
    
    struct DashboardProgressView: View {
        let title: String
        @State var progressLevel: Double
        
        var body: some View {
            HStack {
                Text(title)
                ProgressView(value: progressLevel)
                    .border(.black, width: 0.1)
                    .scaleEffect(y:6)
                    .tint(.green)
            }
        }
    }
}

#Preview {
    Dashboard().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
