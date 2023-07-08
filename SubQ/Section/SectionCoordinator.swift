//
//  InjectionSiteCoordinator.swift
//  SubQ
//
//  Created by Constantine Thalasinos on 5/4/23.
//

import UIKit

class SectionCoordinator: NSObject, Coordinator, UINavigationControllerDelegate{
    
    var parentCoordinator: Coordinator?
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    var storageProvider: StorageProvider
    let viewModel: SectionViewModel
    
    required init(navigationController: UINavigationController, parentCoordinator: Coordinator?, storageProvider: StorageProvider) {
        self.navigationController = navigationController
        self.storageProvider = storageProvider
        self.viewModel = SectionViewModel(storageProvider: storageProvider)
    }
    
    
    func start() {
        let vc = SectionViewController(viewModel: viewModel)
        vc.coordinator = self
        vc.sectionCoordinator = self
        
        navigationController.delegate = self
        navigationController.pushViewController(vc, animated: false)
        
        
        vc.tabBarItem = UITabBarItem(title: "Injection Sites", image: UIImage(systemName: "figure.arms.open"), selectedImage: nil)
        vc.navigationItem.title = "Injection Sites"
        
        let backButton = UIBarButtonItem()
        backButton.tintColor = .label
        vc.navigationItem.backBarButtonItem = backButton
    }
    
    func showSites(forSection section: Section){
        let child  = SiteCoordinator(navigationController: navigationController, parentCoordinator: self, storageProvider: storageProvider, section: section)
        
        
        childCoordinators.append(child)
        child.start()
        
        let vc = child.navigationController.viewControllers.last as! SiteViewController
        
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
        if let sectionViewController = fromViewController as? SiteViewController {
            // We're popping a buy view controller; end its coordinator
            childDidFinish(sectionViewController.coordinator)
        }
    }
    
    
}
