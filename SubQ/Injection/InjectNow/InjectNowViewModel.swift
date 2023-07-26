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
    var injectionFromNotification: Injection?
    let historyProvider: HistoryProvider
    let queueProvider: QueueProvider
    let dateDue: Date?
    
    let isFromNotification: Bool
    
    @Published var selectedInjection: Injection?
    
    @Published var selectedQueueObject: Queue?
    
    @Published var selectedSite: Site?
    
    lazy var siteSnapshot: AnyPublisher<NSDiffableDataSourceSnapshot<Int, NSManagedObjectID>?, Never> = {
        return siteProvider.$snapshot.eraseToAnyPublisher()
    }()
    
    lazy var queueSnapshot: AnyPublisher<NSDiffableDataSourceSnapshot<Int, NSManagedObjectID>?, Never> = {
        return queueProvider.$snapshot.eraseToAnyPublisher()
    }()
    
    lazy var injectionSnapshot: AnyPublisher<NSDiffableDataSourceSnapshot<Int, NSManagedObjectID>?, Never> = {
        return injectionProvider.$snapshot.eraseToAnyPublisher()
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
    
    
    init(storageProvider: StorageProvider, injectionIDString: String?, dateDue: Date?) {
        self.injectionProvider = InjectionProvider(storageProvider: storageProvider)
        self.siteProvider = SiteProvider(storageProvider: storageProvider)
        self.historyProvider = HistoryProvider(storageProvider: storageProvider, fetch: false)
        self.dateDue = dateDue
        
        
        if let injectionIDString{
            isFromNotification = true
            queueProvider = QueueProvider(storageProvider: storageProvider, fetch: false)
            injectionFromNotification = getInjection(withIDString: injectionIDString)
            
        }
        else{
            isFromNotification = false
            queueProvider = QueueProvider(storageProvider: storageProvider)
            print("QUEUE ITEMS \(queueProvider.snapshot?.numberOfItems)")
        }
        
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
        
        historyProvider.saveHistory(injection: injectionFromNotification!, site: site, date: date)
        siteProvider.update(site: site, withDate: date)
        
        
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
        
    
        queueProvider.saveObject(injection: injection, dateDue: dateDue!, snoozedUntil: snoozedDate)
        
       /*NotificationManager.scheduleNotificationForInjectionWith(objectID: injection.objectID, name: injection.name!, dosage: Double(truncating: injection.dosage!), units: injection.unitsVal, frequency: injection.daysVal, frequencyString: injection.scheduledString, time: snoozedDate!, snoozed: true, originalDateDue: dateDue)*/
        
        NotificationManager.scheduleSnoozedNotificationForInjectionWith(objectID: injection.objectID, name: injection.name!, dosage: Double(truncating: injection.dosage!), units: injection.unitsVal, frequency: injection.daysVal, frequencyString: injection.scheduledString, snoozedUntil: snoozedDate!, originalDateDue: dateDue!)
        
    }
    
}
