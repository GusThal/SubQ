//
//  MainCoordinator.swift
//  SubQ
//
//  Created by Constantine Thalasinos on 5/2/23.
//https://www.hackingwithswift.com/articles/71/how-to-use-the-coordinator-pattern-in-ios-apps
//

import UIKit

class MainCoordinator: Coordinator {
    var parentCoordinator: Coordinator?
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    var storageProvider: StorageProvider
    
    init(navigationController: UINavigationController, parentCoordinator: Coordinator?, storageProvider: StorageProvider) {
        self.navigationController = navigationController
        self.storageProvider = storageProvider
        
    }


    func start() {
        navigationController.setNavigationBarHidden(true, animated: true)
        let vc = MainTabBarController(coordinator: self, storageProvider: storageProvider)
        vc.tabBar.tintColor = InterfaceDefaults.primaryColor
        
        navigationController.pushViewController(vc, animated: false)
        
    
    }
    
    func startOnboardingFlow(){
        
        let child = OnboardingCoordinator(navigationController: self.navigationController, parentCoordinator: self, storageProvider: storageProvider)
        
        childCoordinators.append(child)
        
        child.start()
        
        
    }
}
