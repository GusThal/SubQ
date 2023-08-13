//
//  HistoryViewController.swift
//  SubQ
//
//  Created by Constantine Thalasinos on 8/11/23.
//

import UIKit
import SnapKit

class HistoryViewController: UIViewController, Coordinated {
    
    weak var coordinator: Coordinator?
    weak var historyCoordinator: HistoryCoordinator?
    
    let history: History
    
    lazy var stackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [injectionDescriptionLabel, injectedDateLabel, siteLabel, dueDateLabel])
        stack.axis = .vertical
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        return stack
        
    }()
    
    let injectedDateLabel: UILabel = {
        let label = UILabel()
        
        return label
    }()
    
    let injectionDescriptionLabel: UILabel = {
        let label = UILabel()
        
        return label
    }()
    
    let siteLabel: UILabel = {
        let label = UILabel()
        
        return label
    }()
    
    let dueDateLabel: UILabel = {
        let label = UILabel()
        
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .red
        
        view.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.leadingMargin.equalToSuperview()
            make.trailingMargin.equalToSuperview()
            make.centerY.equalToSuperview()
        }

    }
    
    init(history: History){
        self.history = history
        
        injectionDescriptionLabel.text = history.injection?.descriptionString
        injectedDateLabel.text = history.date!.fullDateTime
        siteLabel.text = "\(history.site!.section!.bodyPart!.part!) | \(history.site!.section!.quadrant!) | \(history.site!.subQuadrant!)"
        dueDateLabel.text = history.dueDate!.fullDateTime
        
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
