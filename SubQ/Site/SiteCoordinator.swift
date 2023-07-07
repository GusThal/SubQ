//
//  InjectionSectionCoordinator.swift
//  SubQ
//
//  Created by Constantine Thalasinos on 5/17/23.
//

import Foundation
import UIKit

class SiteCoordinator: Coordinator{
    

    weak var parentCoordinator: Coordinator?
    
    var childCoordinators =  [Coordinator]()
    
    var navigationController: UINavigationController
    
    var storageProvider: StorageProvider
    
    required init(navigationController: UINavigationController, parentCoordinator: Coordinator?, storageProvider: StorageProvider) {
        self.navigationController = navigationController
        self.parentCoordinator = parentCoordinator
        self.storageProvider = storageProvider
        
    }
    
    

    
    func start() {
        let vc = SiteViewController()
        vc.coordinator = self
        vc.siteCoordinator = self
        
        
        navigationController.pushViewController(vc, animated: true)
            
        //parentNavigationController!.present(navigationController, animated: true)
    }
    
    
}
