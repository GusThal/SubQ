//
//  InjectionViewModel.swift
//  SubQ
//
//  Created by Constantine Thalasinos on 5/29/23.
//

import Foundation
import Combine
import CoreData

class EditInjectionViewModel{
    
    let injection: Injection?
    
    var cancellables = Set<AnyCancellable>()
    
    
    let days = Injection.Frequency.allCases.filter { ![Injection.Frequency.asNeeded, Injection.Frequency.daily].contains($0) }
    
    @Published var selectedFrequency = [Injection.Frequency]()
    
    var currentValueFrequency = CurrentValueSubject<[Injection.Frequency], Never>([Injection.Frequency]())
    
    @Published var name = ""
    
    @Published var dosage = ""
    
    let injectionProvider: InjectionProvider
    
    var areNotificationsEnabled: Bool
    
    
    lazy var frequencySubject: AnyPublisher<String?, Never> = {

        return currentValueFrequency.map({ frequency in
            print(frequency)
            return frequency.count == 1 ? frequency[0].shortened : frequency.map { $0.shortened }.joined(separator: ", ")
            
        }).eraseToAnyPublisher()
    }()
    
    var isValidNamePublisher: AnyPublisher<Bool, Never> {
        $name.map { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
            .eraseToAnyPublisher()
    }
    
    var isValidDosagePublisher: AnyPublisher<Bool, Never> {
        $dosage.map { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
            .eraseToAnyPublisher()
    }
    
    var isFrequencySelectedPublisher: AnyPublisher<Bool, Never> {
        $selectedFrequency.map { $0 != [] }
            .eraseToAnyPublisher()
    }
    
    
    var isValidInjectionPublisher: AnyPublisher<Bool, Never> {
        Publishers.CombineLatest3(isValidNamePublisher, isValidDosagePublisher, isFrequencySelectedPublisher).map { $0 && $1 && $2 }
            .eraseToAnyPublisher()
    }
    
    
    //datasource
    
    init(injectionProvider: InjectionProvider, injection: Injection?) {
        self.injectionProvider = injectionProvider
        self.injection = injection
        self.areNotificationsEnabled = true
        
        if let injection{
            
            selectedFrequency = injection.daysVal
            currentValueFrequency.value = injection.daysVal
            name = injection.name!
            dosage = "\(injection.dosage!)"
            
            if selectedFrequency != [.asNeeded]{
                areNotificationsEnabled = injection.areNotificationsEnabled
            }
            //always default to false for as needed.
            else{
                areNotificationsEnabled = false
            }
           
            
            
        }
    }
    
    
    @discardableResult
    func saveInjection(name: String, dosage: Double, units: Injection.DosageUnits, frequency: String, time: Date?, areNotificationsEnabled: Bool) -> Injection {
        
        return injectionProvider.saveInjection(name: name, dosage: dosage, units: units, frequency: frequency, time: time, areNotificationsEnabled: areNotificationsEnabled)
        
        
    }
    @discardableResult
    func updateInjection(injection: Injection, name: String, dosage: Double, units: Injection.DosageUnits, frequency: String, time: Date?, areNotificationsEnabled: Bool) -> Injection {
        
        return injectionProvider.updateInjection(injection: injection, name: name, dosage: dosage, units: units, frequency: frequency, time: time, areNotificationsEnabled: areNotificationsEnabled)
        
    }
    
    func deleteInjection(_ injection: Injection){
        
        if injection.daysVal != [.asNeeded]{
            NotificationManager.removeExistingNotifications(forInjection: injection)
        }

        let queueProvider = QueueProvider(storageProvider: StorageProvider.shared, fetchAllForInjection: injection)
        queueProvider.deleteAllInSnapshot()
        
        injectionProvider.deleteInjection(injection)
    }
    
    func isDuplicateInjection(name: String, dosage: Double, units: Injection.DosageUnits, frequencyString: String, date: Date?) -> Bool{
        
        return injectionProvider.isDuplicateInjection(existingInjection: injection, name: name, dosage: dosage, units: units, frequencyString: frequencyString, date: date)
        
    }

    
    
}

