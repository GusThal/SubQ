//
//  SettingsViewController.swift
//  SubQ
//
//  Created by Constantine Thalasinos on 5/4/23.
//

import UIKit

class SettingsViewController: UIViewController {
    
    var dataSource: UICollectionViewDiffableDataSource<Section, String>!
    
    var collectionView: UICollectionView! = nil
    
    weak var coordinator: SettingsCoordinator?
    
    enum Section: Int{
        case zones, misc
        var description: String {
            switch self {
            case .zones: return "Zones"
            case .misc: return "Misc"
            }
        }
    }
    
    enum MiscCells: Int, CaseIterable{
        case disc, privacy, feedback
        var description: String {
            switch self{
            case .disc: return "Disclaimer"
            case .privacy: return "Privacy Statement"
            case .feedback: return "Send Feedback"
            }
        }
    }
    
    let zones = Site.Zone.allCases
    
    var enabledZones = Site.Zone.allCases

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .green
        
        
        configureHierarchy()
        configureDataSource()

        // Do any additional setup after loading the view.
    }
    

    func createLayout() -> UICollectionViewLayout {
        
        let sectionProvider = { (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            
            guard let sectionKind = Section(rawValue: sectionIndex) else { return nil }
            
            
            if sectionKind == .zones {
                
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .fractionalHeight(1.0))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(0.10))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 2)
                
                let section = NSCollectionLayoutSection(group: group)
                
                return section
                
            } else{
                
                let configuration = UICollectionLayoutListConfiguration(appearance: .grouped)
    
                let section = NSCollectionLayoutSection.list(using: configuration, layoutEnvironment: layoutEnvironment)
           
                return section
            }
            
        }
        return UICollectionViewCompositionalLayout(sectionProvider: sectionProvider)
    }

}

extension SettingsViewController{
    func configureHierarchy() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = .systemBackground
        view.addSubview(collectionView)
        
        collectionView.delegate = self
    }
    func configureDataSource() {
        let zoneCellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, String> { (cell, indexPath, zone) in
            // Populate the cell with our item description.
            
            var content = cell.defaultContentConfiguration()
            content.text = zone
            cell.contentConfiguration = content
            
            cell.accessories = self.enabledZones.contains(Site.Zone.init(rawValue: zone)!) ? [.checkmark()] : []
        
        }
        
        let miscCellRegistration = UICollectionView.CellRegistration <UICollectionViewListCell, String> { cell, indexPath, item in
            
            var content = cell.defaultContentConfiguration()
            content.text = item
            cell.contentConfiguration = content
            
            cell.accessories = indexPath.item == MiscCells.feedback.rawValue ? [.disclosureIndicator()]: [.detail()]
            
        }
        
        dataSource = UICollectionViewDiffableDataSource<Section, String>(collectionView: collectionView) {
            (collectionView: UICollectionView, indexPath: IndexPath, item: String) -> UICollectionViewCell? in
            
            if indexPath.section == Section.zones.rawValue{
                return collectionView.dequeueConfiguredReusableCell(using: zoneCellRegistration, for: indexPath, item: item)
            }
            else{
                return collectionView.dequeueConfiguredReusableCell(using: miscCellRegistration, for: indexPath, item: item)
            }
            
        }

        // initial data
        var snapshot = NSDiffableDataSourceSnapshot<Section, String>()
        snapshot.appendSections([Section.zones, Section.misc])
        dataSource.apply(snapshot, animatingDifferences: false)

        
        
        var zonesSnapshot = NSDiffableDataSourceSectionSnapshot<String>()
        //zonesSnapshot.append(Site.zones)
        zonesSnapshot.append(enabledZones.map({ $0.rawValue }))
        dataSource.apply(zonesSnapshot, to: .zones, animatingDifferences: false)
        
        var sitesSnapshot = NSDiffableDataSourceSectionSnapshot<String>()
        //sitesSnapshot.append(Site.sites)
        //sitesSnapshot.append(User.sites)
        sitesSnapshot.append(MiscCells.allCases.map({ $0.description }))
        dataSource.apply(sitesSnapshot, to: .misc, animatingDifferences: false)
        
        
    }
}

extension SettingsViewController: UICollectionViewDelegate{
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let section = indexPath.section
        let index = indexPath.item
        let cell = collectionView.cellForItem(at: indexPath) as! UICollectionViewListCell
        
        collectionView.deselectItem(at: indexPath, animated: true)
        
        if section == Section.zones.rawValue{
            if cell.accessories.isEmpty{
                cell.accessories = [.checkmark()]
                
                if !enabledZones.contains(zones[index]){
                    enabledZones.append(zones[index])
                }
            }
            else{
                cell.accessories = []
                enabledZones.removeAll { value in
                    return value == zones[index]
                }
            }
            //applySnapshots()
            
        }
        else{
            
        }
        
        print(enabledZones)
        
    }
    
}
