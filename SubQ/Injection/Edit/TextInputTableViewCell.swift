//
//  TextInputTableViewCell.swift
//  SubQ
//
//  Created by Constantine Thalasinos on 8/17/23.
//

import UIKit
import SnapKit

class TextInputTableViewCell: UITableViewCell {
    
    enum TextType{
        case text, number
    }
    
    var textInputType: TextType = .text{
        didSet{
            textField.keyboardType = textInputType == .number ? .decimalPad : .default
        }
    }
    
    lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [label, textField])
        stackView.axis = .horizontal
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.distribution = .fillProportionally
        stackView.spacing = 5
        
        return stackView
    }()
    
    let label: UILabel = {
        let label = UILabel()
        label.text = "Injection Name: "
        label.translatesAutoresizingMaskIntoConstraints = false
        //label.backgroundColor = .purple
        label.frame.size = label.intrinsicContentSize
        
        label.setContentHuggingPriority(.required, for: .horizontal)
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        return label
    }()
    let textField: UITextField = {
        let field = UITextField()
       // field.backgroundColor = .green
        
        field.textAlignment = .left
        field.placeholder = "beep boop"
        
        field.translatesAutoresizingMaskIntoConstraints = false
        //field.setContentHuggingPriority(.required, for: .horizontal)
        
        
        //field.adjustsFontSizeToFitWidth = true
        
        
        
        //field.addTarget(self, action: #selector(nameTextFieldChanged), for: .editingChanged)
        
        return field
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(stackView)
        
        stackView.snp.makeConstraints { make in
            make.leadingMargin.trailingMargin.centerY.equalToSuperview()
        }
    
        
        
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
    
    override func prepareForReuse() {
        accessoryView = nil
        label.text = ""
        textField.text = ""
    }

}
    

