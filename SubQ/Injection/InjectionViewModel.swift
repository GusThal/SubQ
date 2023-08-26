//
//  InjectionViewModel.swift
//  SubQ
//
//  Created by Constantine Thalasinos on 6/4/23.
//

import Foundation
import Combine
import CoreData
import UIKit

class InjectionViewModel{
    
    let storageProvider: StorageProvider
    let injectionProvider: InjectionProvider
    
    lazy var snapshot: AnyPublisher<NSDiffableDataSourceSnapshot<Int, NSManagedObjectID>?, Never> = {
        return injectionProvider.$snapshot.eraseToAnyPublisher()
    }()
    
    init(storageProvider: StorageProvider) {
        self.storageProvider = storageProvider
        self.injectionProvider = InjectionProvider(storageProvider: storageProvider)
    }
    
    
    
    func deleteInjection(_ injection: Injection){
        
        if injection.typeVal == .scheduled{
            NotificationManager.removeExistingNotifications(forInjection: injection, removeQueued: true)
        }
        
        let queueProvider = QueueProvider(storageProvider: storageProvider, fetchAllForInjection: injection)
        queueProvider.deleteAllInSnapshot()
   
   
        injectionProvider.deleteInjection(injection)
    }
    
    func object(at indexPath: IndexPath) -> Injection {
        injectionProvider.object(at: indexPath)
    }
    
    func updateAreNotificationsEnabled(forInjection injection: Injection, withValue value: Bool){
        injectionProvider.updateAreNotificationsEnabled(forInjection: injection, withValue: value)
    }
    
}
