//
//  EditInjectionViewController.swift
//  SubQ
//
//  Created by Constantine Thalasinos on 5/18/23.
//

import UIKit
import Combine

class EditInjectionViewController: UIViewController {

    weak var coordinator: EditInjectionCoordinator?
    
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
        case info = 0, frequency = 1, delete = 2
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
            
            
            if !snap.contains(freq!){
                
                snap.insert([freq!], before: firstItem)
                snap.delete([firstItem])
                
                dataSource.apply(snap, to: Section.frequency.rawValue, animatingDifferences: false)
              
            }
            
        }.store(in: &cancellables)
        
    }
    
    @objc func cancelButtonPressed(_ sender: Any){
        print("cancel")
        coordinator?.cancelEdit()
        
    }
    
    @objc func saveButtonPressed(_ sender: Any){
        print("save")
        
        
        let units = Injection.DosageUnits(rawValue: Injection.DosageUnits.allCases.map({$0.rawValue})[unitsSelector.selectedSegmentIndex])!
        
        let name = nameTextField.text!
        let dosage = Double.init(dosageTextField.text!)!
        
        let time = viewModel.selectedFrequency != [.asNeeded] ? selectedDate : nil
        
        
        if let injection = viewModel.injection{
            viewModel.updateInjection(injection: injection, name: name, dosage: dosage, units: units, frequency: viewModel.selectedFrequency, time: time)
        }
        else{
            viewModel.saveInjection(name: nameTextField.text!, dosage: Double.init(dosageTextField.text!)!, units: units, frequency: viewModel.selectedFrequency, time: time)
        }
        
        coordinator?.savePressed()
        
        
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
                    cell.textInputType = .text
                  //  cell.label.sizeToFit()
                  //  cell.label.adjustsFontSizeToFitWidth = true
                    
                }
                else if indexPath.item == 1{
                    cell.label.text = "Dosage:"
                    cell.textField.placeholder = "0.0"
                    cell.textField.text = item == "dosage" ? "" : item
                    
                    self.dosageTextField = cell.textField
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
            
            if indexPath.section == Section.delete.rawValue && indexPath.item == 0{
                content.textProperties.color = .red

            }
        
            cell.contentConfiguration = content
            
            

        }
        
        let segueCellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, String> { [weak self] cell, indexPath, item in
            guard let self else { return }
            
            var content = UIListContentConfiguration.valueCell()
            content.text = "Day(s)"
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
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .full
        dateFormatter.timeStyle = .full
        
        let timeString = dateFormatter.string(from: injection?.time ?? Date())
        
        
        snapshot.appendItems([timeString])
        
        if injection != nil{
            snapshot.appendSections([Section.delete.rawValue])
            snapshot.appendItems(["Delete Injection"])
        }
        
        dataSource.apply(snapshot, animatingDifferences: false)
        
    }
}

extension EditInjectionViewController: UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let section = indexPath.section
        let item = indexPath.item
        
        let cell = collectionView.cellForItem(at: indexPath) as! UICollectionViewListCell
        
        collectionView.deselectItem(at: indexPath, animated: false)
        
        if section == Section.frequency.rawValue && item == 0{
            coordinator?.showFrequencyController()
        }
        else if section == Section.delete.rawValue{
            
            let alert = UIAlertController(title: "Delete Injection", message: "Are you sure you want to delete this injection?", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            
            alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { [self] _ in
                coordinator?.deleteInjection(viewModel.injection!)
            }))
            
            self.present(alert, animated: true)
        }
        
        
    }
    
}
