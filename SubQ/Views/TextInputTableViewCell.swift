//
//  TextInputTableViewCell.swift
//  SubQ
//
//  Created by Constantine Thalasinos on 5/11/23.
//

import UIKit
import SnapKit

class TextInputTableViewCell: UITableViewCell {

    var tableView: EditInjectionTableViewController?
    
    
    let label: UILabel = {
        let label = UILabel()
        label.text = "Injection Name: "
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = .purple
        
        return label
    }()
    let textField: UITextField = {
        let field = UITextField()
        field.backgroundColor = .green
        
        field.textAlignment = .left
        field.placeholder = "beep boop"
        
        field.translatesAutoresizingMaskIntoConstraints = false
        
        //field.addTarget(self, action: #selector(nameTextFieldChanged), for: .editingChanged)
        
        return field
    }()
    
  
    
   let horizonalStackView: UIStackView = {
       let stack = UIStackView()
       stack.axis = .horizontal
       stack.distribution = .fillEqually
       stack.spacing = CGFloat(10)
      // stack.alignment = .bottom
       
       
       //stack.isLayoutMarginsRelativeArrangement = true
        
       stack.translatesAutoresizingMaskIntoConstraints = false
        
       return stack
    }()
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?){
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        horizonalStackView.addArrangedSubview(label)
        horizonalStackView.addArrangedSubview(textField)
        
        textField.snp.makeConstraints { make in
            make.right.equalToSuperview()
            make.left.equalTo(label.snp.right)
        }
        
        contentView.addSubview(horizonalStackView)
        
        
        
        
        
       horizonalStackView.snp.makeConstraints {(make) -> Void in
           make.center.equalToSuperview()
           make.leading.equalToSuperview()
           make.trailing.equalToSuperview()
        }
    }
    
    @objc func nameTextFieldChanged(_ sender: UITextField){
        //tableView!.name = sender.text
        
    }
    
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
