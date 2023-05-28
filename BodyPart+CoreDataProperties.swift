//
//  BodyPart+CoreDataProperties.swift
//  SubQ
//
//  Created by Constantine Thalasinos on 5/28/23.
//
//

import Foundation
import CoreData


extension BodyPart {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<BodyPart> {
        return NSFetchRequest<BodyPart>(entityName: "BodyPart")
    }

    @NSManaged public var part: String?
    @NSManaged public var enabled: Bool
    @NSManaged public var site: Site?
    
    enum Location: String, CaseIterable{
           case abdomen = "Abdomen", thigh = "Thigh", upperArm = "Upper Arm", buttocks = "Buttocks"
    }
    
    var partVal: Location{
        get{
            return Location(rawValue: part!)!
        }
        set{
            part = newValue.rawValue
        }
    }

}

extension BodyPart : Identifiable {

}
