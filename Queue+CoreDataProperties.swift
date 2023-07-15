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

}

extension Queue : Identifiable {

}
