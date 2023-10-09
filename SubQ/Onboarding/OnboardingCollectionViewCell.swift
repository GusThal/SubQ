//
//  OnboardingCollectionViewCell.swift
//  SubQ
//
//  Created by Constantine Thalasinos on 9/28/23.
//

import UIKit

class OnboardingCollectionViewCell: UICollectionViewCell {
    //https://williamboles.com/hosting-viewcontrollers-in-cells/
    
    private weak var _hostedView: UIView? {
            didSet {
                if let oldValue = oldValue {
                    if oldValue.isDescendant(of: self) { //Make sure that hostedView hasn't been added as a subview to a different cell
                        oldValue.removeFromSuperview()
                    }
                }

                if let _hostedView = _hostedView {
                    _hostedView.frame = contentView.bounds
                    contentView.addSubview(_hostedView)
                }
            }
        }
    
    weak var hostedView: UIView? {
        
        get {
            guard _hostedView?.isDescendant(of: self) ?? false else {
                _hostedView = nil
                return nil
            }

            return _hostedView
        }
        
        set {
            _hostedView = newValue
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        hostedView = nil
    }
}
