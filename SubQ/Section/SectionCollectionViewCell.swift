//
//  ZoneCollectionViewCell.swift
//  SubQ
//
//  Created by Constantine Thalasinos on 5/16/23.
//

import UIKit
import SnapKit

class SectionCollectionViewCell: UICollectionViewCell {
    //let label = UILabel()
    
    var imageView: UIImageView?
    
    var section: Section? {
        didSet{
            
            guard section != nil else { return }
            
            if section?.bodyPart?.partVal != .abdomen {
                imageView = UIImageView(image: UIImage(named: "man"))
            } else {
                imageView = UIImageView(image: UIImage(named: "\(section!.bodyPart!.part!.lowercased())-\(section!.quadrant!)"))
            }
            
            imageView!.translatesAutoresizingMaskIntoConstraints = false
            imageView!.backgroundColor = .secondarySystemBackground
            
            contentView.addSubview(imageView!)
            
            imageView!.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
            
           
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        
       /* label.translatesAutoresizingMaskIntoConstraints = false
        label.adjustsFontForContentSizeCategory = true
        contentView.addSubview(label)
        
        label.backgroundColor = .orange
        
        
        label.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }*/
    }
    
    override func prepareForReuse() {
        section = nil
        imageView = nil
    }
    
    required init?(coder: NSCoder) {
        fatalError("not implemnted")
    }
}
