//
//  InjectNowCoordinator.swift
//  SubQ
//
//  Created by Constantine Thalasinos on 7/5/23.
//

import Foundation
import UIKit

class InjectNowCoordinator: ModalChildCoordinator{
    var parentNavigationController: UINavigationController?
    
    var childCoordinators =  [Coordinator]()
    
    var navigationController: UINavigationController
    
    var parentCoordinator: Coordinator?
    
    var storageProvider: StorageProvider
    
    var injection: Injection?
    
    let viewModel: InjectNowViewModel
    
    let dateDue: Date?
    
    init(navigationController: UINavigationController, parentNavigationController: UINavigationController, parentCoordinator: Coordinator, storageProvider: StorageProvider, injectionIDString: String?, dateDue: Date?, queueObjectIDString: String?) {
        self.navigationController = navigationController
        self.parentNavigationController = parentNavigationController
        self.parentCoordinator = parentCoordinator
        self.storageProvider = storageProvider
        self.viewModel = InjectNowViewModel(storageProvider: storageProvider, injectionIDString: injectionIDString, dateDue: dateDue, queueObjectIDString: queueObjectIDString)
        self.dateDue = dateDue
        
    }
    
    
    func start() {
        let vc = InjectNowViewController(viewModel: viewModel)
        
        vc.coordinator = self
        vc.injectNowCoordinator = self
        
        //navigationController.present(vc, animated: true)
        
        navigationController.navigationBar.prefersLargeTitles = true
        navigationController.navigationBar.largeTitleTextAttributes = InterfaceDefaults.navigationBarLargeTextAttributes
        
        navigationController.pushViewController(vc, animated: false)
        
        vc.modalPresentationStyle = .automatic
        
        vc.isModalInPresentation = true
        
        parentNavigationController!.present(navigationController, animated: true)
        
    }
    
    func injectPressed(injection: Injection){
        parentNavigationController!.dismiss(animated: true)
        
        var vc = parentNavigationController!.topViewController!
        
        if let tabController = vc as? MainTabBarController {
            print("tab")
            
            vc = tabController.selectedViewController!
        }
        
        let str = "\(injection.descriptionString) injected"
        
        vc.showConfirmationView(message: str, color: .systemBlue)

        parentCoordinator?.childDidFinish(self)
    }
    
    func snoozedPressed(injection: Injection) {
        parentNavigationController!.dismiss(animated: true)
        
        let vc = parentNavigationController!.topViewController!
        
        let str = "\(injection.descriptionString) snoozed"
        
        vc.showConfirmationView(message: str, color: .systemOrange)
    
        parentCoordinator?.childDidFinish(self)
    }
    
    func skipPressed(injection: Injection) {
        parentNavigationController!.dismiss(animated: true)
        
        let vc = parentNavigationController!.topViewController!
        
        let str = "\(injection.descriptionString) skipped"
        
        vc.showConfirmationView(message: str, color: .systemRed)
    
        parentCoordinator?.childDidFinish(self)
    }
    
    //for close button pressed, and also when the user has zero scheduled injections and clicks the "schedule injection" button
    func dismissViewController(){
        parentNavigationController!.dismiss(animated: true)
        

        parentCoordinator?.childDidFinish(self)
    }
    
    func showSelectInjectionViewController(){
        let child = SelectInjectionCoordinator(navigationController: UINavigationController(), parentNavigationController: self.navigationController, parentCoordinator: self, storageProvider: storageProvider, viewModel: viewModel)
        
        childCoordinators.append(child)
        
        child.start()
        
    }
    
    
}
