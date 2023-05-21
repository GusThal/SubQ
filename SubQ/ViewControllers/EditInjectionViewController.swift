//
//  EditInjectionViewController.swift
//  SubQ
//
//  Created by Constantine Thalasinos on 5/18/23.
//

import UIKit

class EditInjectionViewController: UIViewController {

    weak var coordinator: EditInjectionCoordinator?
    
    private var dataSource: UICollectionViewDiffableDataSource<Int, String>! = nil
    private var collectionView: UICollectionView! = nil
    
    
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
        
    }
    
    @objc func cancelButtonPressed(_ sender: Any){
        print("cancel")
        coordinator?.cancelEdit()
        
    }
    
    @objc func saveButtonPressed(_ sender: Any){
        print("save")
        coordinator?.saveEdit()
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
                    cell.textField.placeholder = item
                  //  cell.label.sizeToFit()
                  //  cell.label.adjustsFontSizeToFitWidth = true
                    
                }
                else if indexPath.item == 1{
                    cell.label.text = "Dosage:"
                    cell.textField.placeholder = item

                    
                    let segmentedControl = UISegmentedControl(items: Injection.DosageUnits.allCases.map({$0.rawValue}))
                    segmentedControl.selectedSegmentIndex = 0
                    
                    let segmentedAccessory = UICellAccessory.CustomViewConfiguration(customView: segmentedControl, placement: .trailing(displayed: .always), reservedLayoutWidth: .actual)
                    
                    cell.accessories = [.customView(configuration: segmentedAccessory)]
                    
                    
                }
                
                cell.label.snp.makeConstraints { make in
                    make.width.equalTo(cell.label.intrinsicContentSize.width)
                }
            }
            
            
        }
        
        let timePickerRegistration = UICollectionView.CellRegistration<TimePickerCollectionViewCell, String> { cell, indexPath, itemIdentifier in
            
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
        
        snapshot.appendSections([Section.info.rawValue])
        snapshot.appendItems(["Hi"])
        snapshot.appendItems(["0.0"])
        snapshot.appendSections([Section.frequency.rawValue])
        snapshot.appendItems(["None Selected"])
        snapshot.appendItems(["time"])
        snapshot.appendSections([Section.delete.rawValue])
        snapshot.appendItems(["Delete Injection"])
        
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
        
        
        
        
        
    }
    
}
