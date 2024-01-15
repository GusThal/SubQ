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
    
    
    init(navigationController: UINavigationController, parentCoordinator: Coordinator?, storageProvider: StorageProvider) {
        self.navigationController = navigationController
        self.storageProvider = storageProvider
        self.viewModel = BodyPartViewModel(storageProvider: storageProvider)
    }
    
    
    func start() {
        let vc = SettingsViewController(viewModel: viewModel)
        vc.coordinator = self
        vc.settingsCoordinator = self
        
        navigationController.pushViewController(vc, animated: false)
        
        navigationController.navigationBar.prefersLargeTitles = true
        navigationController.navigationBar.largeTitleTextAttributes = InterfaceDefaults.navigationBarLargeTextAttributes
        
        vc.tabBarItem = UITabBarItem(title: nil, image: UIImage(systemName: "gear"), selectedImage: nil)
        vc.navigationItem.title = "Settings"
        vc.navigationItem.backButtonTitle = ""
    }
     
    func showScreenLockSettingsController(){
        
        let vc = ScreenLockSettingsViewController(style: .insetGrouped)
        
        vc.coordinator = self
        
        vc.title = "Screen Lock"
        
        navigationController.pushViewController(vc, animated: true)
        
    }
    
    
}
