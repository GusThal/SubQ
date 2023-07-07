//
//  SettingsViewController.swift
//  SubQ
//
//  Created by Constantine Thalasinos on 5/4/23.
//

import UIKit
import Combine
import CoreData

class SettingsViewController: UIViewController, Coordinated {
    
    var dataSource: UICollectionViewDiffableDataSource<Section, String>!
    
    var collectionView: UICollectionView! = nil
    
    weak var coordinator: Coordinator?
    weak var settingsCoordinator: SettingsCoordinator?
    
    let viewModel: BodyPartViewModel
    
    var cancellables = Set<AnyCancellable>()
    
    enum Section: Int{
        case bodyParts, misc
        var description: String {
            switch self {
            case .bodyParts: return "Body Parts"
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
    
    let bodyParts = BodyPart.Location.allCases
    
    var enabledBodyParts = BodyPart.Location.allCases

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .green
        
        
        configureHierarchy()
        configureDataSource()
        
        viewModel.snapshot.receive(on: DispatchQueue.main)
            .sink { sectionSnapshot in
            
            if let sectionSnapshot{
                
                
                self.dataSource?.apply(sectionSnapshot, to: Section.bodyParts, animatingDifferences: false)
                
                //since the Diffable Datasource contains Strings, which we're populating with the object id for the BodyParts, the collection view isn't reloading when the enabled field is changed. So we need to reload.
                self.collectionView.reloadData()

            }
        }.store(in: &cancellables)

        // Do any additional setup after loading the view.
    }
    
    init(viewModel: BodyPartViewModel){
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    func createLayout() -> UICollectionViewLayout {
        
        let sectionProvider = { (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            
            guard let sectionKind = Section(rawValue: sectionIndex) else { return nil }
            
            
            if sectionKind == .bodyParts {
                
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .fractionalHeight(1.0))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(0.10))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, repeatingSubitem: item, count: 2)
                
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
        
        let bodyPartCellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, String> { [weak self] (cell, indexPath, bodyPart) in
            // Populate the cell with our item description.
            
            guard let self = self else { return }
            
            
            let obj = self.viewModel.object(at: indexPath)
            
            var content = cell.defaultContentConfiguration()
            content.text = obj.part
            cell.contentConfiguration = content
            
            cell.accessories = obj.enabled ? [.checkmark()] : []
        
        }
        
        let miscCellRegistration = UICollectionView.CellRegistration <UICollectionViewListCell, String> { cell, indexPath, item in
            
            var content = cell.defaultContentConfiguration()
            content.text = item
            cell.contentConfiguration = content
            
            cell.accessories = indexPath.item == MiscCells.feedback.rawValue ? [.disclosureIndicator()]: [.detail()]
            
        }
        
        dataSource = UICollectionViewDiffableDataSource<Section, String>(collectionView: collectionView) {
            (collectionView: UICollectionView, indexPath: IndexPath, item: String) -> UICollectionViewCell? in
            
            if indexPath.section == Section.bodyParts.rawValue{
                return collectionView.dequeueConfiguredReusableCell(using: bodyPartCellRegistration, for: indexPath, item: item)
            }
            else{
                return collectionView.dequeueConfiguredReusableCell(using: miscCellRegistration, for: indexPath, item: item)
            }
            
        }

        // initial data
        var snapshot = NSDiffableDataSourceSnapshot<Section, String>()
        snapshot.appendSections([Section.bodyParts, Section.misc])
        dataSource.apply(snapshot, animatingDifferences: false)

        
        
       // var bodyPartsSnapshot = NSDiffableDataSourceSectionSnapshot<String>()
        //zonesSnapshot.append(Site.zones)
        //bodyPartsSnapshot.append(enabledBodyParts.map({ $0.rawValue }))
      //  dataSource.apply(bodyPartsSnapshot, to: Section.bodyParts, animatingDifferences: false)
        
        var sitesSnapshot = NSDiffableDataSourceSectionSnapshot<String>()
        //sitesSnapshot.append(Site.sites)
        //sitesSnapshot.append(User.sites)
        sitesSnapshot.append(MiscCells.allCases.map({ $0.description }))
        dataSource.apply(sitesSnapshot, to: Section.misc, animatingDifferences: false)
        
        
    }
}

extension SettingsViewController: UICollectionViewDelegate{
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let section = indexPath.section
        let index = indexPath.item
        let cell = collectionView.cellForItem(at: indexPath) as! UICollectionViewListCell
        
        collectionView.deselectItem(at: indexPath, animated: true)
        
        if section == Section.bodyParts.rawValue{
            
            let object = viewModel.object(at: indexPath)
            
            //toggle value
            let enabled = object.enabled ? false : true
            
            viewModel.setEnabled(forBodyPart: object, to: enabled)
            
          /*
            
            if cell.accessories.isEmpty{
                
                cell.accessories = [.checkmark()]
                
                if !enabledBodyParts.contains(bodyParts[index]){
                    enabledBodyParts.append(bodyParts[index])
                }
            }
            else{
                cell.accessories = []
                enabledBodyParts.removeAll { value in
                    return value == bodyParts[index]
                }
            }*/
            //applySnapshots()
            
        }
        else{
            
        }
        
    }
    
}
