//
//  TimePickerCollectionViewCell.swift
//  SubQ
//
//  Created by Constantine Thalasinos on 5/19/23.
//

import UIKit

class TimePickerCollectionViewCell: UICollectionViewListCell {
    
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
