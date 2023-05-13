//
//  DayTableViewCell.swift
//  SubQ
//
//  Created by Constantine Thalasinos on 5/13/23.
//

import UIKit

class DayTableViewCell: UITableViewCell {
    
    #warning("This cell might need to display six days at once, so its size needs to be dynamic.")
    
    let leftLabel: UILabel = {
        let label = UILabel()
        label.text = "Day(s)"
        
        return label
        
    }()
    
    let rightLabel: UILabel = {
        let label = UILabel()
        label.text = "None Selected"
        
        return label
    }()
    
    let horizontalStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        
        return stack
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        horizontalStackView.addArrangedSubview(leftLabel)
        horizontalStackView.addArrangedSubview(rightLabel)
        
        contentView.addSubview(horizontalStackView)
        
        horizontalStackView.snp.makeConstraints { (make) -> Void in
            make.center.equalToSuperview()
            make.trailing.equalToSuperview()
            make.leading.equalToSuperview()
        }
        
        self.accessoryType = .disclosureIndicator
        
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
        
        self.isSelected = false
    }

}
