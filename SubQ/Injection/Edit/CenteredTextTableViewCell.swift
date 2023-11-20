//
//  CenteredTextTableViewCell.swift
//  SubQ
//
//  Created by Constantine Thalasinos on 8/20/23.
//

import UIKit

class CenteredTextTableViewCell: UITableViewCell {
    
    let label: UILabel = {
        let label = UILabel()
        label.text = "Delete Injection"
        label.translatesAutoresizingMaskIntoConstraints = false

        label.textColor = .systemRed
        label.frame.size = label.intrinsicContentSize
        
        return label
    }()

    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(label)
        
        label.snp.makeConstraints { make in
            make.center.equalToSuperview()
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
    

}
