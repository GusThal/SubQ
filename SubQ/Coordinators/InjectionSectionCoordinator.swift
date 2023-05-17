//
//  InjectionSectionCoordinator.swift
//  SubQ
//
//  Created by Constantine Thalasinos on 5/17/23.
//

import Foundation
import UIKit

class InjectionSectionCoordinator: Coordinator{
    

    weak var parentCoordinator: Coordinator?
    
    var childCoordinators =  [Coordinator]()
    
    var navigationController: UINavigationController
    
    required init(navigationController: UINavigationController, parentCoordinator: Coordinator?) {
        self.navigationController = navigationController
        self.parentCoordinator = parentCoordinator
        
    }
    
    
    required init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let vc = InjectionSectionViewController()
        vc.coordinator = self
        
        
        navigationController.pushViewController(vc, animated: true)
            
        //parentNavigationController!.present(navigationController, animated: true)
    }
    
    
}
