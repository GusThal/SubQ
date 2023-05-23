//
//  Site+CoreDataProperties.swift
//  SubQ
//
//  Created by Constantine Thalasinos on 5/6/23.
//
//

import Foundation
import CoreData


extension Site {
    
    enum Zone: String, CaseIterable{
        case abdomen = "Abdomen", thigh = "Thigh", upperArm = "Upper Arm", buttocks = "Buttocks"
    }
    
    enum InjectionSection: String, CaseIterable{
        case topLeft = "Top Left", bottomLeft = "Bottom Left", topRight = "Top Right", bottomRight = "Bottom Right"
    }

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Site> {
        return NSFetchRequest<Site>(entityName: "Site")
    }

    @NSManaged public var enabled: Bool
    @NSManaged public var injectionZone: String?
    @NSManaged public var lastInjected: Date?
    @NSManaged public var section: String
    @NSManaged public var subSection: String
    @NSManaged public var siteHistory: NSSet?
    
    var subSectionVal: InjectionSection{
        get{
            return InjectionSection(rawValue: subSection)!
        }
        set{
            subSection = newValue.rawValue
        }
    }
    
    var sectionVal: InjectionSection{
        get{
            return InjectionSection(rawValue: section)!
        }
        set{
            section = newValue.rawValue
        }
    }

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
