//
//  MainTabController.swift
//  SubQ
//
//  Created by Constantine Thalasinos on 5/3/23.
//

import UIKit

class MainTabBarController: UITabBarController {
    
    let injectionTableCoordinator = InjectionTableCoordinator(navigationController: UINavigationController(), parentCoordinator: nil)
    let injectionSiteCoordinator = InjectionSiteCoordinator(navigationController: UINavigationController(), parentCoordinator: nil)
    let injectionHistoryCoordinator = InjectionHistoryCoordinator(navigationController: UINavigationController(), parentCoordinator: nil)
    let settingsCoordinator = SettingsCoordinator(navigationController: UINavigationController(),
    parentCoordinator: nil)

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewControllers = [injectionTableCoordinator.navigationController, injectionSiteCoordinator.navigationController, injectionHistoryCoordinator.navigationController, settingsCoordinator.navigationController]
        
        injectionTableCoordinator.tabBarController = self
        
        injectionTableCoordinator.start()
        
        injectionSiteCoordinator.start()
        
        injectionHistoryCoordinator.start()
        
        settingsCoordinator.start()
        
        
        view.backgroundColor = .green

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
