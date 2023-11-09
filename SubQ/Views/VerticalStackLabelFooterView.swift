//
//  VerticalStackLabelFooterView.swift
//  SubQ
//
//  Created by Constantine Thalasinos on 11/8/23.
//

import UIKit

class VerticalStackLabelFooterView: UICollectionReusableView {

    private lazy var stackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [label, secondaryLabel])
        stack.axis = .vertical
        
        return stack
    }()
    
    
    let label: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 16)
        
        return label
    }()
    
    let secondaryLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .gray
        label.numberOfLines = 2
        
       return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(stackView)
        
        stackView.snp.makeConstraints { make in
            make.leftMargin.equalToSuperview()
            make.rightMargin.topMargin.bottomMargin.equalToSuperview()
        }
        
    }
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func prepareForReuse() {
        label.text = ""
        secondaryLabel.text = ""
    }
}
