//
//  TextSupplementaryView.swift
//  SubQ
//
//  Created by Constantine Thalasinos on 5/16/23.
//

import UIKit

class TextSupplementaryView: UICollectionReusableView {
    
    enum SupplementaryViewKind {
        case header, footer
    }
    
    var supplementaryViewKind: SupplementaryViewKind = .header{
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
            make.leadingMargin.equalToSuperview().offset(15)
            make.centerY.equalToSuperview()
        }
        
        label.font = UIFont.preferredFont(forTextStyle: .title3)
    }
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    private func addSupplementaryLabel(){
        
        secondaryLabel.translatesAutoresizingMaskIntoConstraints = false
        secondaryLabel.numberOfLines = 2
        addSubview(secondaryLabel)
        
        secondaryLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailingMargin.equalToSuperview().offset(-15)
            make.leadingMargin.equalTo(label.snp.trailing).offset(15)
        }
        
    }
    
    override func prepareForReuse() {
        label.text = ""
        secondaryLabel.text = ""
    }
    
}
