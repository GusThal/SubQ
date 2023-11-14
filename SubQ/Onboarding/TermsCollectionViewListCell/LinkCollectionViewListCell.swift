//
//  AttributedTextFieldListCell.swift
//  SubQ
//
//  Created by Constantine Thalasinos on 11/10/23.
//

import UIKit

class LinkCollectionViewListCell: UICollectionViewListCell {
    
    var attributedText: NSAttributedString?
    
    override func updateConfiguration(using state: UICellConfigurationState) {
               
           // Create new configuration object and update it base on state
           var newConfiguration = LinkCollectionViewListCellContentConfiguration().updated(for: state)
           
           // Update any configuration parameters related to data item
            newConfiguration.attributedText = attributedText

           // Set content configuration in order to update custom content view
           contentConfiguration = newConfiguration
           
       }
    
}
