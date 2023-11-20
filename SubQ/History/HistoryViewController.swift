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
    
    lazy var imageView: UIImageView = {
        let image = UIImage(named: "\(history.site!.section!.bodyPart!.part!.lowercased())-\(history.site!.section!.quadrant!)-\(history.site!.subQuadrant!)")
        
        let view = UIImageView(image: image)
        view.contentMode = .scaleAspectFit
        
        return view
    }()
    
    lazy var stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.spacing = 1
        stack.alignment = .fill
    
        
        return stack
        
    }()
    
    let injectionDescriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.text = "Injection:"
        
        return label
    }()
    
    let injectionDescriptionDataLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        
        return label
    }()
    
    let injectedDateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.text = "Injected:"
        
        return label
    }()
    
    let injectedDateDataLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        
        return label
    }()
    
    let dueDateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.text = "Due:"
        
        return label
    }()
    
    let dueDateDataLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        
        return label
    }()
    
    
    let siteLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.text = "Site:"
        
        return label
    }()
    
    let siteDataLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        
        return label
    }()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Past Injection"
        
        
        view.backgroundColor = .systemBackground
        
        
        view.addSubview(stackView)
        
        stackView.snp.makeConstraints { make in
            make.leftMargin.rightMargin.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
        }
    }
    
    init(history: History){
        self.history = history
        
        super.init(nibName: nil, bundle: nil)
        
        injectionDescriptionDataLabel.text = history.injection!.descriptionString
        
        stackView.addArrangedSubview(injectionDescriptionLabel)
        stackView.addArrangedSubview(injectionDescriptionDataLabel)
        
        injectedDateDataLabel.text = history.date!.fullDateTime
        
        stackView.addArrangedSubview(injectedDateLabel)
        stackView.addArrangedSubview(injectedDateDataLabel)
        
        
        if let date = history.dueDate {
            dueDateDataLabel.text = date.fullDateTime
            
            stackView.addArrangedSubview(dueDateLabel)
            stackView.addArrangedSubview(dueDateDataLabel)
        }
        
        
        siteDataLabel.text = "\(history.site!.subQuadrantVal.description) of \(history.site!.section!.quadrantVal.description) of \(history.site!.section!.bodyPart!.part!)"
        stackView.addArrangedSubview(siteLabel)
        stackView.addArrangedSubview(siteDataLabel)
        stackView.addArrangedSubview(imageView)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
