//
//  ZoneCollectionViewCell.swift
//  SubQ
//
//  Created by Constantine Thalasinos on 5/16/23.
//

import UIKit
import SnapKit

class SectionCollectionViewCell: UICollectionViewCell {
    let label = UILabel()
    
    var section: Section?

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.adjustsFontForContentSizeCategory = true
        contentView.addSubview(label)
        
        label.backgroundColor = .orange
        
        
        label.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    required init?(coder: NSCoder) {
        fatalError("not implemnted")
    }
}
