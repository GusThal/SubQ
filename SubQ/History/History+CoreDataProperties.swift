//
//  History+CoreDataProperties.swift
//  SubQ
//
//  Created by Constantine Thalasinos on 5/28/23.
//
//

import Foundation
import CoreData


extension History {
    
    enum InjectStatus: String, CaseIterable{
        case all = "All", injected = "injected", skipped = "skipped"
    }

    @nonobjc public class func fetchRequest() -> NSFetchRequest<History> {
        return NSFetchRequest<History>(entityName: "History")
    }

    @NSManaged public var date: Date?
    @NSManaged public var injection: Injection?
    @NSManaged public var site: Site?
    @NSManaged public var dueDate: Date?
    @NSManaged public var status: String?
    
    var statusVal: InjectStatus{
        get{
            InjectStatus(rawValue: status!)!
        }
        set{
            status = newValue.rawValue
        }
    }

}

extension History : Identifiable {

}
