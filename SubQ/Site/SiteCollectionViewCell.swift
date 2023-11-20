//
//  ZoneCollectionViewCell.swift
//  SubQ
//
//  Created by Constantine Thalasinos on 5/16/23.
//

import UIKit
import SnapKit

class SiteCollectionViewCell: UICollectionViewCell {

    
    var stackView: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .vertical
        
        return view
    }()
    
    let checkMarkView: UIImageView = {
        let image = UIImage(systemName: "checkmark.circle.fill")
        
        let view = UIImageView(image: image)
        view.tintColor = .systemGreen
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    var site: Site? {
        didSet{
            
            guard site != nil else { return }
            
            let section = site!.section!
            
            let imageView: UIImageView!
            
            
            imageView = UIImageView(image: UIImage(named: "\(section.bodyPart!.part!.lowercased())-\(section.quadrant!)-\(site!.subQuadrant!)"))
            
            imageView.contentMode = .scaleAspectFill

            imageView.backgroundColor = .secondarySystemBackground
            imageView.layer.cornerRadius = 5
            
            let topLabel = UILabel()
            topLabel.text = " Last Used:"
            topLabel.font = UIFont.boldSystemFont(ofSize: 14)
            topLabel.setContentHuggingPriority(.required, for: .vertical)
            topLabel.setContentCompressionResistancePriority(.required, for: .vertical)

            let bottomLabel = UILabel()
            bottomLabel.text = " \(site!.lastInjected?.fullDate ?? "n/a")"
            bottomLabel.font = UIFont.systemFont(ofSize: 14)
            bottomLabel.setContentHuggingPriority(.required, for: .vertical)
            bottomLabel.setContentCompressionResistancePriority(.required, for: .vertical)
            

            stackView.addArrangedSubview(imageView)
            stackView.addArrangedSubview(topLabel)
            stackView.addArrangedSubview(bottomLabel)
            
            stackView.clipsToBounds = true

        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        contentView.addSubview(checkMarkView)
        checkMarkView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.right.equalToSuperview()
        }
        
        setSelected(to: false)
    
    }
    
    func setSelected(to value: Bool) {
        
        if value {
            contentView.layer.borderWidth = 1.5
            contentView.layer.borderColor = UIColor.systemGreen.cgColor
            checkMarkView.alpha = 1
        } else {
            contentView.layer.borderWidth = 0
            contentView.layer.borderColor = UIColor.systemGreen.cgColor
            checkMarkView.alpha = 0
        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("not implemnted")
    }
    
    override func prepareForReuse() {
        site = nil
        
        for view in stackView.arrangedSubviews {
            view.removeFromSuperview()
        }
        
        setSelected(to: false)
        
    }
    
}
