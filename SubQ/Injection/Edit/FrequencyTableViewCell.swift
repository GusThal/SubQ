//
//  FrequencyTableViewCell.swift
//  SubQ
//
//  Created by Constantine Thalasinos on 8/18/23.
//

import UIKit
import SnapKit

class FrequencyTableViewCell: UITableViewCell {
    
    let timePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .time
        picker.preferredDatePickerStyle = .inline
        picker.translatesAutoresizingMaskIntoConstraints = false
        picker.backgroundColor = .red
        
        return picker
    }()
    
    var daysButtonTitle: String?{
        didSet{
            daysButton.setNeedsUpdateConfiguration()
        }
    }
    
    lazy var daysButton: UIButton = {
        let action = UIAction { _ in
            
        }
        
        
        let button = UIButton(primaryAction: action)
        
        button.configurationUpdateHandler = { [unowned self] button in
            
            var config: UIButton.Configuration!
            config = UIButton.Configuration.gray()
            
            if let daysButtonTitle{
                config.title = daysButtonTitle
                config.baseForegroundColor = .black
            }
            
            else{
                config.baseForegroundColor = .blue
                config.title = "Select Day(s)"
            }
            
            config.imagePlacement = .trailing
            
            let imageConfig = UIImage.SymbolConfiguration(pointSize: 10)
            let image = UIImage(systemName: "chevron.right", withConfiguration: imageConfig)
            
            config.image = image
            button.configuration = config
        }

        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(timePicker)
        contentView.addSubview(daysButton)
        
        print(timePicker.contentHuggingPriority(for: .horizontal))
        print(daysButton.contentHuggingPriority(for: .horizontal))
        
        timePicker.snp.makeConstraints { make in
            make.centerY.trailingMargin.equalToSuperview()
        }
        
        daysButton.snp.makeConstraints { make in
            make.centerY.leadingMargin.equalToSuperview()
            make.trailingMargin.equalTo(timePicker.snp.leading)
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
        daysButtonTitle = nil
        timePicker.date = Date()
    }

}
