//
//  InjectionViewModel.swift
//  SubQ
//
//  Created by Constantine Thalasinos on 5/29/23.
//

import Foundation
import Combine

class EditInjectionViewModel{
    
    let injection: Injection?
    
    var cancellables = Set<AnyCancellable>()
    
    
    let days = Injection.Frequency.allCases.filter { ![Injection.Frequency.asNeeded, Injection.Frequency.daily].contains($0) }
    
    @Published var selectedFrequency = [Injection.Frequency]()
    
    let injectionProvider: InjectionProvider
    
    
    lazy var frequencySubject: AnyPublisher<String?, Never> = {

        return $selectedFrequency.map({ frequency in
            return frequency.count == 1 ? frequency[0].shortened : frequency.map { $0.shortened }.joined(separator: ", ")
            
        }).eraseToAnyPublisher()
    }()
    
    
    //datasource
    
    init(injectionProvider: InjectionProvider, injection: Injection?) {
        self.injectionProvider = injectionProvider
        self.injection = injection
       
        
        if let injection{
            
            selectedFrequency = injection.daysVal
            
            //init other properties
        }
        

    }
    
    
    func saveInjection(name: String, dosage: Double, units: Injection.DosageUnits, frequency: [Injection.Frequency], time: Date?) {
        
        injectionProvider.saveInjection(name: name, dosage: dosage, units: units, frequency: frequency, time: time)
        
        
    }
    
    func updateInjection(injection: Injection, name: String, dosage: Double, units: Injection.DosageUnits, frequency: [Injection.Frequency], time: Date?) {
        
        injectionProvider.updateInjection(injection: injection, name: name, dosage: dosage, units: units, frequency: frequency, time: time)
        
        
    }

    
    
}

