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
    let historyProvider: HistoryProvider
    
    let isFromNotification: Bool
    
    
    lazy var siteSnapshot: AnyPublisher<NSDiffableDataSourceSnapshot<Int, NSManagedObjectID>?, Never> = {
        return siteProvider.$snapshot.eraseToAnyPublisher()
    }()
    
    init(storageProvider: StorageProvider, injectionIDString: String?) {
        self.injectionProvider = InjectionProvider(storageProvider: storageProvider)
        self.siteProvider = SiteProvider(storageProvider: storageProvider)
        self.historyProvider = HistoryProvider(storageProvider: storageProvider, fetch: false)
        
        
        if let injectionIDString{
            isFromNotification = true
            injection = getInjection(withIDString: injectionIDString)
        }
        else{
            isFromNotification = false
        }
        
    }
    
    func getInjection(withIDString id: String) -> Injection{
        return injectionProvider.object(fromIDString: id)
    }
    
    func getSite(forIndexPath indexPath: IndexPath) -> Site{
        return siteProvider.object(at: indexPath)
    }
    
    func injectionPerformed(site: Site){
        
        let date = Date()
        
        historyProvider.saveHistory(injection: injection!, site: site, date: date)
        siteProvider.update(site: site, withDate: date)
        
        
    }
    
}
