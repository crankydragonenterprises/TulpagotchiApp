//
//  GrowDragonView.swift
//  Tulpagotchi Revamp
//
//  Created by Angela Tarbett on 8/15/25.
//

import SwiftUI

struct GrowDragonView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Dragon.id, ascending: true)],
        animation: .default
    )
    private var dragons: FetchedResults<Dragon>
    
    private var dragon: Dragon {
        dragons[0]
    }
    
    var body: some View {
        AsyncImage(url: dragon.dragonImageLocation) { image in
            image
                .resizable()
                .scaledToFit()
        } placeholder : {
            ProgressView()
        }
    }
}

#Preview {
    GrowDragonView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
