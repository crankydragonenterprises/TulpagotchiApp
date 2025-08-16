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
        sortDescriptors: [NSSortDescriptor(keyPath: \Project.id, ascending: true)],
        animation: .default)
    private var projects: FetchedResults<Project>
    
    
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
    
    //provide a way to cancel the game
    @State private var showCancelAlert = false
    @State private var goToDashboard = false
    
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
                    .background(.red)
                    .foregroundStyle(.white)
                    .clipShape(.capsule)
                    .alert("Cancel?",
                           isPresented: $showCancelAlert) {
                        Button("Yes, Cancel", role: .destructive) {
                            //return to the Dashboard
                            stopTimer()
                            goToDashboard = true
                        }
                        Button("No", role: .cancel) {
                            // Do nothing — alert dismisses
                        }
                    } message: {
                        Text("Are you sure you want to quit? Your progress will be lost.")
                    }
                    
                }
                .padding(.trailing)
                .navigationDestination(isPresented: $goToDashboard) {
                    Dashboard()
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
                //Progress Bar
                ProgressView(value: wordCountProgress)
                    .scaleEffect(y:6)
                    .tint(.green)
                    .padding()
                
                NavigationLink {
                    //end the game
                    EndGame(finalWordCount: wordCount, finalMinuteCount: timeElapsed)
                } label : {
                    Text(gameComplete ? "End your game" : "Keep Writing!")
                    
                }
                .padding()
                .background(gameComplete ? .green.opacity(1) : .gray.opacity(0.5))
                .foregroundStyle(.white)
                .disabled(!gameComplete)
                .clipShape(.capsule)
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
    let dragons: [Dragon] = [DragonStruct.returnCoreDataDragonFromDragonStruct(dragon:DragonStruct.returnRandomDragon(age: .Adult)), DragonStruct.returnCoreDataDragonFromDragonStruct(dragon:DragonStruct.returnRandomDragon(age: .Adult))]
    
    NavigationStack {
        WritingPage(dragons: dragons, wordCountGoal: 300).environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        
    }
}
