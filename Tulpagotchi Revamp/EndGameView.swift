//
//  EndGameSheet.swift
//  Tulpagotchi
//
//  Created by Angela Tarbett on 8/12/25.
//

import SwiftUI

struct EndGameView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    let finalWordCount: Int
    let finalMinuteCount: Double
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                Image(.rainbow5)
                    .resizable()
                    .opacity(0.5)
                    .scaledToFill()
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
                        Dashboard()
                            .environment(\.managedObjectContext, viewContext)
                    } label : {
                        Text("Return to Dashboard")
                            .padding()
                            .background(.pink)
                            .foregroundStyle(.white)
                    }
                    .clipShape(.rect(cornerRadius: 25))
                    .padding()
                }
                .frame(width: geo.size.width, height: geo.size.height)
            }
            .frame(width: geo.size.width, height: geo.size.height)
            .navigationBarBackButtonHidden(true)
        }
    }
}

#Preview {
    NavigationStack {
        EndGameView(finalWordCount: 100, finalMinuteCount: 10).environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
