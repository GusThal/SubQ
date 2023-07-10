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
    var injection: Injection?
    
    
    lazy var siteSnapshot: AnyPublisher<NSDiffableDataSourceSnapshot<Int, NSManagedObjectID>?, Never> = {
        return siteProvider.$snapshot.eraseToAnyPublisher()
    }()
    
    init(storageProvider: StorageProvider, injectionIDString: String?) {
        self.injectionProvider = InjectionProvider(storageProvider: storageProvider)
        self.siteProvider = SiteProvider(storageProvider: storageProvider)
        
        
        if let injectionIDString{
            injection = getInjection(withIDString: injectionIDString)
        }
        
    }
    
    func getInjection(withIDString id: String) -> Injection{
        return injectionProvider.object(fromIDString: id)
    }
    
    func getSite(forIndexPath indexPath: IndexPath) -> Site{
        return siteProvider.object(at: indexPath)
    }
    
}
