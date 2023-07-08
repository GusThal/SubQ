//
//  SiteViewModel.swift
//  SubQ
//
//  Created by Constantine Thalasinos on 7/7/23.
//

import Foundation
import Combine
import UIKit
import CoreData

class SiteViewModel{
    
    let storageProvider: StorageProvider
    let siteProvider: SiteProvider
    let section: Section
    
    lazy var snapshot: AnyPublisher<NSDiffableDataSourceSnapshot<Int, NSManagedObjectID>?, Never> = {
        return siteProvider.$snapshot.eraseToAnyPublisher()
    }()
    
    init(storageProvider: StorageProvider, section: Section) {
        self.storageProvider = storageProvider
        self.siteProvider = SiteProvider(storageProvider: storageProvider, section: section)
        self.section = section
    }
    
    func object(at indexPath: IndexPath) -> Site {
        return siteProvider.object(at: indexPath)
    }
    
    
}
