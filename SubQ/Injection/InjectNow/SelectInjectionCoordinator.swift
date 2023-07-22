//
//  SelectInjectionCoordinator.swift
//  SubQ
//
//  Created by Constantine Thalasinos on 7/20/23.
//

import Foundation
import UIKit

class SelectInjectionCoordinator: ModalChildCoordinator{
    var parentNavigationController: UINavigationController?
    let viewModel: InjectNowViewModel?
    
    var childCoordinators = [Coordinator]()
    
    var navigationController: UINavigationController
    
    var parentCoordinator: Coordinator?
    
    var storageProvider: StorageProvider
    
    
    required init(navigationController: UINavigationController, parentNavigationController: UINavigationController, parentCoordinator: Coordinator, storageProvider: StorageProvider, viewModel: InjectNowViewModel) {
        
        self.navigationController = navigationController
        self.parentNavigationController = parentNavigationController
        self.parentCoordinator = parentCoordinator
        self.storageProvider = storageProvider
        self.viewModel = viewModel
        
    }
    
    required init(navigationController: UINavigationController, parentNavigationController: UINavigationController, parentCoordinator: Coordinator, storageProvider: StorageProvider) {
        
        self.navigationController = navigationController
        self.parentNavigationController = parentNavigationController
        self.parentCoordinator = parentCoordinator
        self.storageProvider = storageProvider
        self.viewModel = nil
    
    }
    
    
    required init(navigationController: UINavigationController, parentCoordinator: Coordinator?, storageProvider: StorageProvider) {
        self.navigationController = navigationController
        self.parentCoordinator = parentCoordinator
        self.storageProvider = storageProvider
        self.viewModel = nil
    }
    
    func start() {
        let vc = SelectInjectionViewController(viewModel: viewModel!)
        
        
        vc.coordinator = self
        vc.selectInjectionCoordinator = self
        
        navigationController.modalPresentationStyle = .pageSheet
        
       
        vc.title = "Select Injection"
        
        if let presentationController = navigationController.presentationController as? UISheetPresentationController {
            presentationController.detents = [.medium(), .large()]
            presentationController.prefersGrabberVisible = true
            presentationController.prefersScrollingExpandsWhenScrolledToEdge = false
            presentationController.preferredCornerRadius = 20
        }
        
        navigationController.pushViewController(vc, animated: false)
        
        
        
        parentNavigationController!.present(navigationController, animated: true)
    }
    
    func dismiss(){
        parentNavigationController!.dismiss(animated: true)
        
        parentCoordinator?.childDidFinish(self)
    }
    
    
}
