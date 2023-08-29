//
//  Frequency+CoreDataProperties.swift
//  SubQ
//
//  Created by Constantine Thalasinos on 8/17/23.
//
//

import Foundation
import CoreData


extension Frequency {
    
    enum InjectionDay: String, CaseIterable{
        case sun = "Sunday", mon = "Monday", tues = "Tuesday", wed = "Wednesday", thurs = "Thursday", fri = "Friday", sat = "Saturday", daily = "Daily"
        
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
        
        var weekday: Int? {
            switch self{
            case .sun: return 1
            case .mon: return 2
            case .tues: return 3
            case .wed: return 4
            case .thurs: return 5
            case .fri: return 6
            case .sat: return 7
            default:
                return nil
            }
        }
    }

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Frequency> {
        return NSFetchRequest<Frequency>(entityName: "Frequency")
    }

    @NSManaged public var time: Date?
    @NSManaged public var days: String?
    @NSManaged public var injection: Injection?
    
    var daysVal: [Frequency.InjectionDay]{
            get{
                
                days!.components(separatedBy: ", ").map({ Frequency.InjectionDay(rawValue: $0)!})
                
            }
            
        }
    
    var shortenedDayString: String{
        get{
            
            let arr = days!.components(separatedBy: ", ")
            
            let shortened = arr.map({Frequency.InjectionDay(rawValue: $0)!.shortened})
            
            return shortened.joined(separator: ", ")
        }
    }
    
    var scheduledString: String{
                
        var str = self.shortenedDayString
        str.append(" | \(self.time!.prettyTime)")
            
            
        return str
        
        
    }

}

extension Frequency : Identifiable {

}
