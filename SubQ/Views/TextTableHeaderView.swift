//
//  TextTableHeaderView.swift
//  SubQ
//
//  Created by Constantine Thalasinos on 10/9/23.
//

import UIKit
import SnapKit

class TextTableHeaderView: UITableViewHeaderFooterView {
    
    let label = UILabel()

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(label)
        label.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(-4)
            make.top.equalToSuperview().offset(4)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        label.text = ""
    }
    
}
