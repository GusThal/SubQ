//
//  InjectionProvider.swift
//  SubQ
//
//  Created by Constantine Thalasinos on 6/1/23.
//

import UIKit
import CoreData

class InjectionProvider: NSObject{
    
    enum SaveResult{
        case success, duplicate
    }
    
    enum ValidationError: Error{
        case duplicate(String)
    }
    
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
    
    func saveInjection(name: String, dosage: Double, units: Injection.DosageUnits, frequency: String, time: Date?) {
        
        #warning("TODO: check if injection name already exists")
        
        
        let persistentContainer = storageProvider.persistentContainer
        
        
        
        let injection = Injection(context: persistentContainer.viewContext)
        injection.name = name
        injection.dosage = NSDecimalNumber(decimal: Decimal(dosage))
        injection.units = units.rawValue
        //injection.days = frequency.map({ $0.rawValue }).joined(separator: ", ")
        injection.days = frequency
        injection.time = time
        
        do{
            try persistentContainer.viewContext.save()
            print("saved successfully")
            
        } catch{
            print("failed with \(error)")
            persistentContainer.viewContext.rollback()
        }
        
    }
    func updateInjection(injection: Injection, name: String, dosage: Double, units: Injection.DosageUnits, frequency: String, time: Date?) {
        
        let persistentContainer = storageProvider.persistentContainer
        
        injection.name = name
        injection.dosage = NSDecimalNumber(decimal: Decimal(dosage))
        injection.units = units.rawValue
       // injection.days = frequency.map({ $0.rawValue }).joined(separator: ", ")
        injection.days = frequency
        injection.time = time
        
        do{
            try persistentContainer.viewContext.save()
            print("saved successfully")
            
        } catch{
            print("failed with \(error)")
            persistentContainer.viewContext.rollback()
        }
        
    }
    
    //we need to accesss storage to validate whether the injection is unique, so it made sense to do it here rather than in the NSManagedObject class, where StorageProvider isn't available.
    //fetch all dates with same name, dosage, units, and frequency. And then check the prettyDate to see if it's a dupe
    
    func isDuplicateInjection(existingInjection: Injection?, name: String, dosage: Double, units: Injection.DosageUnits, frequencyString: String, date: Date?) -> Bool{
        
        let request: NSFetchRequest<Injection> = Injection.fetchRequest()
        
        let namePredicate = NSPredicate(format: "%K ==[c] %@", #keyPath(Injection.name), name)
        
        let dosagePredicate = NSPredicate(format: "%K == %f", #keyPath(Injection.dosage), dosage)
        
        let unitsPredicate = NSPredicate(format: "%K == %@", #keyPath(Injection.units), units.rawValue)
        
        let daysPredicate = NSPredicate(format: "%K == %@", #keyPath(Injection.days), frequencyString)
        
        let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [namePredicate, dosagePredicate, unitsPredicate, daysPredicate])
        
        
        request.predicate = compoundPredicate
        
        do{
            let injections = try storageProvider.persistentContainer.viewContext.fetch(request)
            
            print(compoundPredicate)
            
            print(injections.count)
            
            for injection in injections{
                
                
                if let date = date{
                    if injection.prettyTime == date.prettyTime{
                        
                        
                        if let objectID = existingInjection?.objectID{
                            //make sure this isn't the same injection
                            if injection.objectID != objectID{
                                return true
                            }
                            
                        }
                        //if we're not updating an existing injection, this is a duplicate.
                        else{
                            return true
                        }
                        
                        
                    }
                }
                //if there's no date then it's an As Needed injection
                else{
                    
                    if let objectID = existingInjection?.objectID{
                        //make sure this isn't the same injection
                        if injection.objectID != objectID{
                            return true
                        }
                        
                    }
                    //if we're not updating an existing injection, this is a duplicate.
                    else{
                        return true
                    }
                }
                
            }
        }
        catch{
            print("failed to fetch injections")
            return true
        }
        
        return false
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
