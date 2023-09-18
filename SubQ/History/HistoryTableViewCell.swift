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
        label.font = UIFont.systemFont(ofSize: 14)
        
        return label
        
    }()
    
    let historyDateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 14)
        
        return label
    }()
    
    
    lazy var statusStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [statusLabel, historyView])
        stack.axis = .horizontal
        stack.alignment = .firstBaseline
        stack.spacing = 5
        
        return stack
        
    }()
    
    lazy var historyView: UIView = {
        let view = UIView(frame: .zero)
        view.addSubview(historyDateLabel)
        historyDateLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        return view
    }()
    
    lazy var dueDateView: UIView = {
        let view = UIView(frame: .zero)
        view.addSubview(dueDateLabel)
        dueDateLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        return view
    }()
    
    let dueDateLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 14)
        
        return label
    }()
    
    lazy var historyDataStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [statusStackView, dueDateView])
        stack.axis = .vertical
        
        
        return stack
    }()
    
    func setHistory(_ history: History) {
        statusLabel.text = "\(history.status!.capitalized):"
        
        if history.statusVal == .injected {
            statusLabel.textColor = .systemBlue
        } else {
            statusLabel.textColor = .systemRed
        }
        
        historyDateLabel.text = history.date!.fullDateTime
        dueDateLabel.text = "Originally Due: \(history.dueDate!.fullDateTime)"
        
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
