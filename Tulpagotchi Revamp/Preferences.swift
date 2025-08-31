//
//  Preferences.swift
//  Tulpagotchi
//
//  Created by Angela Tarbett on 8/11/25.
//

import SwiftUI
import CoreData
import UniformTypeIdentifiers

struct Preferences: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    
    @Environment(\.colorScheme) private var scheme
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \User.id, ascending: true)],
        animation: .default) private var users: FetchedResults<User>
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Project.id, ascending: true)],
        animation: .default) private var projects: FetchedResults<Project>
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Entry.id, ascending: true)],
        animation: .default) private var entries: FetchedResults<Entry>
    
    @State var preferredGoal : String = ""
    @State var showSuccessAlert: Bool = false
    @State var showErrorAlert: Bool = false
    @State var selectedProjectTitle: String = "Pick a project to export"
    @State private var selectedProjectID: NSManagedObjectID?
    @State var compiledProjectText: String = ""
    @State var showShareSheet: Bool = false
    @State private var exportURL: URL?
    @State private var activityItems: [Any] = []
    
    private var selectedProject : Project? {
        guard let projectID = selectedProjectID else { return nil }
        return (try? (viewContext.existingObject(with: projectID) as! Project))
    }
    
    private var PreferencesSection : some View {
        VStack {
            HStack {
                Text("Daily Goal")
                    .padding()
                Spacer()
                TextField("Words to write each day", text: $preferredGoal)
                    .keyboardType(.numberPad)
                    .padding()
                    .background(scheme == .dark ? .black : .white)
            }
            
            HStack {
                Spacer()
                Button {
                    savePreferences()
                } label : {
                    Text("Save")
                        .frame(width: 100)
                        .padding()
                        .background(.blue)
                        .foregroundStyle(.white)
                        .clipShape(.capsule)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal)
    }
    
    var body: some View {
        GeometryReader {geo in
            ZStack {
                Image(.rainbow6)
                    .resizable()
                    .scaledToFill()
                    .opacity(0.6)
                    .ignoresSafeArea()
                VStack {
                    Text("Preferences")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    Spacer()
                    PreferencesSection
                    
                    Spacer()
                    HStack {
                        Spacer()
                        
                        Menu {
                            PickerView(selectedProjectName: $selectedProjectTitle)
                        } label : {
                            Text(selectedProjectTitle)
                                .frame(width: 200)
                                .padding()
                                .background(.gray.opacity(0.2))
                                .foregroundColor(.white)
                                .clipShape(.capsule)
                        }
                        .buttonStyle(.plain)
                        .onAppear() {
                            if selectedProjectID == nil, let first = projects.first {
                                selectedProjectID = first.objectID
                            }
                        }
                        
                        Button {
                            print("exporting from project: \(selectedProjectTitle)")
                            compiledProjectText = getProjectEntries(for: selectedProjectTitle, in: viewContext)
                            print("Compiled texts: \(compiledProjectText)")
                            
                            
                            //TO DO - export the project data
//                            exportText(compiledProjectText, as: "\(selectedProjectTitle).txt")
                            
                        } label: {
                            ExportView(fileName: "\(selectedProjectTitle).txt", fileText: compiledProjectText)
//                            Text("Export Data")
                        }
                        .buttonStyle(.plain)
                        .frame(width: 100)
                        .padding()
                        .background( selectedProjectTitle == "Pick a project to export" ? .gray : .blue )
                        .foregroundColor(.white)
                        .clipShape(.capsule)
                        .disabled(selectedProjectTitle == "Pick a project to export")
                    }
                    .padding(.horizontal)
                    Footer()
                }
                .frame(width: geo.size.width, height: geo.size.height)
            }
            .frame(width: geo.size.width, height: geo.size.height)
            .navigationBarBackButtonHidden(true)
            .alert("Preferences saved!", isPresented: $showSuccessAlert) {
                Button("OK", role: .cancel) {}
            }
            .alert("Error saving preferences", isPresented: $showErrorAlert) {
                Button("OK", role: .cancel) {}
            }
        }
    }

    func getProjectEntries(for projectName: String, in context: NSManagedObjectContext) -> String {
        
        // Fetch the first matching project
        let projectReq: NSFetchRequest<Project> = Project.fetchRequest()
        projectReq.predicate = NSPredicate(format: "name == %@", projectName)
        projectReq.fetchLimit = 1
        
        guard let project = try? context.fetch(projectReq).first else {
            return ""
        }
        
        let projectId = project.id  // Int16
        
        let entryReq: NSFetchRequest<Entry> = Entry.fetchRequest()
        entryReq.predicate = NSPredicate(format: "projectID == %@", NSNumber(value: projectId))
        entryReq.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]

        let entries = (try? context.fetch(entryReq)) ?? []
        
        return entries.map { $0.text ?? "Unknown text" }
            .joined(separator: "\n")
    }
    
    func savePreferences() {
        print("preferred goal: \(preferredGoal)")
        
        //try to make the preferredGoal an integer
        guard let dailyGoalInt = Int(preferredGoal) else {
            showErrorAlert.toggle()
            print("Could not convert preferredGoal to Int")
            return
        }
        
        //save it to the user's dailyGoal property
        users.first?.dailyGoal = Int64(dailyGoalInt)
        
        do {
            try viewContext.save()
            showSuccessAlert.toggle()
            print("Save preferences")
        }
        catch {
            print("Error saving user preferences: \(error)")
            showErrorAlert.toggle()
        }
    }
}

#Preview {
    NavigationStack {
        Preferences().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
