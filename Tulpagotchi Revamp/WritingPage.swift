//
//  WritingPage.swift
//  Tulpagotchi
//
//  Created by Angela Tarbett on 8/11/25.
//

import SwiftUI
import Combine

struct WritingPage: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \User.id, ascending: true)],
        animation: .default) private var users: FetchedResults<User>
    
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \DragondexEntry.id, ascending: true)],
        animation: .default) private var allDragondexEntries: FetchedResults<DragondexEntry>
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \DragondexEntry.id, ascending: true)],
        animation: .default) private var filteredDragondexEntries: FetchedResults<DragondexEntry>
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Project.id, ascending: true)],
        animation: .default) private var projects: FetchedResults<Project>
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Entry.id, ascending: true)],
        animation: .default) private var entries: FetchedResults<Entry>
    
    
    @Environment(\.colorScheme) private var scheme   // <-- name it 'scheme' to avoid collisions
    
    
    let dragons: [Dragon]
    @State var projectTitle: String = "Project Name"
    @State var projectText: String = ""
    @State var selectedProject: Project? = nil
    
    //variable to track whether the user is typing
    @FocusState private var isProjectTitleFocused: Bool
    @FocusState private var isProjectTextFocused: Bool
    
    //keeping track of second typed
    @State var timeElapsed: Double = 0
    @State private var timer = Timer.publish(every: 1, on: .main, in: .common)
    @State private var timerConnection: Cancellable? = nil
    
    
    //keeping track of word count
    let wordCountGoal: Int
    @State var wordCount: Int = 0
    
    var wordCountProgress: CGFloat { return CGFloat(Double(wordCount) / Double(wordCountGoal)) }
    
    var gameComplete: Bool { return wordCount >= wordCountGoal }
    
    private var hasValidGoal: Bool { wordCountGoal > 0 }
    
    //provide a way to cancel the game
    @State private var showCancelAlert = false
    @State private var goToDashboard = false
    @State private var showEndGamePage = false
    
    //need a variable to track the number of eggs & coins the user has gained
    @State var eggsGained: Int = 0
    @State var coinsGained: Int = 0
    
    var body: some View {
        ZStack {
            Image(.rainbow4)
                .resizable()
                .scaledToFill()
                .opacity(0.6)
                .ignoresSafeArea()
            VStack {
                HStack {
                    Spacer()
                    Button("Cancel") {
                        showCancelAlert = true
                    }
                    .padding()
                    .background(.gray)
                    .foregroundStyle(.white)
                    .clipShape(.capsule)
                    .alert("Cancel?",
                           isPresented: $showCancelAlert) {
                        Button("Yes, Cancel", role: .destructive) {
                            //return to the Dashboard
                            stopTimer()
                            goToDashboard = true
                        }
                        Button("No", role: .cancel) {}
                    } message: {
                        Text("Are you sure you want to quit? Your progress will be lost.")
                    }
                    
                }
                .padding(.trailing)
                .navigationDestination(isPresented: $goToDashboard) {
                    Dashboard().environment(\.managedObjectContext, viewContext)
                }
                
                HStack {
                    //dragon images
                    ForEach (dragons) {dragon in
                        let isFirst = dragons.first?.id == dragon.id
                        let xScale: CGFloat = isFirst ? -1 : 1
                        
                        AsyncImage (url: dragon.dragonImageLocation) { image in
                            image
                                .resizable()
                                .scaledToFit()
                                .scaleEffect(x: xScale)
                        } placeholder: {
                            ProgressView()
                        }
                    }
                }
                .padding()
                .frame(height: isProjectTextFocused || isProjectTitleFocused ? 100 : 200)
                
                
                //Text Area for the Project
                ZStack {
                    Menu {
                        ForEach(projects) {project in
                            Button {
                                //replace the project title
                                projectTitle = project.name ?? ""
                            } label : {
                                Text(project.name ?? "")
                            }
                        }
                    } label: {
                        Spacer()
                        Text("Project Name    ˅")
                            .padding(15)
                            .background(scheme == .dark ? .black : .white)
                        
                    }
                    .padding()
                    
                    TextEditor(text: $projectTitle)
                        .frame(height: 50)
                        .padding(.trailing, 40)
                        .padding(.leading)
                        .opacity(1.0)
                        .frame(height: 50)
                        .multilineTextAlignment(.center)
                        .focused($isProjectTitleFocused)
                }
                
                
                //Text Area for Writing
                CustomTextEditor(text: $projectText)
                    .padding()
                    .onChange(of: projectText) {
                        wordCount = wordCount(in: projectText)
                    }
                    .focused($isProjectTextFocused)
                
                Spacer()
                if hasValidGoal {
                    ProgressView(
                        value: Double(wordCount),
                        total: Double(wordCountGoal)
                    )
                    .scaleEffect(y:6)
                    .tint(.green)
                    .padding()
                } else {
                    // Goal not ready yet? Show indeterminate until it is.
                    ProgressView()
                }
                Button {
                    eggsGained = returnNumberOfEggs()
                    coinsGained = returnCoinsEarned()
                    showEndGamePage = true
                    endGame()
                } label: {
                    Text(gameComplete ? "End your game" : "Keep Writing!")
                }
                .padding()
                .background(gameComplete ? .green.opacity(1) : .gray.opacity(0.5))
                .foregroundStyle(.white)
                .disabled(!gameComplete)
                .clipShape(.capsule)
                .navigationTitle("")
                .navigationDestination (isPresented: $showEndGamePage) {
                    EndGameView(finalWordCount: wordCount, finalMinuteCount: timeElapsed, numberOfEggs: eggsGained, numberOfCoins: coinsGained)
                        .environment(\.managedObjectContext, viewContext)
                }
            }
            .padding()
        }
        .onTapGesture {
            isProjectTextFocused = false
            isProjectTitleFocused = false
        }
        .navigationBarBackButtonHidden(true)
        .onReceive(timer, perform: { _ in
            timeElapsed += 1/60
        })
        .onAppear() {
            startTimer()
        }
        .onDisappear { stopTimer() }
        
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
        
        filteredDragondexEntries.nsPredicate = dynamicPredicate
        
        if filteredDragondexEntries.count > 0 { return true }
        else { return false }
    }
    
    func returnNumberOfEggs() -> Int {
        var numberOfEggs: Int
        if dragons[0].dragonAge == "Adult" { numberOfEggs = 1}
        else if dragons[0].dragonAge == "Baby" { numberOfEggs = 0 }
        else if dragons[0].dragonAge == "Egg" { numberOfEggs = 0 }
        else { numberOfEggs = 0 }
        
        //print(dragons[0].prettyName)
        //print(numberOfEggs)
        
        return numberOfEggs
    }
    
    func returnCoinsEarned() -> Int {
        var coinsEarned: Int
        
        coinsEarned = wordCount / 10
        
        return coinsEarned
    }
    
    func endGame() {
        var hasValidProject = false
        var projectToSave: Project?
        var projectID: Int16?
        
        //Check if a project exists with the projectTitle
        for project in projects
        {
            if project.name == self.projectTitle {
                hasValidProject = true
                projectToSave = project
                projectID = project.id
            }
        }
        
        //if so, update the project
        if hasValidProject {
            projectToSave?.totalWords += Int64(wordCount)
        }
        else
        {
            //if not, make a new project
            projectToSave = Project(context: viewContext)
            projectToSave?.id = Int16(projects.count + 1)
            projectToSave?.name = projectTitle
            projectToSave?.totalWords = Int64(wordCount)
            
            projectID = Int16(projects.count + 1)
        }
        
        //Save the text in an entry
        let entry = Entry(context: viewContext)
        entry.text = projectText
        entry.id = Int64(entries.count + 1)
        entry.projectID = projectID ?? 1
        
        //Update the user in the level progress and check for level upgrades
        let user = users[0]
        user.coins += Int64(coinsGained)
        user.currentLevel += Int64(wordCount)
        user.dailyProgress += Int64(wordCount)
        
        // check if the current level is above the level ceiling
        if user.currentLevel >= user.levelCeiling {
            user.level += 1
            user.levelFloor = user.levelCeiling
            user.levelCeiling = Int64(getNewLevelCeiling(level: Int(user.level)))
            
            //check for achievements
            if user.level > 4 {
                user.highestPatternAllowed = "Striped"
            }
            if user.level > 9 {
                user.highestPatternAllowed = "Mottled"
            }
            if user.level > 14 {
                user.highestTypeAllowed = "Gryphon"
            }
            if user.level > 24 {
                user.highestTypeAllowed = "Phoenix"
            }
            if user.level > 34 {
                user.highestTypeAllowed = "Kraken"
            }
            if user.level > 44 {
                user.highestTypeAllowed = "Cthulhu"
            }
        }
        
        let dragon = dragons[0]
        //TO DO - if the dragon is an adult, add an egg to the dragons
        if dragon.dragonAge == "Adult" {
            //create a new dragon of age baby with mixed characteristics
            let motherDragon = dragons[0]
            let fatherDragon = dragons[1]
            
            //make a new egg
            let newDragon = Dragon(context: viewContext)
            newDragon.id = Utilities.generateRandomGuid(length: 10)
            newDragon.dragonAge = "Egg"
            
            //mix the mother and father characteristics
            var randomNumber = Int.random(in: 0...1)
            var babysType: String
            if randomNumber == 0 {
                babysType = motherDragon.dragonType ?? "Dragon"
            } else { babysType = fatherDragon.dragonType ?? "Dragon" }
            newDragon.dragonType = babysType
            
            randomNumber = Int.random(in: 0...1)
            var babysPattern: String
            if randomNumber == 0 {
                babysPattern = motherDragon.dragonPattern ?? "Basic"
            } else { babysPattern = fatherDragon.dragonPattern ?? "Basic" }
            newDragon.dragonPattern = babysPattern
            
            randomNumber = Int.random(in: 0...1)
            var babysMain: String
            if randomNumber == 0 {
                babysMain = motherDragon.dragonMain ?? "Black"
            } else { babysMain = fatherDragon.dragonMain ?? "Black" }
            newDragon.dragonMain = babysMain
            
            randomNumber = Int.random(in: 0...1)
            var babysSecondary: String
            if randomNumber == 0 {
                babysSecondary = motherDragon.dragonSecond ?? "Black"
            } else { babysSecondary = fatherDragon.dragonSecond ?? "Black" }
            newDragon.dragonSecond = babysSecondary
            
            //selling and cloning prices
            newDragon.dragonSellingPrice = Utilities.returnSellingPrice(dragon: newDragon)
            
            let newDragonStruct = DragonStruct.returnDragonStructFromCoreDataDragon(coreDataDragon: newDragon)
            newDragon.dragonCloningPrice = Utilities.returnCloningPrice(type: newDragonStruct.dragonType, pattern: newDragonStruct.dragonPattern, color: newDragonStruct.dragonMain, secondColor: newDragonStruct.dragonSecond)
            
            newDragon.dragonImageLocation = Utilities.returnImageLocation(dragon: newDragon)
            
            //check if the new dragon is in the dragondex; add it if not
            if !dragonPresentInDragondex(type: newDragon.dragonType!, pattern: newDragon.dragonPattern!, color: newDragon.dragonMain!, secondColor: newDragon.dragonSecond!) {
                
                //print("dragondex Count: \(allDragondexEntries.count)")
                
                let newDragondexEntry = DragondexEntry(context: viewContext)
                newDragondexEntry.id = Int16(allDragondexEntries.count + 1)
                newDragondexEntry.type = newDragon.dragonType!
                newDragondexEntry.pattern = newDragon.dragonPattern!
                newDragondexEntry.mainColor = newDragon.dragonMain!
                newDragondexEntry.secondColor = newDragon.dragonSecond!
                
                print("\(newDragondexEntry)")
            }
        }
        
        //if the dragon is a baby, update it to be an adult
        if dragon.dragonAge == "Baby" {
            dragon.dragonAge = "Adult"
            dragon.dragonImageLocation = Utilities.returnImageLocation(dragon: dragon)
            dragon.dragonSellingPrice = Utilities.returnSellingPrice(dragon: dragon)
        }
        
        //if the dragon is an egg, update it to be a baby
        if dragon.dragonAge == "Egg" {
            dragon.dragonAge = "Baby"
            dragon.dragonImageLocation = Utilities.returnImageLocation(dragon: dragon)
            dragon.dragonSellingPrice = Utilities.returnSellingPrice(dragon: dragon)
        }
        
        do {
            try viewContext.save()
            print("Save successful!")
        } catch {
            print(error)
        }
    }
    
    func getNewLevelCeiling(level: Int) -> Int{
        let constant = 1000
        
        var newLevelCeiling: Float {
            Float(level * constant) * Float(level).squareRoot()
        }
        
        return Int(newLevelCeiling)
    }
    
    func wordCount(in text: String) -> Int {
        let words = text.split { $0.isWhitespace || $0.isNewline }
        return words.count
    }
    
    func startTimer() {
        if timerConnection == nil {
            // Connect once; keep the connection for reuse
            timerConnection = timer.connect()
        }
    }
    
    func stopTimer() {
        timerConnection?.cancel()
        timerConnection = nil
    }
}

#Preview {
    let dragons: [Dragon] = [DragonStruct.returnCoreDataDragonFromDragonStruct(dragon:DragonStruct.returnRandomDragon(age: .Adult, highestType: .Cthulhu, highestPattern: .Mottled), in: PersistenceController.shared.container.viewContext), DragonStruct.returnCoreDataDragonFromDragonStruct(dragon:DragonStruct.returnRandomDragon(age: .Adult, highestType: .Cthulhu, highestPattern: .Mottled), in: PersistenceController.shared.container.viewContext)
    ]
    
    NavigationStack {
        WritingPage(dragons: dragons, wordCountGoal: 10).environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        
    }
}
