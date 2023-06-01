//
//  TimePickerCollectionViewCell.swift
//  SubQ
//
//  Created by Constantine Thalasinos on 5/19/23.
//

//https://github.com/LeeKahSeng/SwiftSenpai-UICollectionView-List/blob/master/Swift-Senpai-UICollectionView-List/Date%20Picker%20Replica/DatePickerReplicaViewController.swift

//https://swiftsenpai.com/development/uicollectionview-list-custom-cell/

import UIKit

class TimePickerCollectionViewCell: UICollectionViewListCell {
    
    override func updateConfiguration(using state: UICellConfigurationState) {
        
        // Create new configuration object and update it base on state
        var newConfiguration = DatePickerContentConfiguration().updated(for: state)
        
        // Update any configuration parameters related to data item
        //newConfiguration.item = item
        
        // Set content configuration in order to update custom content view
        contentConfiguration = newConfiguration
        
    }
}

    
 /*
    let picker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .time
        picker.preferredDatePickerStyle = .wheels
        picker.translatesAutoresizingMaskIntoConstraints = true
        
       
        
        return picker
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.translatesAutoresizingMaskIntoConstraints = true
        contentView.addSubview(picker)
        
        
        contentView.snp.makeConstraints { make in
            make.height.equalTo(200)
         }
        
        picker.snp.makeConstraints { make in
            make.edges.equalTo(self)
        }
        
       
        
        
    }
    

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

  }
*/

