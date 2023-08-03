//
//  HistoryViewModel.swift
//  SubQ
//
//  Created by Constantine Thalasinos on 7/11/23.
//

import Foundation
import Combine
import CoreData
import UIKit

class HistoryViewModel{
    
    let historyProvider: HistoryProvider
    
    lazy var snapshot: AnyPublisher<NSDiffableDataSourceSnapshot<Int, NSManagedObjectID>?, Never> = {
        return historyProvider.$snapshot.eraseToAnyPublisher()
    }()
    
    
    init(storageProvider: StorageProvider) {
        self.historyProvider = HistoryProvider(storageProvider: storageProvider)
    }
    
    
    func object(at indexPath: IndexPath) -> History {
        historyProvider.object(at: indexPath)
    }
    
    func performSearch(forText text: String){
        historyProvider.performSearch(forText: text)
    }
    
    
    
}
