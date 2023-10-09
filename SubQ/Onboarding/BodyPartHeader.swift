//
//  BodyPartHeader.swift
//  SubQ
//
//  Created by Constantine Thalasinos on 10/1/23.
//

import UIKit
import SnapKit

class BodyPartHeader: UICollectionReusableView {
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Select Injection Sites"
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 30)
        label.backgroundColor = .brown
        label.numberOfLines = 0
        
        return label
    }()
    
    let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Note: These Can Be Changed Later in Settings."
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 15)
        label.numberOfLines = 0
        label.backgroundColor = .yellow
        
        return label
    }()
    
    lazy var stackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        stack.axis = .vertical
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(stackView)
        
        stackView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.bottomMargin.equalToSuperview()
        }
        
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
