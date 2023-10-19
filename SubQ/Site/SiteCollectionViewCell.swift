//
//  ZoneCollectionViewCell.swift
//  SubQ
//
//  Created by Constantine Thalasinos on 5/16/23.
//

import UIKit
import SnapKit

class SiteCollectionViewCell: UICollectionViewCell {

    
    var imageView: UIImageView?
    
    var site: Site? {
        didSet{
            
            guard site != nil else { return }
            
            let section = site!.section!
            
            if section.bodyPart!.partVal != .abdomen {
                imageView = UIImageView(image: UIImage(named: "man"))
            } else {
                imageView = UIImageView(image: UIImage(named: "\(section.bodyPart!.part!.lowercased())-\(section.quadrant!)-\(site!.subQuadrant!)"))
            }
            imageView?.contentMode = .scaleAspectFill
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
        
    }
    required init?(coder: NSCoder) {
        fatalError("not implemnted")
    }
    
    override func prepareForReuse() {
        site = nil
        imageView = nil
    }
}
