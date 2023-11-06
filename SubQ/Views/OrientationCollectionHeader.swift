//
//  OrientationCollectionHeader.swift
//  SubQ
//
//  Created by Constantine Thalasinos on 10/24/23.
//

import UIKit
import SnapKit

class OrientationCollectionHeader: UICollectionReusableView {
    
    let leftLabel: UILabel = {
        let label = UILabel()
        label.text = "← Your Left"
        label.textColor = .label
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.backgroundColor = .systemBackground

        return label
    }()
    
    let rightLabel: UILabel = {
        let label = UILabel()
        label.text = "Your Right →"
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textColor = .label
        label.backgroundColor = .systemBackground
        
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(leftLabel)
        addSubview(rightLabel)
        
        backgroundColor = .systemBackground
        
        
        
        leftLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(5)
            make.top.bottom.equalToSuperview()
        }
        
        rightLabel.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-5)
            make.top.bottom.equalToSuperview()
        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
