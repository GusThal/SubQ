//
//  DatePickerContentConfiguration.swift
//  SubQ
//
//  Created by Constantine Thalasinos on 5/31/23.
//

import UIKit

struct DatePickerContentConfiguration: UIContentConfiguration, Hashable{

    var date: String?
    
    func makeContentView() -> UIView & UIContentView {
        // Initialize an instance of DatePickerContentView
        return DatePickerContentView(configuration: self)
    }
    
    func updated(for state: UIConfigurationState) -> Self {
        return self
    }
    
}
