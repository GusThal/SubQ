//
//  SectionViewModel.swift
//  SubQ
//
//  Created by Constantine Thalasinos on 6/11/23.
//

import Foundation
import Combine
import CoreData
import UIKit

class SectionViewModel{
    
    let storageProvider: StorageProvider
    let sectionProvider: SectionProvider
    
    lazy var snapshot: AnyPublisher<NSDiffableDataSourceSnapshot<Int, NSManagedObjectID>?, Never> = {
        return sectionProvider.$snapshot.eraseToAnyPublisher()
    }()
    
    init(storageProvider: StorageProvider){
        self.storageProvider = storageProvider
        self.sectionProvider = SectionProvider(storageProvider: storageProvider)
        
        let updateNotification = NSManagedObjectContext.didChangeObjectsNotification

        NotificationCenter.default.addObserver(self, selector: #selector(bodyPartToggled(_:)), name: BodyPartProvider.bodyPartToggledNotification, object: nil)
    }
    
    func object(at indexPath: IndexPath) -> Section {
        sectionProvider.object(at: indexPath)
    }
    
    func bodyPart(for indexPath: IndexPath) -> BodyPart {
        sectionProvider.bodyPart(for: indexPath)
    }
    
    #warning("i believe this is unused")
    @objc func dataDidUpdate(_ notification: Notification){
        
        let updatedKey = NSManagedObjectContext.NotificationKey.updatedObjects.rawValue
        
        
        if let update = notification.userInfo?[updatedKey], update is Set<BodyPart> {
            let set = update as! Set<BodyPart>
        }
        
        
    }
    
    @objc func bodyPartToggled(_ notification: Notification){
        
        let updatedKey = BodyPartProvider.updatedNotificationKey
        
        if let updatedBodyParts = notification.userInfo?[updatedKey]{
            
            let part = updatedBodyParts as! BodyPart
            
            
            sectionProvider.refreshSnapshot(forBodyParts: part)

        }
        
        
    }
    
    
    
}
