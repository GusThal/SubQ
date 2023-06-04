//
//  InjectionTableCoordinator.swift
//  SubQ
//
//  Created by Constantine Thalasinos on 5/4/23.
//

import UIKit

class InjectionCoordinator: Coordinator{
    
    var parentCoordinator: Coordinator?
    
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    weak var tabBarController: UITabBarController?
    var storageProvider: StorageProvider
    let injectionProvider: InjectionProvider
    let viewModel: InjectionViewModel
    
    
    required init(navigationController: UINavigationController, parentCoordinator: Coordinator?, storageProvider: StorageProvider) {
        self.navigationController = navigationController
        self.storageProvider = storageProvider
        self.injectionProvider = InjectionProvider(storageProvider: storageProvider)
        
        viewModel = InjectionViewModel(storageProvider: storageProvider)
    }
    
    func start() {
        let vc = InjectionViewController(viewModel: viewModel)
        
        vc.coordinator = self
        navigationController.navigationBar.prefersLargeTitles = true
        
        navigationController.pushViewController(vc, animated: false)
        vc.tabBarItem = UITabBarItem(title: "Injections", image: UIImage(systemName: "cross.vial"), selectedImage: UIImage(systemName: "cross.vial.fill"))

        vc.navigationItem.title = "Injections"
    }
    
    func addInjection(){
        
       /* let vc = EditInjectionViewController()
        
        let nc = UINavigationController(rootViewController: vc)
        
        vc.modalPresentationStyle = .automatic
        
        navigationController.viewControllers.first!.present(nc, animated: true)*/
        
        
        let child  = EditInjectionCoordinator(navigationController: UINavigationController(), parentNavigationController: self.navigationController, parentCoordinator: self, storageProvider: storageProvider, injectionProvider: viewModel.injectionProvider)
        
        childCoordinators.append(child)
        child.start()
        
    }
    
 
    
    
}

