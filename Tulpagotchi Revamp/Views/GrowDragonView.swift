//
//  GrowDragonView.swift
//  Tulpagotchi Revamp
//
//  Created by Angela Tarbett on 8/15/25.
//

import SwiftUI

struct GrowDragonView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @EnvironmentObject private var dragon: Dragon
    
    var body: some View {
        if dragon.dragonAge == "Baby" || dragon.dragonAge == "Egg" {
            GrowBabyAndEggView()
                .environmentObject(dragon)
        } else if dragon.dragonAge == "Adult" {
            GrowAdultView(randomDragon: DragonStruct.returnCoreDataDragonFromDragonStruct(dragon: DragonStruct.returnRandomDragon(age: .Adult, highestType: DragonStruct.DragonType.Cthulhu, highestPattern: DragonStruct.DragonPattern.Mottled), in: PersistenceController.shared.container.viewContext))
        }
        else {
            Text(dragon.prettyName)
        }
            
    }
}

#Preview {
    NavigationStack {
        GrowDragonView()
            .environmentObject(PersistenceController.previewDragon)
    }
}
