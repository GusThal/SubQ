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

        }
    }
    
    var selectedDayCellIndex = 0
    
    var selectedTimeCellIndex: Int? = nil
    
    var currentValueSelectedDay = CurrentValueSubject<[Frequency.InjectionDay], Never>([Frequency.InjectionDay]())
    
    @Published var name = ""
    
    @Published var dosage = ""
    
    @Published var selectedUnits: Injection.DosageUnits?
    
    let injectionProvider: InjectionProvider
    
    @Published var areNotificationsEnabled: Bool
    
    @Published var isAsNeeded: Bool
    
    lazy var daysSubject: AnyPublisher<String?, Never> = {

          return currentValueSelectedDay.map({ days in
              print(days)
              return days.count == 1 ? days[0].shortened : days.map { $0.shortened }.joined(separator: ", ")
              
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
    
    var areFrequenciesValidPublisher: AnyPublisher<Bool, Never> {
        $frequencies.map { self.areFrequenciesValid(frequencies: $0) }
            .eraseToAnyPublisher()
    }
    
    var isValidInjectionPublisher: AnyPublisher<Bool, Never> {
           
        Publishers.CombineLatest3(isValidNamePublisher, isValidDosagePublisher, areFrequenciesValidPublisher).map { $0 && $1 && $2 }
            .eraseToAnyPublisher()
    }
    
    private var nameChangedPublisher: AnyPublisher<Bool, Never> {
        $name.map { $0 != self.injection!.name! }
            .eraseToAnyPublisher()
    }
    
    private var dosageChangedPublisher: AnyPublisher<Bool, Never> {
        $dosage.map { $0 != "\(self.injection!.dosage!)" }
            .eraseToAnyPublisher()
    }
    
    private var unitsChangedPublisher: AnyPublisher<Bool, Never> {
        $selectedUnits.map { $0 != self.injection!.unitsVal }
            .eraseToAnyPublisher()
    }
    
    private var notificationsChangedPublisher: AnyPublisher<Bool, Never> {
        $areNotificationsEnabled.map { $0 != self.injection!.areNotificationsEnabled }
            .eraseToAnyPublisher()
    }
    
    private var asNeededChangedPublisher: AnyPublisher<Bool, Never> {
        $isAsNeeded.map { value in
            if self.injection?.typeVal == .asNeeded && value {
                return false
            } else if self.injection?.typeVal == .scheduled && !value {
                return false
            } else{
                return true
            }
        }.eraseToAnyPublisher()
    }
    
    private var frequenciesChangedPublisher: AnyPublisher<Bool, Never> {
        $frequencies.map { frequenciesSelected in
            let currentInjection = self.injection!
            
            if currentInjection.typeVal == .scheduled {
                
                var freqCount = frequenciesSelected.count
                
                if let _ = self.selectedTimeCellIndex {
                    freqCount -= 1
                }
                
                if freqCount != currentInjection.frequency!.count {
                    return true
                }
                
                for freq in currentInjection.frequency as! Set<Frequency> {
                    
                    var contains = false
                    
                    for frequencySectionData in frequenciesSelected {
                        
                        if !frequencySectionData.isTimePickerCell {
                            
                            if freq.daysVal == frequencySectionData.days && freq.time!.prettyTime == frequencySectionData.time!.prettyTime {
                                contains = true
                                break
                            }
                        }
                        
                    }
                    
                    if !contains {
                        return true
                    }
                    
                }
                
            }
            return false
        }.eraseToAnyPublisher()
    }
    
    private var descriptionChangedPublisher: AnyPublisher<Bool, Never> {
        Publishers.CombineLatest3(nameChangedPublisher, dosageChangedPublisher, unitsChangedPublisher).map { $0 || $1 || $2 }
            .eraseToAnyPublisher()
    }
    
    var changesMadePublisher: AnyPublisher<Bool, Never> {
        
        if let injection {
            
           return Publishers.CombineLatest4(descriptionChangedPublisher, notificationsChangedPublisher, asNeededChangedPublisher, frequenciesChangedPublisher).map { $0 || $1 || $2 || $3 }
                .eraseToAnyPublisher()
        } else {
            return Publishers.CombineLatest3($name, $dosage, $frequencies).map { !$0.isEmpty || !$1.isEmpty || !$2.isEmpty }.eraseToAnyPublisher()
        }
    }
    
    var canSaveInjectionPublisher: AnyPublisher<Bool, Never> {
        
        Publishers.CombineLatest(isValidInjectionPublisher, changesMadePublisher).map { $0 && $1 }
            .eraseToAnyPublisher()
        
    }
    
    
    init(injectionProvider: InjectionProvider, injection: Injection?) {
        self.injectionProvider = injectionProvider
        self.injection = injection
        self.areNotificationsEnabled = true
        self.isAsNeeded = true
        
        if let injection{
            
            name = injection.name!
            dosage = "\(injection.dosage!)"
            selectedUnits = injection.unitsVal
            
            self.isAsNeeded = injection.typeVal == .asNeeded ? true : false
            self.areNotificationsEnabled = injection.areNotificationsEnabled
            
            for frequency in injection.frequency! as! Set<Frequency>{
                frequencies.append(EditInjectionTableViewController.FrequencySectionData(isTimePickerCell: false, days: frequency.daysVal, time: frequency.time))
                
            }
            
            
        }
    }
    
    func getShortenedString(forDays days: [Frequency.InjectionDay]) -> String {
        
        return days.count == 1 ? days[0].shortened : days.map { $0.shortened }.joined(separator: ", ")
    }
    
    func areFrequenciesValid(frequencies: [EditInjectionTableViewController.FrequencySectionData]) -> Bool{

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

