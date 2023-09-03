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
    
    /*var fullDateTime: String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .full
        dateFormatter.timeStyle = .full
        
        return dateFormatter.string(from: self)
    }*/
    
    var fullDateTime: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.timeZone = .autoupdatingCurrent
        formatter.setLocalizedDateFormatFromTemplate("EEE MMM d yyyy'T'hh:mm:zzz")
        
        return formatter.string(from: self)
    }
}
