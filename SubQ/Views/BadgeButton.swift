//
//  NotificationButton.swift
//  SubQ
//
//  Created by Constantine Thalasinos on 9/7/23.
//

import UIKit

class BadgeButton: UIButton {
    
    let badgeSize: CGFloat = 20
    let badgeTag = 9830384
    
    var badgeCount = 0 {
        didSet {
            
            if badgeCount == 0 {
                removeBadgeLabel()
            } else {
                showBadgeLabel(withCount: badgeCount)
            }
        }
    }
    
    var badgeBackgroundColor: UIColor = .systemRed{
        didSet {
            badgeLabel.backgroundColor = badgeBackgroundColor
        }
    }
    
    
    
    //based on https://nemecek.be/blog/17/how-to-add-badge-to-uibarbuttonitem
    lazy var badgeLabel: UILabel = {
        
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: badgeSize, height: badgeSize))
        label.translatesAutoresizingMaskIntoConstraints = false
        label.tag = badgeTag
        label.layer.cornerRadius = label.bounds.size.height / 2
        label.textAlignment = .center
        label.layer.masksToBounds = true
        label.textColor = .white
        label.font = label.font.withSize(12)
        
        label.backgroundColor = badgeBackgroundColor
        
        return label
    }()

     
    private func showBadgeLabel(withCount count: Int) {
        badgeLabel.text = String(count)
        
        self.addSubview(badgeLabel)

        NSLayoutConstraint.activate([
             badgeLabel.leftAnchor.constraint(equalTo: self.rightAnchor, constant: -10),
             badgeLabel.bottomAnchor.constraint(equalTo: self.topAnchor, constant: 10),
             badgeLabel.widthAnchor.constraint(equalToConstant: 20),
             badgeLabel.heightAnchor.constraint(equalToConstant: 20)
         ])
     }
    
    private func removeBadgeLabel() {
        
        badgeLabel.removeFromSuperview()
    
    }


}
