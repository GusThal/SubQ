//
//  InjectionSectionViewController.swift
//  SubQ
//
//  Created by Constantine Thalasinos on 5/17/23.
//

import UIKit
import CoreData
import Combine

class SiteViewController: UIViewController, Coordinated {
    
    struct ElementKind{
        static let globalHeader = "global-header-element-kind"
    }
    
    
    weak var coordinator: Coordinator?
    
    weak var siteCoordinator: SiteCoordinator?
    
    var dataSource: UICollectionViewDiffableDataSource<Int, NSManagedObjectID>! = nil
    var collectionView: UICollectionView! = nil
    
    var cancellables = Set<AnyCancellable>()
    
    let viewModel: SiteViewModel

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        view.backgroundColor = .systemBrown
        
        navigationItem.title = "\(viewModel.section.quadrantVal.description) \(viewModel.section.bodyPart!.part!)"
    
        configureHierarchy()
        configureDataSource()
        
        viewModel.snapshot
          .sink(receiveValue: { [weak self] snapshot in
            if let snapshot = snapshot {
                print("Number of Snapshot sections in publisher \(snapshot.numberOfItems)")
                
              self?.dataSource.apply(snapshot, animatingDifferences: false)
               // self?.collectionView.reloadData()
            }
          })
          .store(in: &cancellables)
    }
    
    init(viewModel: SiteViewModel){
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    


}

extension SiteViewController{
    func createLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                              heightDimension: .fractionalHeight(0.5))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        item.contentInsets = NSDirectionalEdgeInsets(top: 3, leading: 3, bottom: 3, trailing: 3)
       
       /* let spacing = CGFloat(10)
        group.interItemSpacing = .fixed(spacing)*/
        
        let innerGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .fractionalHeight(1.0))
        
        let innerGroup = NSCollectionLayoutGroup.vertical(layoutSize: innerGroupSize, repeatingSubitem: item, count: 2)

        let outerGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                    heightDimension: .fractionalHeight(0.6))
        
        let outerGroup = NSCollectionLayoutGroup.horizontal(layoutSize: outerGroupSize, repeatingSubitem: innerGroup, count: 2)

        let section = NSCollectionLayoutSection(group: outerGroup)
        
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 3, bottom: 3, trailing: 5)
        
        /*section.interGroupSpacing = spacing
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10)
         */
        
        let globalHeaderSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                      heightDimension: .absolute(44))
        
        let globalHeader = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: globalHeaderSize, elementKind: ElementKind.globalHeader, alignment: .top)
        
        globalHeader.pinToVisibleBounds = true
        globalHeader.zIndex = 2
        
        let config = UICollectionViewCompositionalLayoutConfiguration()
        
        config.boundarySupplementaryItems = [globalHeader]
        
        let layout = UICollectionViewCompositionalLayout(section: section)
        layout.configuration = config
        
        return layout
    }
}

extension SiteViewController{
    func configureHierarchy() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = .systemBackground
        view.addSubview(collectionView)
    }
    func configureDataSource() {
        let cellRegistration = UICollectionView.CellRegistration<SiteCollectionViewCell, NSManagedObjectID> { (cell, indexPath, item) in
            
            let site = self.viewModel.object(at: indexPath)
            // Populate the cell with our item description.
            cell.site = site
            cell.contentView.layer.cornerRadius = 5
           // cell.label.text = "\(site.subQuadrantVal) + \(site.lastInjected)"
           /* cell.contentView.backgroundColor = .cornflowerBlue
            cell.layer.borderColor = UIColor.black.cgColor
            cell.layer.borderWidth = 1*/
           // cell.label.textAlignment = .center
            //cell.label.font = UIFont.preferredFont(forTextStyle: .body)
        }
        
        let globalHeaderRegistration = UICollectionView.SupplementaryRegistration<OrientationCollectionHeader>(elementKind: ElementKind.globalHeader) { supplementaryView, elementKind, indexPath in
            
        }
        
        dataSource = UICollectionViewDiffableDataSource<Int, NSManagedObjectID>(collectionView: collectionView) {
            (collectionView: UICollectionView, indexPath: IndexPath, item: NSManagedObjectID) -> UICollectionViewCell? in
            // Return the cell.
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: item)
        }
        
        dataSource.supplementaryViewProvider = { (view, kind, index) in
            return self.collectionView.dequeueConfiguredReusableSupplementary(using: globalHeaderRegistration, for: index)
        }

        // initial data
        var snapshot = NSDiffableDataSourceSnapshot<Int, NSManagedObjectID>()
        //snapshot.appendSections([0])
        //snapshot.appendItems(Quadrant.allCases.map({ $0.description }))
        
        
        dataSource.apply(snapshot, animatingDifferences: false)
    }
}
