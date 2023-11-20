//
//  Quadrant.swift
//  SubQ
//
//  Created by Constantine Thalasinos on 6/10/23.
//

import Foundation

enum Quadrant: Int, CaseIterable{
    case topLeft = 0, bottomLeft = 1, topRight = 2,  bottomRight = 3
    
    var description: String{
        switch self{
        case .topLeft: return "Top Left"
        case .bottomLeft: return "Bottom Left"
        case .topRight: return "Top Right"
        case .bottomRight: return "Bottom Right"
        }
    }
    
    var asNSNumber: NSNumber{
        return NSNumber(integerLiteral: self.rawValue)
    }
}
