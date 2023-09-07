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
    var selectedType = Injection.InjectionType.all
    
    var filterCount = CurrentValueSubject<Int, Never>(0)
    
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
    
    func applyFilters(sortDateBy: HistoryViewModel.DateSorting, status: History.InjectStatus, type: Injection.InjectionType, startDate: Date, endDate: Date){
        
        var count = 0
        
        print("\(sortDateBy.rawValue) + \(status.rawValue) + \(type.rawValue) ")
        
        if sortDateBy == .oldest {
            count += 1
        }
        
        if status != .all {
            count += 1
        }
        
        if type != .all {
            count += 1
        }
        
        let startOfCurrentDate = Calendar.current.startOfDay(for: Date())
        
        let startOfEndDate = Calendar.current.startOfDay(for: endDate)
        
        if startDate != oldestDate || startOfCurrentDate != startOfEndDate {
            count += 1
        }
        
        filterCount.value = count
        
        selectedDateSorting = sortDateBy
        selectedStatus = status
        selectedStartDate = startDate
        selectedEndDate = endDate
        selectedType = type
        
        historyProvider.applyFilters(dateSorting: sortDateBy, status: status, type: type, startDate: startDate, endDate: endDate)
        
    }
    
    func applyDefaultFilters(){
        
        filterCount.value = 0
        
        selectedDateSorting = .newest
        selectedStatus = .all
        selectedStartDate = nil
        selectedEndDate = nil
        selectedType = .all
        
        historyProvider.applyFilters(dateSorting: .newest, status: .all, type: .all, startDate: oldestDate, endDate: Date())
        
        
        
        
    }
}
