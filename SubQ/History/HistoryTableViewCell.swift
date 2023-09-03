//
//  HistoryTableViewCell.swift
//  SubQ
//
//  Created by Constantine Thalasinos on 9/1/23.
//

import UIKit

class HistoryTableViewCell: InjectionDescriptionTableViewCell {
    
    var history: History?
    
    lazy var mainStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [injectionDescriptionStackView, historyDataStackView])
        stack.axis = .vertical
        
        return stack
        
    }()
    
    let statusLabel: UILabel = {
        let label = UILabel()
        label.setContentHuggingPriority(.required, for: .horizontal)
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        return label
        
    }()
    
    let historyDateLabel: UILabel = {
        let label = UILabel()
        
        return label
    }()
    
    lazy var statusStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [statusLabel, historyDateLabel])
        stack.axis = .horizontal
        stack.spacing = 5
        
        return stack
        
    }()
    
    let dueDateLabel: UILabel = {
        let label = UILabel()
        
        return label
    }()
    
    lazy var historyDataStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [statusStackView, dueDateLabel] )
        stack.axis = .vertical
        
        
        return stack
    }()
    
    func setHistory(_ history: History) {
        statusLabel.text = history.status
        historyDateLabel.text = history.date!.fullDateTime
        dueDateLabel.text = history.dueDate!.fullDateTime
        
        super.setInjection(history.injection!)
        
        
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(mainStackView)
        
        mainStackView.snp.makeConstraints { make in
             make.margins.equalToSuperview()
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
        super.prepareForReuse()
        
        history = nil
        statusLabel.text = ""
        historyDateLabel.text = ""
        dueDateLabel.text = ""
        
    }

}
