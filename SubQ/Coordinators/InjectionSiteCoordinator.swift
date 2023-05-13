//
//  InjectionSiteCoordinator.swift
//  SubQ
//
//  Created by Constantine Thalasinos on 5/4/23.
//

import UIKit

class InjectionSiteCoordinator: Coordinator{
    
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    
    required init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let vc = InjectionSiteViewController()
        navigationController.pushViewController(vc, animated: false)
        
        vc.tabBarItem = UITabBarItem(title: "Injection Sites", image: UIImage(systemName: "figure.arms.open"), selectedImage: nil)
        vc.navigationItem.title = "Injection Sites"
    }
    
    
}
