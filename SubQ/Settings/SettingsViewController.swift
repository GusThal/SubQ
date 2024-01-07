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
    
    struct ElementKind{
        static let sectionHeader = "section-header-element-kind"
    }
    
    var dataSource: UICollectionViewDiffableDataSource<Section, String>!
    
    var collectionView: UICollectionView! = nil
    
    weak var coordinator: Coordinator?
    weak var settingsCoordinator: SettingsCoordinator?
    
    let viewModel: BodyPartViewModel
    
    var cancellables = Set<AnyCancellable>()
    
    enum Section: Int{
        case bodyParts, misc, legal
        var description: String {
            switch self {
            case .bodyParts: return "Body Parts"
            case .legal: return "Legal"
            case .misc: return "Misc"
            }
        }
    }
    
    enum LegalCells: Int, CaseIterable{
        case terms, medicalDisclaimer, privacy
        var description: String {
            switch self{
            case .terms: return "Terms of Service"
            case .medicalDisclaimer: return "Medical Disclaimer"
            case .privacy: return "Privacy Policy"
            
            }
        }
    }
    
    enum MiscCells: Int, CaseIterable {
        case lock
        var description: String {
            switch self{
            case .lock: return "Screen Lock"
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
                item.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)
                
                let sectionHeaderSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                             heightDimension: .estimated(44))
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(0.10))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, repeatingSubitem: item, count: 2)
                
                let section = NSCollectionLayoutSection(group: group)
                section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 5, bottom: 5, trailing: 5)
                
                let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
                    layoutSize: sectionHeaderSize,
                    elementKind: ElementKind.sectionHeader, alignment: .top)
                
                section.boundarySupplementaryItems = [sectionHeader]
                
                return section
                
            } else{
                
                var configuration = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
                configuration.footerMode = .supplementary
    
                let section = NSCollectionLayoutSection.list(using: configuration, layoutEnvironment: layoutEnvironment)
                
                section.contentInsets = NSDirectionalEdgeInsets(top: 15, leading: 10, bottom: 10, trailing: 10)
           
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
        
        let bodyPartCellRegistration = UICollectionView.CellRegistration<CheckableBodyPartCollectionViewCell, String> { [weak self] (cell, indexPath, bodyPart) in
            // Populate the cell with our item description.
            
            guard let self = self else { return }
            
            cell.bodyPartButton.addAction(cell.buttonAction, for: .primaryActionTriggered)
            
            cell.contentView.layer.cornerRadius = 5
            
            
            let obj = self.viewModel.object(at: indexPath)
            cell.bodyPart = obj
            cell.viewModel = viewModel
            
            if obj.enabled {
                cell.isButtonSelected = true
            } else {
                cell.isButtonSelected = false
            }
        
        }
        
        let legalCellRegistration = UICollectionView.CellRegistration <UICollectionViewListCell, String> { cell, indexPath, item in
            
            var content = cell.defaultContentConfiguration()
            content.text = item
            content.textProperties.color = .systemBlue
            
            cell.contentConfiguration = content
            
            
            cell.accessories = [.disclosureIndicator()]
            
        }
        
        let miscCellRegistration = UICollectionView.CellRegistration <UICollectionViewListCell, String> { cell, indexPath, item in
            
            var content = cell.defaultContentConfiguration()
            content.text = item
            content.textProperties.color = .label
            
            cell.contentConfiguration = content
            
            
            cell.accessories = [.disclosureIndicator()]
            
        }
        
        
        let headerRegistration = UICollectionView.SupplementaryRegistration
        <TextSupplementaryView>(elementKind: ElementKind.sectionHeader) {
            (supplementaryView, string, indexPath) in
            
            supplementaryView.label.text = "Body Parts"

        }
        
        let footerRegistration = UICollectionView.SupplementaryRegistration
        <UICollectionViewListCell>(elementKind: UICollectionView.elementKindSectionFooter) {
            [unowned self] (footerView, elementKind, indexPath) in
            
            var configuration = footerView.defaultContentConfiguration()
            
            if indexPath.section == Section.legal.rawValue {
                var attributedString = AttributedString(stringLiteral: InterfaceDefaults.disclaimerString)
                let range = attributedString.range(of: InterfaceDefaults.disclaimerBoldSubstring)!
                attributedString[range].font = UIFont.boldSystemFont(ofSize: 13)
                
                configuration.attributedText = NSAttributedString(attributedString)
            } else {
                configuration.text = "Require Face ID or device passcode (if Face ID is disabled) to unlock SubQ."
            }
            
           
            //configuration.text = InterfaceDefaults.disclaimerString
            footerView.contentConfiguration = configuration
        }
        
        dataSource = UICollectionViewDiffableDataSource<Section, String>(collectionView: collectionView) {
            (collectionView: UICollectionView, indexPath: IndexPath, item: String) -> UICollectionViewCell? in
            
            if indexPath.section == Section.bodyParts.rawValue{
                return collectionView.dequeueConfiguredReusableCell(using: bodyPartCellRegistration, for: indexPath, item: item)
            } else if indexPath.section == Section.legal.rawValue{
                return collectionView.dequeueConfiguredReusableCell(using: legalCellRegistration, for: indexPath, item: item)
            } else {
                return collectionView.dequeueConfiguredReusableCell(using: miscCellRegistration, for: indexPath, item: item)
            }
            
        }
        
        dataSource.supplementaryViewProvider = { (view, kind, index) in
            if index.section == Section.bodyParts.rawValue {
                return self.collectionView.dequeueConfiguredReusableSupplementary(using: headerRegistration, for: index)
            } else {
                return self.collectionView.dequeueConfiguredReusableSupplementary(using: footerRegistration, for: index)
            }
        }

        // initial data
        var snapshot = NSDiffableDataSourceSnapshot<Section, String>()
        snapshot.appendSections([Section.bodyParts, Section.misc, Section.legal])
        dataSource.apply(snapshot, animatingDifferences: false)
        
        var miscSnapshot = NSDiffableDataSourceSectionSnapshot<String>()
        miscSnapshot.append(MiscCells.allCases.map({ $0.description }))
        
        dataSource.apply(miscSnapshot, to: Section.misc, animatingDifferences: false)
        
        var legalSnapshot = NSDiffableDataSourceSectionSnapshot<String>()
        legalSnapshot.append(LegalCells.allCases.map({ $0.description }))
        
        dataSource.apply(legalSnapshot, to: Section.legal, animatingDifferences: false)
        
       
        
        
    }
}

extension SettingsViewController: UICollectionViewDelegate{
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let section = indexPath.section
        let index = indexPath.item
        let cell = collectionView.cellForItem(at: indexPath) as! UICollectionViewListCell
        
        collectionView.deselectItem(at: indexPath, animated: true)
        
        if section == Section.legal.rawValue {
            
            if index == LegalCells.privacy.rawValue {
                UIApplication.shared.open(InterfaceDefaults.privacyPolicyURL)
            } else if index == LegalCells.terms.rawValue {
                UIApplication.shared.open(InterfaceDefaults.termsURL)
            } else if index == LegalCells.medicalDisclaimer.rawValue {
                UIApplication.shared.open(InterfaceDefaults.medicalDisclaimerURL)
            }
            
        } else if section == Section.misc.rawValue {
            if index == MiscCells.lock.rawValue {
                settingsCoordinator?.showScreenLockSettingsController()
            }
        }
        
    }
    
}

