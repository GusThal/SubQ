//
//  SectionProvider.swift
//  SubQ
//
//  Created by Constantine Thalasinos on 6/10/23.
//

import Foundation
import CoreData
import UIKit

class SectionProvider: NSObject{
    
    let storageProvider: StorageProvider
    
    @Published var snapshot: NSDiffableDataSourceSnapshot<Int, NSManagedObjectID>?
    
    private var fetchedResultsController: NSFetchedResultsController<Section>!
    
    let request: NSFetchRequest = {
        let request: NSFetchRequest<Section> = Section.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Section.bodyPart!.part, ascending: true), NSSortDescriptor(keyPath: \Section.quadrant, ascending: true)]
        
        return request
    }()
    
    let bodyPredicate = NSPredicate(format: "%K==%d", #keyPath(Section.bodyPart.enabled), true)
    
    
    
    init(storageProvider: StorageProvider, applyingBodyPredicate: Bool = true){
        self.storageProvider = storageProvider
        
        super.init()
        
        setUpFetchedResultsController(applyingBodyPredicate: applyingBodyPredicate)

        //delegate will be informed any time a managed object changes, a new one is inserted, or one is deleted

    }
    
    func setUpFetchedResultsController(applyingBodyPredicate: Bool){
        
        var req = request
        var sectionNameKeyPath: String?
        
        if applyingBodyPredicate{
            
            req.predicate = bodyPredicate
            sectionNameKeyPath = "bodyPart"
            
        }
        
        self.fetchedResultsController =
          NSFetchedResultsController(fetchRequest: req,
                                     managedObjectContext: storageProvider.persistentContainer.viewContext,
                                     sectionNameKeyPath: sectionNameKeyPath, cacheName: nil)
        
        fetchedResultsController.delegate = self
        try! fetchedResultsController.performFetch()
    }
    
    func insertInitialData(){
          
          let quadrants = Quadrant.allCases
          
          let persistentContainer = storageProvider.persistentContainer
          
          let bodyPartProvider = BodyPartProvider(storageProvider: storageProvider)
          
          
          for bodyPart in bodyPartProvider.snapshot!.itemIdentifiers{
              
              let partObj = persistentContainer.viewContext.object(with: bodyPart) as! BodyPart
              
              for quadrant in quadrants{
                
                      
                  let section = Section(context: persistentContainer.viewContext)
                  section.quadrant = quadrant.asNSNumber
                  section.bodyPart = partObj
            
              }
              
              
          }

          
          do{
              try persistentContainer.viewContext.save()
              
          } catch{
              print("failed with \(error)")
              persistentContainer.viewContext.rollback()
          }
          
      }
    
    func object(at indexPath: IndexPath) -> Section {
      return fetchedResultsController.object(at: indexPath)
    }
    
    func bodyPart(for indexPath: IndexPath) -> BodyPart {
        return fetchedResultsController.object(at: indexPath).bodyPart!
    }
    

    
    func sectionObjectIds(forBodyPart part: BodyPart) -> [NSManagedObjectID]{
        
        var ret = [NSManagedObjectID]()
        
        let context  = storageProvider.persistentContainer.viewContext
        
        
        for id in snapshot!.itemIdentifiers{
            
            let obj = context.object(with: id) as! Section
            
            if obj.bodyPart == part{
                ret.append(id)
            }
            
        }
        
        
        return ret
        
    }
    
    func refreshSnapshot(forBodyParts part: BodyPart){
        setUpFetchedResultsController(applyingBodyPredicate: true)
        
    }
    
}

extension SectionProvider: NSFetchedResultsControllerDelegate{
    
    //from chapter 4 of Donny Wals's book Practical Core Data
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChangeContentWith snapshot: NSDiffableDataSourceSnapshotReference) {
        
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

        newSnapshot.reloadItems(idsToReload)

        self.snapshot = newSnapshot
        
    }
    
}
