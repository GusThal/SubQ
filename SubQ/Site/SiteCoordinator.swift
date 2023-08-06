//
//  InjectionSectionCoordinator.swift
//  SubQ
//
//  Created by Constantine Thalasinos on 5/17/23.
//

import Foundation
import UIKit

class SiteCoordinator: Coordinator{
    

    weak var parentCoordinator: Coordinator?
    
    var childCoordinators =  [Coordinator]()
    
    var navigationController: UINavigationController
    
    var storageProvider: StorageProvider
    
    var viewModel: SiteViewModel?
    
    
    init(navigationController: UINavigationController, parentCoordinator: Coordinator?, storageProvider: StorageProvider, section: Section) {
        self.navigationController = navigationController
        self.parentCoordinator = parentCoordinator
        self.storageProvider = storageProvider
        self.viewModel = SiteViewModel(storageProvider: storageProvider, section: section)
       
   }

    
    func start() {
        let vc = SiteViewController(viewModel: viewModel!)
        vc.coordinator = self
        vc.siteCoordinator = self
        
        
        navigationController.pushViewController(vc, animated: true)
            
        //parentNavigationController!.present(navigationController, animated: true)
    }
    
    
}
