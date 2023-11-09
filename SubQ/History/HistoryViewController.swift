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
       // view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleAspectFit
        
        return view
    }()
    
    lazy var stackView: UIStackView = {
       // let stack = UIStackView(arrangedSubviews: [injectionDescriptionLabel, injectedDateLabel, siteLabel, dueDateLabel])
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
 //       view.addSubview(imageView)
        
        stackView.snp.makeConstraints { make in
            make.leftMargin.rightMargin.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
        }
        
/*        imageView.snp.makeConstraints { make in
            make.top.equalTo(stackView.snp.bottom).offset(10)
           // make.centerX.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }*/
        
        /*view.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }*/
        
/*        view.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.leadingMargin.equalToSuperview()
            make.trailingMargin.equalToSuperview()
            make.centerY.equalToSuperview()
        }*/
        
        

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
        
        
   /*     let injectionDataView = DataView(field: "Injection:", data: history.injection!.descriptionString)
        stackView.addArrangedSubview(injectionDataView)
        
        let dateDataView = DataView(field: "Injected:", data: history.date!.fullDateTime)
        stackView.addArrangedSubview(dateDataView)
        
        
        
        if let dueDate = history.dueDate {
            let dueDateDataView = DataView(field: "Due:", data: dueDate.fullDateTime)
            stackView.addArrangedSubview(dueDateDataView)
        }
        
        let siteDataView = DataView(field: "Site:", data: "\(history.site!.subQuadrant!) of \(history.site!.section!.quadrant!) of \(history.site!.section!.bodyPart!.part!)")
        stackView.addArrangedSubview(siteDataView)*/
        
        
       /* injectionDescriptionLabel.text = history.injection?.descriptionString
        injectedDateLabel.text = history.date!.fullDateTime
        siteLabel.text = "\(history.site!.section!.bodyPart!.part!) | \(history.site!.section!.quadrant!) | \(history.site!.subQuadrant!)"
        dueDateLabel.text = history.dueDate?.fullDateTime ?? ""*/
        
        
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
