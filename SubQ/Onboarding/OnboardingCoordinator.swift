//
//  OnboardingCoordinator.swift
//  SubQ
//
//  Created by Constantine Thalasinos on 9/26/23.
//

import Foundation
import UIKit

class OnboardingCoordinator: Coordinator {
    var childCoordinators =  [Coordinator]()
    
    var navigationController: UINavigationController
    
    var parentCoordinator: Coordinator?
    
    var storageProvider: StorageProvider
    
    let viewModel: OnboardingViewModel
    
    init(navigationController: UINavigationController, parentCoordinator: Coordinator? = nil, storageProvider: StorageProvider) {
        self.navigationController = navigationController
        self.parentCoordinator = parentCoordinator
        self.storageProvider = storageProvider
        
        self.viewModel = OnboardingViewModel(storageProvider: storageProvider)
    }
    
    func start() {
        
        let vc = OnboardingViewController(viewModel: viewModel, coordinator: self)
        //vc.coordinator = self
        navigationController.pushViewController(vc, animated: false)
    }
    
    func startButtonPressed() {
        viewModel.updateEnabledBodyParts()
        
        navigationController.dismiss(animated: true)
        parentCoordinator!.childDidFinish(self)
        parentCoordinator!.start()
        
    }
    
    
}
