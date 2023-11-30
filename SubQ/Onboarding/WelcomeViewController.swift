//
//  WelcomeViewController.swift
//  SubQ
//
//  Created by Constantine Thalasinos on 9/26/23.
//

import UIKit
import SnapKit
import Lottie

class WelcomeViewController: UIViewController, OnboardingChildViewController {
    
    let systemFont = UIFont(descriptor: UIFont.boldSystemFont(ofSize: 30).fontDescriptor.withDesign(.rounded)!, size: 30)
    
    weak var onboardingViewController: OnboardingViewController?
    
    let welcomeLabel: UILabel = {
        let label = UILabel()
        label.text = "Welcome to SubQ!"
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 30)

        label.translatesAutoresizingMaskIntoConstraints = false

        return label
    }()
    
    let descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "Track your subcutaneous injections and recently used injection sites."
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 15)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    
    let animationView: LottieAnimationView = {
        
        let view = LottieAnimationView(asset: "injection")
        view.translatesAutoresizingMaskIntoConstraints = false
        
        view.loopMode = .loop
        view.animationSpeed = 0.75

        view.play()
        
        return view
    }()
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(animationView)
        
        animationView.snp.makeConstraints { make in
            make.leftMargin.rightMargin.equalToSuperview()
            make.top.equalToSuperview()
            make.height.equalTo(350)
        }
        
        view.addSubview(welcomeLabel)
        welcomeLabel.snp.makeConstraints { make in
            make.leftMargin.rightMargin.equalToSuperview()
            make.top.equalTo(animationView.snp.bottom)
            make.height.equalTo(40)
        }
        
        view.addSubview(descriptionLabel)
        descriptionLabel.snp.makeConstraints { make in
            make.leftMargin.rightMargin.equalToSuperview()
            make.top.equalTo(welcomeLabel.snp.bottom).offset(5)

            make.height.equalTo(40)
        }
    }
    


}
