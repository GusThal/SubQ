//
//  MainTabController.swift
//  SubQ
//
//  Created by Constantine Thalasinos on 5/3/23.
//

import UIKit

class MainTabBarController: UITabBarController {
    
    let injectionTableCoordinator: InjectionCoordinator
    let injectionSiteCoordinator: InjectionSiteCoordinator
    let injectionHistoryCoordinator: InjectionHistoryCoordinator
    let settingsCoordinator: SettingsCoordinator
    
    let storageProvider: StorageProvider
    
    init(storageProvider: StorageProvider){
        self.storageProvider = storageProvider
        
        self.injectionTableCoordinator = InjectionCoordinator(navigationController: UINavigationController(), parentCoordinator: nil, storageProvider: storageProvider)
        self.injectionSiteCoordinator = InjectionSiteCoordinator(navigationController: UINavigationController(), parentCoordinator: nil, storageProvider: storageProvider)
        self.injectionHistoryCoordinator = InjectionHistoryCoordinator(navigationController: UINavigationController(), parentCoordinator: nil,  storageProvider: storageProvider)
        self.settingsCoordinator = SettingsCoordinator(navigationController: UINavigationController(),
        parentCoordinator: nil,  storageProvider: storageProvider)
        
        super.init(nibName: nil, bundle: nil)
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
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
