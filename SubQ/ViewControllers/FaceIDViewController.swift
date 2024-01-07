//
//  FaceIDViewController.swift
//  SubQ
//
//  Created by Constantine Thalasinos on 1/6/24.
//

import UIKit
import LocalAuthentication
import SnapKit

class FaceIDViewController: UIViewController {
    
    let imageView: UIImageView = {
        let image = UIImage(systemName: "lock,fill")
        
        let imageView = UIImageView(image: image)
        
        return imageView
        
    }()
    
    let primaryLabel: UILabel = {
        let label = UILabel()
        
        label.text = "SubQ Locked"
        
        return label
    }()
    
    let secondaryLabel: UILabel = {
        let label = UILabel()
        
        label.text = "Unlock with Face ID to open SubQ"
        
        return label
    }()
    
    lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [imageView, primaryLabel, secondaryLabel])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        return stackView
        
    }()
    
    let buttonAction: UIAction = {
        return UIAction { _ in
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .carPlay, .sound, .criticalAlert] ) { success, error in
                
            }
        }
    }()
    
    lazy var button: UIButton = {
        var buttonConfig = UIButton.Configuration.filled()
        buttonConfig.buttonSize = .large
        buttonConfig.cornerStyle = .capsule
        buttonConfig.title = "Allow Notifications"
        buttonConfig.baseBackgroundColor = InterfaceDefaults.primaryColor
        
        let button =  UIButton(configuration: buttonConfig, primaryAction: buttonAction)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(stackView)
        
        stackView.snp.makeConstraints { make in
            make.topMargin.leftMargin.rightMargin.equalToSuperview()
        }
        
        view.addSubview(button)
        
        button.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-200)
            make.leftMargin.rightMargin.equalToSuperview()
        }

       
    }
    
    func unlockScreen() {
        Task {
             
            do {
                
                let context = LAContext()
                
                try await context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Unlock SubQ.")
                       
            } catch let error {
                print(error.localizedDescription)
            }
        }
    }

}
