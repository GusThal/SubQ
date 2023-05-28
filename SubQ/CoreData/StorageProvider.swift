//
//  StorageProvider.swift
//  SubQ
//
//  Created by Constantine Thalasinos on 5/24/23.
//

import Foundation
import CoreData

// I'm using a subclass so the persistent container will look for the data model in the framework bundle rather than the app bundle
public class PersistentContainer: NSPersistentCloudKitContainer {}

public class StorageProvider{
    
   public let persistentContainer: PersistentContainer
    
    public init(){
        let id = "group.com.gusthal.subq"
        let container = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: id)!
        let url = container.appendingPathComponent("SubQ.sqlite")
        
        persistentContainer = PersistentContainer(name: "SubQ")
        persistentContainer.persistentStoreDescriptions.first!.url = url
        persistentContainer.persistentStoreDescriptions.first!.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
        persistentContainer.persistentStoreDescriptions.first!.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)

        
        persistentContainer.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Core Data store failed to load with error: \(error)")
                
            }
        }
        
        persistentContainer.viewContext.automaticallyMergesChangesFromParent = true
        
        //object in memory trumps the persistent store in merge cconflicts
        persistentContainer.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        
    }
    
}
