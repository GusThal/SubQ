//
//  FrequencyViewController.swift
//  SubQ
//
//  Created by Constantine Thalasinos on 5/13/23.
//

import UIKit

class DaysViewController: UIViewController, Coordinated {
    
    weak var coordinator: Coordinator?
    weak var frequencyCoordinator: DaysCoordinator?
    
    private var dataSource: UICollectionViewDiffableDataSource<Int, Frequency.InjectionDay>! = nil
    private var collectionView: UICollectionView! = nil
    

    let days = Frequency.InjectionDay.allCases.filter { Frequency.InjectionDay.daily != $0 }
    
    
    var isDailySelected = false

    
    var isADaySelected: Bool{
        for day in selectedDays{
            if day{
                return true
            }
        }
        return false
    }
    
    var selectedDays = Array(repeating: false, count: 7)
    
    
    
    enum Section: Int{
        case daily = 0, days = 1
    }
    
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonPressed))
        
        navigationItem.rightBarButtonItem!.tintColor = InterfaceDefaults.primaryColor
        
        configureHierarchy()
        configureDataSource()
        
        setDoneButtonState()
        
    }
    

    init(selectedFrequency: [Frequency.InjectionDay]?){
        
        if let selectedFrequency{
            if selectedFrequency == [.daily]{
                isDailySelected = true
            }
            else{
                for (index, day) in days.enumerated(){
                    if selectedFrequency.contains(day){
                        selectedDays[index] = true
                    }
                }
            }
        }
        
        super.init(nibName: nil, bundle: nil)
    }
    
    
    func setDoneButtonState(){
        if isDailySelected || isADaySelected{
            navigationItem.rightBarButtonItem!.isEnabled = true
        }
        else{
            navigationItem.rightBarButtonItem!.isEnabled = false
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func doneButtonPressed(_ sender: Any){
        print("done")
        frequencyCoordinator?.done(isDailySelected: isDailySelected, selectedDays: selectedDays)
    }
    
    

}

extension DaysViewController{
    
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
        
        
        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, Frequency.InjectionDay> { [weak self] (cell, indexPath, item) in
            guard let self = self else { return }
            
            var content = cell.defaultContentConfiguration()
            content.text = item.rawValue
            
            if indexPath.section == Section.daily.rawValue && self.isDailySelected{
                cell.accessories = [.checkmark(options: .init(tintColor: InterfaceDefaults.primaryColor))]
            }
            else if indexPath.section == Section.days.rawValue && self.selectedDays[indexPath.item]{
                cell.accessories = [.checkmark(options: .init(tintColor: InterfaceDefaults.primaryColor))]
            }
            
            
            
            cell.contentConfiguration = content

        }
        

        
        dataSource = UICollectionViewDiffableDataSource<Int, Frequency.InjectionDay>(collectionView: collectionView) {
            (collectionView: UICollectionView, indexPath: IndexPath, item: Frequency.InjectionDay) -> UICollectionViewCell? in
          
                return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: item)
        }
        

        
        // initial data
        var snapshot = NSDiffableDataSourceSnapshot<Int, Frequency.InjectionDay>()
        

        snapshot.appendSections([0])
        snapshot.appendItems([Frequency.InjectionDay.daily])
        snapshot.appendSections([1])
        snapshot.appendItems(days)
        
        
        dataSource.apply(snapshot, animatingDifferences: false)
        
    }
}

extension DaysViewController: UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let section = indexPath.section
        let item = indexPath.item
        
        let cell = collectionView.cellForItem(at: indexPath) as! UICollectionViewListCell
        
        
        

        if section == Section.daily.rawValue{
            
            if !cell.accessories.isEmpty{
                cell.accessories = []
            
                isDailySelected = false
            }
            else{
                cell.accessories = [.checkmark(options: .init(tintColor: InterfaceDefaults.primaryColor))]
                isDailySelected = true
                

                
                uncheckAllDays()
            }
            
            
        }
        //a day is selected
        else{
            if !cell.accessories.isEmpty{
                cell.accessories = []
                selectedDays[item] = false
                
               // selectedDays[row] = false
            }
            else{
                cell.accessories = [.checkmark(options: .init(tintColor: InterfaceDefaults.primaryColor))]
                selectedDays[item] = true
                

                
                let dailyCell = collectionView.cellForItem(at: IndexPath(item: 0, section: Section.daily.rawValue)) as! UICollectionViewListCell

                
                if allDaysSelected(){
                    dailyCell.accessories = [.checkmark(options: .init(tintColor: InterfaceDefaults.primaryColor))]
                    cell.accessories = []
                    isDailySelected = true
                    uncheckAllDays()
                }
                else{
                    dailyCell.accessories = []
                    isDailySelected = false
                }
                
            }
            
        }
        
        collectionView.deselectItem(at: indexPath, animated: false)
        
        setDoneButtonState()
        
        
    }
    
    func uncheckAllDays(){
            
        for i in 0...days.count-1{
            let cell = collectionView.cellForItem(at: IndexPath(item: i, section: Section.days.rawValue)) as! UICollectionViewListCell
            cell.accessories = []
            selectedDays[i] = false
        }
    }
    
    func allDaysSelected() -> Bool{
        
        var numOfCheckedDays = 0
        
        for i in 0...days.count-1{
            let cell = collectionView.cellForItem(at: IndexPath(item: i, section: Section.days.rawValue)) as! UICollectionViewListCell
            
            if !cell.accessories.isEmpty{
                numOfCheckedDays+=1
            }
        }
        
        
        return numOfCheckedDays == days.count ? true : false
    }
    
}
