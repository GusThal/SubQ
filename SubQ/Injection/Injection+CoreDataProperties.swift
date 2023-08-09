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

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Injection> {
        return NSFetchRequest<Injection>(entityName: "Injection")
    }

    @NSManaged public var days: String?
    @NSManaged public var dosage: NSDecimalNumber?
    @NSManaged public var name: String?
    @NSManaged public var time: Date?
    @NSManaged public var units: String?
    @NSManaged public var injectionHistory: NSSet?
    @NSManaged public var queue: NSSet?
    @NSManaged public var areNotificationsEnabled: Bool
    @NSManaged public var isInjectionDeleted: Bool
    
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
    
    
    var descriptionString: String{
        get{
            return "\(self.name!) \(self.dosage!) \(self.units!)"
        }
    }
    
    var scheduledString: String{
       
        var str = "\(self.daysVal.map({ $0.shortened}).joined(separator: ", "))"
        
        if self.daysVal != [Injection.Frequency.asNeeded] {
            if let time = self.time{
                str.append(" | \(time.prettyTime)")
            }
        }
        
        return str
        
    }
    
    var timeUntilNextInjection: String?{
        
        let currentDate = Date()
        
        let calendar = Calendar.current
        
        if daysVal == [.asNeeded]{
            return nil
        }
        else{
            
            let injectionHour = calendar.component(.hour, from: time!)
            let injectionMinute = calendar.component(.minute, from: time!)
            
            if daysVal == [.daily]{

                var injectionDateComponents = DateComponents()

                injectionDateComponents.hour = injectionHour
                injectionDateComponents.minute = injectionMinute
                injectionDateComponents.day = calendar.component(.day, from: currentDate)
                injectionDateComponents.month = calendar.component(.month, from: currentDate)
                injectionDateComponents.year = calendar.component(.year, from: currentDate)
                
                let injectionDate = calendar.date(from: injectionDateComponents)!
                
                if injectionDate > currentDate{
                    let components = calendar.dateComponents([.hour, .minute], from: currentDate, to: injectionDate)
                    return "\(components.hour!) hours, and \(components.minute!) minutes"
                }
                //we already injected today, so calculate the time until tomorrow's injection
                else{
                    let tomorrow = calendar.date(byAdding: .day, value: 1, to: injectionDate)
                    let components = calendar.dateComponents([.hour, .minute], from: currentDate, to: tomorrow!)
                    
                    return "\(components.hour!) hours, and \(components.minute!) minutes"
                }
                
            }
            else{
                
                let currentDay = calendar.component(.weekday, from: currentDate)
                
                var closestDay: Int?
                
                for day in daysVal{
                    
                    if day.weekday == currentDay{
                        
                        var injectionDateComponents = DateComponents()
                        
                        injectionDateComponents.minute = injectionMinute
                        injectionDateComponents.hour = injectionHour
                        injectionDateComponents.day = calendar.component(.day, from: currentDate)
                        injectionDateComponents.month = calendar.component(.month, from: currentDate)
                        injectionDateComponents.year = calendar.component(.year, from: currentDate)
                        
                        let injectionDate = calendar.date(from: injectionDateComponents)!
                        
                        if currentDate < injectionDate{
                            let components = calendar.dateComponents([.hour, .minute], from: currentDate, to: injectionDate)
                            return "\(components.day!) days, \(components.hour!) hours, and \(components.minute!) minutes"
                        }
                        
                    }
                    else if currentDay < day.weekday!{
                        closestDay = day.weekday
                        
                    }
                        
                        
                }
                
                //if closest day is nil, then set it to days[0]
                
                var nextDate: Date
                
                if closestDay == nil{
                    closestDay = daysVal[0].weekday
                    
                    let nextDayComponents = DateComponents(calendar: calendar, hour: injectionHour, minute: injectionMinute, weekday: closestDay)

                    //get the date of the next day
                    nextDate = calendar.nextDate(after: currentDate, matching: nextDayComponents, matchingPolicy: .nextTimePreservingSmallerComponents)! // "Jan 14, 2018 at 12:00 AM"*/
                }
                else{
                    
                    let nextDayComponents = DateComponents(calendar: calendar, hour: injectionHour, minute: injectionMinute, weekday: closestDay)
                    
                    nextDate = calendar.nextDate(after: currentDate, matching: nextDayComponents, matchingPolicy: .nextTimePreservingSmallerComponents)!
                }
                
                
                let components = calendar.dateComponents([.day, .hour, .minute], from: currentDate, to: nextDate)
                return "\(components.day!) days, \(components.hour!) hours, and \(components.minute!) minutes"
                
                
            }
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
