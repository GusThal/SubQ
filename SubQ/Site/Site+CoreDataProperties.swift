//
//  Site+CoreDataProperties.swift
//  SubQ
//
//  Created by Constantine Thalasinos on 5/28/23.
//
//

import Foundation
import CoreData


extension Site {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Site> {
        return NSFetchRequest<Site>(entityName: "Site")
    }

    @NSManaged public var lastInjected: Date?
    @NSManaged public var subQuadrant: NSNumber?
    @NSManaged public var siteHistory: NSSet?
    @NSManaged public var section: Section?
    

    
    var subQuadrantVal: Quadrant{
        get{
            return Quadrant(rawValue: Int(truncating: subQuadrant!))!
        }
        set{
            subQuadrant = NSNumber(integerLiteral: newValue.rawValue)
        }
    }
  /*
    var sectionVal: InjectionSection{
        get{
            return InjectionSection(rawValue: section!)!
        }
        set{
            section = newValue.rawValue
        }
    }*/

}

// MARK: Generated accessors for siteHistory
extension Site {

    @objc(addSiteHistoryObject:)
    @NSManaged public func addToSiteHistory(_ value: History)

    @objc(removeSiteHistoryObject:)
    @NSManaged public func removeFromSiteHistory(_ value: History)

    @objc(addSiteHistory:)
    @NSManaged public func addToSiteHistory(_ values: NSSet)

    @objc(removeSiteHistory:)
    @NSManaged public func removeFromSiteHistory(_ values: NSSet)

}

extension Site : Identifiable {

}
