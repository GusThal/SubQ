//
//  InjectionProvider.swift
//  SubQ
//
//  Created by Constantine Thalasinos on 6/1/23.
//

import UIKit
import CoreData

class InjectionProvider: NSObject{
    
    let storageProvider: StorageProvider
    
    @Published var snapshot: NSDiffableDataSourceSnapshot<Int, NSManagedObjectID>?
    
    private let fetchedResultsController: NSFetchedResultsController<Injection>
    
    init(storageProvider: StorageProvider) {
        self.storageProvider = storageProvider
        
        let request: NSFetchRequest<Injection> = Injection.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Injection.name, ascending: true)]

        self.fetchedResultsController =
          NSFetchedResultsController(fetchRequest: request,
                                     managedObjectContext: storageProvider.persistentContainer.viewContext,
                                     sectionNameKeyPath: nil, cacheName: nil)

        super.init()

        //delegate will be informed any time a managed object changes, a new one is inserted, or one is deleted
        fetchedResultsController.delegate = self
        try! fetchedResultsController.performFetch()
    }
    
    func getInjections(){
        
    }
    
    func deleteInjection(_ injection: Injection){
        storageProvider.persistentContainer.viewContext.delete(injection)

        do {
            try storageProvider.persistentContainer.viewContext.save()
        } catch {
            storageProvider.persistentContainer.viewContext.rollback()
            print("Failed to save context: \(error)")
          }
    }
    
    func object(at indexPath: IndexPath) -> Injection {
      return fetchedResultsController.object(at: indexPath)
    }
    
    func saveInjection(name: String, dosage: Double, units: Injection.DosageUnits, frequency: [Injection.Frequency], time: Date?) {
        
        #warning("TODO: check if injection name already exists")
        
        
        let persistentContainer = storageProvider.persistentContainer
        
        
        
        let injection = Injection(context: persistentContainer.viewContext)
        injection.name = name
        injection.dosage = NSDecimalNumber(decimal: Decimal(dosage))
        injection.units = units.rawValue
        injection.days = frequency.map({ $0.rawValue }).joined(separator: ", ")
        injection.time = time
        
        do{
            try persistentContainer.viewContext.save()
            print("saved successfully")
            
        } catch{
            print("failed with \(error)")
            persistentContainer.viewContext.rollback()
        }
        
    }
    func updateInjection(injection: Injection, name: String, dosage: Double, units: Injection.DosageUnits, frequency: [Injection.Frequency], time: Date?) {
        
        let persistentContainer = storageProvider.persistentContainer
        
        injection.name = name
        injection.dosage = NSDecimalNumber(decimal: Decimal(dosage))
        injection.units = units.rawValue
        injection.days = frequency.map({ $0.rawValue }).joined(separator: ", ")
        injection.time = time
        
        do{
            try persistentContainer.viewContext.save()
            print("saved successfully")
            
        } catch{
            print("failed with \(error)")
            persistentContainer.viewContext.rollback()
        }
        
        
        
    }
    
    
    
}

extension InjectionProvider: NSFetchedResultsControllerDelegate{
    
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
