//
//  DragonExt.swift
//  Tulpagotchi Revamp
//
//  Created by Angela Tarbett on 8/16/25.
//

extension Dragon {
    var prettyName: String {
        return "\(dragonAge ?? "Unknown") \(dragonMain ?? "Unknown") and \(dragonSecond ?? "Unknown") \(dragonPattern ?? "Unknown") \(dragonType ?? "Unknown")"
    }
}
