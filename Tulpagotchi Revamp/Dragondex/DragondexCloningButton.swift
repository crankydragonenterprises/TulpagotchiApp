//
//  DragondexCloningButton.swift
//  Tulpagotchi Revamp
//
//  Created by Angela Tarbett on 8/18/25.
//

import SwiftUI
import CoreData

struct DragondexCloningButton: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    
    //pull all the other dragons
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \User.id, ascending: true)])
    private var users: FetchedResults<User>
    
    let secondColor: DragonStruct.SecondaryColor
    let type: String
    let pattern: String
    let color: String
    let showCloneButton: Bool
    var string: String {
        "\(pattern) \(color) and \(secondColor) \(type)"
    }
    
    @State var returnToDashboard = false
    
    var body: some View {
        
        let ct = DragonStruct.DragonType(rawValue: type) ?? .Dragon
        let cp = DragonStruct.DragonPattern(rawValue: pattern) ?? .Basic
        let cc = DragonStruct.MainColor(rawValue: color) ?? .Black
        
        let cloningPrice = Utilities.returnCloningPrice(type: ct, pattern: cp, color: cc, secondColor: secondColor)
        
        VStack {
            let userHasEnoughCoins: Bool = users[0].coins >= cloningPrice
            let secondColorRaw: String = secondColor.rawValue
            
            //text & clone button contingent on dragondex entry
            Text(string)
            
            if showCloneButton {
                Button {
                    cloneDragon(cloningPrice: Int16(cloningPrice), secondaryColor: secondColorRaw)
                    returnToDashboard.toggle()
                } label: {
                    Text("Clone for\n\(cloningPrice) coins")
                        .multilineTextAlignment(.center)
                }
                .buttonStyle(.plain)
                .padding()
                .background(userHasEnoughCoins ? .yellow : .gray)
                .foregroundColor(.black) // simpler than foregroundStyle
                .clipShape(.rect(cornerRadius: 20))
                .disabled(!userHasEnoughCoins)
                .navigationDestination(isPresented: $returnToDashboard) {
                    Dashboard().environment(\.managedObjectContext, viewContext)
                }
            }
        }
    }
    
    func cloneDragon(cloningPrice: Int16, secondaryColor: String) {
        let d = Dragon(context: viewContext)
        d.id = Utilities.generateRandomGuid(length: 10)
        d.dragonType =  type
        d.dragonPattern = pattern
        d.dragonMain = color
        d.dragonSecond = secondaryColor
        d.dragonAge = "Egg"
        d.dragonImageLocation =  Utilities.returnImageLocation(dragon: d)
        d.dragonSellingPrice = Utilities.returnSellingPrice(dragon: d)
        d.dragonCloningPrice = cloningPrice
        
        if let user = users.first {
            user.coins -= Int64(cloningPrice)
        }
        
        do {
            try viewContext.save()
        } catch {
            print(error)
        }
    }
}

#Preview {
    NavigationStack {
        DragondexCloningButton(
            secondColor: DragonStruct.SecondaryColor.Black,
            type: "Dragon",
            pattern: "Basic",
            color: "Black",
            showCloneButton: true).environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
