//
//  InjectionTableViewCell.swift
//  SubQ
//
//  Created by Constantine Thalasinos on 8/21/23.
//

import UIKit

class InjectionTableViewCell: InjectionDescriptionTableViewCell {
    
    lazy var mainStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [injectionDescriptionStackView, frequencyStackView])
        stack.axis = .vertical
        
        return stack
        
    }()
    
    let frequencyStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        
        return stack
    }()
    
    var frequencyLabels = [UILabel]()
    
    override func setInjection(_ injection: Injection) {
        
        super.setInjection(injection)
        
        createFrequencyLabels(injection)
        
        if injection.typeVal == .scheduled && !injection.areNotificationsEnabled {
            
            nameLabel.textColor = .gray
            dosageLabel.textColor = .gray
            unitsLabel.textColor = .gray
            
            for label in frequencyLabels {
                label.textColor = .gray
            }
            
        } else {
            nameLabel.textColor = .label
            dosageLabel.textColor = .label
            unitsLabel.textColor = .label
            
            for label in frequencyLabels {
                label.textColor = .label
            }
        }
    }
    
    func createFrequencyLabels(_ injection: Injection) {
        
        if injection.typeVal == .asNeeded {
            let label = UILabel()
            label.text = Injection.InjectionType.asNeeded.rawValue
            frequencyStackView.addArrangedSubview(label)
            frequencyLabels.append(label)
        } else {
            for frequency in injection.sortedFrequencies! {
                let label = UILabel()
                label.text = frequency.scheduledString
                frequencyStackView.addArrangedSubview(label)
                frequencyLabels.append(label)
            }
        }
    }
    
    
    
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(mainStackView)
        
       mainStackView.snp.makeConstraints { make in
            make.margins.equalToSuperview()
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
        
        super.prepareForReuse()
        
        for label in frequencyLabels {
            label.removeFromSuperview()
        }
        
        frequencyLabels = [UILabel]()
    }
    

}
