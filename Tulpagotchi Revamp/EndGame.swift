//
//  EndGameSheet.swift
//  Tulpagotchi
//
//  Created by Angela Tarbett on 8/12/25.
//

import SwiftUI

struct EndGame: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    let finalWordCount: Int
    let finalMinuteCount: Double
    
    var body: some View {
        ZStack {
            Color(.magenta).opacity(0.2)
                .ignoresSafeArea()
            VStack {
                Spacer()
                Text("Game Over")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding()
                Text("You wrote \(finalWordCount) words in \(String(format: "%.2f", finalMinuteCount)) minutes and earned 1 egg! Good job!")
                    .font(.title)
                    .padding()
                    .multilineTextAlignment(.center)
                Spacer()
                NavigationLink() {
                    Dashboard().environment(\.managedObjectContext, viewContext)
                } label : {
                    Text("Return to Dashboard")
                        .padding()
                        .background(.pink)
                        .foregroundStyle(.white)
                }
                .clipShape(.rect(cornerRadius: 25))
                .padding()
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    NavigationStack {
        EndGame(finalWordCount: 100, finalMinuteCount: 10).environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
