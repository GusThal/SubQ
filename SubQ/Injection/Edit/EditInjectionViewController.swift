//
//  EditInjectionViewController.swift
//  SubQ
//
//  Created by Constantine Thalasinos on 5/18/23.
//

import UIKit
import Combine
import CoreData

class EditInjectionViewController: UIViewController, Coordinated {
    

    
    weak var coordinator: Coordinator?
    weak var editCoordinator: EditInjectionCoordinator?
    
    private var dataSource: UICollectionViewDiffableDataSource<Int, String>! = nil
    private var collectionView: UICollectionView! = nil
    
    var viewModel: EditInjectionViewModel
    var cancellables = Set<AnyCancellable>()
    
    lazy var nameTextField = UITextField()
    lazy var dosageTextField = UITextField()
    lazy var unitsSelector = UISegmentedControl()
    lazy var timePicker = UIDatePicker()
    lazy var selectedDate = Date()
    
    
    enum Section: Int{
        case info = 0, frequency = 1, notifications = 2, delete = 3
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelButtonPressed))
         navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveButtonPressed))
        
        
        view.backgroundColor = .brown
        
        
        configureHierarchy()
        configureDataSource()
        
        bindVariables()
        
    }
    
    func bindVariables(){
        
        viewModel.frequencySubject.sink { [self] frequency in
                
            var snap = dataSource.snapshot(for: Section.frequency.rawValue)
                
            let firstItem = snap.items[0]
            
            var freq = frequency
            
            if frequency == nil || frequency!.isEmpty{
                freq = "None Selected"
            }
            
            if  ["None Selected", Injection.Frequency.asNeeded.rawValue].contains(freq){
                
                if !snap.contains(freq!){
                    snap.deleteAll()
                    snap.append([freq!])
                    
                    dataSource.apply(snap, to: Section.frequency.rawValue, animatingDifferences: true)
                }
                
            }
            
           else if !snap.contains(freq!){
               
               
               //this means we're coming from "as needed" or "none selected and as such need to add a time to the snapshot
               if snap.items.count == 1{
                   
                   snap.deleteAll()
                   snap.append([freq!])
                   
                   let dateFormatter = DateFormatter()
                   dateFormatter.dateStyle = .full
                   dateFormatter.timeStyle = .full
                   
                   let timeString = dateFormatter.string(from: Date())
                   
                   snap.append([timeString])
                   
               }
               
               else{
                   
                   snap.insert([freq!], before: firstItem)
                   snap.delete([firstItem])
               }
                
                dataSource.apply(snap, to: Section.frequency.rawValue, animatingDifferences: true)
              
            }
            
            handleNotificationSection(frequency: freq!)
            
            
        }.store(in: &cancellables)
        
        

        
        viewModel.isValidInjectionPublisher
            .assign(to: \.isEnabled, on: navigationItem.rightBarButtonItem!)
            .store(in: &cancellables)
        
    }
    
    func handleNotificationSection(frequency: String){
        
        var snapshot = dataSource.snapshot()
        
        
        //this means there's a delete injection section
        if let injection = self.viewModel.injection{
            
            if frequency == Injection.Frequency.asNeeded.rawValue || frequency == "None Selected"{

                if snapshot.numberOfSections == 4{
                    //delete the third section.
                    snapshot.deleteSections([Section.notifications.rawValue])
                }
                
            }
            else{
                
                if snapshot.numberOfSections == 3{
                    //since we have a delete section, insert the notification section after section 2
                    snapshot.insertSections([Section.notifications.rawValue], afterSection: Section.frequency.rawValue)
                    snapshot.appendItems(["Notification"], toSection: Section.notifications.rawValue)
                }
                
            }
            
        }
        //new injection, therefore there's no delete section/button
        else{
            if frequency == Injection.Frequency.asNeeded.rawValue || frequency == "None Selected"{
                if dataSource.snapshot().numberOfSections == 3{
                   //delete the notification section
                    snapshot.deleteSections([Section.notifications.rawValue])
                    
                }
            }
            else{
                if dataSource.snapshot().numberOfSections == 2{
                    //append the notification section
                    snapshot.appendSections([Section.notifications.rawValue])
                   // snapshot.insertSections([Section.notifications.rawValue], afterSection: Section.frequency.rawValue)
                    snapshot.appendItems(["Notifications"], toSection: Section.notifications.rawValue)
                }
            }
        }
        
        dataSource.apply(snapshot)
    }
    
    @objc func cancelButtonPressed(_ sender: Any){
        print("cancel")
        editCoordinator?.cancelEdit()
        
    }
    
    @objc func saveButtonPressed(_ sender: Any){
        print("save")
        
        
        let units = Injection.DosageUnits(rawValue: Injection.DosageUnits.allCases.map({$0.rawValue})[unitsSelector.selectedSegmentIndex])!
        
        let name = nameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let dosage = Double.init(dosageTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines))!
        
        print("Dosage: \(dosage)")
        
        let time = viewModel.selectedFrequency != [.asNeeded] ? selectedDate : nil
        
        let frequency = viewModel.selectedFrequency.map({ $0.rawValue }).joined(separator: ", ")
        
        
        if !viewModel.isDuplicateInjection(name: name, dosage: dosage, units: units, frequencyString: frequency, date: time){
            
            var savedInjection: Injection!
            
            
            if let existingInjection = viewModel.injection{
                
                if existingInjection.daysVal != [.asNeeded]{
                    
                    //check if notifications were previously enabled
                    if existingInjection.areNotificationsEnabled{
                        //check if they're not currently enabled
                        if !viewModel.areNotificationsEnabled{
                            
                            //remove the notifications.
                            NotificationManager.removeExistingNotifications(forInjection: existingInjection, snoozedUntil: nil, originalDateDue: nil)
                        }
                        else{
                            //remove existing notifications only if the day or time has changed.
                            //this will actually handle cases where we switch from A scheduled injection to As Needed
                            if existingInjection.daysVal != viewModel.selectedFrequency || existingInjection.time!.prettyTime != time?.prettyTime{
                                
                                NotificationManager.removeExistingNotifications(forInjection: existingInjection, snoozedUntil: nil, originalDateDue: nil)
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
        }
        
        
    }
    
    init(viewModel: EditInjectionViewModel){
        self.viewModel = viewModel
    
        
        super.init(nibName: nil, bundle: nil)
        
        if let time = viewModel.injection?.time{
            selectedDate = time
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    

}

extension EditInjectionViewController{
    
    private func createLayout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout { [unowned self] section, layoutEnvironment in
            var config = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
            return NSCollectionLayoutSection.list(using: config, layoutEnvironment: layoutEnvironment)
        }
    }
    
    private func configureHierarchy() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(collectionView)
        collectionView.delegate = self
    }
    
    private func configureDataSource() {
        
        let textInputRegistration = UICollectionView.CellRegistration<TextInputCollectionViewCell, String> { [weak self] cell, indexPath, item in
            guard let self = self else { return }
            
            if indexPath.section == 0{
                
                
                if indexPath.item == 0{
                    cell.label.text = "Injection Name:"
                    cell.textField.placeholder = "Beep boop"
                    cell.textField.text = item == "name" ? "" : item
                    
                    self.nameTextField = cell.textField
                    
                    self.nameTextField.textPublisher()
                        .assign(to: \.name, on: self.viewModel)
                        .store(in: &self.cancellables)
                    
                    //only update the title for existing injections.
                    if let _ = self.viewModel.injection{
                        let action = UIAction { _ in
                            self.navigationItem.title = self.nameTextField.text
                        }
                        self.nameTextField.addAction(action, for: .editingChanged)
                    }
                    
                    cell.textInputType = .text
                  //  cell.label.sizeToFit()
                  //  cell.label.adjustsFontSizeToFitWidth = true
                    
                }
                else if indexPath.item == 1{
                    cell.label.text = "Dosage:"
                    cell.textField.placeholder = "0.0"
                    cell.textField.text = item == "dosage" ? "" : item
                    
                    self.dosageTextField = cell.textField
                    
                    self.dosageTextField.textPublisher()
                        .assign(to: \.dosage, on: self.viewModel)
                        .store(in: &self.cancellables)
                    
                    cell.textInputType = .number

                    let unitsArr = Injection.DosageUnits.allCases
                    
                    let segmentedControl = UISegmentedControl(items: unitsArr.map({ $0.rawValue }))
                    
                    segmentedControl.selectedSegmentIndex = 0
                    
                    for (index, units) in unitsArr.enumerated(){
                        if self.viewModel.injection?.unitsVal == units{
                            segmentedControl.selectedSegmentIndex = index
                        }
                    }
                
                    
                    self.unitsSelector = segmentedControl
                    
                    let segmentedAccessory = UICellAccessory.CustomViewConfiguration(customView: segmentedControl, placement: .trailing(displayed: .always), reservedLayoutWidth: .actual)
                    
                    cell.accessories = [.customView(configuration: segmentedAccessory)]
                    
                    
                }
                
                cell.label.snp.makeConstraints { make in
                    make.width.equalTo(cell.label.intrinsicContentSize.width)
                }
            }
            
            
        }
        
        let timePickerRegistration = UICollectionView.CellRegistration<TimePickerCollectionViewCell, String> { cell, indexPath, item in
            
            print("item \(item)")
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .full
            dateFormatter.timeStyle = .full
            
            let date = dateFormatter.date(from: item)
            
            cell.date = date
            
            cell.action = UIAction(handler: { [unowned self] (action) in
                
                print("picker action")
                
                // Make sure sender is a date picker
                guard let picker = action.sender as? UIDatePicker else {
                    return
                }
        
                selectedDate = picker.date
                
            
            })
            
            
        }
        
        let deleteRegistration = UICollectionView.CellRegistration<CenteredTextLabelCell, String> { cell, indexPath, item in
            
            cell.label.text = item
        }
        
        
        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, String> { [weak self] (cell, indexPath, item) in
            guard let self = self else { return }
            
            var content = cell.defaultContentConfiguration()
            content.text = item
            
            if indexPath.section == Section.notifications.rawValue{
                
                let notificationSwitch = UISwitch()
                
               // notificationSwitch.isOn = self.viewModel.areNotificationsEnabled
                
                let action = UIAction { _ in
                    self.viewModel.areNotificationsEnabled = notificationSwitch.isOn
                }
                
                notificationSwitch.addAction(action, for: .primaryActionTriggered)
                
                if let injection = viewModel.injection{
                    notificationSwitch.isOn = viewModel.areNotificationsEnabled
                }
                else{
                    notificationSwitch.isOn = true
                }
                
                let accessory = UICellAccessory.CustomViewConfiguration(customView: notificationSwitch, placement: .trailing(displayed: .whenNotEditing), reservedLayoutWidth: .actual)
                
                cell.accessories = [.customView(configuration: accessory)]
                
            }
            
            cell.contentConfiguration = content

        }
        
        let segueCellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, String> { [weak self] cell, indexPath, item in
            guard let self else { return }
            
            var content = UIListContentConfiguration.valueCell()
            content.text = "Frequency"
            content.secondaryText = item
            cell.contentConfiguration = content
            cell.accessories = [.disclosureIndicator()]
            
        }
        
        dataSource = UICollectionViewDiffableDataSource<Int, String>(collectionView: collectionView) {
            (collectionView: UICollectionView, indexPath: IndexPath, item: String) -> UICollectionViewCell? in
          
            if indexPath.section == Section.info.rawValue{
                
                if indexPath.item == 0{
                    return collectionView.dequeueConfiguredReusableCell(using: textInputRegistration, for: indexPath, item: item)
                }
                else if indexPath.item == 1{
                    return collectionView.dequeueConfiguredReusableCell(using: textInputRegistration, for: indexPath, item: item)
                }
            }
            
            else if indexPath.section == Section.frequency.rawValue{
                
                if indexPath.item == 0{
                    
                    return collectionView.dequeueConfiguredReusableCell(using: segueCellRegistration, for: indexPath, item: item)
                }
                else if indexPath.item == 1{
                    return collectionView.dequeueConfiguredReusableCell(using: timePickerRegistration, for: indexPath, item: item)
                }
            }
            
            else if indexPath.section == Section.notifications.rawValue{
                print(self.viewModel.selectedFrequency)
                if self.viewModel.currentValueFrequency.value != [.asNeeded]{
                    return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: item)
                }
                else{
                    print("uh")
                    return collectionView.dequeueConfiguredReusableCell(using: deleteRegistration, for: indexPath, item: item)
                }
            }
            
            else{
                return collectionView.dequeueConfiguredReusableCell(using: deleteRegistration, for: indexPath, item: item)
            }
            
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: item)
        }
        
        // initial data
        var snapshot = NSDiffableDataSourceSnapshot<Int, String>()
        
        let injection = viewModel.injection
        
        snapshot.appendSections([Section.info.rawValue])
        
        
        snapshot.appendItems([injection?.name ?? "name"])
        snapshot.appendItems([injection?.dosage?.stringValue ?? "dosage"])
        snapshot.appendSections([Section.frequency.rawValue])
        

        snapshot.appendItems([injection?.shortenedDayString ?? "None Selected"])
        
        if viewModel.selectedFrequency != [.asNeeded] && !viewModel.selectedFrequency.isEmpty{
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .full
            dateFormatter.timeStyle = .full
            
            let timeString = dateFormatter.string(from: injection?.time ?? Date())
            
            snapshot.appendItems([timeString])
        }
        if viewModel.selectedFrequency != [.asNeeded] && !viewModel.selectedFrequency.isEmpty{
            snapshot.appendSections([Section.notifications.rawValue])
            snapshot.appendItems(["Notifications"])
        }
        
        if injection != nil{
            snapshot.appendSections([Section.delete.rawValue])
            snapshot.appendItems(["Delete Injection"])
        }
        
        dataSource.apply(snapshot, animatingDifferences: true)
        
    }
}

extension EditInjectionViewController: UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let section = indexPath.section
        let item = indexPath.item
        
        let cell = collectionView.cellForItem(at: indexPath) as! UICollectionViewListCell
        
        collectionView.deselectItem(at: indexPath, animated: false)
        
        if section == Section.frequency.rawValue && item == 0{
            editCoordinator?.showFrequencyController()
        }
        else if section == Section.delete.rawValue{
            
            let alert = UIAlertController(title: "Delete Injection", message: "Are you sure you want to delete this injection?", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            
            alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { [self] _ in
                
                
                viewModel.deleteInjection(viewModel.injection!)
                
                editCoordinator?.deleteInjection()
            }))
            
            self.present(alert, animated: true)
        }
        
        
    }
    
}
