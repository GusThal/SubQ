//
//  FrequencyCoordinator.swift
//  SubQ
//
//  Created by Constantine Thalasinos on 5/13/23.
//

import Foundation
import UIKit

class FrequencyCoordinator: ChildCoordinator{
    weak var parentNavigationController: UINavigationController?
    
    weak var parentCoordinator: Coordinator?
    
    required init(navigationController: UINavigationController, parentNavigationController: UINavigationController, parentCoordinator: Coordinator) {
        self.navigationController = navigationController
        self.parentNavigationController = parentNavigationController
        self.parentCoordinator = parentCoordinator
    }
    
    required init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    var childCoordinators = [Coordinator]()
    
    var navigationController: UINavigationController
    
    
    
    func start() {
        let vc = FrequencyViewController()
        vc.coordinator = self
        
        //navigationController.present(vc, animated: true)
        
        navigationController.pushViewController(vc, animated: false)
        
        vc.modalPresentationStyle = .automatic
        
        parentNavigationController!.present(navigationController, animated: true)
    }
    
    func done(){
        parentNavigationController!.dismiss(animated: true)

        parentCoordinator?.childDidFinish(self)
    }
    
    
}
