//
//  SceneDelegate.swift
//  SubQ
//
//  Created by Constantine Thalasinos on 4/30/23.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    
    var coordinator: MainCoordinator?
    
    //let storageProvider = StorageProvider()
    
    


    //I think it makes the most sense to keep a MainCoordinator that launches the TabBarController. This Coordinator can instantiate the Login/account creation flow.
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        UNUserNotificationCenter.current().delegate = self
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        let newUser = false
        
       // let navController = UINavigationController()

        // send that into our coordinator so that it can display view controllers
        //coordinator = MainCoordinator(navigationController: navController)

        // tell the coordinator to take over control
        //coordinator?.start()
        
       // let tabBarController = MainTabBarController(storageProvider: storageProvider)
        
        let navigationController = UINavigationController()
       // navigationController.setNavigationBarHidden(true, animated: false)
        
        let mainCoordinator = MainCoordinator(navigationController: navigationController, parentCoordinator: nil, storageProvider: StorageProvider.shared)
        
        coordinator = mainCoordinator
        
        if newUser {
            mainCoordinator.startOnboardingFlow()
            
        } else {
            mainCoordinator.start()
        }

        // create a basic UIWindow and activate it
        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = mainCoordinator.navigationController
        window?.makeKeyAndVisible()
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        print("foreground")
        
        NotificationManager.populateInjectionQueueForExistingNotifications()
        
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            
            print("Pending notification count: \(requests.count)")
            
            for request in requests {
                print("\(request.identifier) | \(request.trigger?.repeats)")
            }
        }
        
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.

        // Save changes in the application's managed object context when the application transitions to the background.
        
        #warning("I commented this out, not sure if this will be needed")
       // (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
    }
    


}

extension SceneDelegate: UNUserNotificationCenterDelegate{
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        print("did receive")
        
        let userInfo = response.notification.request.content.userInfo
        
        //snoozed injections are already in the queue
        if response.actionIdentifier == UNNotificationDismissActionIdentifier && response.notification.request.content.categoryIdentifier == NotificationManager.NotificationCategoryIdentifier.scheduledInjection.rawValue{
            
            print("dismiss")
            
            NotificationManager.populateInjectionQueueFor(injectionNotifications: [response.notification])
        }
        
        
        else{
            
            let navController = window?.rootViewController as! UINavigationController
            
            let tabBarController = navController.topViewController as! MainTabBarController
            
            
            let selectedVC = tabBarController.selectedViewController
            
            var vcToPresentFrom: UIViewController!
            
            
            
            //check if the currently selected tab is displaying a modal view controller
            if let presented = selectedVC?.presentedViewController{
                
                var presentedVC = presented.presentedViewController
                
                while presentedVC != nil{
                    vcToPresentFrom = presentedVC
                    presentedVC = presentedVC!.presentedViewController
                }
                
                if vcToPresentFrom == nil{
                    vcToPresentFrom = presented
                }
                
                if let navController = vcToPresentFrom as? UINavigationController{
                    vcToPresentFrom = navController.topViewController
                }
                
            }
            
            else{
                
                //check if the currently selected VC is a UINavController. if so, get the top ViewController
                if let nav = selectedVC as? UINavigationController{
                    vcToPresentFrom = nav.topViewController
                }
                else{
                    vcToPresentFrom = selectedVC
                }
                
            }
            
            //check if the VC conforms to Coordinated--basically a protocol to indicate whether there's a coordinator object.
            if let vc = vcToPresentFrom as? Coordinated{
                
                
                let dateDue: Date = userInfo[NotificationManager.UserInfoKeys.originalDateDue.rawValue] as! Date? ?? response.notification.date
                
                print("due date \(dateDue)")
                
                let queueObjectID = userInfo[NotificationManager.UserInfoKeys.queueManagedObjectID.rawValue] as! String? ?? nil
                
                print("Queue Obj ID? \(queueObjectID)")
                
                
                vc.coordinator?.startInjectNowCoordinator(forInjectionObjectIDAsString: userInfo["injectionObjectID"] as! String, dateDue: dateDue, queueObjectIDAsString: queueObjectID)
            }
        }
        
        
        //vcToPresentFrom.present(navigationController, animated: true)
        
        
        completionHandler()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {

        completionHandler([.banner, .list, .sound])
        
        
    }
}

