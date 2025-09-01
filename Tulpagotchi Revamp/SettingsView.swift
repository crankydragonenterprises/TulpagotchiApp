//
//  SettingsView.swift
//  Tulpagotchi Revamp
//
//  Created by Angela Tarbett on 9/1/25.
//

// SettingsView.swift
import SwiftUI

struct SettingsView: View {
    @AppStorage("appTheme") private var storedTheme = AppTheme.system.rawValue
    
    var body: some View {
        let theme = AppTheme(rawValue: storedTheme) ?? .system
            Picker("Appearance", selection: Binding(
                get: { theme },
                set: { storedTheme = $0.rawValue }
            )) {
                Text("System").tag(AppTheme.system)
                Text("Light").tag(AppTheme.light)
                Text("Dark").tag(AppTheme.dark)
            }
            .pickerStyle(.segmented)
    }
}
