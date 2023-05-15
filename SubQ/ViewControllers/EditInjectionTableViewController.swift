//
//  EditInjectionTableViewController.swift
//  SubQ
//
//  Created by Constantine Thalasinos on 5/9/23.
//

import UIKit

class EditInjectionTableViewController: UITableViewController {
    
    weak var coordinator: EditInjectionCoordinator?
    
    let dosageIdentifier = "dosageCell"
    let injectionIdentifier = "injectionCell"
    let dayIdentifier = "dayCell"

    override func viewDidLoad() {
        super.viewDidLoad()
        
       navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelButtonPressed))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveButtonPressed))
        
        print(navigationItem)
        
        view.backgroundColor = .brown
        
        tableView.register(TextInputTableViewCell.self, forCellReuseIdentifier: injectionIdentifier)
        
        tableView.register(DosageTableViewCell.self, forCellReuseIdentifier: dosageIdentifier)
        
        tableView.register(DayTableViewCell.self, forCellReuseIdentifier: dayIdentifier)

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    @objc func cancelButtonPressed(_ sender: Any){
        print("cancel")
        coordinator?.cancelEdit()
        
    }
    
    @objc func saveButtonPressed(_ sender: Any){
        print("save")
        coordinator?.saveEdit()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 4
    }
    
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        // Configure the cell...
        
        let section = indexPath.section
        let row = indexPath.row
        
        if row == 1{
            let cell = tableView.dequeueReusableCell(withIdentifier: dosageIdentifier, for: indexPath) as! DosageTableViewCell
            
            return cell
        }
        
        if row == 2{
            let cell = tableView.dequeueReusableCell(withIdentifier: dayIdentifier, for: indexPath) as! DayTableViewCell
            
            return cell
        }
    
        
        else{
            let cell = tableView.dequeueReusableCell(withIdentifier: injectionIdentifier, for: indexPath) as! TextInputTableViewCell
            
            return cell
        }
            
         //   cell.tableView = self
         //   nameTextField = cell.textField
            
        /*    if let name = name{
                nameTextField!.text = name
            }
            else if let injection = injection{
                nameTextField!.text = injection.name
            }*/
        
        

    }
    

    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return false
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let row = indexPath.row
        
        
        tableView.deselectRow(at: indexPath, animated: false)
        
        if row == 2{
            coordinator?.showFrequencyController()
        }
        
        
    }


}
