//
//  InjectNowCoordinator.swift
//  SubQ
//
//  Created by Constantine Thalasinos on 7/5/23.
//

import Foundation
import UIKit

class InjectNowCoordinator: ModalChildCoordinator{
    var parentNavigationController: UINavigationController?
    
    var childCoordinators =  [Coordinator]()
    
    var navigationController: UINavigationController
    
    var parentCoordinator: Coordinator?
    
    var storageProvider: StorageProvider
    
    var injection: Injection?
    
    let viewModel: InjectNowViewModel
    
    let dateDue: Date?
    
    init(navigationController: UINavigationController, parentNavigationController: UINavigationController, parentCoordinator: Coordinator, storageProvider: StorageProvider, injectionIDString: String?, dateDue: Date?, queueObjectIDString: String?) {
        self.navigationController = navigationController
        self.parentNavigationController = parentNavigationController
        self.parentCoordinator = parentCoordinator
        self.storageProvider = storageProvider
        self.viewModel = InjectNowViewModel(storageProvider: storageProvider, injectionIDString: injectionIDString, dateDue: dateDue, queueObjectIDString: queueObjectIDString)
        self.dateDue = dateDue
        
    }
    
    
    func start() {
        let vc = InjectNowViewController(viewModel: viewModel)
        
        vc.coordinator = self
        vc.injectNowCoordinator = self
        
        //navigationController.present(vc, animated: true)
        
        navigationController.navigationBar.prefersLargeTitles = true
        
        navigationController.pushViewController(vc, animated: false)
        
        vc.modalPresentationStyle = .automatic
        
        parentNavigationController!.present(navigationController, animated: true)
        
    }
    
    func injectPressed(){
        dismissViewController()
    }
    
    func dismissViewController(){
        parentNavigationController!.dismiss(animated: true)
        

        parentCoordinator?.childDidFinish(self)
    }
    
    func showSelectInjectionViewController(){
        let child = SelectInjectionCoordinator(navigationController: UINavigationController(), parentNavigationController: self.navigationController, parentCoordinator: self, storageProvider: storageProvider, viewModel: viewModel)
        
        childCoordinators.append(child)
        
        child.start()
        
    }
    
    
}
