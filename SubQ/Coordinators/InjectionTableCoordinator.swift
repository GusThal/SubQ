//
//  InjectionTableCoordinator.swift
//  SubQ
//
//  Created by Constantine Thalasinos on 5/4/23.
//

import UIKit

class InjectionTableCoordinator: Coordinator{
    
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    weak var tabBarController: UITabBarController?
    
    required init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    init(navigationController: UINavigationController, tabBarController: UITabBarController){
        self.navigationController = navigationController
        self.tabBarController = tabBarController
    }
    
    func start() {
        let vc = InjectionCollectionViewController()
        vc.coordinator = self
        
        navigationController.pushViewController(vc, animated: false)
        vc.tabBarItem = UITabBarItem(title: "Injections", image: UIImage(systemName: "cross.vial"), selectedImage: UIImage(systemName: "cross.vial.fill"))

        vc.navigationItem.title = "Injections"
    }
    
    func addInjection(){
        
       /* let vc = EditInjectionViewController()
        
        let nc = UINavigationController(rootViewController: vc)
        
        vc.modalPresentationStyle = .automatic
        
        navigationController.viewControllers.first!.present(nc, animated: true)*/
        
        
        let child = EditInjectionCoordinator(navigationController: UINavigationController())
        child.parentCoordinator = self
        child.parentNavigationController = self.navigationController
        
        childCoordinators.append(child)
        child.start()
        
    }
    
 
    
    
}

