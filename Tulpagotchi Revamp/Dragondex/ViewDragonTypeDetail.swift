//
//  Untitled.swift
//  Tulpagotchi
//
//  Created by Angela Tarbett on 8/10/25.
//

import SwiftUI


struct ViewDragonTypeDetail: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    
    let type: String
    
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
                VStack {
                    Text("\(type)")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    VStack {
                        ZStack {
                            Color(.white).opacity(0.5)
                                .padding()
                            VStack {
                                ForEach(DragonStruct.DragonPattern.allCases.dropLast()) { pattern in
                                    let percentageComplete = returnPercentageComplete(type: type, pattern: pattern.rawValue)
                                    let percentageString = String(format: "%.2f", percentageComplete)
                                    
                                    NavigationLink {
                                        ViewDragonPatternDetail(type: type, pattern: pattern.rawValue).environment(\.managedObjectContext, viewContext)
                                    } label: {
                                        HStack {
                                            VStack {
                                                AsyncImage(url: returnImageURL(forType: type, forPattern: pattern.rawValue)) { image in
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
                                            Text("\(pattern) \(type)s")
                                                .font(.title)
                                        }
                                        .padding(.horizontal)
                                        Spacer()
                                    }
                                    .buttonStyle(.plain)
                                }
                                Spacer()
                            }
                            .padding()
                        }
                        Footer()
                    }
                    
                }
                .frame(width: geo.size.width, height: geo.size.height)
            }
            .frame(width: geo.size.width, height: geo.size.height)
            //.navigationBarBackButtonHidden()
        }
    }
    
    func returnPercentageComplete(type dragonType: String, pattern dragonPattern: String) -> Double {
        let totalNumberOfDragonsPerColor: Double = Double(DragonStruct.SecondaryColor.allCases.dropLast().count * DragonStruct.MainColor.allCases.dropLast().count)
        var numberOfOwnedDragons: Double = 0
        
        var dynamicPredicate: NSPredicate {
            var predicates : [NSPredicate] = []
            
            //search predicate
            predicates.append(NSPredicate(format: "type contains[c] %@", dragonType))
            predicates.append(NSPredicate(format: "pattern contains[c] %@", dragonPattern))
            
            //combine predicate and return
            return NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        }
        
        filteredDragondexEntries.nsPredicate = dynamicPredicate
        
        numberOfOwnedDragons = Double(filteredDragondexEntries.count)
        
        return (numberOfOwnedDragons / totalNumberOfDragonsPerColor) * 100
    }
        
    func dragonPresentInDragondex(type dragonType: String, pattern dragonPattern: String) -> Bool {
        var dynamicPredicate: NSPredicate {
            var predicates : [NSPredicate] = []
            
            //search predicate
            predicates.append(NSPredicate(format: "type contains[c] %@", dragonType))
            predicates.append(NSPredicate(format: "pattern contains[c] %@", dragonPattern))
            
            //combine predicate and return
            return NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        }
        
        allDragondexEntries.nsPredicate = dynamicPredicate
        
        if allDragondexEntries.count > 0 { return true }
        else { return false }
    }
    
    func returnImageURL (
        forType dragonType: String,
        forPattern dragonPattern: String) -> URL
    {
        if dragonPresentInDragondex(type: dragonType, pattern: dragonPattern) {
            return URL(string: "\(Constants.imageBaseUrl)/images/tulpagotchi-images/\(dragonType)/\(dragonPattern)/\(dragonPattern)_Baby/\(dragonPattern)_Baby_Black_White.png") ?? URL(string:"\(Constants.imageBaseUrl)/images/egg.png")!
        } else {
            return URL(string: "\(Constants.imageBaseUrl)/images/tulpagotchi-images/\(dragonType)/\(dragonType)Shadow.png") ?? URL(string:"\(Constants.imageBaseUrl)/images/egg.png")!
        }
    }
}
    //
#Preview {
    NavigationStack {
        ViewDragonTypeDetail(type: "Dragon").environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}

