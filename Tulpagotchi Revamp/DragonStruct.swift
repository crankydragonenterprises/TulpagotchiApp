//
//  DragonStruct.swift
//  Tulpagotchi
//
//  Created by Angela Tarbett on 8/2/25.
//

import SwiftUI
import Foundation
import CoreData

struct DragonStruct : Identifiable, Codable {
    var id: String?
    let dragonType: DragonType
    let dragonPattern: DragonPattern
    var dragonMain: MainColor
    let dragonSecond: SecondaryColor
    var dragonAge: DragonAge
    var dragonSellingPrice: Int = 0
    var dragonImageLocation: URL?
    
    //initialize the dragon
    init(dragonType: DragonType, dragonPattern: DragonPattern, dragonMain: MainColor, dragonSecond: SecondaryColor, dragonAge: DragonAge, dragonSellingPrice: Int, dragonImageLocation: URL, id: String) {
        self.dragonType = dragonType
        self.dragonPattern = dragonPattern
        self.dragonMain = dragonMain
        self.dragonSecond = dragonSecond
        self.dragonAge = dragonAge
        self.dragonSellingPrice = dragonSellingPrice
        self.dragonImageLocation = dragonImageLocation
        self.id = id
    }
    
    //enums
    enum DragonType: String, CaseIterable, Codable, Identifiable {
        var id: Self { self }
        case Dragon
        case Gryphon
        case Phoenix
        case Kraken
        case Cthulhu
        case All
    }
    enum DragonPattern: String, CaseIterable, Codable, Identifiable {
        var id: Self { self }
        case Basic
        case Striped
        case Mottled
        case All
    }
    enum MainColor: String, CaseIterable, Codable, Identifiable {
        var id: Self { self }
        case Red
        case Orange
        case Yellow
        case Green
        case Cyan
        case Blue
        case Purple
        case Pink
        case Brown
        case Black
        case White
        case Rainbow
        case All
    }
    enum SecondaryColor: String, CaseIterable, Codable, Identifiable {
        var id: Self { self }
        case Red
        case Orange
        case Yellow
        case Green
        case Cyan
        case Blue
        case Purple
        case Pink
        case Brown
        case Black
        case White
        case All
    }
    enum DragonAge: String, CaseIterable, Codable, Identifiable {
        var id: Self { self }
        case Egg
        case Baby
        case Adult
        case All
    }
    
    //return the image location
    static func returnImageLocation(dragon: DragonStruct, owned: Bool = true) -> URL {
        let baseURL = "\(Constants.imageBaseUrl)/images/tulpagotchi-images/"
        var imageURL: String = ""
        
        if !owned {
            imageURL = baseURL + "tulpagotchi-images/\(dragon.dragonType)/\(dragon.dragonType)Shadow.png"
        } else if dragon.dragonAge == DragonStruct.DragonAge.Egg {
            imageURL = "https://tulpagotchi-images.s3.us-east-1.amazonaws.com/images/egg.png"
        } else {
            imageURL = baseURL +  "\(dragon.dragonType)/\(dragon.dragonPattern)/\(dragon.dragonPattern)_\(dragon.dragonAge)/\(dragon.dragonPattern)_\(dragon.dragonAge)_\(dragon.dragonMain)_\(dragon.dragonSecond).png"
        }
        return URL(string: imageURL)!
        
    }
    
    static func returnDragonStructFromCoreDataDragon(coreDataDragon: Dragon) -> DragonStruct
    {
        var dragon = DragonStruct(
            dragonType: DragonStruct.DragonType(rawValue: coreDataDragon.dragonType!) ?? .Dragon,
            dragonPattern: DragonStruct.DragonPattern(rawValue: coreDataDragon.dragonPattern!) ?? .Basic,
            dragonMain: DragonStruct.MainColor(rawValue: coreDataDragon.dragonMain!) ?? .White,
            dragonSecond: DragonStruct.SecondaryColor(rawValue: coreDataDragon.dragonSecond!) ?? .White,
            dragonAge: DragonStruct.DragonAge(rawValue: coreDataDragon.dragonAge!) ?? .Adult,
            dragonSellingPrice: 0,
            dragonImageLocation: URL(string: "https://www.google.com/images")!,
            id: Utilities.generateRandomGuid(length: 10),
        )
        
        let imageURL = returnImageLocation(dragon: dragon)
        dragon.dragonImageLocation = imageURL
        dragon.dragonSellingPrice = returnSellingPrice(dragon: dragon)
        
        return dragon
    }
    
