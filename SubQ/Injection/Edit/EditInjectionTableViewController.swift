//
//  EditInjectionTableViewController.swift
//  SubQ
//
//  Created by Constantine Thalasinos on 8/17/23.
//

import UIKit
import Combine
import CoreData

class EditInjectionTableViewController: UITableViewController, Coordinated {
    
    let viewModel: EditInjectionViewModel
    
    weak var coordinator: Coordinator?
    weak var editCoordinator: EditInjectionCoordinator?
    
    var cancellables = Set<AnyCancellable>()
    
    lazy var nameTextField = UITextField()
    lazy var dosageTextField = UITextField()
    lazy var unitsSegmentedControl = UISegmentedControl()
    lazy var timePicker = UIDatePicker()
    lazy var selectedDate = Date()
    lazy var asNeededSwitch = UISwitch()
    lazy var notificationSwitch = UISwitch()
    
    let textInputReuseIdentifier = "textInputReuseIdentifier"
    
    let defaultReuseIdentifier = "defaultReuseIdentifier"
    let frequencyReuseIdentifier = "frequencyReuseIdentifier"
    
    let centeredTextReuseIdentifier = "centeredTextReuseIdentifier"
    
    let timePickerCellReuseIdentifier = "timePickerCellReuseIdentifier"
    
    let allUnitsCases = Injection.DosageUnits.allCases
    
    lazy var nameAction: UIAction = {
        return UIAction { _ in
            self.viewModel.name = self.nameTextField.text!
            
            if let _ = self.viewModel.injection{
                self.navigationItem.title = self.nameTextField.text
            }
                
        }
    }()
    
    lazy var dosageAction: UIAction = {
        return UIAction { _ in
            self.viewModel.dosage = self.dosageTextField.text!
        }
    }()
    
