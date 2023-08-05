//
//  ResultsHeaderView.swift
//  SubQ
//
//  Created by Constantine Thalasinos on 8/3/23.
//

import UIKit
import SnapKit

class ResultsHeaderView: UICollectionReusableView {
    
    let label = UILabel()
    
    lazy var filterButton: UIButton = {
        
        var buttonConfig = UIButton.Configuration.gray()
        buttonConfig.buttonSize = .medium
        buttonConfig.cornerStyle = .small
        buttonConfig.title = "Filter"
        
        return UIButton(configuration: buttonConfig)
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(label)
        addSubview(filterButton)
        
        
        label.translatesAutoresizingMaskIntoConstraints = false
        filterButton.translatesAutoresizingMaskIntoConstraints = false
        
        label.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        
        filterButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.centerY.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
