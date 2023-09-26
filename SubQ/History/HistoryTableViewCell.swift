//
//  HistoryTableViewCell.swift
//  SubQ
//
//  Created by Constantine Thalasinos on 9/1/23.
//

import UIKit
import SnapKit

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
        label.font = UIFont.boldSystemFont(ofSize: 14)
        
        return label
        
    }()
    
    let dueLabel: UILabel = {
        let label = UILabel()
        label.text = "Due:"
        
        label.setContentHuggingPriority(.required, for: .horizontal)
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        label.font = UIFont.boldSystemFont(ofSize: 14)
        
        return label
        
    }()
    
    let historyDateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 14)
        
        return label
    }()
    
    let statusImageView: UIImageView = {
        let view = UIImageView()
        view.setContentHuggingPriority(.required, for: .horizontal)
        view.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        return view
    }()
    
   let dueImageView: UIImageView = {
        let config = UIImage.SymbolConfiguration(font: UIFont.systemFont(ofSize: 14))
        let image = UIImage(systemName: "calendar.badge.clock", withConfiguration: config)
        
        let view = UIImageView(image: image)
        view.tintColor = .label
        view.setContentHuggingPriority(.required, for: .horizontal)
        view.setContentCompressionResistancePriority(.required, for: .horizontal)

        
        return view
    }()
    
    
    lazy var statusStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [statusImageView, statusLabel, historyView])
        stack.axis = .horizontal
        stack.alignment = .firstBaseline
        stack.spacing = 5
        
        return stack
        
    }()
    
    lazy var dueStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [dueImageView, dueLabel, dueDateView])
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
        let stack = UIStackView(arrangedSubviews: [statusStackView])
        stack.axis = .vertical
        
        
        return stack
    }()
    
    func setHistory(_ history: History) {
        statusLabel.text = "\(history.status!.capitalized):"
        
        let symbolConfig = UIImage.SymbolConfiguration(font: UIFont.systemFont(ofSize: 14))
        
        
        if history.statusVal == .injected {
            statusImageView.image = UIImage(systemName: "checkmark.circle.fill", withConfiguration: symbolConfig)
            statusImageView.tintColor = .systemGreen
        } else {
            statusImageView.image = UIImage(systemName: "x.circle.fill", withConfiguration: symbolConfig)
            statusImageView.tintColor = .systemRed
        }
        
        historyDateLabel.text = history.date!.fullDateTime
        
        if let due = history.dueDate {
            historyDataStackView.addArrangedSubview(dueStackView)
            
            dueDateLabel.text = due.fullDateTime
        }
        
        
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
        statusImageView.image = nil
        dueStackView.removeFromSuperview()
        
    }

}
