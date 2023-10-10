//
//  ResultsHeaderView.swift
//  SubQ
//
//  Created by Constantine Thalasinos on 8/3/23.
//

import UIKit
import SnapKit

class ResultsHeaderView: UITableViewHeaderFooterView {
    
    let label = UILabel()
    
    lazy var filterButton: BadgeButton = {
        
        var buttonConfig = UIButton.Configuration.gray()
        buttonConfig.buttonSize = .medium
        buttonConfig.cornerStyle = .small
        buttonConfig.title = "Filter"
        buttonConfig.baseForegroundColor = InterfaceDefaults.primaryColor
        
        return BadgeButton(configuration: buttonConfig)
    }()
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        addSubview(label)
        addSubview(filterButton)
        
        
        label.translatesAutoresizingMaskIntoConstraints = false
        filterButton.translatesAutoresizingMaskIntoConstraints = false
        
        label.snp.makeConstraints { make in
            make.leadingMargin.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        
        filterButton.snp.makeConstraints { make in
            make.trailingMargin.equalToSuperview()
            make.centerY.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
