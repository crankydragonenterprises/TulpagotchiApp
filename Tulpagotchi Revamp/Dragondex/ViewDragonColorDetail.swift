////
//  Untitled.swift
//  Tulpagotchi
//
//  Created by Angela Tarbett on 8/10/25.
//

import SwiftUI
import CoreData

struct ViewDragonColorDetail: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    
    let type: String
    let pattern: String
    let color: String
    
    //pull all the other dragons
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \DragondexEntry.id, ascending: true)])
    private var allDragondexEntries: FetchedResults<DragondexEntry>
    
//    //pull all the other dragons
//    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \User.id, ascending: true)])
//    private var users: FetchedResults<User>
    
    @State private var returnToDashboard = false
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                ImageView()
                VStack (alignment: .leading) {
                    Text("\(pattern) \(color) \(type)s")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding()
                    ZStack {
                        Color(.white).opacity(0.5)
                            .padding()
                        //list of dragons with clone button if they have gotten the dragon
                        ScrollView {
                            VStack {
                                ForEach(DragonStruct.SecondaryColor.allCases.dropLast()) { secondColor in
                                    
                                    
                                    HStack {
                                        //image
                                        let imageUrl: URL = returnImageURL(forType: type, forPattern: pattern, forColor: color, forSecondcolor: secondColor.rawValue)
                                        
                                        DragonImage(imageUrl: imageUrl)
                                        Spacer()
                                        //VStack {
                                            //Text("\(pattern) \(color) and \(secondColor) \(type)")
                                            
                                            DragondexCloningButton(
                                                secondColor: secondColor,
                                                type: type,
                                                pattern: pattern,
                                                color: color,
                                                showCloneButton: dragonPresentInDragondex(type: type, pattern: pattern, color: color, secondColor: secondColor.rawValue),
                                                string: "\(pattern) \(color) and \(secondColor) \(type)")
                                        //}
                                    }
                                    .padding()
                                    Spacer()
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
        
        allDragondexEntries.nsPredicate = dynamicPredicate
        
        if allDragondexEntries.count > 0 { return true }
        else { return false }
    }
    
    func returnImageURL (
        forType dragonType: String,
        forPattern dragonPattern: String,
        forColor dragonColor: String,
        forSecondcolor dragonSecondaryColor: String) -> URL
    {
        if dragonPresentInDragondex(type: dragonType, pattern: dragonPattern, color: dragonColor, secondColor: dragonSecondaryColor) {
            return URL(string: "\(Constants.imageBaseUrl)/images/tulpagotchi-images/\(dragonType)/\(dragonPattern)/\(dragonPattern)_Baby/\(dragonPattern)_Baby_\(dragonColor)_\(dragonSecondaryColor).png") ?? URL(string:"\(Constants.imageBaseUrl)/images/egg.png")!
        } else {
            return URL(string: "\(Constants.imageBaseUrl)/images/tulpagotchi-images/\(dragonType)/\(dragonType)Shadow.png") ?? URL(string:"\(Constants.imageBaseUrl)/images/egg.png")!
        }
    }
    
    
}




#Preview {
    NavigationStack {
        ViewDragonColorDetail(type: "Dragon", pattern: "Basic", color: "Green").environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}



struct ImageView: View {
    var body: some View {
        Image(.rainbow5)
            .resizable()
            .scaledToFill()
            .ignoresSafeArea()
            .opacity(0.5)
    }
}

struct DragonImage: View {
    let imageUrl: URL
    
    var body: some View {
        AsyncImage(url: imageUrl) { image in
            image
                .resizable()
                .scaledToFit()
                .frame(width: 150, height: 150)
                .shadow(color: .white, radius: 2)
        } placeholder: {
            ProgressView()
        }
    }
}