    static func returnCoreDataDragonFromDragonStruct(dragon: DragonStruct, in context: NSManagedObjectContext) -> Dragon
    {
        let entity = NSEntityDescription.entity(forEntityName: "Dragon", in: context)!
        let coreDataDragon = Dragon(entity: entity, insertInto: nil)
        
//        let coreDataDragon = Dragon(
//            context: PersistenceController.shared.container.viewContext
//        )
        coreDataDragon.id = dragon.id
        coreDataDragon.dragonType =  dragon.dragonType.rawValue
        coreDataDragon.dragonPattern = dragon.dragonPattern.rawValue
        coreDataDragon.dragonMain = dragon.dragonMain.rawValue
        coreDataDragon.dragonSecond = dragon.dragonSecond.rawValue
        coreDataDragon.dragonAge = dragon.dragonAge.rawValue
        coreDataDragon.dragonImageLocation =  Utilities.returnImageLocation(dragon: coreDataDragon)
        coreDataDragon.dragonSellingPrice = Utilities.returnSellingPrice(dragon: coreDataDragon)
        coreDataDragon.dragonCloningPrice = Utilities.returnCloningPrice(type: DragonStruct.DragonType(rawValue: coreDataDragon.dragonType!) ?? DragonStruct.DragonType.Dragon, pattern: DragonStruct.DragonPattern(rawValue: coreDataDragon.dragonPattern!) ?? DragonStruct.DragonPattern.Basic, color: DragonStruct.MainColor(rawValue: coreDataDragon.dragonMain!) ?? DragonStruct.MainColor.Black, secondColor: DragonStruct.SecondaryColor(rawValue: coreDataDragon.dragonSecond!) ?? DragonStruct.SecondaryColor.Black)
        
        return coreDataDragon
    }
    
    //return the price to clone a dragon
    static func returnCloningPrice(type: DragonType, pattern: DragonPattern, color: MainColor, secondColor: SecondaryColor) -> Int {
        var cloningPrice = 0
        
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
    static func returnSellingPrice(dragon: DragonStruct) -> Int {
        var sellingPrice = 0
        
        switch(dragon.dragonAge) {
            case .All:
                sellingPrice += 0
            case .Egg:
                sellingPrice += 0
            case .Baby:
                sellingPrice += 100
            case .Adult:
                sellingPrice += 200
        }
        
        switch(dragon.dragonType) {
            case .Dragon:
                sellingPrice += 50
            case .Gryphon:
                sellingPrice += 100
            case .Phoenix:
                sellingPrice += 150
            case .Kraken:
                sellingPrice += 200
            case .Cthulhu:
                sellingPrice += 250
            case .All:
                sellingPrice += 0
        }
        
        switch(dragon.dragonPattern)
        {
            
        case .Basic:
            sellingPrice += 25
        case .Striped:
            sellingPrice += 50
        case .Mottled:
            sellingPrice += 75
        case .All:
            sellingPrice += 0
        }
        
        switch(dragon.dragonMain)
        {
            
        case .Red:
            sellingPrice += 10
        case .Orange:
            sellingPrice += 11
        case .Yellow:
            sellingPrice += 12
        case .Green:
            sellingPrice += 13
        case .Cyan:
            sellingPrice += 14
        case .Blue:
            sellingPrice += 15
        case .Purple:
            sellingPrice += 16
        case .Pink:
            sellingPrice += 17
        case .Brown:
            sellingPrice += 18
        case .Black:
            sellingPrice += 19
        case .White:
            sellingPrice += 20
        case .Rainbow:
            sellingPrice += 21
        case .All:
            sellingPrice += 0
        }
        
        switch(dragon.dragonSecond)
        {
            
        case .Red:
            sellingPrice += 1
        case .Orange:
            sellingPrice += 2
        case .Yellow:
            sellingPrice += 3
        case .Green:
            sellingPrice += 4
        case .Cyan:
            sellingPrice += 5
        case .Blue:
            sellingPrice += 6
        case .Purple:
            sellingPrice += 7
        case .Pink:
            sellingPrice += 8
        case .Brown:
            sellingPrice += 9
        case .Black:
            sellingPrice += 10
        case .White:
            sellingPrice += 11
        case .All:
            sellingPrice += 0
        }
        
        return sellingPrice
    }
    
    static func returnRandomDragon(age ofAge: DragonAge) -> DragonStruct
    {
        var dragon = DragonStruct(
            dragonType: DragonType.allCases.dropLast().randomElement() ?? DragonType.Dragon,
            dragonPattern: DragonPattern.allCases.dropLast().randomElement() ?? DragonPattern.Basic,
            dragonMain: MainColor.allCases.dropLast().randomElement() ?? MainColor.Black,
            dragonSecond: SecondaryColor.allCases.dropLast().randomElement() ?? SecondaryColor.White,
            dragonAge: ofAge,
            dragonSellingPrice: 0,
            dragonImageLocation: URL(string:"https://www.google.com")!,
            id: Utilities.generateRandomGuid(length: 10)
        )
        let imageURL = returnImageLocation(dragon: dragon)
        dragon.dragonImageLocation = imageURL
        dragon.dragonSellingPrice = returnSellingPrice(dragon: dragon)
        
        return dragon
    }
}

extension DragonStruct : CustomStringConvertible {
    public var description: String {
        return "\(dragonMain) and \(dragonSecond) \(dragonPattern) \(dragonType)"
    }
}
