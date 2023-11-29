//
//  InterfaceDefaults.swift
//  SubQ
//
//  Created by Constantine Thalasinos on 10/10/23.
//

import Foundation
import UIKit

struct InterfaceDefaults {
    
    static let primaryColor = UIColor(hex: "#6167afff")
    
    static let secondaryColor = UIColor(hex: "#F79345ff")
    
    static let navigationBarLargeTextAttributes: [NSAttributedString.Key : Any]? = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 25)]
    
    private static let termsAddress = "https://sites.google.com/view/subq-app/terms"
    
    private static let privacyPolicyAddress = termsAddress.appending("/#h.f5rbewwuj4ri")
    
    private static let medicalDisclaimerAddress = termsAddress.appending("/#h.96wclw23ycf4")
    
    static let disclaimerString = "This app was created by a junior iOS developer for his own learning purposes only, and as such should not be relied upon by the user as the sole method for tracking their injections."
    
    static let disclaimerBoldSubstring = "should not be relied upon by the user as the sole method for tracking their injections."
    
    static var termsURL: URL {
        get {
            URL(string: termsAddress)!
        }
    }
    
    static var privacyPolicyURL: URL {
        get {
           return URL(string: privacyPolicyAddress)!
        }
    }
    
    static var medicalDisclaimerURL: URL {
        get {
            return URL(string: medicalDisclaimerAddress)!
        }
    }
    
}
