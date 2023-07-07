//
//  Coordinated.swift
//  SubQ
//
//  Created by Constantine Thalasinos on 7/5/23.
//

import Foundation
import UIKit

protocol Coordinated: UIViewController{
    
    var coordinator: Coordinator? { get set }
}
