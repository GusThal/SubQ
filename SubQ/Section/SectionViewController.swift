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
            
            item.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)

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
            
          
            
           // section.contentInsets = NSDirectionalEdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20)
            return section
        }
        let config = UICollectionViewCompositionalLayoutConfiguration()
        layout.configuration = config
        return layout
    }
}

extension SectionViewController {
    func configureHierarchy() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        //collectionView.backgroundColor = .systemBackground
        view.addSubview(collectionView)
        collectionView.delegate = self
    }
    func configureDataSource() {
        
        let cellRegistration = UICollectionView.CellRegistration<SectionCollectionViewCell, NSManagedObjectID> { (cell, indexPath, item) in
            
            // Populate the cell with our item description.
            //cell.bodyPart = self.enabledBodyParts[indexPath.section]
            
           /* if let match = item.prefixMatch(of: /\w+\s\w+/){
                cell.section = Quadrant.init(rawValue: String(match.0))
            }*/
            
            let sectionObject = self.viewModel.object(at: indexPath)
            
            cell.section = sectionObject
            
            //cell.label.text = "\(sectionObject.bodyPart!.part) + \(sectionObject.quadrantVal.description)"
            //cell.contentView.backgroundColor = .systemGreen
           /* cell.contentView.layer.borderColor = UIColor.black.cgColor
            cell.contentView.layer.borderWidth = 1
            cell.contentView.layer.cornerRadius = SectionLayoutKind(rawValue: indexPath.section)! == .grid5 ? 8 : 0*/
            //cell.label.textAlignment = .center
        }
        
        let headerRegistration = UICollectionView.SupplementaryRegistration
        <TextSupplementaryView>(elementKind: ElementKind.sectionHeader) {
            (supplementaryView, string, indexPath) in
            
            let bodyPart = self.viewModel.bodyPart(for: indexPath)
            
            supplementaryView.label.text = "\(bodyPart.part!)"
            
           /* supplementaryView.backgroundColor = .lightGray
            supplementaryView.layer.borderColor = UIColor.black.cgColor
            supplementaryView.layer.borderWidth = 1.0*/
        }

        
        dataSource = UICollectionViewDiffableDataSource<Int, NSManagedObjectID>(collectionView: collectionView) {
            (collectionView: UICollectionView, indexPath: IndexPath, item: NSManagedObjectID) -> UICollectionViewCell? in
            // Return the cell.
            
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: item)
        }
        
        dataSource.supplementaryViewProvider = { (view, kind, index) in
            return self.collectionView.dequeueConfiguredReusableSupplementary(using: headerRegistration, for: index)
        }

        // initial data

        var snapshot = NSDiffableDataSourceSnapshot<Int, NSManagedObjectID>()
        
     /*   for i in 0...3{
            snapshot.appendSections([i])
            
            #warning("without the i, diffable datasource thinks these are duplicates. may not be an issue with")
            let items = Quadrant.allCases.map({"\($0.rawValue) + \(i)" })
            
            snapshot.appendItems(items)
        }*/
        
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

