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
    
    @State var userName: String = "Bruno"

    var body: some View {
        VStack {
            TextField("What's your name", text: $userName)
            
            NavigationView() {
                List {
                    ForEach(user) { user in
                        NavigationLink {
                            Text("\(user.id ?? "Unknown ID")")
                        } label: {
                            Text("\(user.id ?? "Unknown ID")")
                        }
                    }
                }
                
                //            .toolbar {
                //                ToolbarItem(placement: .navigationBarTrailing) {
                //                    EditButton()
                //                }
                //                ToolbarItem {
                //                    Button("Add Item", systemImage: "plus") {
                //                    }
                //                }
                //            }
            }
        }
    }
    
    func saveUser() {
        let newUser = User(context: viewContext)
        newUser.id = userName
        newUser.level = 1
        newUser.levelFloor = 0
        newUser.levelCeiling = 500
        newUser.currentLevel = 0
        newUser.dailyGoal = 200
        newUser.dailyProgress = 0
        newUser.coins = 0
        
        
        do {
            try viewContext.save()
        } catch {
            
        }
    }
}

#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
