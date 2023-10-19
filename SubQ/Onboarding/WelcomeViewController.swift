//
//  WelcomeViewController.swift
//  SubQ
//
//  Created by Constantine Thalasinos on 9/26/23.
//

import UIKit
import SnapKit
import Lottie

class WelcomeViewController: UIViewController {
    
    /*lazy var stackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [welcomeLabel, descriptionView])
        stack.axis = .vertical
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.backgroundColor = .red

       // stack.distribution = .fillProportionally
        
        return stack
    }()*/
    
    let systemFont = UIFont(descriptor: UIFont.boldSystemFont(ofSize: 30).fontDescriptor.withDesign(.rounded)!, size: 30)
    
    
    
    let welcomeLabel: UILabel = {
        let label = UILabel()
        label.text = "Welcome to SubQ!"
        label.textAlignment = .center
        label.font = UIFont(descriptor: UIFont.boldSystemFont(ofSize: 30).fontDescriptor.withDesign(.rounded)!, size: 30)
        label.backgroundColor = .brown
        label.translatesAutoresizingMaskIntoConstraints = false
       // label.setContentHuggingPriority(.required, for: .vertical)
       // label.setContentCompressionResistancePriority(.required, for: .vertical)
        
        
        return label
    }()
    
    let descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "Track your subcutaneous injections and recently used injection sites."
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 15)
        label.numberOfLines = 0
        label.backgroundColor = .yellow
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
  /*  lazy var descriptionView: UIView = {
        let view = UIView()
        view.addSubview(descriptionLabel)
        descriptionLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        view.backgroundColor = .orange
        
        view.setContentHuggingPriority(.required, for: .vertical)
        view.setContentCompressionResistancePriority(.required, for: .vertical)
        
        return view
    }()*/
    
    let animationView: LottieAnimationView = {
        
        let view = LottieAnimationView(asset: "injection")
        view.translatesAutoresizingMaskIntoConstraints = false
        
        view.loopMode = .loop
        view.animationSpeed = 0.75
        //view.contentMode = .scaleAspectFit
        
        view.play()
        
        return view
    }()
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
       /* view.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.leftMargin.rightMargin.bottomMargin.equalToSuperview()
            make.height.equalTo(150)
           // make.center.equalToSuperview()
        }*/
        
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
            make.top.equalTo(welcomeLabel.snp.bottom)
            //make.center.equalToSuperview()
            make.height.equalTo(40)
        }
        
        
        
        /*view.backgroundColor = .green
        view.addSubview(label)
        label.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }*/
        
        

        // Do any additional setup after loading the view.
    }
    


}
