//
//  NotificationsViewController.swift
//  SubQ
//
//  Created by Constantine Thalasinos on 9/28/23.
//

import UIKit
import Lottie
import SnapKit

class NotificationsViewController: UIViewController, OnboardingChildViewController {
    
    weak var onboardingViewController: OnboardingViewController?
    
    let animationView: LottieAnimationView = {
        
        let view = LottieAnimationView(asset: "notification")
        view.translatesAutoresizingMaskIntoConstraints = false
        
        view.loopMode = .loop
        view.animationSpeed = 0.75
        view.contentMode = .scaleAspectFit
        
        view.play()
        
        return view
    }()
    
    let notificationLabel: UILabel = {
        let label = UILabel()
        label.text = "Never Miss an Injection"
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 30)
        label.translatesAutoresizingMaskIntoConstraints = false

        return label
    }()
    
    lazy var notificationButton: UIButton = {
        
        var buttonConfig = UIButton.Configuration.filled()
        buttonConfig.buttonSize = .large
        buttonConfig.cornerStyle = .capsule
        buttonConfig.title = "Allow Notifications"
        buttonConfig.baseBackgroundColor = InterfaceDefaults.primaryColor
        
        let button =  UIButton(configuration: buttonConfig, primaryAction: notificationAction)
        return button
    }()
    
    lazy var notificationAction: UIAction = {
        return UIAction { _ in
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .carPlay, .sound, .criticalAlert] ) { success, error in
                if success {
                    print("Registered for notifications")
                } else if let error = error {
                    print(error.localizedDescription)
                }
                
                print("clicked")
                DispatchQueue.main.async{
                    self.onboardingViewController!.moveToNextIndex()
                }
            }
        }
    }()
    


    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(animationView)
        
        animationView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview()
            make.height.equalTo(350)
        }
        
        view.addSubview(notificationButton)
        
        view.addSubview(notificationLabel)
    
        
       
        
        notificationLabel.snp.makeConstraints { make in
            make.top.equalTo(animationView.snp.bottom)
            make.centerX.equalToSuperview()
        }
        
        notificationButton.snp.makeConstraints { make in

            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.centerX.equalToSuperview()
            make.top.equalTo(notificationLabel.snp.bottom).offset(10)
        }

    }
    

}
