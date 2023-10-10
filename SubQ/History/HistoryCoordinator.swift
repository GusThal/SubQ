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
    let viewModel: HistoryViewModel
    
    init(navigationController: UINavigationController, parentCoordinator: Coordinator?, storageProvider: StorageProvider) {
        self.navigationController = navigationController
        self.storageProvider = storageProvider
        self.viewModel = HistoryViewModel(storageProvider: storageProvider)
    }

    
    func start() {
        let vc = HistoryTableViewController(viewModel: viewModel)
        vc.coordinator = self
        vc.historyCoordinator = self
        
        navigationController.pushViewController(vc, animated: false)
        navigationController.navigationBar.prefersLargeTitles = true
        navigationController.navigationBar.largeTitleTextAttributes = InterfaceDefaults.navigationBarLargeTextAttributes
       
        
        vc.tabBarItem = UITabBarItem(tabBarSystemItem: .history, tag: 0)
        vc.navigationItem.title = "Injection History"
        
        
        vc.tabBarItem = UITabBarItem(title: nil, image: UIImage(systemName: "clock"), selectedImage: UIImage(systemName: "clock.fill"))
        
        let backButton = UIBarButtonItem()
        backButton.tintColor = .label
        vc.navigationItem.backBarButtonItem = backButton
    }
    
    func showFilterController(){
        
        let child = FilterCoordinator(navigationController: UINavigationController(), parentNavigationController: navigationController, parentCoordinator: self, storageProvider: storageProvider, viewModel: viewModel)
        
        childCoordinators.append(child)
        
        child.start()
        
    }
    
    func showHistoryController(forObject history: History){
        
        let vc = HistoryViewController(history: history)
        
        vc.title = "Hello"
        
        navigationController.pushViewController(vc, animated: true)
        
    }
    
    
}
