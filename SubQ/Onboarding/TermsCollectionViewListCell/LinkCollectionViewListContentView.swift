//
//  LinkContentView.swift
//  SubQ
//
//  Created by Constantine Thalasinos on 11/10/23.
// https://swiftsenpai.com/development/uicollectionview-list-custom-cell/

import UIKit
import SnapKit

class LinkCollectionViewListContentView: UIView, UIContentView {
    
    private var currentConfiguration: LinkCollectionViewListCellContentConfiguration!
    
    var configuration: UIContentConfiguration {
        get {
            currentConfiguration
        } set {
            guard let newConfiguration = newValue as? LinkCollectionViewListCellContentConfiguration else {
                return
            }
            apply(configuration: newConfiguration)
        }
    }
    
    private lazy var textView: UITextView = {
        let view = UITextView()
        view.isSelectable = true
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isEditable = false
        view.delegate = self
        return view
        
    }()
    
    init(configuration: LinkCollectionViewListCellContentConfiguration) {
        super.init(frame: .zero)
        

        setUpView()
        
        apply(configuration: configuration)
        
       
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpView() {
        
        addSubview(textView)
        textView.snp.makeConstraints { make in
            make.rightMargin.bottomMargin.topMargin.equalToSuperview()
            make.leftMargin.equalToSuperview().offset(10)
            make.height.equalTo(80)
        }
    }
    
    private func apply(configuration: LinkCollectionViewListCellContentConfiguration) {
    
        // Only apply configuration if new configuration and current configuration are not the same
        guard currentConfiguration != configuration else {
            return
        }
        
        // Replace current configuration with new configuration
        currentConfiguration = configuration
        
        // Set data to UI elements
        textView.attributedText = configuration.attributedText
        
        if let textColor = configuration.textColor {
            textView.textColor = configuration.textColor
        }
        
        if let textColor = configuration.textColor {
            textView.backgroundColor = configuration.backgroundColor
        }
        
        
    }
    

}

extension LinkCollectionViewListContentView: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
            UIApplication.shared.open(URL)
            return false
        }
}
