//
//  TimePickerTableViewCell.swift
//  SubQ
//
//  Created by Constantine Thalasinos on 8/27/23.
//

import UIKit
import SnapKit

class TimePickerTableViewCell: UITableViewCell {
    
    let timePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .time
        picker.preferredDatePickerStyle = .wheels
        picker.translatesAutoresizingMaskIntoConstraints = false
    
         return picker
     }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(timePicker)
        timePicker.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        self.timePicker.date = Date()
        
        timePicker.enumerateEventHandlers { action, selector, event, stop in
            if event == .primaryActionTriggered {
                if let action {
                    timePicker.removeAction(action, for: .primaryActionTriggered)
                }
               
            }
        }
    }

}
