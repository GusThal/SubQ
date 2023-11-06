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
            //imageView!.translatesAutoresizingMaskIntoConstraints = false
            imageView.backgroundColor = .secondarySystemBackground
            imageView.layer.cornerRadius = 5
            
            let label = UILabel()
            //label!.translatesAutoresizingMaskIntoConstraints = false
            label.numberOfLines = 2
            
            
            
            label.text = " Last Used: \(site!.lastInjected?.fullDate ?? "-\n")"
            //label.backgroundColor = .red
          //  label.setContentHuggingPriority(.required, for: .vertical)
          //  label.setContentCompressionResistancePriority(.required, for: .vertical)
            
            stackView.addArrangedSubview(imageView)
            stackView.addArrangedSubview(label)
            
            stackView.clipsToBounds = true
            
            
            
            //label!.text = "Hello"
            
           /* contentView.addSubview(imageView!)
            contentView.addSubview(label)
            //label?.backgroundColor = .red
            
            label.snp.makeConstraints { make in
                make.bottom.leading.trailing.equalToSuperview()
                
               // make.height.equalTo(20)
            }
            
            imageView.snp.makeConstraints { make in
                make.bottom.equalTo(label.snp.top)
                make.leading.trailing.top.equalToSuperview()
            }*/
            
          
            
           
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
