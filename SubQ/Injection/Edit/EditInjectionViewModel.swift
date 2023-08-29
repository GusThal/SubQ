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
    
    
    let days = Frequency.InjectionDay.allCases.filter { Frequency.InjectionDay.daily != $0 }
    
    @Published var frequencies = [EditInjectionTableViewController.FrequencySectionData]() {
        didSet {
            print(frequencies)
        }
    }
    
    var selectedDayCellIndex = 0
    
    var selectedTimeCellIndex: Int? = nil
    
   // @Published var selectedFrequency = [Injection.Frequency]()
    
   // @Published var selectedFrequencies = [Frequency.InjectionDay]()
    
   // var currentValueFrequency = CurrentValueSubject<[Injection.Frequency], Never>([Injection.Frequency]())
    
    var currentValueSelectedDay = CurrentValueSubject<[Frequency.InjectionDay], Never>([Frequency.InjectionDay]())
    
    @Published var name = ""
    
    @Published var dosage = ""
    
    var selectedUnits: Injection.DosageUnits?
    
    let injectionProvider: InjectionProvider
    
    var areNotificationsEnabled: Bool
    
    var isAsNeeded: Bool
    
    lazy var daysSubject: AnyPublisher<String?, Never> = {

          return currentValueSelectedDay.map({ days in
              print(days)
              return days.count == 1 ? days[0].shortened : days.map { $0.shortened }.joined(separator: ", ")
              
          }).eraseToAnyPublisher()
      }()
    
    
  /*  lazy var frequencySubject: AnyPublisher<String?, Never> = {

        return currentValueFrequency.map({ frequency in
            print(frequency)
            return frequency.count == 1 ? frequency[0].shortened : frequency.map { $0.shortened }.joined(separator: ", ")
            
        }).eraseToAnyPublisher()
    }() */
    
    var isValidNamePublisher: AnyPublisher<Bool, Never> {
        $name.map { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
            .eraseToAnyPublisher()
    }
    
    var isValidDosagePublisher: AnyPublisher<Bool, Never> {
        $dosage.map { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
            .eraseToAnyPublisher()
    }
    /*
    
    var isFrequencySelectedPublisher: AnyPublisher<Bool, Never> {
        $selectedFrequency.map { $0 != [] }
            .eraseToAnyPublisher()
    }
     */
    
    var areFrequenciesValidPublisher: AnyPublisher<Bool, Never> {
        
        $frequencies.map { self.areFrequenciesValid(frequencies: $0) }
            .eraseToAnyPublisher()
    }
    
    var isValidInjectionPublisher: AnyPublisher<Bool, Never> {
           
        Publishers.CombineLatest3(isValidNamePublisher, isValidDosagePublisher, areFrequenciesValidPublisher).map { $0 && $1 && $2 }
            .eraseToAnyPublisher()
    }
    
    
    init(injectionProvider: InjectionProvider, injection: Injection?) {
        self.injectionProvider = injectionProvider
        self.injection = injection
        self.areNotificationsEnabled = true
        self.isAsNeeded = true
        
        if let injection{
            
           // selectedFrequency = injection.daysVal
           // currentValueFrequency.value = injection.daysVal
            name = injection.name!
            dosage = "\(injection.dosage!)"
            
            self.isAsNeeded = injection.typeVal == .asNeeded ? true : false
            self.areNotificationsEnabled = injection.areNotificationsEnabled
            
            for frequency in injection.frequency! as! Set<Frequency>{
                frequencies.append(EditInjectionTableViewController.FrequencySectionData(isTimePickerCell: false, days: frequency.daysVal, time: frequency.time))
                
            }
            
           /* if injection.typeVal != .asNeeded{
                self.isAsNeeded = false
            }*/
            
         /*   if selectedFrequency != [.asNeeded]{
                areNotificationsEnabled = injection.areNotificationsEnabled
            }
            //always default to false for as needed.
            else{
                areNotificationsEnabled = false
            }*/
           
            
            
        }
    }
    
    func areFrequenciesValid(frequencies: [EditInjectionTableViewController.FrequencySectionData]) -> Bool{
        
       // print("are frequncies valid  \(frequencies)")
        
        var validFrequencies = [Bool]()
        
        if isAsNeeded{
            return true
        }
        else{
            if frequencies.count == 0{
                return false
            }
            
            else{
                
                for frequency in frequencies {
                    
                    if frequency.isTimePickerCell {
                        validFrequencies.append(true)
                    } else if frequency.days != nil && frequency.time != nil {
                        validFrequencies.append(true)
                    } else {
                        validFrequencies.append(false)
                    }
                }

            }
           
        }
        
        for bool in validFrequencies {
            if !bool {
                return false
            }
        }
        
        return true
    }
    
    
    @discardableResult
    func saveInjection(name: String, dosage: Double, units: Injection.DosageUnits, frequencies: [EditInjectionTableViewController.FrequencySectionData], areNotificationsEnabled: Bool, isAsNeeded: Bool) -> Injection {
        
        return injectionProvider.saveInjection(name: name, dosage: dosage, units: units, frequencies: frequencies, areNotificationsEnabled: areNotificationsEnabled, isAsNeeded: isAsNeeded)
        
        
    }
    @discardableResult
    func updateInjection(injection: Injection, name: String, dosage: Double, units: Injection.DosageUnits, frequencies: [EditInjectionTableViewController.FrequencySectionData], areNotificationsEnabled: Bool, isAsNeeded: Bool) -> Injection {
        
        return injectionProvider.updateInjection(injection: injection, name: name, dosage: dosage, units: units, frequencies: frequencies, areNotificationsEnabled: areNotificationsEnabled, isAsNeeded: isAsNeeded)
        
    }
    
    func deleteInjection(_ injection: Injection){
        
        
        
        if injection.typeVal == .scheduled{
            NotificationManager.removeExistingNotifications(forInjection: injection, removeQueued: true)
        }

        let queueProvider = QueueProvider(storageProvider: StorageProvider.shared, fetchAllForInjection: injection)
        queueProvider.deleteAllInSnapshot()
        
        injectionProvider.deleteInjection(injection)
    }
    
    func isDuplicateInjection(name: String, dosage: Double, units: Injection.DosageUnits) -> Bool{
        
        return injectionProvider.isDuplicateInjection(existingInjection: injection, name: name, dosage: dosage, units: units)
        
    }

    
    
}

