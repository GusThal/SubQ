//
//  DatePickerContentView.swift
//  SubQ
//
//  Created by Constantine Thalasinos on 5/31/23.
//

import UIKit

class DatePickerContentView: UIView, UIContentView {

    let picker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .time
        picker.preferredDatePickerStyle = .wheels
        picker.translatesAutoresizingMaskIntoConstraints = true
        
        return picker
    }()
    
    private var currentConfiguration: DatePickerContentConfiguration!
    
    var configuration: UIContentConfiguration {
        get {
            currentConfiguration
        }
        set {
            guard let newConfiguration = newValue as? DatePickerContentConfiguration else {
                return
            }
      
            apply(configuration: newConfiguration)
        }
    }
    
    init(configuration: DatePickerContentConfiguration) {
        super.init(frame: .zero)
        
        // Create the content view UI
        setupAllViews()
        
        // Apply the configuration (set data to UI elements / define custom content view appearance)
        apply(configuration: configuration)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK:- Private functions
private extension DatePickerContentView {
    
    private func setupAllViews() {
    
        
        addSubview(picker)
        picker.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            picker.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
            picker.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),
            picker.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
            picker.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor),
        ])
    }
    
    private func apply(configuration: DatePickerContentConfiguration) {
    
        // Only apply configuration if new configuration and current configuration are not the same
        guard currentConfiguration != configuration else {
            return
        }
        
        //picker.date = configuration.date ?? Date()
        
        // Replace current configuration with new configuration
        currentConfiguration = configuration
        
        if let action = currentConfiguration.action{
            picker.addAction(action, for: .primaryActionTriggered)
        }
    }
}
