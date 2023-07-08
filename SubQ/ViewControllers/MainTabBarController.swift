//
//  MainTabController.swift
//  SubQ
//
//  Created by Constantine Thalasinos on 5/3/23.
//

import UIKit

class MainTabBarController: UITabBarController {
    
    let injectionTableCoordinator: InjectionCoordinator
    let siteCoordinator: SectionCoordinator
    let injectionHistoryCoordinator: HistoryCoordinator
    let settingsCoordinator: SettingsCoordinator
    
    weak var mainCoordinator: MainCoordinator?
    
    let dummyVCForInjectNow: UIViewController = {
        
        let vc = UIViewController()
        vc.tabBarItem = UITabBarItem(title: "Inject Now", image: UIImage(systemName: "syringe"), selectedImage: UIImage(systemName: "syringe.fill"))
        
        return vc
    }()
    
    let storageProvider: StorageProvider
    
    init(coordinator: MainCoordinator, storageProvider: StorageProvider){
        
        self.mainCoordinator = coordinator
        
        self.storageProvider = storageProvider
        
        self.injectionTableCoordinator = InjectionCoordinator(navigationController: UINavigationController(), parentCoordinator: nil, storageProvider: storageProvider)
        self.siteCoordinator = SectionCoordinator(navigationController: UINavigationController(), parentCoordinator: nil, storageProvider: storageProvider)
        self.injectionHistoryCoordinator = HistoryCoordinator(navigationController: UINavigationController(), parentCoordinator: nil,  storageProvider: storageProvider)
        self.settingsCoordinator = SettingsCoordinator(navigationController: UINavigationController(),
        parentCoordinator: nil,  storageProvider: storageProvider)
        
        
        super.init(nibName: nil, bundle: nil)
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.delegate = self
        
        
        
        viewControllers = [injectionTableCoordinator.navigationController, siteCoordinator.navigationController, dummyVCForInjectNow, injectionHistoryCoordinator.navigationController, settingsCoordinator.navigationController]
        
        injectionTableCoordinator.tabBarController = self
        
        injectionTableCoordinator.start()
        
        siteCoordinator.start()
        
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

extension MainTabBarController: UITabBarControllerDelegate{
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        
        print(settingsCoordinator)
        if !(viewController is UINavigationController){
            mainCoordinator!.startInjectNowCoordinator(forInjectionObjectIDAsString: nil)
            return false
        }
        else{
            return true
        }
        

    }
    
}
