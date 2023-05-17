//
//  SettingsCoordinator.swift
//  SubQ
//
//  Created by Constantine Thalasinos on 5/4/23.
//

import UIKit

class SettingsCoordinator: Coordinator{
    
    var parentCoordinator: Coordinator?
    
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    
    
    required init(navigationController: UINavigationController, parentCoordinator: Coordinator?) {
        self.navigationController = navigationController
    }
    
    
    func start() {
        let vc = SettingsViewController()
        navigationController.pushViewController(vc, animated: false)
        
        vc.tabBarItem = UITabBarItem(title: "Settings", image: UIImage(systemName: "gear"), selectedImage: nil)
        vc.navigationItem.title = "Settings"
    }
    
    
}
