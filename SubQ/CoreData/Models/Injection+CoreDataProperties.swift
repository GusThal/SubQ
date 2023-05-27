//
//  Injection+CoreDataProperties.swift
//  SubQ
//
//  Created by Constantine Thalasinos on 5/6/23.
//
//

import Foundation
import CoreData


extension Injection {
    
    enum DosageUnits: String, CaseIterable{
        case cc = "cc", ml = "mL"
    }
    
    enum Frequency: String, CaseIterable{
        case sun = "Sunday", mon = "Monday", tues = "Tuesday", wed = "Wednesday", thurs = "Thursday", fri = "Friday", sat = "Saturday", daily = "Daily", asNeeded = "As Needed"
    }

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Injection> {
        return NSFetchRequest<Injection>(entityName: "Injection")
    }

    @NSManaged public var days: String?
    @NSManaged public var dosage: NSDecimalNumber?
    @NSManaged public var name: String?
    @NSManaged public var time: Date?
    @NSManaged public var units: String?
    @NSManaged public var injectionHistory: NSSet?
    
    var unitsVal: DosageUnits{
        get{
            return DosageUnits(rawValue: units!)!
        }
        set{
            units = newValue.rawValue
        }
    }

}

// MARK: Generated accessors for injectionHistory
extension Injection {

    @objc(addInjectionHistoryObject:)
    @NSManaged public func addToInjectionHistory(_ value: History)

    @objc(removeInjectionHistoryObject:)
    @NSManaged public func removeFromInjectionHistory(_ value: History)

    @objc(addInjectionHistory:)
    @NSManaged public func addToInjectionHistory(_ values: NSSet)

    @objc(removeInjectionHistory:)
    @NSManaged public func removeFromInjectionHistory(_ values: NSSet)

}

extension Injection : Identifiable {

}
