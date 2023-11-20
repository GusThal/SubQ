//
//  FrequencyTableViewCell.swift
//  SubQ
//
//  Created by Constantine Thalasinos on 8/18/23.
//

import UIKit
import SnapKit

class FrequencyTableViewCell: UITableViewCell {
    
    
    var daysButtonTitle: String?{
        didSet{
            daysButton.setNeedsUpdateConfiguration()
        }
    }
    
    var selectedTime: Date = Date() {
        didSet {
            timeButton.setNeedsUpdateConfiguration()
        }
    }
    
    var timeButtonSelected = false {
        didSet {
            timeButton.setNeedsUpdateConfiguration()
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
                config.baseForegroundColor = .label
            }
            
            else{
                config.baseForegroundColor = .systemBlue
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
    
    lazy var timeButton: UIButton = {
        let action = UIAction { _ in
            
        }
        
        let button = UIButton(primaryAction: action)
        
        button.configurationUpdateHandler = { [unowned self] button in
            
            var config: UIButton.Configuration!
            config = UIButton.Configuration.gray()
            
            if timeButtonSelected {
                config.baseForegroundColor = .systemRed
            }
            else {
                config.baseForegroundColor = .label
            }
            
            config.title = selectedTime.prettyTime
            
            button.configuration = config
        }

        button.translatesAutoresizingMaskIntoConstraints = false
        button.setContentHuggingPriority(.required, for: .horizontal)
        button.setContentCompressionResistancePriority(.required, for: .horizontal)
        button.setContentHuggingPriority(.required, for: .vertical)
        button.setContentCompressionResistancePriority(.required, for: .vertical)
        
        return button
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(timeButton)
        contentView.addSubview(daysButton)
        
        timeButton.snp.makeConstraints { make in
            make.trailingMargin.bottomMargin.topMargin.equalToSuperview().offset(5)
            make.width.equalTo(100)
            make.centerY.equalToSuperview()
            //make.centerY.equalToSuperview()
        }
        
        daysButton.snp.makeConstraints { make in
            make.leadingMargin.bottomMargin.topMargin.equalToSuperview().offset(5)
            make.right.equalTo(timeButton.snp.left).offset(-5)
            make.centerY.equalToSuperview()
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
        selectedTime = Date()
        timeButtonSelected = false
        
        timeButton.enumerateEventHandlers { action, selector, event, stop in
            if event == .primaryActionTriggered {
                if let action {
                    timeButton.removeAction(action, for: .primaryActionTriggered)
                }
               
            }
        }
        
    }

}
