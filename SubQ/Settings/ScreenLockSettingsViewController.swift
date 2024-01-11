//
//  ScreenLockSettingsViewController.swift
//  SubQ
//
//  Created by Constantine Thalasinos on 1/5/24.
//

import UIKit
import LocalAuthentication

class ScreenLockSettingsViewController: UITableViewController, Coordinated {
    var coordinator: Coordinator?
    
    let defaultReuseIdentifier = "defaultReuseIdentifier"
    let footerIdentifier = "footerReuseIdentifier"
    
    var isFaceIdEnabled = false
    
    enum Section: Int{
        case faceID, passcode
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let context = LAContext()
        
        var error: NSError?
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: defaultReuseIdentifier)
        
   /*     Task {
        
            do {
                try await context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Log in to your account")
                  
            } catch let error {
                print(error.localizedDescription)
            }
        }*/
        
        
        
        
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            isFaceIdEnabled = true
            return 1
        } else {
            isFaceIdEnabled = false
            return 2
        }
        
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: defaultReuseIdentifier, for: indexPath)
        
        var content = cell.defaultContentConfiguration()

        if indexPath.section == Section.faceID.rawValue {
            content.text = "Require Face ID"
            
            let switchView = UISwitch()
            
            if !isFaceIdEnabled {
                switchView.isUserInteractionEnabled = false
                content.textProperties.color = .gray
            } else {
                switchView.isOn = UserDefaults.standard.bool(forKey: AppDelegate.Keys.isScreenLockEnabled.rawValue)
            }
            
            let action = UIAction { _ in
                
                UserDefaults.standard.setValue(switchView.isOn, forKey: AppDelegate.Keys.isScreenLockEnabled.rawValue)
                
                if switchView.isOn {
                    
                    Task {
                        
                        let context = LAContext()
                        
                        do {
                            try await context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Unlock SubQ.")
                            
                        } catch let error {
                            print(error.localizedDescription)
                        }
                    }
                }
                
            }
            
            switchView.addAction(action, for: .primaryActionTriggered)
            cell.accessoryView = switchView
            
        } else if indexPath.section == Section.passcode.rawValue{
            content.text = "Require Passcode"
            
            let switchView = UISwitch()
            
            switchView.isOn = UserDefaults.standard.bool(forKey: AppDelegate.Keys.isScreenLockEnabled.rawValue)
   
           // switchView.isOn = viewModel.isAsNeeded
            
            let action = UIAction { _ in
                
                UserDefaults.standard.setValue(switchView.isOn, forKey: AppDelegate.Keys.isScreenLockEnabled.rawValue)
                
                if switchView.isOn {
                    
                    Task {
                        
                        let context = LAContext()
                        
                        do {
                            try await context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: "Unlock SubQ.")
                            
                        } catch let error {
                            print(error.localizedDescription)
                        }
                    }
                }
                
            }
            
            switchView.addAction(action, for: .primaryActionTriggered)
            cell.accessoryView = switchView
        }
        
        cell.contentConfiguration = content

        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if section == Section.faceID.rawValue {
            if isFaceIdEnabled {
                return "When enabled, you'll need to use Face ID to unlock SubQ. You'll still receive notifications when the app is locked."
            } else {
                return "Face ID appears to not be enabled. To use Face ID, go to your device's Settings and tap Face ID & Passcode and make sure Face ID is set up. After that, in Settings > SubQ, enable Face ID."
            }
        } else if section == Section.passcode.rawValue {
            return "When enabled, you'll need to use the device's passcode to unlock SubQ. You'll still receive notifications when the app is locked."
        }
        
        return nil
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        
        cell?.setSelected(false, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    

    
}

extension ScreenLockSettingsViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
            UIApplication.shared.open(URL)
            return false
        }
}
