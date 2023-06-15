//
//  Section+CoreDataProperties.swift
//  SubQ
//
//  Created by Constantine Thalasinos on 6/10/23.
//
//

import Foundation
import CoreData


extension Section {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Section> {
        return NSFetchRequest<Section>(entityName: "Section")
    }

    @NSManaged public var quadrant: NSNumber?
    @NSManaged public var bodyPart: BodyPart?
    @NSManaged public var site: NSSet?
    
    var quadrantVal: Quadrant{
        get{
            return Quadrant(rawValue: Int(truncating: quadrant!))!
        }
        set{
            quadrant = NSNumber(integerLiteral: newValue.rawValue)
        }
    }

}

// MARK: Generated accessors for site
extension Section {

    @objc(addSiteObject:)
    @NSManaged public func addToSite(_ value: Site)

    @objc(removeSiteObject:)
    @NSManaged public func removeFromSite(_ value: Site)

    @objc(addSite:)
    @NSManaged public func addToSite(_ values: NSSet)

    @objc(removeSite:)
    @NSManaged public func removeFromSite(_ values: NSSet)

}

extension Section : Identifiable {

}
