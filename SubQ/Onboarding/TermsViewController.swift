//
//  TermsViewController.swift
//  SubQ
//
//  Created by Constantine Thalasinos on 9/28/23.
//

import UIKit

class TermsViewController: UIViewController {
    
    let coordinator: OnboardingCoordinator
    
    let attributedString: NSAttributedString = {
        let str = NSMutableAttributedString(string: "By tapping 'Get Started' you agree to our terms of service.")
        str.addAttribute(.link, value: "https://reddit.com", range: NSRange(location: 42, length: 17))
        str.addAttribute(.foregroundColor, value: UIColor.label, range: NSRange(location: 0, length: str.length))
        
        return str
    }()
    
    let textView: UITextView = {
        let view = UITextView()
        view.isSelectable = true
        view.backgroundColor = .systemBackground
        view.textColor = .label
        view.translatesAutoresizingMaskIntoConstraints = false
        view.textAlignment = .center
        
        return view
        
    }()
    
    lazy var startButton: UIButton = {
        
        var buttonConfig = UIButton.Configuration.filled()
        buttonConfig.buttonSize = .large
        buttonConfig.cornerStyle = .capsule
        buttonConfig.title = "Get Started"
        buttonConfig.baseBackgroundColor = .blue
        
        let button =  UIButton(configuration: buttonConfig, primaryAction: startAction)
        button.translatesAutoresizingMaskIntoConstraints = false

        return button
    }()
    
    lazy var startAction: UIAction = {
        return UIAction { _ in
            self.coordinator.startButtonPressed()
        }
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //textView.text = "hello"
        textView.attributedText = attributedString
        textView.delegate = self
        
        view.addSubview(textView)
        textView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.edges.equalToSuperview()
        }
        
        view.addSubview(startButton)
        
        startButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.bottomMargin.equalToSuperview().offset(-100)
        }
    }
    
    init(coordinator: OnboardingCoordinator) {
        self.coordinator = coordinator
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension TermsViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
            UIApplication.shared.open(URL)
            return false
    }
}
