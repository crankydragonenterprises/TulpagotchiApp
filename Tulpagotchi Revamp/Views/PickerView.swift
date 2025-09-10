//
//  PickerView.swift
//  Tulpagotchi Revamp
//
//  Created by Angela Tarbett on 8/23/25.
//

import SwiftUI
import CoreData

import SwiftUI
import CoreData

struct PickerView: View {
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Project.name, ascending: true)],
        animation: .default
    ) private var projects: FetchedResults<Project>
    
    // Store the chosen project's name directly
    @Binding var selectedProjectName: String
    
    var body: some View {
        VStack {
            Picker("Project", selection: $selectedProjectName) {
                //Text("Export all projects").tag("")   // empty means none
                
                ForEach(projects) { project in
                    let name = project.name?.isEmpty == false ? project.name! : "Untitled"
                    Text(name).tag(name)
                }
            }
            //.pickerStyle(.menu)
            
//            if !selectedProjectName.isEmpty {
//                Text("Selected: \(selectedProjectName)")
//                    .font(.footnote)
//                    .foregroundStyle(.secondary)
//            }
        }
        .onAppear {
            // Pick the first project name if nothing selected yet
            if selectedProjectName.isEmpty, let first = projects.first {
                selectedProjectName = first.name ?? "Untitled"
            }
        }
    }
}



#Preview {
    PickerView(selectedProjectName: .constant("Test Project"))
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
