//
//  AppDelegate.swift
//  SubQ
//
//  Created by Constantine Thalasinos on 4/30/23.
//

import UIKit
import CoreData
import UserNotifications

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    enum Keys: String {
        case userOnboarded = "isUserOnboarded"
        case bodyPartsPopulated = "areBodyPartsPopulated"
    }
    

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        
//        registerForNotifications()
        
        registerNotificationCategories()
        

        if !UserDefaults.standard.bool(forKey: Keys.bodyPartsPopulated.rawValue) {

            let storageProvider = StorageProvider.shared
                
            let bodyPartProvider = BodyPartProvider(storageProvider: storageProvider)
                
            bodyPartProvider.insertInitialData()
                
            let sectionProvider = SectionProvider(storageProvider: storageProvider)
                
            sectionProvider.insertInitialData()
                
            let siteProvider = SiteProvider(storageProvider: storageProvider)
                
            siteProvider.insertInitialData()
            
            UserDefaults.standard.setValue(true, forKey: Keys.bodyPartsPopulated.rawValue)
        }
        
        
        return true
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        
        completionHandler(.newData)
    }
   
    func registerNotificationCategories(){
        
        
        let center = UNUserNotificationCenter.current()
        
        
        let category = UNNotificationCategory(identifier: NotificationManager.NotificationCategoryIdentifier.scheduledInjection.rawValue, actions: [], intentIdentifiers: [], options: [.customDismissAction, .hiddenPreviewsShowTitle, .hiddenPreviewsShowSubtitle, .allowInCarPlay])
        
        center.setNotificationCategories([category])
        
    }
    
    
    func registerForNotifications(){
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .carPlay, .sound, .criticalAlert, .provisional] ) { success, error in
            if success {
                print("Registered for notifications")
            } else if let error = error {
                print(error.localizedDescription)
            }
        }
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

}


