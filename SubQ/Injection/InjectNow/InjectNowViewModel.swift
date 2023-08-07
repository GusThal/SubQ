//
//  InjectNowViewModel.swift
//  SubQ
//
//  Created by Constantine Thalasinos on 7/9/23.
//

import Foundation
import CoreData
import Combine
import UIKit

class InjectNowViewModel{
    
    let injectionProvider: InjectionProvider
    let siteProvider: SiteProvider
    let historyProvider: HistoryProvider
    let queueProvider: QueueProvider
    let dateDue: Date?
    
    var injectionFromNotification: Injection?
    var queueObjectFromNotification: Queue?
    
    let isFromNotification: Bool
    
    @Published var selectedInjection: Injection?
    
    @Published var selectedQueueObject: Queue?
    
    @Published var selectedSite: Site?
    
    var cancellables = Set<AnyCancellable>()
    
    var queuedInjectionIDs = [NSManagedObjectID]()
    
    lazy var siteSnapshot: AnyPublisher<NSDiffableDataSourceSnapshot<Int, NSManagedObjectID>?, Never> = {
        return siteProvider.$snapshot.eraseToAnyPublisher()
    }()
    
    lazy var queueSnapshot: AnyPublisher<NSDiffableDataSourceSnapshot<Int, NSManagedObjectID>?, Never> = {
        return queueProvider.$snapshot.eraseToAnyPublisher()
    }()
    
    lazy var injectionSnapshot: AnyPublisher<NSDiffableDataSourceSnapshot<Int, NSManagedObjectID>?, Never> = {
        return injectionProvider.$snapshot.eraseToAnyPublisher()
    }()
    
    lazy var currentSnapshot: AnyPublisher<NSDiffableDataSourceSnapshot<Int, NSManagedObjectID>?, Never> = {
        return queueProvider.currentValueSnapshot.eraseToAnyPublisher()
    }()
    

    var typeSafeInjectionSnapshot: NSDiffableDataSourceSnapshot<Int, NSManagedObjectID>?{
        var newSnapshot = NSDiffableDataSourceSnapshot<Int, NSManagedObjectID>()
        
        newSnapshot.appendSections([1])
        
        if let snapshot = injectionProvider.snapshot{
            
            for injection in snapshot.itemIdentifiers{
                newSnapshot.appendItems([injection])
            }
        }
        
        return newSnapshot
        
    }
    
    var isInjectionSelectedPublisher: AnyPublisher<Bool, Never> {
        Publishers.Zip($selectedInjection, $selectedQueueObject).map({ self.isFromNotification || $0 != nil || $1 != nil}).eraseToAnyPublisher()
    }
    
    var isSiteSelectedPublisher: AnyPublisher<Bool, Never> {
        $selectedSite.map { $0 != nil }.eraseToAnyPublisher()
    }
    
    var fieldsSelectedPublisher: AnyPublisher<Bool, Never> {
        Publishers.CombineLatest(isInjectionSelectedPublisher, isSiteSelectedPublisher).map { $0 && $1 }.eraseToAnyPublisher()
    }
    
    
    init(storageProvider: StorageProvider, injectionIDString: String?, dateDue: Date?, queueObjectIDString: String?) {
        self.injectionProvider = InjectionProvider(storageProvider: storageProvider)
        self.siteProvider = SiteProvider(storageProvider: storageProvider)
        self.historyProvider = HistoryProvider(storageProvider: storageProvider, fetch: false)
        self.dateDue = dateDue
        
        
        if let injectionIDString{
            isFromNotification = true
            queueProvider = QueueProvider(storageProvider: storageProvider, fetch: false)
            injectionFromNotification = getInjection(withIDString: injectionIDString)
            
            if let id = queueObjectIDString{
                queueObjectFromNotification = getQueueObject(withIDString: id)
            }
            
            
            
        }
        else{
            isFromNotification = false
            queueProvider = QueueProvider(storageProvider: storageProvider)
            print("QUEUE ITEMS \(queueProvider.snapshot?.numberOfItems)")
            
            
            queueProvider.$snapshot.sink { snapshot in
                
                self.queuedInjectionIDs = snapshot?.itemIdentifiers.map({ self.getQueueObject(withIDString: $0.uriRepresentation().absoluteString).injection?.objectID }) as! [NSManagedObjectID]
                
            }.store(in: &cancellables)
        }
        
    }
    
