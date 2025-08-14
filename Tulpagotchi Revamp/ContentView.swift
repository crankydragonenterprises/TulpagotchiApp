//
//  ContentView.swift
//  Tulpagotchi Revamp
//
//  Created by Angela Tarbett on 8/14/25.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \User.id, ascending: true)],
        animation: .default)
    private var user: FetchedResults<User>

    var body: some View {
        NavigationView {
            List {
                ForEach(user) { user in
                    NavigationLink {
                        Text("User name: \(user.id ?? "Unknown ID")")
                    } label: {
                        Text("User name: \(user.id ?? "Unknown ID")")
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem {
                    Button("Add Item", systemImage: "plus") {
                    }
                }
            }
            Text("Select an item")
        }
    }
}

#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
