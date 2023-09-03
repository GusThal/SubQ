//
//  HistoryProvider.swift
//  SubQ
//
//  Created by Constantine Thalasinos on 7/10/23.
//

import Foundation
import CoreData
import UIKit
import Combine

class HistoryProvider: NSObject{
    
    let storageProvider: StorageProvider
    
    @Published var snapshot: NSDiffableDataSourceSnapshot<Int, NSManagedObjectID>?
    
    var currentValueSnapshot = CurrentValueSubject<NSDiffableDataSourceSnapshot<Int, NSManagedObjectID>?, Never>(NSDiffableDataSourceSnapshot<Int, NSManagedObjectID>())
    
    private var fetchedResultsController: NSFetchedResultsController<History>?
    
    private var searchPredicate: NSPredicate?
    
    private let fetchAllRequest: NSFetchRequest = {
        
        let request: NSFetchRequest<History> = History.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \History.date, ascending: false)]

        return request
    }()
    
    init(storageProvider: StorageProvider, fetch: Bool = true) {
        self.storageProvider = storageProvider
        
        if fetch{
            

            self.fetchedResultsController =
              NSFetchedResultsController(fetchRequest: fetchAllRequest,
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
    
    /*
     for both injected and skipped injections
     */
    @discardableResult
    func saveHistory(injection: Injection, site: Site?, date: Date, dateDue: Date?, status: History.InjectStatus) -> Bool{
        
        let persistentContainer = storageProvider.persistentContainer
        
        
        
        let history = History(context: persistentContainer.viewContext)
        history.injection = injection
        history.site = site
        history.date = date
        history.dueDate = date
        history.status = status.rawValue

        do{
            try persistentContainer.viewContext.save()
            print("saved successfully")
            return true
            
        } catch{
            print("failed with \(error)")
            persistentContainer.viewContext.rollback()
        }
        
        return false
        
    }
    
    func object(at indexPath: IndexPath) -> History {
      return fetchedResultsController!.object(at: indexPath)
    }
    
    func getOldestHistory() -> Date?{
        let request: NSFetchRequest<History> = History.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \History.date, ascending: true)]
        request.fetchLimit = 1

        let context = storageProvider.persistentContainer.viewContext
        
        do{
            let history = try context.fetch(request).first
            
            return history?.date
        }
        catch{
            print("failed with \(error)")
            storageProvider.persistentContainer.viewContext.rollback()
        }
        
        return nil
    }
    
    
    func getLastInjectedDate(forInjection injection: Injection) -> Date?{
        
        let request: NSFetchRequest<History> = History.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \History.date, ascending: false)]
        request.predicate = NSPredicate(format: "%K==%@", #keyPath(History.injection), injection)
        request.fetchLimit = 1

        let context = storageProvider.persistentContainer.viewContext
        
        do{
            let history = try context.fetch(request).first
            
            return history?.date
        }
        catch{
            print("failed with \(error)")
            storageProvider.persistentContainer.viewContext.rollback()
        }
        
        return nil
        
        
    }
    
    func performSearch(forText text: String){
        
        if text == ""{
          
            fetchedResultsController!.fetchRequest.predicate = nil
            searchPredicate = nil
        } else{
            searchPredicate = NSPredicate(format: "%K CONTAINS[cd] %@", #keyPath(History.injection.name), text)
            fetchedResultsController!.fetchRequest.predicate = searchPredicate
        }
        
        
        try! fetchedResultsController!.performFetch()
        
    }
    
    func applyFilters(dateSorting: HistoryViewModel.DateSorting, status: History.InjectStatus, type: Injection.InjectionType, startDate: Date, endDate: Date){
        
        var predicates = [NSPredicate]()
        
        if dateSorting == .newest{
            fetchedResultsController?.fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \History.date, ascending: false)]
        }
        else{
            fetchedResultsController?.fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \History.date, ascending: true)]
        }
        
        if status == .injected || status == .skipped {
            let predicate = NSPredicate(format: "%K == %@", #keyPath(History.status), status.rawValue)
            predicates.append(predicate)
        }
        
        if type == .asNeeded || type == .scheduled {
            let predicate = NSPredicate(format: "%K == %@", #keyPath(History.injection.type), type.rawValue)
            predicates.append(predicate)
        }
        
        
        let start = Calendar.current.startOfDay(for: startDate)
        
        
        let endDateStart = Calendar.current.startOfDay(for: endDate)
        
        var components = DateComponents()
        components.day = 1
        components.second = -1
        let end = Calendar.current.date(byAdding: components, to: endDateStart)!

        let datePredicate = NSPredicate(format: "(%K <= %@ AND %K >= %@)",
                                        #keyPath(History.date), end as NSDate,
                                        #keyPath(History.date), start as NSDate)
        
        predicates.append(datePredicate)
        
        if let searchPredicate{
            predicates.append(searchPredicate)
        }
        
        //print(predicates)
        
        fetchedResultsController!.fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        
        try! fetchedResultsController!.performFetch()
        
    }
    
    func deleteObject(_ object: History){
        
        let persistentContainer = storageProvider.persistentContainer
        
        persistentContainer.viewContext.delete(object)

        do {
            try persistentContainer.viewContext.save()
        } catch {
            persistentContainer.viewContext.rollback()
            print("Failed to save context: \(error)")
        }
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
        
        self.currentValueSnapshot.value = newSnapshot
        
    }
    
    
}
