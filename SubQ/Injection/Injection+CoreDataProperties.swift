//
//  Injection+CoreDataProperties.swift
//  SubQ
//
//  Created by Constantine Thalasinos on 5/28/23.
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
        
        var shortened: String {
            switch self{
            case .sun: return "Sun"
            case .mon: return "Mon"
            case .tues:  return "Tue"
            case .wed: return "Wed"
            case .thurs: return "Thu"
            case .fri: return "Fri"
            case .sat: return "Sat"
            default:
                return self.rawValue
            }
            
        }
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
    
    var daysVal: [Injection.Frequency]{
        get{
            
            days!.components(separatedBy: ", ").map({ Injection.Frequency(rawValue: $0)!})
            
        }
        
    }
    
    var shortenedDayString: String{
        get{
            
            let arr = days!.components(separatedBy: ", ")
            
            let shortened = arr.map({Injection.Frequency(rawValue: $0)!.shortened})
            
            return shortened.joined(separator: ", ")
        }
    }
    
    var prettyTime: String?{
        get{
            
            guard let time else { return nil}
            
            let formatter = DateFormatter()
            formatter.dateStyle = .none
            formatter.timeStyle = .short
            
            
            return formatter.string(from: time)
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
