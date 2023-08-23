//
//  InjectionNotifications.swift
//  SubQ
//
//  Created by Constantine Thalasinos on 7/2/23.
//

import Foundation
import NotificationCenter
import CoreData


class NotificationManager{
    
    enum UserInfoKeys: String{
        case injectionManagednObjectID = "injectionObjectID"
        case originalDateDue = "originalDateDue"
        case queueManagedObjectID = "queueObjectID"
    }
    
    enum NotificationCategoryIdentifier: String{
        case scheduledInjection = "ScheduledInjectionNotification", snoozedInjection = "SnoozedInjectionNotification"
    }
    
    
    //name-dosage-units-day-time
    //name-dosage-units-day-time-due-originalDateDue-snoozed-snoozedUntil
    static func getNotificationIDs(forInjection injection: Injection, snoozedUntil: Date?, originalDateDue: Date?, frequency: Frequency?) -> [String]{
  
        var identifiers = [String]()
        
        if let snoozedUntil, let originalDateDue {
            let weekday = Calendar.current.component(.weekday, from: originalDateDue)
            
            identifiers.append("\(injection.name!)-\(injection.dosage!)-\(injection.unitsVal.rawValue)-\(weekday)-\(originalDateDue.prettyTime)-due-\(originalDateDue)-snoozed-\(snoozedUntil)")
        }
        
        else{
            
            if frequency!.daysVal == [.daily]{
                identifiers.append("\(injection.name!)-\(injection.dosage!)-\(injection.unitsVal.rawValue)-\(Frequency.InjectionDay.daily.rawValue)-\(frequency!.time!.prettyTime)")
            }
            else{
                for day in frequency!.daysVal{
                    identifiers.append("\(injection.name!)-\(injection.dosage!)-\(injection.unitsVal.rawValue)-\(day.weekday!)-\(frequency!.time!.prettyTime)")
                }
            }
        }
            
        return identifiers
   /*
        if let snoozedUntil, let originalDateDue{
           
            let weekday = Calendar.current.component(.weekday, from: originalDateDue)
            
            
            identifiers.append("\(injection.name!)-\(injection.dosage!)-\(injection.unitsVal.rawValue)-\(weekday)-\(injection.time!.prettyTime)-due-\(originalDateDue)-snoozed-\(snoozedUntil)")
            
        }
        
        else{
    
            //loop through frequency array
    
            if injection.daysVal == [.daily]{
                identifiers.append("\(injection.name!)-\(injection.dosage!)-\(injection.unitsVal.rawValue)-\(Injection.Frequency.daily.rawValue)-\(injection.time!.prettyTime)")
            }
            else{
                for day in injection.daysVal{
                    identifiers.append("\(injection.name!)-\(injection.dosage!)-\(injection.unitsVal.rawValue)-\(day.weekday!)-\(injection.time!.prettyTime)")
                }
            }
        }
        */
           
    }
    
    static func populateInjectionQueueForExistingNotifications(){
        
        UNUserNotificationCenter.current().getDeliveredNotifications { notifications in
            print("found \(notifications.count) notifications")
            
            if notifications.count > 0{
                
                populateInjectionQueueFor(injectionNotifications: notifications)
                
            }
            
            
           /*if notifications.count > 0{
                
                let queueProvider = QueueProvider(storageProvider: StorageProvider.shared, fetch: false)
                
                for noti in notifications{
                    
                    let idString = noti.request.content.userInfo[UserInfoKeys.injectionManagednObjectID.rawValue] as! String
                    
                    let url = URL(string: idString)!
                    
                    let managedObjectID = queueProvider.storageProvider.persistentContainer.persistentStoreCoordinator.managedObjectID(forURIRepresentation: url)!
                    
                    
                    let injection = StorageProvider.shared.persistentContainer.viewContext.object(with: managedObjectID) as! Injection
                   
                    
                    queueProvider.saveObject(injection: injection, dateDue: noti.date, snoozedUntil: nil)

                }
            }*/
            
           
        }
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
    }
    
