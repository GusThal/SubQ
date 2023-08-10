//
//  QueueProvider.swift
//  SubQ
//
//  Created by Constantine Thalasinos on 7/15/23.
//

import Foundation
import CoreData
import UIKit
import Combine

class QueueProvider: NSObject{
    
    let storageProvider: StorageProvider
    
    @Published var snapshot: NSDiffableDataSourceSnapshot<Int, NSManagedObjectID>?
    
    private var fetchedResultsController: NSFetchedResultsController<Queue>?
    
    @Published var queueCount: Int = 0
    
    var currentValueSnapshot = CurrentValueSubject<NSDiffableDataSourceSnapshot<Int, NSManagedObjectID>?, Never>(NSDiffableDataSourceSnapshot<Int, NSManagedObjectID>())
    
    
    init(storageProvider: StorageProvider, fetch: Bool = true){
        self.storageProvider = storageProvider
        
        if fetch{
            let request: NSFetchRequest<Queue> = Queue.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(keyPath: \Queue.dateDue, ascending: true)]

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
    
    init(storageProvider: StorageProvider, fetchSnoozedForInjection injection: Injection) {
        
        self.storageProvider = storageProvider
        
        let request: NSFetchRequest<Queue> = Queue.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Queue.dateDue, ascending: true)]
        
        let injPredicate = NSPredicate(format: "%K==%@", #keyPath(Queue.injection), injection)
        
        let snoozedPredicate = NSPredicate(format: "%K!=nil", #keyPath(Queue.snoozedUntil))
        
        let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [injPredicate, snoozedPredicate])
        
        request.predicate = compoundPredicate

        self.fetchedResultsController =
          NSFetchedResultsController(fetchRequest: request,
                                     managedObjectContext: storageProvider.persistentContainer.viewContext,
                                     sectionNameKeyPath: nil, cacheName: nil)



        //delegate will be informed any time a managed object changes, a new one is inserted, or one is deleted
        super.init()
        
        fetchedResultsController!.delegate = self
        try! fetchedResultsController!.performFetch()
        
        
    }
    
   
    
    func object(forInjection injection: Injection, withDateDue date: Date) -> Queue?{
        
        let request: NSFetchRequest<Queue> = Queue.fetchRequest()
        let injectionPredicate = NSPredicate(format: "%K==%@", #keyPath(Queue.injection), injection)
        let datePredicate = NSPredicate(format: "%K==%@", #keyPath(Queue.dateDue), date as CVarArg)
        
        let compounded = NSCompoundPredicate(andPredicateWithSubpredicates: [injectionPredicate, datePredicate])
        
        request.predicate = compounded
        
        
        request.fetchLimit = 1

        let context = storageProvider.persistentContainer.viewContext
        
        do{
            let obj = try context.fetch(request).first
            
            return obj
        }
        catch{
            print("failed with \(error)")
            storageProvider.persistentContainer.viewContext.rollback()
        }
        
        return nil
        
    }
    
    func object(fromIDString id: String) -> Queue{
        
        let url = URL(string: id)!
        
        let managedObjectID = storageProvider.persistentContainer.persistentStoreCoordinator.managedObjectID(forURIRepresentation: url)!
        
        return object(withObjectID: managedObjectID)
        
    }
    
    func object(withObjectID id: NSManagedObjectID) -> Queue{
        
        let obj = storageProvider.persistentContainer.viewContext.object(with: id) as! Queue
        
        return obj
        
    }
    
    
    @discardableResult
    func saveObject(injection: Injection, dateDue: Date, snoozedUntil: Date?) -> Queue {
    
        
        let persistentContainer = storageProvider.persistentContainer
        
        var obj: Queue!
        
        if let object = object(forInjection: injection, withDateDue: dateDue){
            
            obj = object
            
            obj.snoozedUntil = snoozedUntil
            
            print("found \(object)")
            
        }
        
        else{
            
            obj = Queue(context: persistentContainer.viewContext)
            obj.injection = injection
            obj.dateDue = dateDue
            obj.snoozedUntil = snoozedUntil
        
            
        }
        
        do{
            try persistentContainer.viewContext.save()
            print("saved successfully")
            
        } catch{
            print("failed with \(error)")
            persistentContainer.viewContext.rollback()
        }
        
        return obj
        
    }
    
    func object(at indexPath: IndexPath) -> Queue{
        return fetchedResultsController!.object(at: indexPath)
    }
    
    func deleteObject(_ obj: Queue){
        storageProvider.persistentContainer.viewContext.delete(obj)

        do {
            try storageProvider.persistentContainer.viewContext.save()
        } catch {
            storageProvider.persistentContainer.viewContext.rollback()
            print("Failed to save context: \(error)")
          }
    }
}




extension QueueProvider: NSFetchedResultsControllerDelegate{
    
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
        
        self.currentValueSnapshot.value = newSnapshot
        
        self.queueCount = self.snapshot!.numberOfItems
        
    }
    
}
