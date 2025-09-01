//
//  AppTheme.swift
//  Tulpagotchi Revamp
//
//  Created by Angela Tarbett on 9/1/25.
//

// AppTheme.swift
import SwiftUI

enum AppTheme: String, CaseIterable, Identifiable {
    case system, light, dark
    var id: String { rawValue }
    
    var preferredColorScheme: ColorScheme? {
        switch self {
        case .system: return nil         // follow device
        case .light:  return .light
        case .dark:   return .dark
        }
    }
}
