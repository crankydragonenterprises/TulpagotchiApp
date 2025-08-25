//
//  Utilities.swift
//  Tulpagotchi Revamp
//
//  Created by Angela Tarbett on 8/14/25.
//

import Foundation
import CoreData
import SwiftUICore
import SwiftUI

enum Utilities {
    //generate a guid
    static func generateRandomGuid(length: Int) -> String {
        let characters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        var randomString = ""
        for _ in 0..<length {
            if let randomCharacter = characters.randomElement() {
                randomString.append(randomCharacter)
            }
        }
        return randomString
    }
    
    static func generateRandomDragonStruct(age ofAge: DragonStruct.DragonAge) -> DragonStruct {
        
        var dragon = DragonStruct(
            dragonType: DragonStruct.DragonType.allCases.dropLast().randomElement() ?? DragonStruct.DragonType.Dragon,
            dragonPattern: DragonStruct.DragonPattern.allCases.dropLast().randomElement() ?? DragonStruct.DragonPattern.Basic,
            dragonMain: DragonStruct.MainColor.allCases.dropLast().randomElement() ?? DragonStruct.MainColor.Black,
            dragonSecond: DragonStruct.SecondaryColor.allCases.dropLast().randomElement() ?? DragonStruct.SecondaryColor.White,
            dragonAge: ofAge,
            dragonSellingPrice: 0,
            dragonImageLocation: URL(string:"https://www.google.com")!,
            id: generateRandomGuid(length: 10)
            )
        let imageURL = DragonStruct.returnImageLocation(dragon: dragon)
        dragon.dragonImageLocation = imageURL
        dragon.dragonSellingPrice = DragonStruct.returnSellingPrice(dragon: dragon)
        
            
        return dragon
        
    }
    
    //return the image location
    static func returnImageLocation(dragon: Dragon, owned: Bool = true) -> URL {
        let baseURL = "\(Constants.imageBaseUrl)/images/tulpagotchi-images/"
        var imageURL: String = ""
        
        if !owned {
            imageURL = baseURL + "tulpagotchi-images/\(dragon.dragonType ?? "Dragon")/\(dragon.dragonType ?? "Dragon")Shadow.png"
        } else if dragon.dragonAge == DragonStruct.DragonAge.Egg.rawValue {
            imageURL = "\(Constants.imageBaseUrl)/images/egg.png"
        } else {
            //Dragon/Basic/Basic_Baby/Basic_Baby_Black_Black.png
            imageURL = baseURL +  "\(dragon.dragonType ?? "Dragon")/\(dragon.dragonPattern ?? "Basic")/\(dragon.dragonPattern ?? "Basic")_\(dragon.dragonAge ?? "Baby")/\(dragon.dragonPattern ?? "Basic")_\(dragon.dragonAge ?? "Baby")_\(dragon.dragonMain ?? "Black")_\(dragon.dragonSecond ?? "Black").png"
        }
        return URL(string: imageURL)!
        
    }
    
    
     //return the price to clone a dragon
    static func returnCloningPrice(type: DragonStruct.DragonType, pattern: DragonStruct.DragonPattern, color: DragonStruct.MainColor, secondColor: DragonStruct.SecondaryColor) -> Int16 {
        var cloningPrice: Int16 = 0
     
     switch(type) {
     
     case .Dragon:
     cloningPrice += 200
     case .Gryphon:
     cloningPrice += 400
     case .Phoenix:
     cloningPrice += 600
     case .Kraken:
     cloningPrice += 800
     case .Cthulhu:
     cloningPrice += 1000
     case .All:
     cloningPrice += 0
     }
     switch(pattern) {
     
     case .Basic:
     cloningPrice += 50
     case .Striped:
     cloningPrice += 100
     case .Mottled:
     cloningPrice += 150
     case .All:
     cloningPrice += 0
     }
     switch(color) {
     
     case .Red:
     cloningPrice += 20
     case .Orange:
     cloningPrice += 40
     case .Yellow:
     cloningPrice += 60
     case .Green:
     cloningPrice += 80
     case .Cyan:
     cloningPrice += 100
     case .Blue:
     cloningPrice += 120
     case .Purple:
     cloningPrice += 140
     case .Pink:
     cloningPrice += 160
     case .Brown:
     cloningPrice += 180
     case .Black:
     cloningPrice += 200
     case .White:
     cloningPrice += 220
     case .Rainbow:
     cloningPrice += 240
     case .All:
     cloningPrice += 0
     }
     switch (secondColor) {
     
     case .Red:
     cloningPrice += 5
     case .Orange:
     cloningPrice += 10
     case .Yellow:
     cloningPrice += 15
     case .Green:
     cloningPrice += 20
     case .Cyan:
     cloningPrice += 25
     case .Blue:
     cloningPrice += 30
     case .Purple:
     cloningPrice += 35
     case .Pink:
     cloningPrice += 40
     case .Brown:
     cloningPrice += 45
     case .Black:
     cloningPrice += 50
     case .White:
     cloningPrice += 55
     case .All:
     cloningPrice += 0
     }
     
     return cloningPrice
     }
     
