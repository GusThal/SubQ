//
//  InjectionSiteCoordinator.swift
//  SubQ
//
//  Created by Constantine Thalasinos on 5/4/23.
//

import UIKit

class InjectionSiteCoordinator: NSObject, Coordinator, UINavigationControllerDelegate{
    
    var parentCoordinator: Coordinator?
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    var storageProvider: StorageProvider
    
    required init(navigationController: UINavigationController, parentCoordinator: Coordinator?, storageProvider: StorageProvider) {
        self.navigationController = navigationController
        self.storageProvider = storageProvider
    }
    
    
    func start() {
        let vc = InjectionSiteViewController()
        vc.coordinator = self
        navigationController.delegate = self
        navigationController.pushViewController(vc, animated: false)
        
        
        vc.tabBarItem = UITabBarItem(title: "Injection Sites", image: UIImage(systemName: "figure.arms.open"), selectedImage: nil)
        vc.navigationItem.title = "Injection Sites"
        
        let backButton = UIBarButtonItem()
        backButton.tintColor = .label
        vc.navigationItem.backBarButtonItem = backButton
    }
    
    func showInjectionBodyPart(bodyPart: BodyPart.Location, section: Site.InjectionSection){
        let child  = InjectionSectionCoordinator(navigationController: navigationController, parentCoordinator: self, storageProvider: storageProvider)
        
        
        childCoordinators.append(child)
        child.start()
        
        let vc = child.navigationController.viewControllers.last as! InjectionSectionViewController
        vc.bodyPart = bodyPart
        vc.section = section
    }
    
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        
        // Read the view controller we’re moving from.
        guard let fromViewController = navigationController.transitionCoordinator?.viewController(forKey: .from) else {
            return
        }

        // Check whether our view controller array already contains that view controller. If it does it means we’re pushing a different view controller on top rather than popping it, so exit.
        if navigationController.viewControllers.contains(fromViewController) {
            return
        }

        // We’re still here – it means we’re popping the view controller, so we can check whether it’s an InjectionSectionViewController
        if let sectionViewController = fromViewController as? InjectionSectionViewController {
            // We're popping a buy view controller; end its coordinator
            childDidFinish(sectionViewController.coordinator)
        }
    }
    
    
}
