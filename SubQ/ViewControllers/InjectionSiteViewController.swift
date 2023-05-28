//
//  InjectionSiteViewController.swift
//  SubQ
//
//  Created by Constantine Thalasinos on 5/4/23.
//

import UIKit

class InjectionSiteViewController: UIViewController {
    
    struct ElementKind{
        static let sectionHeader = "section-header-element-kind"
        static let layoutFooter = "layout-footer-element-kind"
    }
    
    let enabledBodyParts: [BodyPart.Location] = [.upperArm, .abdomen, .thigh, .buttocks]
    
    var dataSource: UICollectionViewDiffableDataSource<Int, String>! = nil
    var collectionView: UICollectionView! = nil
    
    weak var coordinator: InjectionSiteCoordinator?
    
    let footerText = "To customize which body parts are displayed, please head to the Settings tab on the bottom bar."

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .red
        
        configureHierarchy()
        configureDataSource()
        
        

        // Do any additional setup after loading the view.
    }

}

extension InjectionSiteViewController{
    func createLayout() -> UICollectionViewLayout {
        
        let layoutFooterSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(80))
        
        let layoutFooter = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: layoutFooterSize, elementKind: ElementKind.layoutFooter, alignment: .bottom)
        
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
        config.boundarySupplementaryItems = [layoutFooter]
        layout.configuration = config
        return layout
    }
}

extension InjectionSiteViewController {
    func configureHierarchy() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        //collectionView.backgroundColor = .systemBackground
        view.addSubview(collectionView)
        collectionView.delegate = self
    }
    func configureDataSource() {
        
        let cellRegistration = UICollectionView.CellRegistration<BodyPartCollectionViewCell, String> { (cell, indexPath, item) in
            
            // Populate the cell with our item description.
            cell.bodyPart = self.enabledBodyParts[indexPath.section]
            
            if let match = item.prefixMatch(of: /\w+\s\w+/){
                cell.section = Site.InjectionSection.init(rawValue: String(match.0))
            }
            
            cell.label.text = item
            cell.contentView.backgroundColor = .systemGreen
           /* cell.contentView.layer.borderColor = UIColor.black.cgColor
            cell.contentView.layer.borderWidth = 1
            cell.contentView.layer.cornerRadius = SectionLayoutKind(rawValue: indexPath.section)! == .grid5 ? 8 : 0*/
            cell.label.textAlignment = .center
        }
        
        let headerRegistration = UICollectionView.SupplementaryRegistration
        <TextSupplementaryView>(elementKind: ElementKind.sectionHeader) {
            (supplementaryView, string, indexPath) in
            supplementaryView.label.text = "\(self.enabledBodyParts[indexPath.section].rawValue)"
           /* supplementaryView.backgroundColor = .lightGray
            supplementaryView.layer.borderColor = UIColor.black.cgColor
            supplementaryView.layer.borderWidth = 1.0*/
        }
        
        let layoutFooterRegistration = UICollectionView.SupplementaryRegistration<TextSupplementaryView>(elementKind: ElementKind.layoutFooter) { supplementaryView, elementKind, indexPath in
            
            supplementaryView.label.text = self.footerText
        }
        
        dataSource = UICollectionViewDiffableDataSource<Int, String>(collectionView: collectionView) {
            (collectionView: UICollectionView, indexPath: IndexPath, item: String) -> UICollectionViewCell? in
            // Return the cell.
            
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: item)
        }
        
        dataSource.supplementaryViewProvider = { (view, kind, index) in
            
            
            //footer for the layout as a whole
            if index.count == 1{
                return self.collectionView.dequeueConfiguredReusableSupplementary(
                    using: layoutFooterRegistration, for: index)
            }
            else{
                return self.collectionView.dequeueConfiguredReusableSupplementary(
                    using: headerRegistration, for: index)
            }
            
        }

        // initial data

        var snapshot = NSDiffableDataSourceSnapshot<Int, String>()
        
        for i in 0...3{
            snapshot.appendSections([i])
            
            #warning("without the i, diffable datasource thinks these are duplicates. may not be an issue with")
            let items = Site.InjectionSection.allCases.map({"\($0.rawValue) + \(i)" })
            
            snapshot.appendItems(items)
        }
        
        dataSource.apply(snapshot, animatingDifferences: false)
    }
}

extension InjectionSiteViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        let cell = collectionView.cellForItem(at: indexPath) as! BodyPartCollectionViewCell
        
        coordinator?.showInjectionBodyPart(bodyPart: cell.bodyPart!, section: cell.section!)
    }
}

