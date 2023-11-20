//
//  UITextField+textPublisher.swift
//  SubQ
//
//  Created by Constantine Thalasinos on 6/25/23.
//

import Foundation
import UIKit
import Combine

extension UITextField{
    
    //https://stackoverflow.com/questions/60640143/swift-combine-how-to-get-a-publisher-that-delivers-events-for-every-character
    func textPublisher() -> AnyPublisher<String, Never> {
        NotificationCenter.default
            .publisher(for: UITextField.textDidChangeNotification, object: self)
                .map { ($0.object as! UITextField).text  ?? "" }
                .eraseToAnyPublisher()
    }
    
}
