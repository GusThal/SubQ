//
//  TableViewCell.swift
//  SubQ
//
//  Created by Constantine Thalasinos on 8/3/23.
//

import UIKit
import SnapKit

class DateRangeTableViewCell: UITableViewCell {
    
    lazy var stackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [startLabel, startDatePicker, endLabel, endDatePicker])
        view.axis = .horizontal
        view.distribution = .equalCentering
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    let startLabel: UILabel = {
        let label = UILabel()
        label.text = "Start"
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    let endLabel: UILabel = {
        let label = UILabel()
        label.text = "End"
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    let startDatePicker: UIDatePicker = {
        
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .compact
        picker.timeZone = .current
        
        picker.translatesAutoresizingMaskIntoConstraints = false
        
        return picker
    }()
    
    let endDatePicker: UIDatePicker = {
        
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .compact
        picker.timeZone = .current
        
        picker.translatesAutoresizingMaskIntoConstraints = false
        
        return picker
    }()
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
       
        
        contentView.addSubview(stackView)
        
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
       /* contentView.addSubview(label)
        contentView.addSubview(startDatePicker)
        contentView.addSubview(endDatePicker)
        
        label.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview()
        }
        
        datePicker.snp.makeConstraints { make in
            make.trailing.top.bottom.equalToSuperview()
        }*/
        
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

}
