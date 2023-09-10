//
//  SelectQueueObjectTableViewCell.swift
//  SubQ
//
//  Created by Constantine Thalasinos on 9/10/23.
//

import Foundation
import UIKit

class SelectQueueObjectTableViewCell: InjectionTableViewCell {
    
    let originallyDueLabel: UILabel = {
        let label = UILabel()
        
        return label
        
    }()
    
    let snoozedUntilLabel: UILabel = {
        let label = UILabel()
        
        return label
    }()
    
    
    class QueueCellConfiguration: CellConfiguration {
        let originallyDueLabelFont: UIFont
        let snoozedUntilLabelFont: UIFont
        
        static let normalQueueConfiguration = QueueCellConfiguration(nameLabelFont: UIFont.boldSystemFont(ofSize: 20), dosageLabelFont: UIFont.systemFont(ofSize: 16), unitsLabelFont: UIFont.systemFont(ofSize: 16), frequencyLabelFont: UIFont.systemFont(ofSize: 16), originallyDueLabelFont: UIFont.systemFont(ofSize: 16), snoozedUntilLabelFont: UIFont.systemFont(ofSize: 16))
        
        static let smallQueueConfiguration = QueueCellConfiguration(nameLabelFont: UIFont.boldSystemFont(ofSize: 16), dosageLabelFont: UIFont.systemFont(ofSize: 12), unitsLabelFont: UIFont.systemFont(ofSize: 12), frequencyLabelFont: UIFont.systemFont(ofSize: 12), originallyDueLabelFont: UIFont.systemFont(ofSize: 14), snoozedUntilLabelFont: UIFont.systemFont(ofSize: 14))
        
        init(nameLabelFont: UIFont, dosageLabelFont: UIFont, unitsLabelFont: UIFont, frequencyLabelFont: UIFont, originallyDueLabelFont: UIFont, snoozedUntilLabelFont: UIFont) {
            self.originallyDueLabelFont = originallyDueLabelFont
            self.snoozedUntilLabelFont = snoozedUntilLabelFont
            
            super.init(nameLabelFont: nameLabelFont, dosageLabelFont: dosageLabelFont, unitsLabelFont: unitsLabelFont, frequencyLabelFont: frequencyLabelFont)
        }
    }
    
    override func applyCellConfiguration(mode: InjectionTableViewCell.CellMode) {
        var config: QueueCellConfiguration
        
        if mode == .small {
            config = QueueCellConfiguration.smallQueueConfiguration
        } else {
            config = QueueCellConfiguration.normalQueueConfiguration
        }
        
        nameLabel.font = config.nameLabelFont
        dosageLabel.font = config.dosageLabelFont
        unitsLabel.font = config.unitsLabelFont
        originallyDueLabel.font = config.originallyDueLabelFont
        snoozedUntilLabel.font = config.snoozedUntilLabelFont
        
        for label in frequencyLabels {
            label.font = config.frequencyLabelFont
        }
    }
    
    func setQueueObject(_ object: Queue) {
        super.setInjection(object.injection!)
        
        originallyDueLabel.text = "Due: \(object.dateDue!.fullDateTime)"
        
        //insert before the frequency rows
        mainStackView.insertArrangedSubview(originallyDueLabel, at: 1)
        
        
        if let snoozed = object.snoozedUntil {
            snoozedUntilLabel.text = "Snoozed Until: \(snoozed.fullDateTime)"
            
            if snoozed < Date() {
                snoozedUntilLabel.textColor = .systemRed
            }
            
            mainStackView.insertArrangedSubview(snoozedUntilLabel, at: 2)
        }
    }
    

    
    
    override func prepareForReuse() {
        
        super.prepareForReuse()
        
        for label in [originallyDueLabel, snoozedUntilLabel] {
            label.text = ""
            label.removeFromSuperview()
        }
        
        
        
        
        
    }
    
   
    
}
