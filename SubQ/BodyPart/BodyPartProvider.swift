//
//  BodyPartProvider.swift
//  SubQ
//
//  Created by Constantine Thalasinos on 6/6/23.
//

import Foundation
import UIKit
import CoreData


class BodyPartProvider: NSObject{
    
    static let bodyPartToggledNotification =  Notification.Name("bodyPartToggledNotification")
    
    static let updatedNotificationKey = "updatedBodyPart"
    
    let storageProvider: StorageProvider
    
    @Published var snapshot: NSDiffableDataSourceSnapshot<Int, NSManagedObjectID>?
    
    private let fetchedResultsController: NSFetchedResultsController<BodyPart>
    
    init(storageProvider: StorageProvider) {
        self.storageProvider = storageProvider
        
        let request: NSFetchRequest<BodyPart> = BodyPart.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \BodyPart.part, ascending: true)]

        self.fetchedResultsController =
          NSFetchedResultsController(fetchRequest: request,
                                     managedObjectContext: storageProvider.persistentContainer.viewContext,
                                     sectionNameKeyPath: nil, cacheName: nil)

        super.init()

        //delegate will be informed any time a managed object changes, a new one is inserted, or one is deleted
        fetchedResultsController.delegate = self
        try! fetchedResultsController.performFetch()
        
        if snapshot!.numberOfItems == 0{
            print("zero body parts")
            
           // insertInitialData()
        }
        else{
            print("BodyPart Provider has \(snapshot!.numberOfItems)")
            
           /* for item in snapshot!.itemIdentifiers{
                let partObj = storageProvider.persistentContainer.viewContext.object(with: item) as! BodyPart
                
                print(partObj.part)
            }*/
        }

    }
    
    func object(at indexPath: IndexPath) -> BodyPart {
      return fetchedResultsController.object(at: indexPath)
    }
    
    func setEnabled(forBodyPart bodyPart: BodyPart, to enabled: Bool){
        
        let persistentContainer = storageProvider.persistentContainer
        
        bodyPart.enabled = enabled
        
        do{
            try persistentContainer.viewContext.save()
            print("saved Body Part successfully")
            
        } catch{
            print("failed with \(error)")
            persistentContainer.viewContext.rollback()
        }
    
        
        NotificationCenter.default.post(name: BodyPartProvider.bodyPartToggledNotification, object: self, userInfo: [BodyPartProvider.updatedNotificationKey: bodyPart])
        
        
    }
    
    func insertInitialData(){
        let bodyParts = BodyPart.Location.allCases
        let persistentContainer = storageProvider.persistentContainer
        
        for part in bodyParts{
            
            let obj = BodyPart(context: persistentContainer.viewContext)
            obj.enabled = true
            obj.part = part.rawValue
            
        }
        
        do{
            try persistentContainer.viewContext.save()
            print("saved successfully")
            
        } catch{
            print("failed with \(error)")
            persistentContainer.viewContext.rollback()
        }
    }
    
    
    
}

extension BodyPartProvider: NSFetchedResultsControllerDelegate{
    
    //from chapter 4 of Donny Wals's book Practical Core Data
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChangeContentWith snapshot: NSDiffableDataSourceSnapshotReference) {
        
        print("body part NSFetchedResultsControllerDelegate triggered")
        
        var newSnapshot = snapshot as NSDiffableDataSourceSnapshot<Int, NSManagedObjectID>

        let idsToReload = newSnapshot.itemIdentifiers.filter({ identifier in
          // check if this identifier is in the old snapshot
          // and that it didn't move to a new position
          guard let oldIndex = self.snapshot?.indexOfItem(identifier),
                let newIndex = newSnapshot.indexOfItem(identifier),
                oldIndex == newIndex else {
            return false
          }

          // check if we need to update this object
          guard (try? controller.managedObjectContext.existingObject(with: identifier))?.isUpdated == true else {
            return false
          }

          return true
        })

        print(idsToReload)
        
        newSnapshot.reloadItems(idsToReload)

        self.snapshot = newSnapshot
        
        
        
    }
    
}
