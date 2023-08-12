//
//  HistoryViewController.swift
//  SubQ
//
//  Created by Constantine Thalasinos on 8/11/23.
//

import UIKit

class HistoryViewController: UIViewController, Coordinated {
    
    weak var coordinator: Coordinator?
    weak var historyCoordinator: HistoryCoordinator?
    
    let history: History
    
    lazy var stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        
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

        // Do any additional setup after loading the view.
    }
    
    init(history: History){
        self.history = history
        
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