    func isInjectionInQueue(injectionManagedID id: NSManagedObjectID) -> Bool{
        return queuedInjectionIDs.contains(id)
    }
    
    func getQueueObject(withIDString id: String) -> Queue{
        return queueProvider.object(fromIDString: id)
    }
    
    func getQueueObject(forIndexPath indexPath: IndexPath)-> Queue{
        return queueProvider.object(at: indexPath)
    }
    
    func getInjection(forIndexPath indexPath: IndexPath)-> Injection{
        return injectionProvider.object(at: indexPath)
    }
    
    func getInjection(withObjectID id: NSManagedObjectID) -> Injection{
        return injectionProvider.object(withObjectID: id)
    }
    
    func getInjection(withIDString id: String) -> Injection{
        return injectionProvider.object(fromIDString: id)
    }
    
    func getSite(forIndexPath indexPath: IndexPath) -> Site{
        return siteProvider.object(at: indexPath)
    }
    
    func injectionPerformed(site: Site){
        
        let date = Date()
        
        var injection: Injection!
        
        if !isFromNotification{
            if let selectedInjection{
                injection = selectedInjection
            }
            else if let selectedQueueObject{
                injection = selectedQueueObject.injection!
                
                if let snoozedUntil = selectedQueueObject.snoozedUntil{
                    NotificationManager.removeExistingNotifications(forInjection: injection, snoozedUntil: snoozedUntil, originalDateDue: selectedQueueObject.dateDue)
                }
            }
        }
        else{
            injection = injectionFromNotification!
        }
        
        
        if historyProvider.saveHistory(injection: injection, site: site, date: date, dateDue: dateDue, status: .injected){
            
            if !isFromNotification{
                
                if let selectedQueueObject{
                    delete(queueObject: selectedQueueObject)
                }
                
            }
            
            else{
                if let queueObjectFromNotification{
                    delete(queueObject: queueObjectFromNotification)
                }
            }
            
            siteProvider.update(site: site, withDate: date)
        }
    
        
        
    }
    
    func delete(queueObject obj: Queue){
        
        queueProvider.deleteObject(obj)
        
    }
    
    func getLastInjectedDate(forInjection injection: Injection) -> Date?{
        
        return historyProvider.getLastInjectedDate(forInjection: injection)
        
    }
    
    func snoozeInjection(forMinutes minutes: String){
        
        guard isFromNotification else { return }
        
        let snoozedDate = Calendar.current.date(byAdding: .minute, value: Int(minutes)!, to: Date())
        
        let injection = injectionFromNotification!
        
    
        let queueObject = queueProvider.saveObject(injection: injection, dateDue: dateDue!, snoozedUntil: snoozedDate)
        
       /*NotificationManager.scheduleNotificationForInjectionWith(objectID: injection.objectID, name: injection.name!, dosage: Double(truncating: injection.dosage!), units: injection.unitsVal, frequency: injection.daysVal, frequencyString: injection.scheduledString, time: snoozedDate!, snoozed: true, originalDateDue: dateDue)*/
        
        NotificationManager.scheduleSnoozedNotification(forInjection: injection, snoozedUntil: snoozedDate!, originalDateDue: dateDue!, queueObject: queueObject)
        
    }
    
    /*
     only Injections from notifiations can be skipped
     */
    func skipInjection(){
        
        
        historyProvider.saveHistory(injection: injectionFromNotification!, site: nil, date: Date(), dateDue: dateDue, status: .skipped)
        
        //only snoozed injections will have a dateDue
        if let queueObjectFromNotification{
            
            print("deleting queue obj \(queueObjectFromNotification)")
            
            delete(queueObject: queueObjectFromNotification)
            
        }
        
    }
    
}
