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
                                            NavigationLink {
                                                ViewDragonTypeDetail(type: type.rawValue).environment(\.managedObjectContext, viewContext)
                                            } label: {
                                                HStack {
                                                    AsyncImage(url: returnImageURL(for: type.rawValue)) { image in
                                                        image
                                                            .resizable()
                                                            .scaledToFit()
                                                            .frame(width: 150, height: 150)
                                                            .shadow(color: .white, radius: 2)
                                                    } placeholder: {
                                                        ProgressView()
                                                    }
                                                    Spacer()
                                                    Text("\(type)")
                                                        .font(.title)
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
                        
                        Footer()
                        
                    }
                    .frame(width: geo.size.width, height: geo.size.height)
                }
                .frame(width: geo.size.width, height: geo.size.height)
                .navigationBarBackButtonHidden()
            }
        }
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
            return URL(string: "\(Constants.imageBaseUrl)/images/tulpagotchi-images/\(dragonType)/Basic/Basic_Baby/Basic_Baby_Black_White.png")!
        } else {
            return URL(string: "\(Constants.imageBaseUrl)/images/tulpagotchi-images/\(dragonType)/\(dragonType)Shadow.png")!
        }
    }
    
}



#Preview {
    NavigationStack {
        Dragondex().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
