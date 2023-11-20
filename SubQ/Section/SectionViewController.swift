//
//  InjectionSiteViewController.swift
//  SubQ
//
//  Created by Constantine Thalasinos on 5/4/23.
//

import UIKit
import Combine
import CoreData

class SectionViewController: UIViewController, Coordinated {
    
    struct ElementKind{
        static let sectionHeader = "section-header-element-kind"
        static let globalHeader = "global-header-element-kind"
    }
    
    let enabledBodyParts: [BodyPart.Location] = [.upperArm, .abdomen, .thigh, .buttocks]
    
    var dataSource: UICollectionViewDiffableDataSource<Int, NSManagedObjectID>! = nil
    var collectionView: UICollectionView! = nil
    
    let viewModel: SectionViewModel
    var cancellables = Set<AnyCancellable>()
    
    weak var coordinator: Coordinator?
    weak var sectionCoordinator: SectionCoordinator?
    
    lazy var customizeButton: UIButton = {
        var buttonConfig = UIButton.Configuration.plain()
        buttonConfig.title = "Customize"
        buttonConfig.baseForegroundColor = InterfaceDefaults.primaryColor
        
        let action = UIAction { _ in
            
            let controller = self.sectionCoordinator!.navigationController.tabBarController
            controller!.selectedIndex = 4
        }
        
        return UIButton(configuration: buttonConfig, primaryAction: action)
        
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .red
                
        configureHierarchy()
        configureDataSource()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: customizeButton)
        
        viewModel.snapshot
          .sink(receiveValue: { [weak self] snapshot in
            if let snapshot = snapshot {
                print("Number of Snapshot sections in publisher \(snapshot.numberOfSections)")
                
              self?.dataSource.apply(snapshot, animatingDifferences: false)
               self?.collectionView.reloadData()
            }
          })
          .store(in: &cancellables)
        
        

        // Do any additional setup after loading the view.
    }
    
    init(viewModel: SectionViewModel){
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension SectionViewController{
    func createLayout() -> UICollectionViewLayout {
        
        let layout = UICollectionViewCompositionalLayout { (sectionIndex: Int,
            layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in

            
            let bodyPart = self.enabledBodyParts[sectionIndex]
            
            let sectionHeaderSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                         heightDimension: .estimated(44))
            
            
            
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                  heightDimension: .fractionalHeight(0.5))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            
            item.contentInsets = NSDirectionalEdgeInsets(top: 3, leading: 3, bottom: 3, trailing: 3)


            let innerGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .fractionalHeight(1.0))
            
            let innerGroup = NSCollectionLayoutGroup.vertical(layoutSize: innerGroupSize, repeatingSubitem: item, count: 2)

            let outerGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                        heightDimension: .fractionalHeight(0.5))
            
            let outerGroup = NSCollectionLayoutGroup.horizontal(layoutSize: outerGroupSize, repeatingSubitem: innerGroup, count: 2)

            let section = NSCollectionLayoutSection(group: outerGroup)
            
            let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: sectionHeaderSize,
                elementKind: ElementKind.sectionHeader, alignment: .top)
            
            section.boundarySupplementaryItems = [sectionHeader]
            
            section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 3, bottom: 3, trailing: 5)

            return section
        }
        
        let globalHeaderSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                      heightDimension: .absolute(44))
        
        let globalHeader = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: globalHeaderSize, elementKind: ElementKind.globalHeader, alignment: .top)
        
        globalHeader.pinToVisibleBounds = true
        globalHeader.zIndex = 2
        
        let config = UICollectionViewCompositionalLayoutConfiguration()
        
        config.boundarySupplementaryItems = [globalHeader]
        
        
        layout.configuration = config
        return layout
    }
}

extension SectionViewController {
    func configureHierarchy() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        view.addSubview(collectionView)
        collectionView.delegate = self
    }
    func configureDataSource() {
        
        let cellRegistration = UICollectionView.CellRegistration<SectionCollectionViewCell, NSManagedObjectID> { (cell, indexPath, item) in
            
            // Populate the cell with our item description.
            
            let sectionObject = self.viewModel.object(at: indexPath)
            
            cell.section = sectionObject
            
            cell.contentView.layer.cornerRadius = 5
        }
        
        let sectionHeaderRegistration = UICollectionView.SupplementaryRegistration
        <TextSupplementaryView>(elementKind: ElementKind.sectionHeader) {
            (supplementaryView, string, indexPath) in
            
            let bodyPart = self.viewModel.bodyPart(for: indexPath)
            
            supplementaryView.label.text = "\(bodyPart.part!)"
        }
        
        let globalHeaderRegistration = UICollectionView.SupplementaryRegistration<OrientationCollectionHeader>(elementKind: ElementKind.globalHeader) { supplementaryView, elementKind, indexPath in
            
        }

        
        dataSource = UICollectionViewDiffableDataSource<Int, NSManagedObjectID>(collectionView: collectionView) {
            (collectionView: UICollectionView, indexPath: IndexPath, item: NSManagedObjectID) -> UICollectionViewCell? in
            // Return the cell.
            
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: item)
        }
        
        dataSource.supplementaryViewProvider = { (view, kind, index) in
            if kind == ElementKind.globalHeader {
                return self.collectionView.dequeueConfiguredReusableSupplementary(using: globalHeaderRegistration, for: index)
            } else {
                return self.collectionView.dequeueConfiguredReusableSupplementary(using: sectionHeaderRegistration, for: index)
            }
            
        }

        // initial data

        var snapshot = NSDiffableDataSourceSnapshot<Int, NSManagedObjectID>()
        
        dataSource.apply(snapshot, animatingDifferences: false)
    }
}

extension SectionViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        let cell = collectionView.cellForItem(at: indexPath) as! SectionCollectionViewCell
        
        sectionCoordinator?.showSites(forSection: cell.section!)
    }
}

