//
//  Dragondex.swift
//  Tulpagotchi
//
//  Created by Angela Tarbett on 8/10/25.
//

import SwiftUI

//main dragondex view
struct Dragondex: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    //pull all the other dragons
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \DragondexEntry.id, ascending: true)])
    private var allDragondexEntries: FetchedResults<DragondexEntry> 
    
    //pull all the other dragons
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \DragondexEntry.id, ascending: true)])
    private var filteredDragondexEntries: FetchedResults<DragondexEntry>
    
    var body: some View {
        GeometryReader { geo in
            NavigationStack {
                ZStack {
                    Image(.rainbow5)
                        .resizable()
                        .scaledToFill()
                        .ignoresSafeArea()
                        .opacity(0.5)
                    VStack {
                        Text("Dragondex")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        ZStack {
                            Color(.white).opacity(0.5)
                                .padding()
                                ScrollView {
                                    VStack {
                                        ForEach(DragonStruct.DragonType.allCases.dropLast()) {type in
                                            let percentageComplete = returnPercentageComplete(type: type.rawValue)
                                            let percentageString = String(format: "%.2f", percentageComplete)
                                            
                                            NavigationLink {
                                                ViewDragonTypeDetail(type: type.rawValue).environment(\.managedObjectContext, viewContext)
                                            } label: {
                                                HStack {
                                                    VStack {
                                                        AsyncImage(url: returnImageURL(for: type.rawValue)) { image in
                                                            image
                                                                .resizable()
                                                                .scaledToFit()
                                                                .frame(width: 150, height: 150)
                                                                .shadow(color: .white, radius: 2)
                                                        } placeholder: {
                                                            ProgressView()
                                                        }
                                                        Text("\(percentageString)% Complete")
                                                    }
                                                    Spacer()
                                                    Text("\(type)")
                                                        .font(.title)
                                                }
                                                .padding()
                                                Spacer()
                                            }
                                            .buttonStyle(.plain)
                                        }
                                    }
                                    .padding()
                                }
                                .padding()
                            
                        }
                        
                        Footer()
                        
                    }
                    .frame(width: geo.size.width, height: geo.size.height)
                }
                .frame(width: geo.size.width, height: geo.size.height)
                .navigationBarBackButtonHidden()
            }
        }
    }
    
    func returnPercentageComplete(type dragonType: String) -> Double {
        let totalNumberOfDragonsPerColor: Double = Double(DragonStruct.SecondaryColor.allCases.dropLast().count * DragonStruct.MainColor.allCases.dropLast().count * DragonStruct.DragonPattern.allCases.dropLast().count)
        var numberOfOwnedDragons: Double = 0
        
        var dynamicPredicate: NSPredicate {
            var predicates : [NSPredicate] = []
            
            //search predicate
            predicates.append(NSPredicate(format: "type contains[c] %@", dragonType))
            
            //combine predicate and return
            return NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        }
        
        filteredDragondexEntries.nsPredicate = dynamicPredicate
        
        numberOfOwnedDragons = Double(filteredDragondexEntries.count)
        
        return (numberOfOwnedDragons / totalNumberOfDragonsPerColor) * 100
    }
    
    func dragonPresentInDragondex(_ dragonType: String) -> Bool {
        var dynamicPredicate: NSPredicate {
            var predicates : [NSPredicate] = []
            
            //search predicate
            predicates.append(NSPredicate(format: "type contains[c] %@", dragonType))
            
            //combine predicate and return
            return NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        }
        
        allDragondexEntries.nsPredicate = dynamicPredicate
        
        if allDragondexEntries.count > 0 { return true }
        else { return false }
    }
    
    func returnImageURL (for dragonType: String) -> URL {
        
        if dragonPresentInDragondex(dragonType) {
            return URL(string: "\(dragonType)/Basic/Basic_Baby/Basic_Baby_Black_White.png")!
        } else {
            return URL(string: "\(dragonType)/\(dragonType)Shadow.png")!
        }
    }
    
}



#Preview {
    NavigationStack {
        Dragondex().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
