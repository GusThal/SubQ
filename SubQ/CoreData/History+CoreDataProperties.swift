//
//  History+CoreDataProperties.swift
//  SubQ
//
//  Created by Constantine Thalasinos on 5/6/23.
//
//

import Foundation
import CoreData


extension History {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<History> {
        return NSFetchRequest<History>(entityName: "History")
    }

    @NSManaged public var date: Date?
    @NSManaged public var injection: Injection?
    @NSManaged public var site: Site?

}

extension History : Identifiable {

}
