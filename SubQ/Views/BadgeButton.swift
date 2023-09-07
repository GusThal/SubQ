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
            
            print("set")
            
            if badgeCount == 0 {
                print("remove the heckin label dawg")
                removeBadgeLabel()
            } else {
                print("uhhh called?")
                showBadgeLabel(withCount: badgeCount)
            }
        }
    }
    
    var badgeBackgroundColor: UIColor = .systemRed{
        didSet {
            badgeLabel.backgroundColor = badgeBackgroundColor
        }
    }
    
    
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
        //label.text = String(count)
        
        return label
    }()

     
    private func showBadgeLabel(withCount count: Int) {
        badgeLabel.text = String(count)
        
        self.addSubview(badgeLabel)

        NSLayoutConstraint.activate([
             badgeLabel.leftAnchor.constraint(equalTo: self.rightAnchor, constant: -10),
             badgeLabel.bottomAnchor.constraint(equalTo: self.topAnchor, constant: 10),
             //badge.centerYAnchor.constraint(equalTo: filterButton.centerYAnchor),
             badgeLabel.widthAnchor.constraint(equalToConstant: 20),
             badgeLabel.heightAnchor.constraint(equalToConstant: 20)
         ])
     }
    
    private func removeBadgeLabel() {
        /*if let badge = self.viewWithTag(badgeTag) {
            badge.removeFromSuperview()
        }*/
        
        badgeLabel.removeFromSuperview()
    
    }


}
