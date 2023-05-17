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
    
    required init(navigationController: UINavigationController, parentCoordinator: Coordinator?) {
        self.navigationController = navigationController
    }
    
    
    func start() {
        let vc = InjectionSiteViewController()
        vc.coordinator = self
        navigationController.delegate = self
        navigationController.pushViewController(vc, animated: false)
        
        vc.tabBarItem = UITabBarItem(title: "Injection Sites", image: UIImage(systemName: "figure.arms.open"), selectedImage: nil)
        vc.navigationItem.title = "Injection Sites"
    }
    
    func showInjectionZone(){
        let child  = InjectionSectionCoordinator(navigationController: navigationController, parentCoordinator: self)
        
        childCoordinators.append(child)
        child.start()
    }
    
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        print("navigating...")
        
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
            print("got a section controller")
            childDidFinish(sectionViewController.coordinator)
        }
    }
    
    
}
