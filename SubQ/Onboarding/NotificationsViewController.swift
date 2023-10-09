//
//  NotificationsViewController.swift
//  SubQ
//
//  Created by Constantine Thalasinos on 9/28/23.
//

import UIKit
import Lottie
import SnapKit

class NotificationsViewController: UIViewController {
    
    let animationView: LottieAnimationView = {
        
        let view = LottieAnimationView(asset: "notification")
        view.translatesAutoresizingMaskIntoConstraints = false
        
        view.loopMode = .loop
        view.animationSpeed = 0.75
        view.contentMode = .scaleAspectFit
        view.backgroundColor = .systemRed
        
        view.play()
        
        return view
    }()
    
    let notificationLabel: UILabel = {
        let label = UILabel()
        label.text = "Never Miss an Injection"
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 30)
        label.backgroundColor = .brown
        label.translatesAutoresizingMaskIntoConstraints = false
       // label.setContentHuggingPriority(.required, for: .vertical)
       // label.setContentCompressionResistancePriority(.required, for: .vertical)
        
        
        return label
    }()
    
    lazy var notificationButton: UIButton = {
        
        var buttonConfig = UIButton.Configuration.filled()
        buttonConfig.buttonSize = .large
        buttonConfig.cornerStyle = .capsule
        buttonConfig.title = "Allow Notifications"
        buttonConfig.baseBackgroundColor = .blue
        
        let button =  UIButton(configuration: buttonConfig, primaryAction: notificationAction)
       // button.translatesAutoresizingMaskIntoConstraints = false

        return button
    }()
    
    lazy var notificationAction: UIAction = {
        return UIAction { _ in
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .carPlay, .sound, .criticalAlert, .provisional] ) { success, error in
                if success {
                    print("Registered for notifications")
                } else if let error = error {
                    print(error.localizedDescription)
                }
            }
        }
    }()
    
    lazy var stackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [notificationLabel, notificationButton])
        stack.axis = .vertical
       // stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(animationView)
        
        animationView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview()
            make.height.equalTo(350)
        }
        
        view.addSubview(stackView)
        
        stackView.snp.makeConstraints { make in
            make.bottomMargin.equalToSuperview().offset(-100)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.centerX.equalToSuperview()
        }
        

        // Do any additional setup after loading the view.
    }
    

}
