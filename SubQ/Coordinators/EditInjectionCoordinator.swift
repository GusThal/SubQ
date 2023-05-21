//
//  EditInjectionCoordinator.swift
//  SubQ
//
//  Created by Constantine Thalasinos on 5/8/23.
//

import UIKit

class EditInjectionCoordinator: ModalChildCoordinator{

    
    
    var childCoordinators = [Coordinator]()
    
    var navigationController: UINavigationController
    
    weak var parentNavigationController: UINavigationController?
    
    weak var parentCoordinator: Coordinator?
    
    required init(navigationController: UINavigationController, parentCoordinator: Coordinator?) {
        self.navigationController = navigationController
    }
    
    required init(navigationController: UINavigationController, parentNavigationController: UINavigationController, parentCoordinator: Coordinator) {
        self.navigationController = navigationController
        self.parentNavigationController = parentNavigationController
        self.parentCoordinator = parentCoordinator
    }
    
    func start() {
        let vc = EditInjectionViewController()
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
    
    func showFrequencyController(){
        let child  = FrequencyCoordinator(navigationController: UINavigationController(), parentNavigationController: self.navigationController, parentCoordinator: self)
        
        childCoordinators.append(child)
        child.start()
    }
    
    
}
