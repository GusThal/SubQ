//
//  InjectionTableViewCell.swift
//  SubQ
//
//  Created by Constantine Thalasinos on 8/21/23.
//

import UIKit

class InjectionDescriptionTableViewCell: UITableViewCell {
    
    var injection: Injection?
    
    let nameLabel: UILabel = {
        
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.setContentHuggingPriority(.required, for: .horizontal)
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        
       // label.backgroundColor = .brown
        
        return label
    }()
    
    let dosageLabel: UILabel = {
        let label = UILabel()
        label.setContentHuggingPriority(.required, for: .horizontal)
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        //label.backgroundColor = .red
        return label
    }()
    
    let unitsLabel: UILabel = {
        let label = UILabel()
        //label.backgroundColor = .blue
        
        return label
    }()
    
    lazy var injectionDescriptionStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [nameLabel, dosageLabel, unitsLabel])
        stack.axis = .horizontal
        
        stack.spacing = 5
        
        return stack
    }()
    
    
    func setInjection(_ injection: Injection) {
        
        
        nameLabel.text = injection.name
        dosageLabel.text = "\(injection.dosage!)"
        unitsLabel.text = injection.units
        
    }
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
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
        
        injection = nil
        nameLabel.text = ""
        dosageLabel.text = ""
        unitsLabel.text = ""
        
    }
    

}

