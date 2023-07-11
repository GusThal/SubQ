//
//  HistoryProvider.swift
//  SubQ
//
//  Created by Constantine Thalasinos on 7/10/23.
//

import Foundation
import CoreData
import UIKit

class HistoryProvider: NSObject{
    
    let storageProvider: StorageProvider
    
    @Published var snapshot: NSDiffableDataSourceSnapshot<Int, NSManagedObjectID>?
    
    private var fetchedResultsController: NSFetchedResultsController<History>?
    
    init(storageProvider: StorageProvider, fetch: Bool = true) {
        self.storageProvider = storageProvider
        
        if fetch{
            let request: NSFetchRequest<History> = History.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(keyPath: \History.date, ascending: true)]

            self.fetchedResultsController =
              NSFetchedResultsController(fetchRequest: request,
                                         managedObjectContext: storageProvider.persistentContainer.viewContext,
                                         sectionNameKeyPath: nil, cacheName: nil)



            //delegate will be informed any time a managed object changes, a new one is inserted, or one is deleted
            super.init()
            
            fetchedResultsController!.delegate = self
            try! fetchedResultsController!.performFetch()
            
        }
        else{
            super.init()
        }
        
        
    }
    
    func saveHistory(injection: Injection, site: Site, date: Date){
        
        let persistentContainer = storageProvider.persistentContainer
        
        
        
        let history = History(context: persistentContainer.viewContext)
        history.injection = injection
        history.site = site
        history.date = date

        do{
            try persistentContainer.viewContext.save()
            print("saved successfully")
            
        } catch{
            print("failed with \(error)")
            persistentContainer.viewContext.rollback()
        }
        
    }
    
    func object(at indexPath: IndexPath) -> History {
      return fetchedResultsController!.object(at: indexPath)
    }
    
}

extension HistoryProvider: NSFetchedResultsControllerDelegate{
    
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
