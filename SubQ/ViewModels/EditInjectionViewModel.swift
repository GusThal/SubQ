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
    
    let storageProvider: StorageProvider
    
    let days = Injection.Frequency.allCases.filter { ![Injection.Frequency.asNeeded, Injection.Frequency.daily].contains($0) }
    
    @Published var selectedFrequency = [Injection.Frequency]()
    
    
    lazy var frequencySubject: AnyPublisher<String?, Never> = {

        return $selectedFrequency.map({ frequency in
            return frequency.count == 1 ? frequency[0].shortened : frequency.map { $0.shortened }.joined(separator: ",")
            
        }).eraseToAnyPublisher()
    }()
    
    
    //datasource
    
    init(storageProvider: StorageProvider, injection: Injection?) {
        self.storageProvider = storageProvider
        self.injection = injection
        
        if let injection{
            
            //init other properties
        }
        
        
        

    }
    
    func saveInjection(isNewInjection: Bool){
        
        if isNewInjection{
            
        }
        
    }
    
    
    
}

