//
//  Queue+CoreDataProperties.swift
//  SubQ
//
//  Created by Constantine Thalasinos on 7/12/23.
//
//

import Foundation
import CoreData


extension Queue {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Queue> {
        return NSFetchRequest<Queue>(entityName: "Queue")
    }

    @NSManaged public var dateDue: Date?
    @NSManaged public var snoozedUntil: Date?
    @NSManaged public var injection: Injection?
    
    var snoozedFor: String?{
        
        
        let currentDate = Date()
        let calendar = Calendar.current
        
        
        let injectionHour = calendar.component(.hour, from: snoozedUntil!)
        let injectionMinute = calendar.component(.minute, from: snoozedUntil!)
        
        guard let snoozedUntil else { return nil }
        
        if snoozedUntil > currentDate{
            let components = calendar.dateComponents([.hour, .minute, .second], from: currentDate, to: snoozedUntil)
            
            return "\(components.hour!) hours, \(components.minute!) minutes, and \(components.second!) seconds"
        } else{
            let components = calendar.dateComponents([.hour, .minute, .second], from: snoozedUntil, to: currentDate)
            
            return "\(components.hour!) hours, \(components.minute!) minutes, and \(components.second!) seconds past due"
        }
        
    }
        

}

extension Queue : Identifiable {

}
