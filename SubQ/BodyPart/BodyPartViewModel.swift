//
//  BodyPartViewModel.swift
//  SubQ
//
//  Created by Constantine Thalasinos on 6/6/23.
//

import Foundation
import Combine
import UIKit
import CoreData

class BodyPartViewModel{
    
    let storageProvider: StorageProvider
    let bodyPartProvider: BodyPartProvider
    var cancellables = Set<AnyCancellable>()
    
   lazy var snapshot: AnyPublisher<NSDiffableDataSourceSectionSnapshot<String>?, Never> = {
       
        bodyPartProvider.$snapshot.map { snap in
            
            let items = snap?.itemIdentifiers
            
                
            var sectionSnapshot = NSDiffableDataSourceSectionSnapshot<String>()
            
            var strings = [String]()
            
            
            if let items{
                
                for item in items{
                  
                    strings.append(item.uriRepresentation().absoluteString)
                }
                
                sectionSnapshot.append(strings)
            }
            
            return sectionSnapshot
        }.eraseToAnyPublisher()
        
    }()
    
    init(storageProvider: StorageProvider) {
        self.storageProvider = storageProvider
        self.bodyPartProvider = BodyPartProvider(storageProvider: storageProvider)
        

    }
    
    
    func object(at indexPath: IndexPath) -> BodyPart {
        bodyPartProvider.object(at: indexPath)
    }
    
    func setEnabled(forBodyPart bodyPart: BodyPart, to enabled: Bool) {
        bodyPartProvider.setEnabled(forBodyPart: bodyPart, to: enabled)
    }
}
