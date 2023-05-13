//
//  DosageTableViewCell.swift
//  SubQ
//
//  Created by Constantine Thalasinos on 5/12/23.
//

import UIKit

class DosageTableViewCell: UITableViewCell {

    var tableView: EditInjectionTableViewController?
    
    let label: UILabel = {
        let label = UILabel()
        label.text = "Dosage: "
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    let textField: UITextField = {
        let field = UITextField()
        
        field.keyboardType = .decimalPad
        field.placeholder = "0.0"
        
        field.translatesAutoresizingMaskIntoConstraints = false
        
        return field
    }()
    
    /*let segmentedControl: HMSegmentedControl = {
        let seg = HMSegmentedControl(sectionTitles: ["CC", "mL"])
        
        seg.translatesAutoresizingMaskIntoConstraints = false
        
        return seg
    }()*/
    
    let segmentedControl: UISegmentedControl = {
        let seg = UISegmentedControl(items: Injection.DosageUnits.allCases.map { $0.rawValue})
        
        seg.translatesAutoresizingMaskIntoConstraints = false
        
        return seg
    }()
    
   let horizonalStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
       stack.isLayoutMarginsRelativeArrangement = true
        
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        return stack
    }()
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?){
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        horizonalStackView.addArrangedSubview(label)
        horizonalStackView.addArrangedSubview(textField)
        horizonalStackView.addArrangedSubview(segmentedControl)
        contentView.addSubview(horizonalStackView)
        
        
        
       horizonalStackView.snp.makeConstraints {(make) -> Void in
           make.center.equalToSuperview()
           make.leading.equalToSuperview()
           make.trailing.equalToSuperview()
        }
    }
    
    
 /*   @objc func dosageTextFieldChanged(_ sender: UITextField){
        tableView!.dosage = sender.text
        
    }*/
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    

}

