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
    
    required init(navigationController: UINavigationController, parentCoordinator: Coordinator?, storageProvider: StorageProvider) {
        self.navigationController = navigationController
        self.storageProvider = storageProvider
        
    }


    func start() {
        let vc = MainTabBarController(storageProvider: storageProvider)
        navigationController.pushViewController(vc, animated: false)
    }
}
