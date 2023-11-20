//
//  UserDefaults+Shared.swift
//  SubQ
//
//  Created by Constantine Thalasinos on 5/27/23.
//

import Foundation

//creates a UserDefaults shared by the app group
extension UserDefaults {
  static var shared = UserDefaults(suiteName: "group.com.gusthal.subq")!
}
