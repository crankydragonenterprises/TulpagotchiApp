////
//  Untitled.swift
//  Tulpagotchi
//
//  Created by Angela Tarbett on 8/10/25.
//

import SwiftUI


struct ViewDragonPatternDetail: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    
    let type: String
    let pattern: String
    
    //pull all the other dragons
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \DragondexEntry.id, ascending: true)])
    private var allDragondexEntries: FetchedResults<DragondexEntry>
    //pull all the other dragons
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \DragondexEntry.id, ascending: true)])
    private var filteredDragondexEntries: FetchedResults<DragondexEntry>
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                Image(.rainbow5)
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                    .opacity(0.5)
                VStack (alignment: .leading) {
                    Text("\(pattern) \(type)s")
                        .padding()
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    VStack {
                        ZStack {
                        Color(.white).opacity(0.5)
                            .padding()
                        
                            ScrollView {
                                VStack {
                                    ForEach(DragonStruct.MainColor.allCases.dropLast()) { color in
                                        let percentageComplete = returnPercentageComplete(type: type, pattern: pattern, color: color.rawValue)
                                        let percentageString = String(format: "%.2f", percentageComplete)
                                        
                                        NavigationLink {
                                            ViewDragonColorDetail(type: type, pattern: pattern, color: color.rawValue).environment(\.managedObjectContext, viewContext)
                                        } label: {
                                            HStack {
                                                VStack {
                                                    AsyncImage(url: returnImageURL(forType: type, forPattern: pattern, forColor: color.rawValue)) { image in
                                                        image
                                                            .resizable()
                                                            .scaledToFit()
                                                            .frame(width: 150, height: 150)
                                                            .shadow(color: .white, radius: 2)
                                                    } placeholder: {
                                                        ProgressView()
                                                    }
                                                    Text("\(percentageString) % Complete")
                                                }
                                                Spacer()
                                                Text("\(pattern) \(color) \(type)s").font(.title)
                                            }
                                            .padding(.horizontal)
                                            Spacer()
                                        }
                                    }
                                }
                                .padding()
                            }
                            .padding()
                        }
                        Footer()
                    }
                    
                }
                .frame(width: geo.size.width, height: geo.size.height)
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
    }
    
    func returnPercentageComplete(type dragonType: String, pattern dragonPattern: String, color dragonColor: String) -> Double {
        let totalNumberOfDragonsPerColor: Double = Double(DragonStruct.SecondaryColor.allCases.dropLast().count)
        var numberOfOwnedDragons: Double = 0
        
        var dynamicPredicate: NSPredicate {
            var predicates : [NSPredicate] = []
            
            //search predicate
            predicates.append(NSPredicate(format: "type contains[c] %@", dragonType))
            predicates.append(NSPredicate(format: "pattern contains[c] %@", dragonPattern))
            predicates.append(NSPredicate(format: "mainColor contains[c] %@", dragonColor))
            
            //combine predicate and return
            return NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        }
        
        filteredDragondexEntries.nsPredicate = dynamicPredicate
        
        numberOfOwnedDragons = Double(filteredDragondexEntries.count)
        
        return (numberOfOwnedDragons / totalNumberOfDragonsPerColor) * 100
    }
    
    func dragonPresentInDragondex(type dragonType: String, pattern dragonPattern: String, color dragonColor: String) -> Bool {
        var dynamicPredicate: NSPredicate {
            var predicates : [NSPredicate] = []
            
            //search predicate
            predicates.append(NSPredicate(format: "type contains[c] %@", dragonType))
            predicates.append(NSPredicate(format: "pattern contains[c] %@", dragonPattern))
            predicates.append(NSPredicate(format: "mainColor contains[c] %@", dragonColor))
            
            //combine predicate and return
            return NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        }
        
        filteredDragondexEntries.nsPredicate = dynamicPredicate
        
        if filteredDragondexEntries.count > 0 { return true }
        else { return false }
    }
    
    func returnImageURL (
        forType dragonType: String,
        forPattern dragonPattern: String,
        forColor dragonColor: String) -> URL
    {
        if dragonPresentInDragondex(type: dragonType, pattern: dragonPattern, color: dragonColor) {
            return URL(string: "\(Constants.imageBaseUrl)/images/tulpagotchi-images/\(dragonType)/\(dragonPattern)/\(dragonPattern)_Baby/\(dragonPattern)_Baby_\(dragonColor)_White.png") ?? URL(string:"\(Constants.imageBaseUrl)/images/egg.png")!
        } else {
            return URL(string: "\(Constants.imageBaseUrl)/images/tulpagotchi-images/\(dragonType)/\(dragonType)Shadow.png") ?? URL(string:"\(Constants.imageBaseUrl)/images/egg.png")!
        }
    }
}
//
#Preview {
    NavigationStack {
        ViewDragonPatternDetail(type: "Dragon", pattern: "Basic").environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}

