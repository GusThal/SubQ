//
//  OnboardingViewModel.swift
//  SubQ
//
//  Created by Constantine Thalasinos on 9/30/23.
//

import Foundation
import Combine
import UIKit
import CoreData

class OnboardingViewModel {
    let storageProvider: StorageProvider
    let bodyPartProvider: BodyPartProvider
    var cancellables = Set<AnyCancellable>()
    
    let bodyParts = BodyPart.Location.allCases.sorted { part1, part2 in
        return part1.rawValue < part2.rawValue
    }
    
    var selectedBodyParts = Array(repeating: true, count: 4) 
    
    lazy var bodyPartSnapshot: AnyPublisher<NSDiffableDataSourceSnapshot<Int, NSManagedObjectID>?, Never> = {
        return bodyPartProvider.$snapshot.eraseToAnyPublisher()
    }()
    
    init(storageProvider: StorageProvider) {
        self.storageProvider = storageProvider
        self.bodyPartProvider = BodyPartProvider(storageProvider: storageProvider)
        
    }
    
    func updateEnabledBodyParts() {
        for (index, id) in bodyPartProvider.snapshot!.itemIdentifiers.enumerated() {
            let obj = bodyPartProvider.object(withObjectID: id)
            setEnabled(forBodyPart: obj, to: selectedBodyParts[index])
            
        }
    }
    
    func setEnabled(forBodyPart bodyPart: BodyPart, to enabled: Bool) {
        bodyPartProvider.setEnabled(forBodyPart: bodyPart, to: enabled)
    }
    
    func bodyPart(at indexPath: IndexPath) -> BodyPart {
        bodyPartProvider.object(at: indexPath)
    }
}
