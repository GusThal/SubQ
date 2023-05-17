//
//  TextSupplementaryView.swift
//  SubQ
//
//  Created by Constantine Thalasinos on 5/16/23.
//

import UIKit

class TextSupplementaryView: UICollectionReusableView {
    let label = UILabel()
    static let reuseIdentifier = "title-supplementary-reuse-identifier"

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.adjustsFontForContentSizeCategory = true
        
        label.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        label.font = UIFont.preferredFont(forTextStyle: .title3)
    }
    required init?(coder: NSCoder) {
        fatalError()
    }
    
}
