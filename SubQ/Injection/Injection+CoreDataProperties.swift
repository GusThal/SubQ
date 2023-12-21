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
    
    public struct NextInjection: Comparable {
        public let date: Date
        public let timeUntil: String
        
        public static func < (lhs: Injection.NextInjection, rhs: Injection.NextInjection) -> Bool {
            return lhs.date < rhs.date
        }
    }
    
    enum DosageUnits: String, CaseIterable{
        case cc = "cc", ml = "mL"
    }
    
    enum InjectionType: String, CaseIterable{
        case all = "All", asNeeded = "As Needed", scheduled = "Scheduled"
    }
    

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Injection> {
        return NSFetchRequest<Injection>(entityName: "Injection")
    }

    @NSManaged public var dosage: NSDecimalNumber?
    @NSManaged public var name: String?
    @NSManaged public var units: String?
    @NSManaged public var injectionHistory: NSSet?
    @NSManaged public var queue: NSSet?
    @NSManaged public var areNotificationsEnabled: Bool
    @NSManaged public var isInjectionDeleted: Bool
    @NSManaged public var type: String?
    @NSManaged public var frequency: NSSet?
    
    var unitsVal: DosageUnits{
        get{
            return DosageUnits(rawValue: units!)!
        }
        set{
            units = newValue.rawValue
        }
    }
    
    var typeVal: InjectionType{
        get{
            return InjectionType(rawValue: type!)!
        } set {
            type = newValue.rawValue
        }
    }
    
    var descriptionString: String{
        get{
            return "\(self.name!) \(self.dosage!) \(self.units!)"
        }
    }
    
    var scheduledString: String{
        
        if self.typeVal == .asNeeded{
            return InjectionType.asNeeded.rawValue
        }
        else{
            var str = "Scheduled "
            for frequency in self.frequency! as! Set<Frequency>{
                
                str.append(frequency.shortenedDayString)
                str.append(" | \(frequency.time!.prettyTime)")
            }
            
            return str
        }
        
    }
    
    var nextInjection: NextInjection?{
        
        
        if self.typeVal == .asNeeded{
            return nil
        }
        else{
            
            let currentDate = Date()
            let calendar = Calendar.current
            var nextInjectionDates = [NextInjection]()
            
            for freq in self.frequency as! Set<Frequency> {
                
                let injectionHour = calendar.component(.hour, from: freq.time!)
                let injectionMinute = calendar.component(.minute, from: freq.time!)
                
                if freq.daysVal == [.daily]{
                    
                    var injectionDateComponents = DateComponents()
                    
                    injectionDateComponents.hour = injectionHour
                    injectionDateComponents.minute = injectionMinute
                    injectionDateComponents.day = calendar.component(.day, from: currentDate)
                    injectionDateComponents.month = calendar.component(.month, from: currentDate)
                    injectionDateComponents.year = calendar.component(.year, from: currentDate)
                    
                    let injectionDate = calendar.date(from: injectionDateComponents)!
                    
                    if injectionDate > currentDate{
                        let components = calendar.dateComponents([.hour, .minute, .second], from: currentDate, to: injectionDate)
                        nextInjectionDates.append(NextInjection(date: injectionDate, timeUntil: "\(components.hour!) hours, \(components.minute!) minutes, and \(components.second!) seconds"))
                    }
                    //we already injected today, so calculate the time until tomorrow's injection
                    else{
                        let tomorrow = calendar.date(byAdding: .day, value: 1, to: injectionDate)!
                        let components = calendar.dateComponents([.hour, .minute, .second], from: currentDate, to: tomorrow)
                        
                        nextInjectionDates.append(NextInjection(date: tomorrow, timeUntil: "\(components.hour!) hours, \(components.minute!) minutes, and \(components.second!) seconds"))
                    }
                    
                }
                else{
                    
                    let currentDay = calendar.component(.weekday, from: currentDate)
                    
                    var closestDay: Int?
                    
                    for day in freq.daysVal{
                        
                        if day.weekday == currentDay{
                            
                            var injectionDateComponents = DateComponents()
                            
                            injectionDateComponents.minute = injectionMinute
                            injectionDateComponents.hour = injectionHour
                            injectionDateComponents.day = calendar.component(.day, from: currentDate)
                            injectionDateComponents.month = calendar.component(.month, from: currentDate)
                            injectionDateComponents.year = calendar.component(.year, from: currentDate)
                            
                            let injectionDate = calendar.date(from: injectionDateComponents)!
                            
                            if currentDate < injectionDate{
                                let components = calendar.dateComponents([.day, .hour, .minute, .second], from: currentDate, to: injectionDate)
                                nextInjectionDates.append(NextInjection(date: injectionDate, timeUntil: "\(components.day!) days, \(components.hour!) hours, \(components.minute!) minutes, and \(components.second!) seconds"))
                            }
                            
                        }
                        else if currentDay < day.weekday!{
                            closestDay = day.weekday
                            
                        }
                        
                        
                    }
                    
                    //if closest day is nil, then set it to days[0]
                    
                    var nextDate: Date
                    
                    if closestDay == nil{
                        closestDay = freq.daysVal[0].weekday
                        
                        let nextDayComponents = DateComponents(calendar: calendar, hour: injectionHour, minute: injectionMinute, weekday: closestDay)
                        
                        //get the date of the next day
                        nextDate = calendar.nextDate(after: currentDate, matching: nextDayComponents, matchingPolicy: .nextTimePreservingSmallerComponents)! // Jan 14, 2018 at 12:00 AM"/
                    }
                    else{
                        
                        let nextDayComponents = DateComponents(calendar: calendar, hour: injectionHour, minute: injectionMinute, weekday: closestDay)
                        
                        nextDate = calendar.nextDate(after: currentDate, matching: nextDayComponents, matchingPolicy: .nextTimePreservingSmallerComponents)!
                    }
                    
                    
                    let components = calendar.dateComponents([.day, .hour, .minute, .second], from: currentDate, to: nextDate)
                    nextInjectionDates.append(NextInjection(date: nextDate, timeUntil: "\(components.day!) days, \(components.hour!) hours, \(components.minute!) minutes, and \(components.second!) seconds"))
                    
                    
                }
            }
            
            return nextInjectionDates.min()
        }
        
        
    }
    
    var sortedFrequencies: [Frequency]? {
        if typeVal == .asNeeded {
            return nil
        }
        
        let frequencySet = frequency as! Set<Frequency>
        
        
        return frequencySet.sorted { item1, item2 in
           
           if item1.daysVal == [.daily] {
               if item2.daysVal == [.daily] {
                   return item1.time! < item2.time!
               }
               else {
                   return true
               }
           } else {
               
               if item2.daysVal == [.daily] {
                   return false
               } else {
                   
                   var day2iterator = item2.daysVal.makeIterator()
                   
                   for day1 in item1.daysVal {
                       
                       if let nextDay2 = day2iterator.next() {
                           if day1.weekday != nextDay2.weekday {
                               return day1.weekday! < nextDay2.weekday!
                           }
                       } else {
                           return false
                       }
                   }
                   
                   if item1.daysVal.count != item2.daysVal.count {
                       return item1.daysVal.count < item2.daysVal.count
                   }
                   
                   return item1.time! < item2.time!
                  
               }
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

extension Injection {
    static let scheduledInjections: NSFetchRequest<Injection> = {
        let request: NSFetchRequest<Injection> = Injection.fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \Injection.name, ascending: false)
        ]
        let deletedPredicate = NSPredicate(format: "%K==%d", #keyPath(Injection.isInjectionDeleted), false)
        let scheduledPredicate = NSPredicate(format: "%K==%d", #keyPath(Injection.areNotificationsEnabled), true)
        
        let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [deletedPredicate, scheduledPredicate])
        
        request.predicate = compoundPredicate
        
        return request
    }()
}
