//
//  DragonExt.swift
//  Tulpagotchi Revamp
//
//  Created by Angela Tarbett on 8/16/25.
//

import SwiftUICore
import UIKit
import CoreData

extension Dragon {
    var prettyName: String {
        return "\(dragonAge ?? "Unknown") \(dragonMain ?? "Unknown") and \(dragonSecond ?? "Unknown") \(dragonPattern ?? "Unknown") \(dragonType ?? "Unknown")"
    }
    
    var dragonImage: Image {
        if let data = dragonImageBinary, let image = UIImage(data: data) {
            Image (uiImage: image)
        }
        else {
            Image ("DefaultDragon")
        }
    }
    
    @MainActor
    func storeImageData(from url: URL, context: NSManagedObjectContext) async {
         
        do {
            //get the data from the url
            let imageData = try await URLSession.shared.data(from: url).0
            
            dragonImageBinary = imageData
            
            try context.save()
            print("Successfully saved dragon image data for \(prettyName)")
        } catch {
            print(error)
        }
    }
    
    
}
