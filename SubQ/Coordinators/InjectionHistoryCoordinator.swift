//
//  InjectionHistoryCoordinator.swift
//  SubQ
//
//  Created by Constantine Thalasinos on 5/4/23.
//

import UIKit

class InjectionHistoryCoordinator: Coordinator{
    
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    
    required init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let vc = InjectionHistoryViewController()
        navigationController.pushViewController(vc, animated: false)
        
        vc.tabBarItem = UITabBarItem(tabBarSystemItem: .history, tag: 0)
        vc.navigationItem.title = "Injection History"
    }
    
    
}
