//
//  EditInjectionCoordinator.swift
//  SubQ
//
//  Created by Constantine Thalasinos on 5/8/23.
//

import UIKit

class EditInjectionCoordinator: Coordinator{
    var childCoordinators = [Coordinator]()
    
    var navigationController: UINavigationController
    
    var parentNavigationController: UINavigationController?
    
    weak var parentCoordinator: Coordinator?
    
    required init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let vc = EditInjectionTableViewController()
        vc.coordinator = self
        
        //navigationController.present(vc, animated: true)
        
        navigationController.pushViewController(vc, animated: false)
        
        vc.modalPresentationStyle = .automatic
        
        parentNavigationController!.present(navigationController, animated: true)
        
    }
    
    func cancelEdit(){
        parentNavigationController!.dismiss(animated: true)

        parentCoordinator?.childDidFinish(self)
    }
    
    func saveEdit(){
        parentNavigationController!.dismiss(animated: true)

        parentCoordinator?.childDidFinish(self)
    }
    
    
}
