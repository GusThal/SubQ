//
//  LinkCollectionViewListCellContentConfiguration.swift
//  SubQ
//
//  Created by Constantine Thalasinos on 11/10/23.
//

import Foundation
import UIKit

struct LinkCollectionViewListCellContentConfiguration: UIContentConfiguration, Hashable {
    
    var backgroundColor: UIColor?
    var textColor: UIColor?
    var attributedText: NSAttributedString?
    
    
    func makeContentView() -> UIView & UIContentView {
        return LinkCollectionViewListContentView(configuration: self)
    }
    
    func updated(for state: UIConfigurationState) -> LinkCollectionViewListCellContentConfiguration {
        
        // the text & background color don't need to be changged
        return self
    }
    
    
}
