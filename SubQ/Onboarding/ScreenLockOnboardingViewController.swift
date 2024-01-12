//
//  FaceIDOnboardingViewController.swift
//  SubQ
//
//  Created by Constantine Thalasinos on 1/11/24.
//

import UIKit
import SnapKit
import LocalAuthentication

class ScreenLockOnboardingViewController: UIViewController, OnboardingChildViewController {
    
    enum LockMethod: String {
        case faceId = "Face ID", passcode = "Device Passcode"
    }
   
    var onboardingViewController: OnboardingViewController?
    
    let enabledLockMethod: LockMethod
    
    
    
    let imageView: UIImageView = {
        let symbolConfig =  UIImage.SymbolConfiguration(font: UIFont.systemFont(ofSize: 25))
        let image = UIImage(systemName: "lock.shield", withConfiguration: symbolConfig)

        
        let view = UIImageView(image: image)
        
        view.tintColor = InterfaceDefaults.primaryColor
        
        view.contentMode = .scaleAspectFit
        
        return view
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Protect Your Injection Data"
        
        
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 30)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 2

        return label
    }()
    
    lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "(Note: This Can Be Changed Later in Settings)"
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 15)
        label.numberOfLines = 0
        label.textColor = .gray

        return label
    }()
    
    lazy var titleStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        stack.axis = .vertical
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.spacing = 10
        return stack
    }()
    
    lazy var enableButton: UIButton = {
        
        var buttonConfig = UIButton.Configuration.filled()
        buttonConfig.buttonSize = .large
        buttonConfig.cornerStyle = .capsule
        buttonConfig.title = "Enable \(enabledLockMethod.rawValue)"
        buttonConfig.baseBackgroundColor = InterfaceDefaults.primaryColor
        
        let action = UIAction { _ in
            UserDefaults.standard.setValue(true, forKey: AppDelegate.Keys.isScreenLockEnabled.rawValue)
            
            Task {
                
                do {
                    
                    let context = LAContext()
                    
                    if self.enabledLockMethod == .faceId {
                        try await context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Unlock SubQ.")
                    } else {
                        try await context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: "Unlock SubQ.")
                    }
                    self.onboardingViewController!.moveToNextIndex()
                    
                } catch let error {
                    print(error.localizedDescription)
                }
            }
        }
        
        let button =  UIButton(configuration: buttonConfig, primaryAction: action)
        return button
    }()
    
    lazy var skipButton: UIButton = {
        
        var buttonConfig = UIButton.Configuration.plain()
        buttonConfig.buttonSize = .large
        buttonConfig.title = "Skip"
        buttonConfig.baseForegroundColor = InterfaceDefaults.primaryColor
        
        let action = UIAction { _ in
            UserDefaults.standard.setValue(false, forKey: AppDelegate.Keys.isScreenLockEnabled.rawValue)
            self.onboardingViewController!.moveToNextIndex()
        }
        
        let button =  UIButton(configuration: buttonConfig, primaryAction: action)
        return button
        
    }()
    
    lazy var buttonStackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [enableButton, skipButton])
        view.axis = .vertical
       // view.alignment = .center
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    init(enabledLockMethod: LockMethod) {
        self.enabledLockMethod = enabledLockMethod
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(imageView)

        view.addSubview(titleStackView)
        
        titleStackView.snp.makeConstraints { make in
            make.topMargin.equalToSuperview().offset(350)
            make.leftMargin.rightMargin.equalToSuperview()
        }
        
        view.addSubview(buttonStackView)
        
        buttonStackView.snp.makeConstraints { make in
            make.leftMargin.equalToSuperview().offset(20)
            make.rightMargin.equalToSuperview().offset(-20)
            make.top.equalTo(titleStackView.snp.bottom).offset(30)
            //make.top.equalTo(titleStackView.snp.bottom)
        }
        
        imageView.snp.makeConstraints { make in
            make.bottom.equalTo(titleStackView.snp.top).offset(-100)
            make.centerX.equalToSuperview()
            make.leftMargin.rightMargin.equalToSuperview()
            make.height.equalTo(150)
        }
        
    }
    


}
