//
//  Coordinator.swift
//  SubQ
//
//  Created by Constantine Thalasinos on 5/2/23.

//https://www.hackingwithswift.com/articles/71/how-to-use-the-coordinator-pattern-in-ios-apps

//

import UIKit

protocol Coordinator: AnyObject {
    var childCoordinators: [Coordinator] { get set }
    var navigationController: UINavigationController { get set }
    var parentCoordinator: Coordinator? { get set }
    var storageProvider: StorageProvider {get set}
    
    init(navigationController: UINavigationController, parentCoordinator: Coordinator?, storageProvider: StorageProvider)

    func start()
}

extension Coordinator{
    func childDidFinish(_ child: Coordinator?) {
        for (index, coordinator) in childCoordinators.enumerated() {
            if coordinator === child {
                childCoordinators.remove(at: index)
                print("Child coords \(childCoordinators)")
                break
            }
        }
    }
    
    func startInjectNowCoordinator(forInjectionObjectIDAsString idString: String?){
        
        print("starting coordinator")
        
        let injectNowCoordinator = InjectNowCoordinator(navigationController: UINavigationController(), parentNavigationController: navigationController, parentCoordinator: self, storageProvider: storageProvider)
        
        childCoordinators.append(injectNowCoordinator)
        
        injectNowCoordinator.start()
    }
    
}

protocol ModalChildCoordinator: Coordinator{
    var parentNavigationController: UINavigationController? { get set }
    
    init(navigationController: UINavigationController, parentNavigationController: UINavigationController, parentCoordinator: Coordinator, storageProvider: StorageProvider)
}
