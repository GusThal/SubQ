//
//  MainCoordinator.swift
//  SubQ
//
//  Created by Constantine Thalasinos on 5/2/23.
//https://www.hackingwithswift.com/articles/71/how-to-use-the-coordinator-pattern-in-ios-apps
//

import UIKit

class MainCoordinator: Coordinator {
    
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController

    required init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        let vc = MainTabBarController()
        navigationController.pushViewController(vc, animated: false)
    }
}
