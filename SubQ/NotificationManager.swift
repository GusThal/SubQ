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
    }
    
    //name-dosage-units-frequency-time
    //name-dosage-units-frequency-time-due-originalDateDue-snoozed-snoozedUntil
    static func getNotificationIDs(forInjection injection: Injection, snoozedUntil: Date?, originalDateDue: Date?) -> [String]{
        
        var identifiers = [String]()
        
        if let snoozedUntil, let originalDateDue{
           
            let weekday = Calendar.current.component(.weekday, from: originalDateDue)
            
            
            identifiers.append("\(injection.name!)-\(injection.dosage!)-\(injection.unitsVal.rawValue)-\(weekday)-\(injection.time!.prettyTime)-due-\(originalDateDue)-snoozed-\(snoozedUntil)")
            
        }
        
        else{
            if injection.daysVal == [.daily]{
                identifiers.append("\(injection.name!)-\(injection.dosage!)-\(injection.unitsVal.rawValue)-\(Injection.Frequency.daily.rawValue)-\(injection.time!.prettyTime)")
            }
            else{
                for day in injection.daysVal{
                    identifiers.append("\(injection.name!)-\(injection.dosage!)-\(injection.unitsVal.rawValue)-\(day.weekday!)-\(injection.time!.prettyTime)")
                }
            }
        }
        
           
        return identifiers
           
    }
    
    static func populateInjectionQueueForExistingNotifications(){
        
        UNUserNotificationCenter.current().getDeliveredNotifications { notifications in
            print("found \(notifications.count) notifications")
            
            if notifications.count > 0{
                
                let queueProvider = QueueProvider(storageProvider: StorageProvider.shared, fetch: false)
                
                for noti in notifications{
                    
                    let idString = noti.request.content.userInfo[UserInfoKeys.injectionManagednObjectID.rawValue] as! String
                    
                    let url = URL(string: idString)!
                    
                    let managedObjectID = queueProvider.storageProvider.persistentContainer.persistentStoreCoordinator.managedObjectID(forURIRepresentation: url)!
                    
                    
                    let injection = StorageProvider.shared.persistentContainer.viewContext.object(with: managedObjectID) as! Injection
                   
                    
                    queueProvider.saveObject(injection: injection, dateDue: noti.date, snoozedUntil: nil)

                }
            }
            
           
        }
    }
    
    static func removeExistingNotifications(forInjection injection: Injection, snoozedUntil: Date?, originalDateDue: Date?){
        
        let identifiers = getNotificationIDs(forInjection: injection, snoozedUntil: snoozedUntil, originalDateDue: originalDateDue)
        
        print("removing notifications with id's \(identifiers)")
            
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
        
        print(UNUserNotificationCenter.current().getPendingNotificationRequests(completionHandler: { notifications in
            print("Notification Count: \(notifications.count)")
        }))
        
    }
    
    
    static func scheduleNotification(forInjection injection: Injection){
        
        let content = UNMutableNotificationContent()
        content.title = "It's Injection O'Clock!"
        content.body = "It's time for your injection \(injection.name!) of \(injection.dosage!) \(injection.units!), scheduled \(injection.shortenedDayString) at \(injection.time!.prettyTime)."
        
        content.sound = .defaultCritical
        content.interruptionLevel = .critical
        
        let objectID = injection.objectID
        print(objectID)
       
        content.userInfo = ["injectionObjectID": objectID.uriRepresentation().absoluteString]
        
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
        
        
        
    }
    
    static func scheduleSnoozedNotification(forInjection injection: Injection, snoozedUntil: Date, originalDateDue: Date){
        
        let content = UNMutableNotificationContent()
        content.title = "It's Injection O'Clock!"
        content.body = "It's time for your injection \(injection.name) of \(injection.dosage) \(injection.units), that was originally due \(originalDateDue) and snoozed until \(snoozedUntil.prettyTime)."
       
       content.sound = .defaultCritical
       content.interruptionLevel = .critical
        
        let objectID = injection.objectID
    
        content.userInfo = ["injectionObjectID": objectID.uriRepresentation().absoluteString]
        content.userInfo[UserInfoKeys.originalDateDue.rawValue] =  originalDateDue
        
        let calendar = Calendar.current
        
        var components = DateComponents()
        
        components.hour = calendar.component(.hour, from: snoozedUntil)
        components.minute = calendar.component(.minute, from: snoozedUntil)
        components.weekday = calendar.component(.weekday, from: snoozedUntil)
        
        let identifiers = getNotificationIDs(forInjection: injection, snoozedUntil: snoozedUntil, originalDateDue: originalDateDue)
        
            
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

