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
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    ZStack {
                        Color(.white).opacity(0.5)
                            .padding()
                        ScrollView {
                            VStack {
                                ForEach(DragonStruct.MainColor.allCases.dropLast()) { color in
                                    NavigationLink {
                                        ViewDragonColorDetail(type: type, pattern: pattern, color: color.rawValue).environment(\.managedObjectContext, viewContext)
                                    } label: {
                                        HStack {
                                            AsyncImage(url: returnImageURL(forType: type, forPattern: pattern, forColor: color.rawValue)) { image in
                                                image
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(width: 150, height: 150)
                                                    .shadow(color: .white, radius: 2)
                                            } placeholder: {
                                                ProgressView()
                                            }
                                            Spacer()
                                            Text("\(color) \(pattern) \(type)s").font(.title)
                                        }
                                        .padding()
                                        Spacer()
                                    }
                                }
                            }
                            .padding()
                        }
                        .padding()
                    }
                    
                }
                .frame(width: geo.size.width, height: geo.size.height)
            }
            .frame(width: geo.size.width, height: geo.size.height)
            //.navigationBarBackButtonHidden()
        }
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
        
        allDragondexEntries.nsPredicate = dynamicPredicate
        
        if allDragondexEntries.count > 0 { return true }
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

