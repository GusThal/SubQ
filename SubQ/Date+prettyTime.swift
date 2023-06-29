//
//  Date+prettyTime.swift
//  SubQ
//
//  Created by Constantine Thalasinos on 6/28/23.
//

import Foundation

extension Date{
    var prettyTime: String{
        get{
            
            let formatter = DateFormatter()
            formatter.dateStyle = .none
            formatter.timeStyle = .short
            
            return formatter.string(from: self)
        }
    }
}
