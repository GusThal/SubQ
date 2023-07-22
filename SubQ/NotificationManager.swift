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
        case injectioManagednObjectID = "injectionObjectID"
    }
    
    
    
    static func populateInjectionQueueForExistingNotifications(){
        
        UNUserNotificationCenter.current().getDeliveredNotifications { notifications in
            print("found \(notifications.count) notifications")
            
            if notifications.count > 0{
                
                let queueProvider = QueueProvider(storageProvider: StorageProvider.shared, fetch: false)

                
                for noti in notifications{
                    
                    
                    let idString = noti.request.content.userInfo[UserInfoKeys.injectioManagednObjectID.rawValue] as! String
                    
                    let url = URL(string: idString)!
                    
                    let managedObjectID = queueProvider.storageProvider.persistentContainer.persistentStoreCoordinator.managedObjectID(forURIRepresentation: url)!
                    
                    
                    let injection = StorageProvider.shared.persistentContainer.viewContext.object(with: managedObjectID) as! Injection
                   
                    
                    queueProvider.saveObject(injection: injection, dateDue: noti.date, snoozedUntil: nil)

                }
            }
            
           
        }
    }
    
    static func removeExistingNotifications(forInjection injection: Injection){
        
        let objectID = injection.objectID
        
        let oldFrequency = injection.daysVal
        
        if oldFrequency == [.daily]{
            
            let notificationID = "\(objectID)"
            
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [notificationID])
            
        }
        else{
            
            var identifiers = [String]()
            
            for day in oldFrequency{
                let identifier = "\(objectID)-\(day.weekday!)"
                
                identifiers.append(identifier)
            }
            
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
            
        }
        
        print(UNUserNotificationCenter.current().getPendingNotificationRequests(completionHandler: { notifications in
            print("Notification Count: \(notifications.count)")
        }))
        
    }
    
   static func scheduleNotificationForInjectionWith(objectID: NSManagedObjectID, name: String, dosage: Double, units: Injection.DosageUnits, frequency: [Injection.Frequency], frequencyString: String, time: Date){
        
        let content = UNMutableNotificationContent()
        content.title = "It's Injection O'Clock!"
        content.body = "It's time for your injection \(name) of \(dosage) \(units), scheduled \(frequencyString) at \(time.prettyTime)"
       
       content.sound = .defaultCritical
       content.interruptionLevel = .critical
       
       print(objectID)
       
       content.userInfo = ["injectionObjectID": objectID.uriRepresentation().absoluteString]
        
        
        // Configure the recurring date.
        var dateComponents = [DateComponents]()
        var notificationIdentifiers = [String]()
        
        let calendar = Calendar.current
        
        if frequency == [.daily]{
            var components = DateComponents()
            
            components.hour = calendar.component(.hour, from: time)
            components.minute = calendar.component(.minute, from: time)
            
            dateComponents.append(components)
            
            let identifier = "\(objectID)"
            
            notificationIdentifiers.append(identifier)
            
            
        }
        else{
            
            for day in frequency{
                
                var components = DateComponents()
                
                components.hour = calendar.component(.hour, from: time)
                components.minute = calendar.component(.minute, from: time)
                components.weekday = day.weekday
                
                dateComponents.append(components)
                
                let identifier = "\(objectID)-\(day.weekday!)"
                
                notificationIdentifiers.append(identifier)
                
            }
            
        }
        
        for i in 0...dateComponents.count-1{
            
            
            // Create the trigger as a repeating event.
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents[i], repeats: true)
                   
            let request = UNNotificationRequest(identifier: notificationIdentifiers[i], content: content, trigger: trigger)


            // Schedule the request with the system.
            let notificationCenter = UNUserNotificationCenter.current()
            
            notificationCenter.add(request) { (error) in
                
                print("notification added")
                
                if error != nil {
                        // Handle any errors.
                }
            }
            
        }
        
        
        
    }
    
    
    
}

