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
    var storageProvider: StorageProvider
    let viewModel: BodyPartViewModel
    
    
    required init(navigationController: UINavigationController, parentCoordinator: Coordinator?, storageProvider: StorageProvider) {
        self.navigationController = navigationController
        self.storageProvider = storageProvider
        self.viewModel = BodyPartViewModel(storageProvider: storageProvider)
    }
    
    
    func start() {
        let vc = SettingsViewController(viewModel: viewModel)
        navigationController.pushViewController(vc, animated: false)
        
        vc.tabBarItem = UITabBarItem(title: "Settings", image: UIImage(systemName: "gear"), selectedImage: nil)
        vc.navigationItem.title = "Settings"
    }
    
    
}
