//
//  FilterTableFooterView.swift
//  SubQ
//
//  Created by Constantine Thalasinos on 8/4/23.
//

import UIKit
import SnapKit

class FilterTableFooterView: UITableViewHeaderFooterView {
    
    lazy var stackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [applyButton, resetButton])
        view.axis = .vertical
        view.distribution = .fillProportionally
        view.translatesAutoresizingMaskIntoConstraints = false
        view.alignment = .fill
        
        return view
    }()
    
    lazy var applyButton: UIButton = {
        
        var buttonConfig = UIButton.Configuration.filled()
        buttonConfig.buttonSize = .large
        buttonConfig.cornerStyle = .capsule
        buttonConfig.title = "Apply"
        buttonConfig.baseBackgroundColor = .blue
        
        let button =  UIButton(configuration: buttonConfig)
        button.translatesAutoresizingMaskIntoConstraints = false

        return button
    }()
    
    lazy var resetButton: UIButton = {
        
        var buttonConfig = UIButton.Configuration.plain()
        buttonConfig.buttonSize = .large
        buttonConfig.cornerStyle = .capsule
        buttonConfig.title = "Reset"
        
        let button =  UIButton(configuration: buttonConfig)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    override init(reuseIdentifier: String?) {
        print("init")
        super.init(reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(stackView)
        
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
