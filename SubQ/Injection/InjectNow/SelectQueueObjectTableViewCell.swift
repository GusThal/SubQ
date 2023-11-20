//
//  SelectQueueObjectTableViewCell.swift
//  SubQ
//
//  Created by Constantine Thalasinos on 9/10/23.
//

import Foundation
import UIKit
import SnapKit

class SelectQueueObjectTableViewCell: InjectionDescriptionTableViewCell {
    
    let dueImageView: UIImageView = {
        let config = UIImage.SymbolConfiguration(font: UIFont.systemFont(ofSize: 12))
        let image = UIImage(systemName: "calendar.badge.clock", withConfiguration: config)
         
        let view = UIImageView(image: image)
        view.tintColor = .label
        view.setContentHuggingPriority(.required, for: .horizontal)
        view.setContentCompressionResistancePriority(.required, for: .horizontal)
         
        return view
     }()
    
    
    let dueLabel: UILabel = {
        let label = UILabel()
        label.text = "Due:"
        label.font = UIFont.boldSystemFont(ofSize: 12)
        label.setContentHuggingPriority(.required, for: .horizontal)
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        return label
    }()
    
    let dueDateLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 12)
        
        return label
        
    }()
    
    lazy var dueStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [dueImageView, dueLabel, dueDateView])
        stack.axis = .horizontal
        stack.spacing = 5
        
        return stack
    }()
    
    lazy var dueDateView: UIView = {
        let view = UIView(frame: .zero)
        view.addSubview(dueDateLabel)
        dueDateLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        return view
    }()
    
    let warningImageView: UIImage = {
        let config = UIImage.SymbolConfiguration(font: UIFont.systemFont(ofSize: 12))
        let image = UIImage(systemName: "exclamationmark.triangle.fill", withConfiguration: config)!

        return image
     }()
    
    let snoozedImage: UIImage = {
        let config = UIImage.SymbolConfiguration(font: UIFont.systemFont(ofSize: 12))
        let image = UIImage(systemName: "zzz", withConfiguration: config)!
        
        return image
    }()
    
    lazy var snoozedImageView: UIImageView = {
         
        let view = UIImageView(image: snoozedImage)
        view.tintColor = .systemOrange
        view.setContentHuggingPriority(.required, for: .horizontal)
        view.setContentCompressionResistancePriority(.required, for: .horizontal)
        view.contentMode = .center
        
        return view
     }()
    
    let snoozedUntilLabel: UILabel = {
        let label = UILabel()
        label.text = "Snoozed Until:"
        label.font = UIFont.boldSystemFont(ofSize: 12)
        label.setContentHuggingPriority(.required, for: .horizontal)
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        return label
    }()
    
    let snoozedUntilDateLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 12)
        
        return label
        
    }()
    
    lazy var snoozedDateView: UIView = {
        let view = UIView(frame: .zero)
        view.addSubview(snoozedUntilDateLabel)
        snoozedUntilDateLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        return view
    }()
    
    lazy var snoozedStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [snoozedImageView, snoozedUntilLabel, snoozedDateView])
        stack.axis = .horizontal
        stack.spacing = 5
        
        return stack
    }()
    
    
    
    lazy var queueStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [dueStackView])
        stack.axis = .vertical
        
        return stack
    }()
    
    lazy var mainStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [injectionDescriptionStackView, queueStackView])
        stack.axis = .vertical
        
        return stack
        
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(mainStackView)
        
        nameLabel.font = UIFont.boldSystemFont(ofSize: 16)
        dosageLabel.font = UIFont.systemFont(ofSize: 14)
        unitsLabel.font = UIFont.systemFont(ofSize: 14)
        
        mainStackView.snp.makeConstraints { make in
            make.margins.equalToSuperview()
        }
        
        print("init")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    
    func setQueueObject(_ object: Queue) {
        guard let _ = object.injection else { return }
        
        super.setInjection(object.injection!)
        
        dueDateLabel.text = object.dateDue!.fullDateTime
        
        //insert before the frequency rows
        
        
       if let snoozedUntil = object.snoozedUntil {
           snoozedUntilDateLabel.text = snoozedUntil.fullDateTime
          
           queueStackView.addArrangedSubview(snoozedStackView)
           snoozedUntilLabel.text = "Snoozed Until:"
           
           if snoozedUntil > Date() {
               snoozedImageView.image = snoozedImage
               snoozedImageView.tintColor = .systemOrange
           } else {
               snoozedImageView.image = warningImageView
               snoozedImageView.tintColor = .systemYellow
           }
           
        }
    }
    
    
    override func prepareForReuse() {
        
        super.prepareForReuse()
        
        for label in [dueDateLabel, snoozedUntilDateLabel, snoozedUntilLabel] {
            label.text = ""
           // label.removeFromSuperview()
        }
        snoozedImageView.image = nil
        queueStackView.removeArrangedSubview(snoozedStackView)
  
        
    }
    
}
