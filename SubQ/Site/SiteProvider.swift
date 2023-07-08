//
//  SiteProvider.swift
//  SubQ
//
//  Created by Constantine Thalasinos on 6/7/23.
//

import Foundation
import CoreData
import UIKit

class SiteProvider: NSObject{
    
    let storageProvider: StorageProvider
    
    @Published var snapshot: NSDiffableDataSourceSnapshot<Int, NSManagedObjectID>?
    
    private let fetchedResultsController: NSFetchedResultsController<Site>
    
    init(storageProvider: StorageProvider, section: Section? = nil){
        
        self.storageProvider = storageProvider
        
        let request: NSFetchRequest<Site> = Site.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Site.subQuadrant, ascending: true)]
        
        //pull all sites for that section
        if let section{
            request.predicate = NSPredicate(format: "%K==%@", #keyPath(Site.section), section)
        }
        //only pull sites with an enabled bodypart. this will be in the InjectNow controller.
        else{
            request.predicate = NSPredicate(format: "%K==%d", #keyPath(Site.section.bodyPart.enabled), true)
        }
        
        
        self.fetchedResultsController =
          NSFetchedResultsController(fetchRequest: request,
                                     managedObjectContext: storageProvider.persistentContainer.viewContext,
                                     sectionNameKeyPath: nil, cacheName: nil)

        super.init()

        //delegate will be informed any time a managed object changes, a new one is inserted, or one is deleted
        fetchedResultsController.delegate = self
        try! fetchedResultsController.performFetch()
        
        
        if snapshot!.numberOfItems == 0{
             print("zerooooo Sites")
            // insertInitialData()
             
         }
         else{
             
             print("number of sites \(snapshot!.numberOfItems)")
             
         }
        
        
    }
    
    func object(at indexPath: IndexPath) -> Site {
      return fetchedResultsController.object(at: indexPath)
    }
    
 /*   init(section: Section, storageProvider: StorageProvider){
        self.storageProvider = storageProvider
        
        let request: NSFetchRequest<Site> = Site.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Site.subQuadrant, ascending: true)]
        
        request.predicate = NSPredicate(format: "%K==%d", #keyPath(Site.section), section)

        self.fetchedResultsController =
          NSFetchedResultsController(fetchRequest: request,
                                     managedObjectContext: storageProvider.persistentContainer.viewContext,
                                     sectionNameKeyPath: nil, cacheName: nil)

        super.init()

        //delegate will be informed any time a managed object changes, a new one is inserted, or one is deleted
        fetchedResultsController.delegate = self
        try! fetchedResultsController.performFetch()
        
       if snapshot!.numberOfItems == 0{
            print("zerooooo Sites")
           // insertInitialData()
            
        }
        else{
            
            print("number of sites \(snapshot!.numberOfItems)")
            
        }
    }*/
    
    func insertInitialData(){
        
        
        let sectionProvider = SectionProvider(storageProvider: storageProvider, applyingBodyPredicate: false)
        
        let persistentContainer = storageProvider.persistentContainer
        
        let subQuadrants = Quadrant.allCases.map { $0.rawValue }
        
        
        print("# of items \(sectionProvider.snapshot!.numberOfItems)")
        
        print("# of sections \(sectionProvider.snapshot!.numberOfSections)")
        
        for section in sectionProvider.snapshot!.itemIdentifiers{
            
            let sectionObj = persistentContainer.viewContext.object(with: section) as! Section
            
            print("-----------FOR: \(sectionObj.bodyPart?.part) + \(sectionObj.quadrantVal)----------")
            
            
            for subQuadrant in subQuadrants{
                
                let site = Site(context: persistentContainer.viewContext)
                site.lastInjected = nil
                site.subQuadrant = NSNumber(integerLiteral: subQuadrant)
                site.section = sectionObj
                
                print("Created \(Quadrant(rawValue: subQuadrant))")
                
            }
            
        }
        
        do{
            try persistentContainer.viewContext.save()
            print("saved successfully")
            
        } catch{
            print("failed with \(error)")
            persistentContainer.viewContext.rollback()
        }
        
        
/*        let bodyParts = BodyPart.Location.allCases
        
        let sections = Quadrant.allCases.map { $0.rawValue }
        
        let persistentContainer = storageProvider.persistentContainer
        
        let bodyPartProvider = BodyPartProvider(storageProvider: storageProvider)
        
        
        for bodyPart in bodyPartProvider.snapshot!.itemIdentifiers{
            
            let partObj = persistentContainer.viewContext.object(with: bodyPart) as! BodyPart
            
            print("-----------FOR: \(partObj.part)----------")
            
            for section in sections{
                
                for subSection in sections{
                    
                    let site = Site(context: persistentContainer.viewContext)
                    site.section = section
                    site.subSection = subSection
                    site.lastInjected = nil
                    site.bodyPart = partObj
                    
                    print("created site with part \(site.bodyPart!.part)")
                    
                   // print(site.bodyPart)
                    
                }
                
            }
            
            
        }

        
        do{
            try persistentContainer.viewContext.save()
            print("saved successfully")
            
        } catch{
            print("failed with \(error)")
            persistentContainer.viewContext.rollback()
        }*/
        
    }
    
    
}

extension SiteProvider: NSFetchedResultsControllerDelegate{
    
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
