//
//  UIViewController+showConfirmationView.swift
//  SubQ
//
//  Created by Constantine Thalasinos on 9/12/23.
//

import Foundation
import UIKit

extension UIViewController {
    func showConfirmationView(message: String, color: UIColor) {
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.layer.cornerRadius = 20
        containerView.layer.masksToBounds = true
        
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.text = message
        label.font = UIFont.systemFont(ofSize: 13)
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .center
        label.numberOfLines = 0
        
        
        
        label.backgroundColor = color
        containerView.backgroundColor = color
        
        
        
        containerView.addSubview(label)
        label.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-12)
            make.top.equalToSuperview().offset(12)
            make.leading.equalToSuperview().offset(15)
            make.trailing.equalToSuperview().offset(-15)
        }
        
        view.addSubview(containerView)
        
        containerView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottomMargin.equalToSuperview().offset(-60)
            
        }
        
        UIView.transition(with: containerView, duration: 5,
                          options: .transitionCrossDissolve,
                          animations: {
                        containerView.alpha = 0
            
        }) { _ in
            label.removeFromSuperview()
            containerView.removeFromSuperview()
        }
        
    }
}
