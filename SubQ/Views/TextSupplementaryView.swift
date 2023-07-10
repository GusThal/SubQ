//
//  TextSupplementaryView.swift
//  SubQ
//
//  Created by Constantine Thalasinos on 5/16/23.
//

import UIKit

class TextSupplementaryView: UICollectionReusableView {
    
    var supplementaryViewKind: InjectNowViewController.SupplementaryViewKind = .header{
        didSet{
            if supplementaryViewKind == .footer{
                addSupplementaryLabel()
            }
        }
    }
    
    let label = UILabel()
    let secondaryLabel = UILabel()
    
    static let reuseIdentifier = "title-supplementary-reuse-identifier"

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.adjustsFontForContentSizeCategory = true
        
        label.snp.makeConstraints { make in
            make.leadingMargin.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        
        label.font = UIFont.preferredFont(forTextStyle: .title3)
    }
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    private func addSupplementaryLabel(){
        
        secondaryLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(secondaryLabel)
        
        secondaryLabel.snp.makeConstraints { make in
            make.trailingMargin.centerY.equalToSuperview()
            make.leadingMargin.equalTo(label.snp.trailingMargin)
        }
        
    }
    
}
