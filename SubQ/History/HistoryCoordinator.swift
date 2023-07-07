//
//  InjectionHistoryCoordinator.swift
//  SubQ
//
//  Created by Constantine Thalasinos on 5/4/23.
//

import UIKit

class HistoryCoordinator: Coordinator{
    var parentCoordinator: Coordinator?
    
    
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    var storageProvider: StorageProvider
    
    required init(navigationController: UINavigationController, parentCoordinator: Coordinator?, storageProvider: StorageProvider) {
        self.navigationController = navigationController
        self.storageProvider = storageProvider
    }

    
    func start() {
        let vc = HistoryViewController()
        vc.coordinator = self
        vc.historyCoordinator = self
        
        navigationController.pushViewController(vc, animated: false)
        navigationController.navigationBar.prefersLargeTitles = true
       
        
        vc.tabBarItem = UITabBarItem(tabBarSystemItem: .history, tag: 0)
        vc.navigationItem.title = "Injection History"
    }
    
    
}
