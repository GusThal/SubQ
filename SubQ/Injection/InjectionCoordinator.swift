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
    let viewModel: InjectionViewModel
    
    
    init(navigationController: UINavigationController, parentCoordinator: Coordinator?, storageProvider: StorageProvider) {
        self.navigationController = navigationController
        self.storageProvider = storageProvider
        
        viewModel = InjectionViewModel(storageProvider: storageProvider)
    }
    
    func start() {
        let vc = InjectionTableViewController(viewModel: viewModel)
        
        vc.coordinator = self
        vc.injectionCoordinator = self
        
        vc.setLogoTitleView()
        
        navigationController.navigationBar.prefersLargeTitles = true
        navigationController.navigationBar.largeTitleTextAttributes = InterfaceDefaults.navigationBarLargeTextAttributes
        
        navigationController.pushViewController(vc, animated: false)
        
        vc.tabBarItem = UITabBarItem(title: nil, image: UIImage(systemName: "cross.vial"), selectedImage: UIImage(systemName: "cross.vial.fill"))

       vc.navigationItem.title = "Your Injections"
    }
    
    func addInjection(){
        
        
        let child  = EditInjectionCoordinator(navigationController: UINavigationController(), parentNavigationController: self.navigationController, parentCoordinator: self, storageProvider: storageProvider, injectionProvider: viewModel.injectionProvider, injection: nil)
        
        childCoordinators.append(child)
        child.start()
        
    }
    
    func editInjection(_ injection: Injection){
        
        let child  = EditInjectionCoordinator(navigationController: UINavigationController(), parentNavigationController: self.navigationController, parentCoordinator: self, storageProvider: storageProvider, injectionProvider: viewModel.injectionProvider, injection: injection)
        
        childCoordinators.append(child)
        child.start()
        
        
    }
    
 
    
    
}

