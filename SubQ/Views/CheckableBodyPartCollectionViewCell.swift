//
//  CheckableButtonCollectionViewCell.swift
//  SubQ
//
//  Created by Constantine Thalasinos on 9/19/23.
//

import UIKit
import SnapKit

class CheckableBodyPartCollectionViewCell: UICollectionViewCell {
    
    var viewModel: BodyPartViewModel?
    
    var isButtonSelected: Bool = false {
        didSet{
            bodyPartButton.setNeedsUpdateConfiguration()
        }
    }
    
    var bodyPart: BodyPart? {
        didSet {
            bodyPartButton.setNeedsUpdateConfiguration()
        }
    }
    
     lazy var buttonAction: UIAction  = UIAction { _ in
        //toggle value
         
         let enabled = !self.bodyPart!.enabled
         
         print("setting \(self.bodyPart!.part!) to \(enabled)")
            
         self.viewModel!.setEnabled(forBodyPart: self.bodyPart!, to: enabled)
         self.isButtonSelected = enabled
            
    }
    

    
    lazy var bodyPartButton: UIButton = {

        let button = UIButton(frame: .zero)
        
        button.configurationUpdateHandler = { [unowned self] button in
            
            var config = UIButton.Configuration.plain()
            
            if let bodyPart {
                config.title = bodyPart.part!
            } else {
                config.title = ""
            }
            
            config.baseForegroundColor = .label
            config.titleAlignment = .leading
            config.imagePlacement = .trailing
            config.imagePadding = 5
        
            
            if isButtonSelected{
                
                let imageConfig = UIImage.SymbolConfiguration(pointSize: 16)
                
                config.image = UIImage(systemName: "checkmark", withConfiguration: imageConfig)
                
                config.imageColorTransformer = UIConfigurationColorTransformer({ _ in
                    return InterfaceDefaults.primaryColor!
                })

            }
            else{
                config.image = nil
            }

            button.configuration = config
        }

        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(bodyPartButton)
        contentView.backgroundColor = .secondarySystemBackground
        
        bodyPartButton.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        isButtonSelected = false
        bodyPart = nil
        bodyPartButton.removeAction(buttonAction, for: .primaryActionTriggered)
        
    }
    
}
