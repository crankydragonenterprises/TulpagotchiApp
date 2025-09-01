//
//  Tulpagotchi_RevampApp.swift
//  Tulpagotchi Revamp
//
//  Created by Angela Tarbett on 8/14/25.
//

import SwiftUI

@main
struct Tulpagotchi_RevampApp: App {
    let persistenceController = PersistenceController.shared
    @AppStorage("appTheme") private var storedTheme = AppTheme.system.rawValue

    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(AppTheme(rawValue: storedTheme)?.preferredColorScheme)
                .onChange(of: storedTheme, perform: {_ in applyUIKitOverride()})
                .onAppear { applyUIKitOverride() }
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(NetworkMonitor())
        }
    }
    private func applyUIKitOverride() {
        //#if os(iOS)
        guard let theme = AppTheme(rawValue: storedTheme) else { return }
        let style: UIUserInterfaceStyle = {
            switch theme {
            case .system: return .unspecified
            case .light:  return .light
            case .dark:   return .dark
            }
        }()
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap(\.windows)
            .forEach { $0.overrideUserInterfaceStyle = style }
        //#endif
    }
}
