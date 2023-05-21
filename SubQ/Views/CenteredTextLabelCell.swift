//
//  CenteredTextLabelCell.swift
//  SubQ
//
//  Created by Constantine Thalasinos on 5/21/23.
//

import UIKit

class CenteredTextLabelCell: UICollectionViewListCell {
    let label: UILabel = {
        let label = UILabel()
        label.text = "Injection Name: "
        label.translatesAutoresizingMaskIntoConstraints = false
       // label.backgroundColor = .purple
        label.textColor = .red
        label.frame.size = label.intrinsicContentSize
        
        return label
    }()

    
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.addSubview(label)
       
       // contentView.backgroundColor = .brown
        
        label.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        

    }
    
    @objc func nameTextFieldChanged(_ sender: UITextField){
        //tableView!.name = sender.text
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
}
