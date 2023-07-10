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
    
    
    init(navigationController: UINavigationController, parentNavigationController: UINavigationController, parentCoordinator: Coordinator, storageProvider: StorageProvider, injectionIDString: String?) {
        self.navigationController = navigationController
        self.parentNavigationController = parentNavigationController
        self.parentCoordinator = parentCoordinator
        self.storageProvider = storageProvider
        self.viewModel = InjectNowViewModel(storageProvider: storageProvider, injectionIDString: injectionIDString)
    }
    
    
    required init(navigationController: UINavigationController, parentNavigationController: UINavigationController, parentCoordinator: Coordinator, storageProvider: StorageProvider) {
        self.navigationController = navigationController
        self.parentNavigationController = parentNavigationController
        self.parentCoordinator = parentCoordinator
        self.storageProvider = storageProvider
        self.viewModel = InjectNowViewModel(storageProvider: storageProvider, injectionIDString: nil)
    }
    
  
    
    required init(navigationController: UINavigationController, parentCoordinator: Coordinator?, storageProvider: StorageProvider) {
        self.navigationController = navigationController
        self.parentCoordinator = parentCoordinator
        self.storageProvider = storageProvider
        self.viewModel = InjectNowViewModel(storageProvider: storageProvider, injectionIDString: nil)
    }
    
    func start() {
        let vc = InjectNowViewController(viewModel: viewModel)
        
        //navigationController.present(vc, animated: true)
        
        navigationController.navigationBar.prefersLargeTitles = true
        
        navigationController.pushViewController(vc, animated: false)
        
        vc.modalPresentationStyle = .automatic
        
        parentNavigationController!.present(navigationController, animated: true)
        
    }
    
    
}