    static func populateInjectionQueueFor(injectionNotifications notifications: [UNNotification]){
        
        let queueProvider = QueueProvider(storageProvider: StorageProvider.shared, fetch: false)

        for noti in notifications{
            
            //only populate for scheduled injections, not snoozed
            if noti.request.content.categoryIdentifier == NotificationCategoryIdentifier.scheduledInjection.rawValue{
                
                let idString = noti.request.content.userInfo[UserInfoKeys.injectionManagednObjectID.rawValue] as! String
                
                let url = URL(string: idString)!
                
                let managedObjectID = queueProvider.storageProvider.persistentContainer.persistentStoreCoordinator.managedObjectID(forURIRepresentation: url)!
                
                
                let injection = StorageProvider.shared.persistentContainer.viewContext.object(with: managedObjectID) as! Injection
                
                
                queueProvider.saveObject(injection: injection, dateDue: noti.date, snoozedUntil: nil)
            }

        }
        
    }
    
   static func removeExistingNotifications(forInjection injection: Injection){
       
       for frequency in injection.frequency as! Set<Frequency> {
           
           NotificationManager.removeExistingNotifications(forInjection: injection, snoozedUntil: nil, originalDateDue: nil, frequency: frequency)
           
       }
            
            
        let queueProvider = QueueProvider(storageProvider: StorageProvider.shared, fetchSnoozedForInjection: injection)
            
        for id in queueProvider.snapshot!.itemIdentifiers{
                
            let queue = queueProvider.object(withObjectID: id)
                
            let queuedInjection = queue.injection!
                
            //remove snoozed / queue notifications for this injection
            NotificationManager.removeExistingNotifications(forInjection: queuedInjection, snoozedUntil: queue.snoozedUntil, originalDateDue: queue.dateDue, frequency: nil)
                
            //delete queue object
            queueProvider.deleteObject(queue)
                
        }
        
    }
    
    static func removeExistingNotifications(forInjection injection: Injection, snoozedUntil: Date?, originalDateDue: Date?, frequency: Frequency?){
        
        let identifiers = getNotificationIDs(forInjection: injection, snoozedUntil: snoozedUntil, originalDateDue: originalDateDue, frequency: frequency)
        
        print("removing notifications with id's \(identifiers)")
            
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
        
        print(UNUserNotificationCenter.current().getPendingNotificationRequests(completionHandler: { notifications in
            print("Notification Count: \(notifications.count)")
        }))
        
    }
    
