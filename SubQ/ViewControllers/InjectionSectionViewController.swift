//
//  InjectionSectionViewController.swift
//  SubQ
//
//  Created by Constantine Thalasinos on 5/17/23.
//

import UIKit

class InjectionSectionViewController: UIViewController {
    
    var bodyPart: BodyPart.Location?
    
    var section: Site.InjectionSection?
    
    weak var coordinator: InjectionSectionCoordinator?
    
    var dataSource: UICollectionViewDiffableDataSource<Int, String>! = nil
    var collectionView: UICollectionView! = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBrown
        
        navigationItem.title = "\(bodyPart!.rawValue) + \(section!.rawValue)"
    
        configureHierarchy()
        configureDataSource()
    }
    


}

extension InjectionSectionViewController{
    func createLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                              heightDimension: .fractionalHeight(0.5))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

       
       /* let spacing = CGFloat(10)
        group.interItemSpacing = .fixed(spacing)*/
        
        let innerGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .fractionalHeight(1.0))
        
        let innerGroup = NSCollectionLayoutGroup.vertical(layoutSize: innerGroupSize, repeatingSubitem: item, count: 2)

        let outerGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                    heightDimension: .fractionalHeight(0.5))
        
        let outerGroup = NSCollectionLayoutGroup.horizontal(layoutSize: outerGroupSize, repeatingSubitem: innerGroup, count: 2)

        let section = NSCollectionLayoutSection(group: outerGroup)
        
        /*section.interGroupSpacing = spacing
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10)
         */
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }
}

extension InjectionSectionViewController{
    func configureHierarchy() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = .systemBackground
        view.addSubview(collectionView)
    }
    func configureDataSource() {
        let cellRegistration = UICollectionView.CellRegistration<BodyPartCollectionViewCell, String> { (cell, indexPath, item) in
            // Populate the cell with our item description.
            cell.label.text = "\(item)"
           /* cell.contentView.backgroundColor = .cornflowerBlue
            cell.layer.borderColor = UIColor.black.cgColor
            cell.layer.borderWidth = 1*/
            cell.label.textAlignment = .center
            cell.label.font = UIFont.preferredFont(forTextStyle: .title1)
        }
        
        dataSource = UICollectionViewDiffableDataSource<Int, String>(collectionView: collectionView) {
            (collectionView: UICollectionView, indexPath: IndexPath, item: String) -> UICollectionViewCell? in
            // Return the cell.
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: item)
        }

        // initial data
        var snapshot = NSDiffableDataSourceSnapshot<Int, String>()
        snapshot.appendSections([0])
        snapshot.appendItems(Site.InjectionSection.allCases.map({ $0.rawValue }))
        dataSource.apply(snapshot, animatingDifferences: false)
    }
}
