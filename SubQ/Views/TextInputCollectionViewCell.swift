//
//  TextInputCollectionViewCell.swift
//  SubQ
//
//  Created by Constantine Thalasinos on 5/19/23.
//

import UIKit

class TextInputCollectionViewCell: UICollectionViewListCell {
    
    enum TextType{
        case text, number
    }
    
    var textInputType: TextType = .text{
        didSet{
            textField.keyboardType = textInputType == .number ? .decimalPad : .default
        }
    }
    
    let label: UILabel = {
        let label = UILabel()
        label.text = "Injection Name: "
        label.translatesAutoresizingMaskIntoConstraints = false
       // label.backgroundColor = .purple
        label.frame.size = label.intrinsicContentSize
        
        return label
    }()
    let textField: UITextField = {
        let field = UITextField()
       // field.backgroundColor = .green
        
        field.textAlignment = .left
        field.placeholder = "beep boop"
        
        field.translatesAutoresizingMaskIntoConstraints = false
        
        field.adjustsFontSizeToFitWidth = true
        
        
        
        //field.addTarget(self, action: #selector(nameTextFieldChanged), for: .editingChanged)
        
        return field
    }()
    
  
    
/*   let horizonalStackView: UIStackView = {
       let stack = UIStackView()
       stack.axis = .horizontal
      // stack.distribution = .fillEqually
       stack.distribution = .fillProportionally
       stack.spacing = CGFloat(10)
      // stack.alignment = .bottom
       
       
       //stack.isLayoutMarginsRelativeArrangement = true
        
       stack.translatesAutoresizingMaskIntoConstraints = false
        
       return stack
    }()*/
    
    override init(frame: CGRect) {
        super.init(frame: frame)
      //  horizonalStackView.addArrangedSubview(label)
     //   horizonalStackView.addArrangedSubview(textField)
        
        
        contentView.addSubview(label)
        contentView.addSubview(textField)
       // contentView.backgroundColor = .brown
        
        label.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(10)
            make.centerY.equalToSuperview()
        }
        
        textField.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(10)
            make.left.equalTo(label.snp.right).offset(5)
            make.centerY.equalToSuperview()
        }
        
        //contentView.addSubview(horizonalStackView)

     /*  horizonalStackView.snp.makeConstraints {(make) -> Void in
           make.center.equalToSuperview()
           make.leading.equalToSuperview()
           make.trailing.equalToSuperview()
        }*/
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


}
