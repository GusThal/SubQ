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
    
    init(navigationController: UINavigationController, parentCoordinator: Coordinator?)

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
}

protocol ModalChildCoordinator: Coordinator{
    var parentNavigationController: UINavigationController? { get set }
    
    init(navigationController: UINavigationController, parentNavigationController: UINavigationController, parentCoordinator: Coordinator)
}
