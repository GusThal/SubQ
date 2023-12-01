//
//  ZoneCollectionViewCell.swift
//  SubQ
//
//  Created by Constantine Thalasinos on 5/16/23.
//

import UIKit
import SnapKit

class SectionCollectionViewCell: UICollectionViewCell {
 
    var imageView: UIImageView?
    
    var section: Section? {
        didSet{
            
            guard section != nil else { return }
            
            imageView = UIImageView(image: UIImage(named: "\(section!.bodyPart!.part!.lowercased())-\(section!.quadrant!)"))
            
            imageView!.translatesAutoresizingMaskIntoConstraints = false
            imageView!.backgroundColor = .secondarySystemBackground
            
            if UIDevice.current.userInterfaceIdiom == .pad {
                imageView!.contentMode = .scaleAspectFit

            }
                            
            
            imageView?.clipsToBounds = true
            
            contentView.addSubview(imageView!)
            
            imageView!.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
            
           
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    override func prepareForReuse() {
        section = nil
        imageView = nil
    }
    
    required init?(coder: NSCoder) {
        fatalError("not implemnted")
    }
}