     //return the selling price based on the dragon's characteristics
    static func returnSellingPrice(dragon: Dragon) -> Int16 {
        var sellingPrice : Int16 = 0
    
        switch(dragon.dragonAge) {
        case "All":
        sellingPrice += 0
        case "Egg":
        sellingPrice += 0
        case "Baby":
        sellingPrice += 100
        case "Adult":
        sellingPrice += 200
        case .none:
            sellingPrice += 0
        case .some(_):
            sellingPrice += 0
        }
        
        switch(dragon.dragonType) {
        case "Dragon":
        sellingPrice += 50
        case "Gryphon":
        sellingPrice += 100
        case "Phoenix":
        sellingPrice += 150
        case "Kraken":
        sellingPrice += 200
        case "Cthulhu":
        sellingPrice += 250
        case "All":
        sellingPrice += 0
        case .none:
            sellingPrice += 0
        case .some(_):
            sellingPrice += 0
        }
        
        switch(dragon.dragonPattern)
        {
        
        case "Basic":
        sellingPrice += 25
        case "Striped":
        sellingPrice += 50
        case "Mottled":
        sellingPrice += 75
        case "All":
        sellingPrice += 0
        case .none:
            sellingPrice += 0
        case .some(_):
            sellingPrice += 0
        }
        
        switch(dragon.dragonMain)
        {
        
        case "Red":
        sellingPrice += 10
        case "Orange":
        sellingPrice += 11
        case "Yellow":
        sellingPrice += 12
        case "Green":
        sellingPrice += 13
        case "Cyan":
        sellingPrice += 14
        case "Blue":
        sellingPrice += 15
        case "Purple":
        sellingPrice += 16
        case "Pink":
        sellingPrice += 17
        case "Brown":
        sellingPrice += 18
        case "Black":
        sellingPrice += 19
        case "White":
        sellingPrice += 20
        case "Rainbow":
        sellingPrice += 21
        case "All":
        sellingPrice += 0
        case .none:
            sellingPrice += 0
        case .some(_):
            sellingPrice += 0
        }
        
        switch(dragon.dragonSecond)
        {
        
        case "Red":
        sellingPrice += 1
        case "Orange":
        sellingPrice += 2
        case "Yellow":
        sellingPrice += 3
        case "Green":
        sellingPrice += 4
        case "Cyan":
        sellingPrice += 5
        case "Blue":
        sellingPrice += 6
        case "Purple":
        sellingPrice += 7
        case "Pink":
        sellingPrice += 8
        case "Brown":
        sellingPrice += 9
        case "Black":
        sellingPrice += 10
        case "White":
        sellingPrice += 11
        case "All":
        sellingPrice += 0
        case .none:
            sellingPrice += 0
        case .some(_):
            sellingPrice += 0
        }
        
        return sellingPrice
    }
     
    enum CoreDataDeleteError: Error { case missingContext }
    
    static func sellDragon(dragonToSell: NSManagedObject) throws {
        print ("Selling dragon...")
        guard let ctx = dragonToSell.managedObjectContext else { throw CoreDataDeleteError.missingContext }
        try ctx.performAndWait {
            ctx.delete(dragonToSell)
            try ctx.save()
        }
        print("Sold dragon...")
    }
}
