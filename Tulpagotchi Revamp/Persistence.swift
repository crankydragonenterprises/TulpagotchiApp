//
//  Persistence.swift
//  Tulpagotchi Revamp
//
//  Created by Angela Tarbett on 8/14/25.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    static var previewBabyDragon: Dragon {
        let context = PersistenceController.preview.container.viewContext
        
        let fetchRequest: NSFetchRequest<Dragon> = Dragon.fetchRequest()
        fetchRequest.fetchLimit = 1
        
        let results = try! context.fetch(fetchRequest)
        
        return results.first!
    }
    
    static let preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        
        let newUser = User(context: viewContext)
        newUser.id = "Test User"
        newUser.level = 1
        newUser.levelFloor = 0
        newUser.levelCeiling = 100
        newUser.currentLevel = 37
        newUser.dailyGoal = 200
        newUser.dailyProgress = 50
        newUser.coins = 75
        newUser.highestTypeAllowed = "Dragon"
        newUser.highestPatternAllowed = "Mottled"
        
        let newDragon1 = Dragon(context: viewContext)
        newDragon1.id = Utilities.generateRandomGuid(length: 10)
        newDragon1.dragonType =  DragonStruct.DragonType.Dragon.rawValue
        newDragon1.dragonPattern = DragonStruct.DragonPattern.Basic.rawValue
        newDragon1.dragonAge = DragonStruct.DragonAge.Adult.rawValue
        newDragon1.dragonMain = DragonStruct.MainColor.Green.rawValue
        newDragon1.dragonSecond = DragonStruct.SecondaryColor.Green.rawValue
        newDragon1.dragonImageLocation =  Utilities.returnImageLocation(dragon: newDragon1)
        newDragon1.dragonSellingPrice = Utilities.returnSellingPrice(dragon: newDragon1)
        newDragon1.dragonCloningPrice = Utilities.returnCloningPrice(
            type: DragonStruct.DragonType(rawValue: newDragon1.dragonType!) ?? DragonStruct.DragonType.Dragon,
            pattern: DragonStruct.DragonPattern(rawValue: newDragon1.dragonPattern!) ?? DragonStruct.DragonPattern.Basic,
            color: DragonStruct.MainColor(rawValue: newDragon1.dragonMain!) ?? DragonStruct.MainColor.Black,
            secondColor: DragonStruct.SecondaryColor(rawValue: newDragon1.dragonSecond!) ?? DragonStruct.SecondaryColor.Black)
        
        
        let newDragon2 = Dragon(context: viewContext)
        newDragon2.id = Utilities.generateRandomGuid(length: 10)
        newDragon2.dragonType =  DragonStruct.DragonType.Dragon.rawValue
        newDragon2.dragonPattern = DragonStruct.DragonPattern.Basic.rawValue
        newDragon2.dragonMain = DragonStruct.MainColor.Brown.rawValue
        newDragon2.dragonSecond = DragonStruct.SecondaryColor.Brown.rawValue
        newDragon2.dragonAge = DragonStruct.DragonAge.Adult.rawValue
        newDragon2.dragonImageLocation =  Utilities.returnImageLocation(dragon: newDragon2)
        newDragon2.dragonSellingPrice = Utilities.returnSellingPrice(dragon: newDragon2)
        newDragon2.dragonCloningPrice = Utilities.returnCloningPrice(
            type: DragonStruct.DragonType(rawValue: newDragon2.dragonType!) ?? DragonStruct.DragonType.Dragon,
            pattern: DragonStruct.DragonPattern(rawValue: newDragon2.dragonPattern!) ?? DragonStruct.DragonPattern.Basic,
            color: DragonStruct.MainColor(rawValue: newDragon2.dragonMain!) ?? DragonStruct.MainColor.Black,
            secondColor: DragonStruct.SecondaryColor(rawValue: newDragon2.dragonSecond!) ?? DragonStruct.SecondaryColor.Black)
        
        do {
            try viewContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            print(error)
        }
        return result
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "Tulpagotchi_Revamp")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.

                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                print(error)
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}
