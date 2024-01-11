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
    
    let coordinator: Coordinator
    
    let imageView: UIImageView = {
        
        let symbolConfig =  UIImage.SymbolConfiguration(font: UIFont.systemFont(ofSize: 50))

        let image = UIImage(systemName: "lock.fill", withConfiguration: symbolConfig)
        
        let view = UIImageView(image: image)
        view.tintColor = InterfaceDefaults.primaryColor
        
        return view
        
    }()
    
    let primaryLabel: UILabel = {
        let label = UILabel()
        
        label.text = "SubQ Locked"
        label.font = UIFont.boldSystemFont(ofSize: 30)
        
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
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 5
        
        return stackView
        
    }()
    
    lazy var buttonAction: UIAction = {
        return UIAction { _ in
            self.unlockScreen()
        }
    }()
    
    lazy var button: UIButton = {
        var buttonConfig = UIButton.Configuration.filled()
        buttonConfig.buttonSize = .large
        buttonConfig.cornerStyle = .capsule
        buttonConfig.title = "Use Face ID"
        buttonConfig.baseBackgroundColor = InterfaceDefaults.primaryColor
        
        let button =  UIButton(configuration: buttonConfig, primaryAction: buttonAction)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    init(coordinator: Coordinator) {
        self.coordinator = coordinator
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        view.addSubview(stackView)
        
        stackView.snp.makeConstraints { make in
            make.leftMargin.rightMargin.equalToSuperview()
            make.topMargin.equalTo(view.snp.topMargin).offset(50)
        }
        
        view.addSubview(button)
        
        button.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-100)
            make.leftMargin.rightMargin.equalToSuperview()
        }

        unlockScreen()
       
    }
    
    //Face ID check called before this view controller is presented.
    func unlockScreen() {
        Task {
             
            do {
                
                let context = LAContext()
                
                try await context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Unlock SubQ.")
                
                
                coordinator.dismissFaceIDViewController()
                       
            } catch let error {
                print(error.localizedDescription)
            }
        }
    }

}
