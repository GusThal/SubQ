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
    
    enum DateSorting: String, CaseIterable{
        case newest = "Newest", oldest = "Oldest"
    }
    
    let historyProvider: HistoryProvider
    let oldestDate: Date
    
    var selectedStartDate: Date?
    var selectedEndDate: Date?
    var selectedStatus = History.InjectStatus.all
    var selectedDateSorting = DateSorting.newest
    
    lazy var snapshot: AnyPublisher<NSDiffableDataSourceSnapshot<Int, NSManagedObjectID>?, Never> = {
        return historyProvider.$snapshot.eraseToAnyPublisher()
    }()
    
    lazy var currentSnapshot: AnyPublisher<NSDiffableDataSourceSnapshot<Int, NSManagedObjectID>?, Never> = {
        return historyProvider.currentValueSnapshot.eraseToAnyPublisher()
    }()
    
    
    init(storageProvider: StorageProvider) {
        self.historyProvider = HistoryProvider(storageProvider: storageProvider)
        
       oldestDate = historyProvider.getOldestHistory() ?? Date()
    }
    
    
    func object(at indexPath: IndexPath) -> History {
        historyProvider.object(at: indexPath)
    }
    
    func performSearch(forText text: String){
        historyProvider.performSearch(forText: text)
    }
    
    func deleteObject(_ object: History){
        historyProvider.deleteObject(object)
    }
    
    func applyFilters(sortDateBy: HistoryViewModel.DateSorting, status: History.InjectStatus, startDate: Date, endDate: Date){
        
        selectedDateSorting = sortDateBy
        selectedStatus = status
        selectedStartDate = startDate
        selectedEndDate = endDate
        
        historyProvider.applyFilters(dateSorting: sortDateBy, status: status, startDate: startDate, endDate: endDate)
        
    }
    
    func applyDefaultFilters(){
        
        selectedDateSorting = .newest
        selectedStatus = .all
        selectedStartDate = nil
        selectedEndDate = nil
        
        historyProvider.applyFilters(dateSorting: .newest, status: .all, startDate: oldestDate, endDate: Date())
        
        
        
        
    }
}