    lazy var unitsSegmentAction: UIAction = {
        return UIAction { _ in
            self.viewModel.selectedUnits = self.allUnitsCases[self.unitsSegmentedControl.selectedSegmentIndex]
            print(self.viewModel.selectedUnits)
        }
    }()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelButtonPressed))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveButtonPressed))
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 50
        tableView.isEditing = true
        tableView.allowsSelectionDuringEditing = true
        
        
        
        tableView.register(TextInputTableViewCell.self, forCellReuseIdentifier: textInputReuseIdentifier)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: defaultReuseIdentifier)
        tableView.register(FrequencyTableViewCell.self, forCellReuseIdentifier: frequencyReuseIdentifier)
        tableView.register(CenteredTextTableViewCell.self, forCellReuseIdentifier: centeredTextReuseIdentifier)
        tableView.register(TimePickerTableViewCell.self, forCellReuseIdentifier: timePickerCellReuseIdentifier)
        
        //https://kaushalelsewhere.medium.com/how-to-dismiss-keyboard-in-a-view-controller-of-ios-3b1bfe973ad1
        let tap = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        
        bindVariables()
        
        
       // tableView.rowHeight = UITableView.automaticDimension
       // tableView.estimatedRowHeight = 80
        
    }
    
    init(viewModel: EditInjectionViewModel){
        self.viewModel = viewModel
        
       /* if let injection = viewModel.injection {
            self.viewModel.isAsNeeded = injection.typeVal == .asNeeded ? true : false
            self.viewModel.areNotificationsEnabled = injection.areNotificationsEnabled
            
            for frequency in injection.frequency! as! Set<Frequency>{
                viewModel.frequencies.append(FrequencyStruct(days: frequency.daysVal, time: frequency.time))
                
            }
            
            print(viewModel.frequencies)
            
            
        }
        else{
            self.viewModel.isAsNeeded = true
            self.viewModel.areNotificationsEnabled = true
        }*/
        
        super.init(style: .insetGrouped)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bindVariables(){
    
        
            viewModel.daysSubject.sink { day in
                
                print(day)
                
                if !self.viewModel.isAsNeeded{
                    
                    let indexPath = IndexPath(row: self.viewModel.selectedDayCellIndex, section: 2)
                    
                    if let frequencyCell = self.tableView.cellForRow(at: indexPath) as? FrequencyTableViewCell{
                        frequencyCell.daysButtonTitle = day
                    }
                    
                    
                }
                    
            }
            .store(in: &cancellables)
        
        viewModel.isValidInjectionPublisher
            .assign(to: \.isEnabled, on: navigationItem.rightBarButtonItem!)
            .store(in: &cancellables)
    }
    
    
    @objc func cancelButtonPressed(_ sender: Any){
        print("cancel")
        editCoordinator?.cancelEdit()
        
    }
    
    @objc func saveButtonPressed(_ sender: Any){
        
        
        let units = Injection.DosageUnits(rawValue: Injection.DosageUnits.allCases.map({$0.rawValue})[unitsSegmentedControl.selectedSegmentIndex])!
        
        let name = nameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let dosage = Double.init(dosageTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines))!
        
        //let time = viewModel.selectedFrequency != [.asNeeded] ? selectedDate : nil
        
        //let frequency = viewModel.selectedFrequency.map({ $0.rawValue }).joined(separator: ", ")
        
        let frequencies = viewModel.frequencies
        
        var savedInjection: Injection!
        
        if !viewModel.isDuplicateInjection(name: name, dosage: dosage, units: units){
            
            if let existingInjection = viewModel.injection{
                
                
                //check the frequency of the injection before the edit controller was opened.
                if existingInjection.typeVal != .asNeeded {
                    //check if notifications were previously enabled
                    if existingInjection.areNotificationsEnabled{
                        
                        //honestly, it makes sense to just remove all notifications regardless.
                        NotificationManager.removeExistingNotifications(forInjection: existingInjection, removeQueued: false)
                        
                        //check if they're not currently enabled
                        //this actually will prob remove notifications if its switched to as needed
                       /* if !viewModel.areNotificationsEnabled{
                            
                            //remove the notifications.
                            NotificationManager.removeExistingNotifications(forInjection: existingInjection)
                        }
                        else{
                            //remove existing notifications only if the day or time has changed.
                            //this will actually handle cases where we switch from A scheduled injection to As Needed
                            if existingInjection.daysVal != viewModel.selectedFrequency || existingInjection.time!.prettyTime != time?.prettyTime{
                                
                                NotificationManager.removeExistingNotifications(forInjection: existingInjection)
                            }
                        }*/
                    }
                }
                
                savedInjection = viewModel.updateInjection(injection: existingInjection, name: name, dosage: dosage, units: units, frequencies: frequencies, areNotificationsEnabled: viewModel.areNotificationsEnabled, isAsNeeded: viewModel.isAsNeeded)
                
                
            } else {
                savedInjection = viewModel.saveInjection(name: name, dosage: dosage, units: units, frequencies: frequencies, areNotificationsEnabled: viewModel.areNotificationsEnabled, isAsNeeded: viewModel.isAsNeeded)
                
            }
            
            if !viewModel.isAsNeeded {
                if viewModel.areNotificationsEnabled{
                    NotificationManager.scheduleNotifications(forInjection: savedInjection)
                }
            }
            
            editCoordinator?.savePressed()
        }
        
        else {
            let alert = UIAlertController(title: "Duplicate Injection", message: "An injection already exists with that name, dosage, and units.", preferredStyle: .actionSheet)
            
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            
            
            self.present(alert, animated: true)
        }
        
      /*  if !viewModel.isDuplicateInjection(name: name, dosage: dosage, units: units, frequencyString: frequency, date: time){
            
            var savedInjection: Injection!
            
            
            if let existingInjection = viewModel.injection{
                
                //check the frequency of the injection before the edit controller was opened.
                if existingInjection.daysVal != [.asNeeded]{
                    
                    //check if notifications were previously enabled
                    if existingInjection.areNotificationsEnabled{
                        //check if they're not currently enabled
                        if !viewModel.areNotificationsEnabled{
                            
                            //remove the notifications.
                            NotificationManager.removeExistingNotifications(forInjection: existingInjection)
                        }
                        else{
                            //remove existing notifications only if the day or time has changed.
                            //this will actually handle cases where we switch from A scheduled injection to As Needed
                            if existingInjection.daysVal != viewModel.selectedFrequency || existingInjection.time!.prettyTime != time?.prettyTime{
                                
                                NotificationManager.removeExistingNotifications(forInjection: existingInjection)
                            }
                        }
                    }
                    
                }
                
                savedInjection = viewModel.updateInjection(injection: existingInjection, name: name, dosage: dosage, units: units, frequency: frequency, time: time, areNotificationsEnabled: viewModel.areNotificationsEnabled)
                
                
            }
            else{
                savedInjection = viewModel.saveInjection(name: name, dosage: dosage, units: units, frequency: frequency, time: time, areNotificationsEnabled: viewModel.areNotificationsEnabled)
                
            }
            
            if viewModel.selectedFrequency != [.asNeeded]{
                
                if viewModel.areNotificationsEnabled{
                    NotificationManager.scheduleNotification(forInjection: savedInjection)
                }
                
            }
            
            editCoordinator?.savePressed()
        }
        
        else{
            let alert = UIAlertController(title: "Duplicate Injection", message: "An injection already exists with that name, dosage, units, and frequency (both day(s) and time)", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            
            
            self.present(alert, animated: true)
        }*/
        
        
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        
        if !viewModel.isAsNeeded{
            
            if let _ = viewModel.injection{
                return 5
            }
            //no delete button
            else{
                return 4
            }
        }
        else{
            
            if let _ = viewModel.injection{
                return 3
            }
            // no delete button
            else{
                return 2
            }
            
        }
        
        
       
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      
        //injection name, dosage,
        if section == 0{
            return 2
        }
        //as needed switch
        else if section == 1{
            return 1
        }
        
        if !viewModel.isAsNeeded{
            //the frequency section
            if section == 2{
                
                var count = viewModel.frequencies.count + 1
                
                //not needed anymore since we're adding the time cell to the frequency obj
               /* if let _ = viewModel.selectedTimeCellIndex {
                    count += 1
                }*/
                
                return count
            }
            //the notification switch
            else if section == 3{
                return 1
            }
            //delete button
            else if section == 4{
                return 1
            }
        }
        else{
            //this would be the delete section in an as needed injection
            if section == 2{
                return 1
            }
        }
        
        return 0
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let section = indexPath.section
        let row = indexPath.row
        
        if section == 0{
            
            
            let cell = tableView.dequeueReusableCell(withIdentifier: textInputReuseIdentifier, for: indexPath) as! TextInputTableViewCell
            
            cell.textField.removeAction(nameAction, for: .editingChanged)
            cell.textField.removeAction(dosageAction, for: .editingChanged)
            
            if row == 0{
                cell.label.text = "Injection Name:"
                cell.textField.placeholder = "Beep Boop"
                cell.textInputType = .text
                
                if viewModel.name != "" {
                    cell.textField.text = viewModel.name
                } else if let injection = viewModel.injection {
                    cell.textField.text = injection.name!
                }
                
                nameTextField = cell.textField
                
                nameTextField.addAction(nameAction, for: .editingChanged)

            }
            else{
                cell.label.text = "Dosage:"
                cell.textField.placeholder = "0.0"
                cell.textInputType = .number
                
            
                
                if viewModel.dosage != "" {
                    cell.textField.text = viewModel.dosage
                }
                
                else if let injection = viewModel.injection {
                    cell.textField.text = "\(injection.dosage!)"
                }
                
                
                let segmentedControl = UISegmentedControl(items: allUnitsCases.map({ $0.rawValue }))
                
                if let selectedUnits = viewModel.selectedUnits {
                    for (index, units) in allUnitsCases.enumerated(){
                        if selectedUnits == units {
                            segmentedControl.selectedSegmentIndex = index
                        }
                    }
                    
                } else if let injection = viewModel.injection {
                    for (index, units) in allUnitsCases.enumerated(){
                        if self.viewModel.injection?.unitsVal == units{
                            segmentedControl.selectedSegmentIndex = index
                        }
                    }
                } else {
                    segmentedControl.selectedSegmentIndex = 0
                }
                
                
                cell.accessoryView = segmentedControl
                
                
                dosageTextField = cell.textField
                unitsSegmentedControl = segmentedControl
                unitsSegmentedControl.addAction(unitsSegmentAction, for: .primaryActionTriggered)
                
                dosageTextField.addAction(dosageAction, for: .editingChanged)
                
            }
            
            return cell
            
        }
        
       else if section == 1{
           let cell = tableView.dequeueReusableCell(withIdentifier: defaultReuseIdentifier, for: indexPath)
            
           var content = cell.defaultContentConfiguration()
           content.text = "As Needed"
           cell.contentConfiguration = content
           
           
           let switchView = UISwitch()
           //isAsNeeded is set in the constructor
           switchView.isOn = viewModel.isAsNeeded
           
           let action = UIAction { _ in
               self.viewModel.isAsNeeded = switchView.isOn
               print("is as needed \(self.viewModel.isAsNeeded)")
               self.viewModel.frequencies = [FrequencySectionData]()
               
               self.tableView.reloadData()
           }
           
           switchView.addAction(action, for: .primaryActionTriggered)
           asNeededSwitch = switchView
           cell.accessoryView = switchView
           
           return cell
            
        }
        
        else if section == 2{
            //frequency
            if !viewModel.isAsNeeded {
                
                
                if row == tableView.numberOfRows(inSection: section) - 1 {
                    
                    let cell = tableView.dequeueReusableCell(withIdentifier: defaultReuseIdentifier, for: indexPath)
                    
                    var content = cell.defaultContentConfiguration()
                    content.text = "add frequency"
                    
                    cell.contentConfiguration = content
                    
                    
                    return cell
                }
                
                else if let selectedRow = viewModel.selectedTimeCellIndex, selectedRow + 1 == row {
                    let cell = tableView.dequeueReusableCell(withIdentifier: timePickerCellReuseIdentifier, for: indexPath) as! TimePickerTableViewCell
                    //add an action to the picker
                    
                    let selectedCell = tableView.cellForRow(at: IndexPath(row: viewModel.selectedTimeCellIndex!, section: 2)) as! FrequencyTableViewCell
                    
                    cell.timePicker.date = selectedCell.selectedTime
                    
                    let timePickerAction = UIAction { _ in
                        let row = tableView.indexPath(for: cell)!.row - 1
                        let frequencyCell = tableView.cellForRow(at: IndexPath(row: row, section: 2)) as! FrequencyTableViewCell
                        frequencyCell.selectedTime = cell.timePicker.date
                        self.viewModel.frequencies[row].time = cell.timePicker.date
                    }
                    
                    cell.timePicker.addAction(timePickerAction, for: .primaryActionTriggered)
                    
                    return cell
                }
                
                else{
                    let cell = tableView.dequeueReusableCell(withIdentifier: frequencyReuseIdentifier, for: indexPath) as! FrequencyTableViewCell
                    
                    if let injection = viewModel.injection, injection.typeVal == .scheduled{
                        
                        //account for frequencies that were just added. ther days will be nil
                        if let days = viewModel.frequencies[row].days {
                            cell.daysButtonTitle =  days.count == 1 ? days[0].shortened : days.map({ $0.shortened }).joined(separator: ", ")
                        }
                        
                        if let time = viewModel.frequencies[row].time {
                            cell.selectedTime = time
                        }
                        
                        
                       // cell.timePicker.date = viewModel.frequencies[row].time!
                        
                    }
                    
                    let dayButtonAction = UIAction { _ in
                        let row = tableView.indexPath(for: cell)!.row
                        
                        self.viewModel.selectedDayCellIndex = row
                        self.editCoordinator?.showFrequencyController()
                        
                    }
                    
                    cell.daysButton.addAction(dayButtonAction, for: .primaryActionTriggered)
                    
                    let timeButtonAction = UIAction { _ in
                        let row = tableView.indexPath(for: cell)!.row
                        
                        print(row)
                        print(self.viewModel.selectedTimeCellIndex)
                        
                        
                        //dismiss datepicker cell if the same cell is clicked
                       if let previouslySelectedRow = self.viewModel.selectedTimeCellIndex {
                           
                           print("uh?")
                           
                           if previouslySelectedRow == row {
                               
                               let path = IndexPath(row: row + 1, section: 2)
                               
                               self.viewModel.selectedTimeCellIndex = nil
                               
                               self.viewModel.frequencies.remove(at: path.row)
                               
                               tableView.deleteRows(at: [path], with: .fade)
                           } else {
                               
                               
                               let deletePath = IndexPath(row: previouslySelectedRow + 1, section: 2)
                               
                               self.viewModel.selectedTimeCellIndex = nil
                               
                               self.viewModel.frequencies.remove(at: deletePath.row)
                               
                               tableView.deleteRows(at: [deletePath], with: .fade)
                               
                               let rowAfterDelete = tableView.indexPath(for: cell)!.row
                               
                               self.viewModel.selectedTimeCellIndex = rowAfterDelete
                               
                               self.insertTimePickerRow(afterRow: rowAfterDelete, section: 2)
                               
                               //self.viewModel.selectedTimeCellIndex = row - 1
                               
                               //self.insertTimePickerRow(afterRow: row - 1, section: 2)
                               
                               
                           }
                        }
                        
                        else {
                            print("glorp")
                            self.viewModel.selectedTimeCellIndex = row
                            
                            self.insertTimePickerRow(afterRow: row, section: 2)
                        }
                        
                        print(row)
                    }
                    
                    
                    
                    cell.timeButton.addAction(timeButtonAction, for: .primaryActionTriggered)
                    
                    
                    
                   /* let timePickerAction = UIAction { _ in
                        let index = tableView.indexPath(for: cell)!.row
                        
                        self.viewModel.frequencies[index].time = cell.timePicker.date
                        print(self.viewModel.frequencies)
                        //print(cell.timePicker.date)
                    }
                    
                    cell.timePicker.addAction(timePickerAction, for: .primaryActionTriggered)*/
                    
                    return cell
                }
                
            }
            //will only ever be a delete cell
            else {
                let cell = tableView.dequeueReusableCell(withIdentifier: centeredTextReuseIdentifier, for: indexPath) as! CenteredTextTableViewCell
                
                return cell
            }
        }
        
        //this will only ever be the notification switch
        else if section == 3{
            let cell = tableView.dequeueReusableCell(withIdentifier: defaultReuseIdentifier, for: indexPath)
             
            var content = cell.defaultContentConfiguration()
            content.text = "Notifications"
            cell.contentConfiguration = content
            
            let switchView = UISwitch()
            //this is set in the initializer
            switchView.isOn = self.viewModel.areNotificationsEnabled
            
            let action = UIAction { _ in
                self.viewModel.areNotificationsEnabled = switchView.isOn
                print("notifications enabled: \(self.viewModel.areNotificationsEnabled)")
            }
            
            switchView.addAction(action, for: .primaryActionTriggered)
            notificationSwitch = switchView
            cell.accessoryView = switchView
            
            return cell
        }
        
        //will only ever be the delete button
        else if section == 4{
            let cell = tableView.dequeueReusableCell(withIdentifier: centeredTextReuseIdentifier, for: indexPath) as! CenteredTextTableViewCell
            
            return cell
        }
    

        // Configure the cell...
        
        
        

        return UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        
        let section = indexPath.section
        let row = indexPath.row
        
        if section == 2{
            
            if !self.viewModel.isAsNeeded{
               
                if row == tableView.numberOfRows(inSection: section) - 1{
                    insertFrequencyRow(section: section)
                }
                
            }
            else{
                presentDeleteAlertController()
            }
        }
        else if section == 4{
            presentDeleteAlertController()
        }
        
       
    
        
        cell?.setSelected(false, animated: false)
    }
    

    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        //frequency section
        if !viewModel.isAsNeeded && indexPath.section == 2 {
            
            if let index = viewModel.selectedTimeCellIndex {
                if index + 1 == indexPath.row {
                    return false
                }
            }
            
            return true
            
        } else {
            return false
        }
        
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        
        if !viewModel.isAsNeeded && indexPath.section == 2{
            if indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1{
                return .insert
            }
        }
        
        return .delete
        
        
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let row = indexPath.row
        let section = indexPath.section
        
        if !viewModel.isAsNeeded && section == 2{
            
            if row == tableView.numberOfRows(inSection: section) - 1 {
                insertFrequencyRow(section: section)
                
            } else {
                
                var pathsToDelete = [indexPath]
                
                if let timeCellIndex = viewModel.selectedTimeCellIndex {
                    pathsToDelete.append(IndexPath(row: row + 1, section: section))
                    viewModel.frequencies.remove(at: row + 1)
                    viewModel.selectedTimeCellIndex = nil
                }
                
                viewModel.frequencies.remove(at: row)
                
                tableView.deleteRows(at: pathsToDelete, with: .automatic)
            }
            
        }
       // print(viewModel.frequencies)
        
        
    }
    
  /*  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 2 {
            if let selected = viewModel.selectedTimeCellIndex {
                if indexPath.row == selected + 1 {
                    return 216
                }
            }
        }
        return 44
    }*/
    
    func insertFrequencyRow(section: Int){
        viewModel.frequencies.append(FrequencySectionData(isTimePickerCell: false, time: Date()))
        
        let row = tableView.numberOfRows(inSection: 2)
        
        tableView.insertRows(at: [IndexPath(row: row - 1, section: section)], with: .automatic)
    }
    
    func insertTimePickerRow(afterRow row: Int, section: Int) {
        
        viewModel.frequencies.insert(FrequencySectionData(isTimePickerCell: true), at: row + 1)
        
        let path = IndexPath(row: row + 1, section: section)
        
        tableView.insertRows(at: [path], with: .fade)
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if section == 1{
            return "Notifications will not be generated for As Needed injections."
        }
        
        if section == 3 && !viewModel.isAsNeeded {
           return  "This injection will be able to selected in the Inject Now tab, whether or not notifications are enabled."
        }
        
        return nil
    }
    
    func presentDeleteAlertController() {
        let alert = UIAlertController(title: "Delete Injection", message: "Are you sure you want to delete this injection?", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { [self] _ in
            
            
            viewModel.deleteInjection(viewModel.injection!)
            
            editCoordinator?.deleteInjection()
        }))
        
        self.present(alert, animated: true)
    }



}

extension EditInjectionTableViewController{
    
    struct FrequencySectionData{
        var isTimePickerCell: Bool
        var days: [Frequency.InjectionDay]?
        var time: Date?
    }
    
}