    static func scheduleNotifications(forInjection injection: Injection) {
        
        
        for frequency in injection.frequency as! Set<Frequency> {
            
            let content = UNMutableNotificationContent()
            content.title = "It's Injection O'Clock!"
            content.body = "It's time for your injection \(injection.name!) of \(injection.dosage!) \(injection.units!), scheduled \(frequency.shortenedDayString) at \(frequency.time!.prettyTime)."
              
            content.sound = .defaultCritical
            content.interruptionLevel = .critical
            content.categoryIdentifier = NotificationManager.NotificationCategoryIdentifier.scheduledInjection.rawValue
              
            let objectID = injection.objectID
            print(objectID)
             
            content.userInfo = [UserInfoKeys.injectionManagednObjectID.rawValue: objectID.uriRepresentation().absoluteString]
            
              
            // Configure the recurring date.
            var dateComponents = [DateComponents]()
            var notificationIdentifiers = [String]()
              
            let calendar = Calendar.current
              
            if frequency.daysVal == [.daily]{
                var components = DateComponents()
                  
                components.hour = calendar.component(.hour, from: frequency.time!)
                components.minute = calendar.component(.minute, from: frequency.time!)
                  
                dateComponents.append(components)
                  
                let identifiers = getNotificationIDs(forInjection: injection, snoozedUntil: nil, originalDateDue: nil, frequency: frequency)
                  
                notificationIdentifiers.append(contentsOf: identifiers)
                  
            }
            else{
                  
                let identifiers = getNotificationIDs(forInjection: injection, snoozedUntil: nil, originalDateDue: nil, frequency: frequency)
                notificationIdentifiers.append(contentsOf: identifiers)
                  
                for day in frequency.daysVal{
                    
                    var components = DateComponents()
                      
                    components.hour = calendar.component(.hour, from: frequency.time!)
                    components.minute = calendar.component(.minute, from: frequency.time!)
                    components.weekday = day.weekday
                    
                    dateComponents.append(components)
                      
                }
                  
            }
              
            for i in 0...dateComponents.count-1{
                  
                // Create the trigger as a repeating event.
                let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents[i], repeats: true)
                         
                let request = UNNotificationRequest(identifier: notificationIdentifiers[i], content: content, trigger: trigger)

                // Schedule the request with the system.
                let notificationCenter = UNUserNotificationCenter.current()
                  
                notificationCenter.add(request) { (error) in
                      
                    print("notification added \(notificationIdentifiers[i])")
                      
                    if error != nil {
                        // Handle any errors.
                    }
                }
                  
            }
            
        }
        
    }
    
    
    
    
    /*  static func scheduleNotification(forInjection injection: Injection){
        

      let content = UNMutableNotificationContent()
        content.title = "It's Injection O'Clock!"
        content.body = "It's time for your injection \(injection.name!) of \(injection.dosage!) \(injection.units!), scheduled \(injection.shortenedDayString) at \(injection.time!.prettyTime)."
        
        content.sound = .defaultCritical
        content.interruptionLevel = .critical
        content.categoryIdentifier = NotificationManager.NotificationCategoryIdentifier.scheduledInjection.rawValue
        
        let objectID = injection.objectID
        print(objectID)
       
        content.userInfo = [UserInfoKeys.injectionManagednObjectID.rawValue: objectID.uriRepresentation().absoluteString]
        
        // Configure the recurring date.
        var dateComponents = [DateComponents]()
        var notificationIdentifiers = [String]()
        
        let calendar = Calendar.current
        
        if injection.daysVal == [.daily]{
            var components = DateComponents()
            
            components.hour = calendar.component(.hour, from: injection.time!)
            components.minute = calendar.component(.minute, from: injection.time!)
            
            dateComponents.append(components)
            
            let identifiers = getNotificationIDs(forInjection: injection, snoozedUntil: nil, originalDateDue: nil)
            
            notificationIdentifiers.append(contentsOf: identifiers)
            
            
        }
        else{
            
            let identifiers = getNotificationIDs(forInjection: injection, snoozedUntil: nil, originalDateDue: nil)
            notificationIdentifiers.append(contentsOf: identifiers)
            
            for day in injection.daysVal{
                
                var components = DateComponents()
                
                components.hour = calendar.component(.hour, from: injection.time!)
                components.minute = calendar.component(.minute, from: injection.time!)
                components.weekday = day.weekday
                
                dateComponents.append(components)
                
            }
            
        }
        
        for i in 0...dateComponents.count-1{
            
            // Create the trigger as a repeating event.
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents[i], repeats: true)
                   
            let request = UNNotificationRequest(identifier: notificationIdentifiers[i], content: content, trigger: trigger)


            // Schedule the request with the system.
            let notificationCenter = UNUserNotificationCenter.current()
            
            notificationCenter.add(request) { (error) in
                
                print("notification added \(notificationIdentifiers[i])")
                
                if error != nil {
                        // Handle any errors.
                }
            }
            
        }
        
        
        
    }*/
    
    static func scheduleSnoozedNotification(forInjection injection: Injection, snoozedUntil: Date, originalDateDue: Date, queueObject: Queue){
        
        let content = UNMutableNotificationContent()
        content.title = "It's Injection O'Clock!"
        content.body = "It's time for your injection \(injection.name) of \(injection.dosage) \(injection.units), that was originally due \(originalDateDue) and snoozed until \(snoozedUntil.prettyTime)."
       
        content.sound = .defaultCritical
        content.interruptionLevel = .critical
        content.categoryIdentifier = NotificationManager.NotificationCategoryIdentifier.snoozedInjection.rawValue
        
        let injectionObjectID = injection.objectID
        
        let queueObjectID = queueObject.objectID
    
        content.userInfo[UserInfoKeys.injectionManagednObjectID.rawValue] = injectionObjectID.uriRepresentation().absoluteString
        content.userInfo[UserInfoKeys.originalDateDue.rawValue] =  originalDateDue
        content.userInfo[UserInfoKeys.queueManagedObjectID.rawValue] = queueObjectID.uriRepresentation().absoluteString
        
        let calendar = Calendar.current
        
        var components = DateComponents()
        
        components.hour = calendar.component(.hour, from: snoozedUntil)
        components.minute = calendar.component(.minute, from: snoozedUntil)
        components.weekday = calendar.component(.weekday, from: snoozedUntil)
        
        let identifiers = getNotificationIDs(forInjection: injection, snoozedUntil: snoozedUntil, originalDateDue: originalDateDue, frequency: nil)
        
            
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
                   
        let request = UNNotificationRequest(identifier: identifiers[0], content: content, trigger: trigger)


            // Schedule the request with the system.
        let notificationCenter = UNUserNotificationCenter.current()
            
        notificationCenter.add(request) { (error) in
                
            print("notification added \(identifiers[0])")
                
            if error != nil {
                        // Handle any errors.
            }
        }
            
        
        
        
    }
    
    
    
}

