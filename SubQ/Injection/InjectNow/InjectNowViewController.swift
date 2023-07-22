//
//  InjectNowViewController.swift
//  SubQ
//
//  Created by Constantine Thalasinos on 7/3/23.
//

import UIKit
import SnapKit
import CoreData
import Combine

class InjectNowViewController: UIViewController {
    
    enum SupplementaryViewKind: String{
        case header = "header", footer = "footer"
    }
        
    let viewModel: InjectNowViewModel
    
    let injectionDataStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.alignment = .leading
        
        return stack
    }()
        
    let injectionNameLabel = UILabel()
    
    let scheduledLabel = UILabel()
    
    let lastInjectedLabel = UILabel()
    
    var siteDataSource: UICollectionViewDiffableDataSource<Int, NSManagedObjectID>!
    
    var siteCollectionView: UICollectionView! = nil
    
    var cancellables = Set<AnyCancellable>()
    
    lazy var selectedSiteLabel = UILabel()
    
    var selectedSite: Site?
    
    #warning("probably will have to be conformed to Coordinated protocol")
    weak var coordinator: InjectNowCoordinator?
    
    var selectInjectionButton: UIButton?
    
    lazy var selectionInjectionViewController = SelectInjectionViewController(viewModel: viewModel)
    

    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        setUpNavBar()
        
        if !viewModel.isFromNotification{
            setUpSelectionButton()
        }
        
        view.backgroundColor = .brown
        //view.translatesAutoresizingMaskIntoConstraints = false
        
        injectionNameLabel.text = "injection Name \(viewModel.injection?.name)"
        scheduledLabel.text = "Scheduled"
        lastInjectedLabel.text = "Last Injected"
        
        injectionDataStackView.addArrangedSubview(injectionNameLabel)
        injectionDataStackView.addArrangedSubview(scheduledLabel)
        injectionDataStackView.addArrangedSubview(lastInjectedLabel)
        
        view.addSubview(injectionDataStackView)
        
        injectionDataStackView.snp.makeConstraints { make in
            make.leadingMargin.rightMargin.equalToSuperview()
            make.topMargin.equalToSuperview()
        }
        
        
        configureHierarchy()
        configureDataSource()
        
        viewModel.siteSnapshot
          .sink(receiveValue: { [weak self] snapshot in
            if let snapshot = snapshot {
                print("Number of items in snapshot \(snapshot.numberOfItems)")
                
              self?.siteDataSource.apply(snapshot, animatingDifferences: false)
            }
          })
          .store(in: &cancellables)
        
        if !viewModel.isFromNotification{
            Publishers.Zip(viewModel.$selectedInjection, viewModel.$selectedQueueObject).sink { injection, queue in
               
                if let injection{
                    self.injectionNameLabel.text = injection.name
                }
                else if let queue{
                    self.injectionNameLabel.text = queue.injection!.name
                }
                
            }.store(in: &cancellables)
            
        }
        
        //view.addSubview(siteCollectionView)

        // Do any additional setup after loading the view.
    }
    
    init(viewModel: InjectNowViewModel) {
        self.viewModel = viewModel
        
                
        print(viewModel.injection?.objectID)
        
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUpNavBar(){
        if viewModel.isFromNotification{
            let button = UIBarButtonItem(title: "Skip", style: .done, target: self, action: nil)
            button.tintColor = .systemRed
            navigationItem.leftBarButtonItem = button
        }
        else{
            let action = UIAction { _ in
                self.coordinator!.dismissViewController()
            }
            navigationItem.leftBarButtonItem = UIBarButtonItem(systemItem: .close, primaryAction: action)
            
        }
        
        
        var injectButtonConfig = UIButton.Configuration.filled()
        injectButtonConfig.buttonSize = .medium
        injectButtonConfig.cornerStyle = .capsule
        injectButtonConfig.title = "Inject"
        injectButtonConfig.baseBackgroundColor = .blue
        
        let injectAction = UIAction { _ in
            self.viewModel.injectionPerformed(site: self.selectedSite!)
            self.coordinator!.injectPressed()
            
        }
        
        let injectButton = UIButton(configuration: injectButtonConfig, primaryAction: injectAction)
        
        //let injectButton = UIBarButtonItem(customView: button)
        
        var rightButtonArray = [UIBarButtonItem(customView: injectButton)]
        
        if viewModel.isFromNotification{
            
            var snoozeButtonConfig = UIButton.Configuration.filled()
            snoozeButtonConfig.buttonSize = .medium
            snoozeButtonConfig.cornerStyle = .capsule
            snoozeButtonConfig.title = "Snooze"
            snoozeButtonConfig.baseBackgroundColor = .orange
            
            let snoozeButton = UIButton(configuration: snoozeButtonConfig)
            
            rightButtonArray.append(UIBarButtonItem(customView: snoozeButton))
            
        }
        
        navigationItem.rightBarButtonItems = rightButtonArray
        
           // navigationItem.rightBarButtonItems = [UIBarButtonItem(customView: injectButton), UIBarButtonItem(customView: snoozeButton)]
            
    
    
        
        //navigationItem.rightBarButtonItem = injectButton
        
        navigationItem.title = viewModel.isFromNotification ?"Injection Time!" : "Inject Now"
    }
    
    #warning("might be unused")
    @objc func injectPressed(_ sender: Any){
        
    }
    
    func setUpSelectionButton(){
        
        let action = UIAction { _ in
            
            self.coordinator!.showSelectInjectionViewController()
        }
        
        var config = UIButton.Configuration.bordered()
        config.imagePlacement = .trailing
        config.image = UIImage(systemName: "chevron.down")
        
        config.title = "Select Injection"
        config.baseForegroundColor = .white
        config.background.strokeColor = .white
        
        let button = UIButton(primaryAction: action)
        
        button.configuration = config
        
        button.translatesAutoresizingMaskIntoConstraints = false
        
        selectInjectionButton = button
        
        injectionDataStackView.addArrangedSubview(selectInjectionButton!)
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension InjectNowViewController{
    
    func createLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5),
                                              heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

       
       /* let spacing = CGFloat(10)
        group.interItemSpacing = .fixed(spacing)*/
        
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(0.5))
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, repeatingSubitem: item, count: 2)


        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .groupPaging
        
        let headerFooterSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                     heightDimension: .estimated(44))
        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerFooterSize,
            elementKind: SupplementaryViewKind.header.rawValue, alignment: .top)
        let sectionFooter = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerFooterSize,
            elementKind: SupplementaryViewKind.footer.rawValue, alignment: .bottom)
        section.boundarySupplementaryItems = [sectionHeader, sectionFooter]

        
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }
    
}

extension InjectNowViewController{
    func configureHierarchy() {
        siteCollectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
       // siteCollectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        siteCollectionView.translatesAutoresizingMaskIntoConstraints = false
        siteCollectionView.backgroundColor = .systemBackground
        siteCollectionView.delegate = self
        view.addSubview(siteCollectionView)
        
        NSLayoutConstraint.activate([
            siteCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            siteCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            siteCollectionView.topAnchor.constraint(equalTo: injectionDataStackView.bottomAnchor),
            siteCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    func configureDataSource() {
        let cellRegistration = UICollectionView.CellRegistration<SiteCollectionViewCell, NSManagedObjectID> { (cell, indexPath, item) in
            
            let site = self.viewModel.getSite(forIndexPath: indexPath)
            // Populate the cell with our item description.
            cell.site = site
            cell.label.text = "\(site.subQuadrantVal) + \(site.lastInjected)"
           /* cell.contentView.backgroundColor = .cornflowerBlue
            cell.layer.borderColor = UIColor.black.cgColor
            cell.layer.borderWidth = 1*/
            cell.label.textAlignment = .center
            cell.label.font = UIFont.preferredFont(forTextStyle: .body)
        }
        
        let headerRegistration = UICollectionView.SupplementaryRegistration
        <TextSupplementaryView>(elementKind: SupplementaryViewKind.header.rawValue) {
            (supplementaryView, string, indexPath) in
            supplementaryView.label.text = "Injection Sites"
           // supplementaryView.backgroundColor = .lightGray
            //supplementaryView.layer.borderColor = UIColor.black.cgColor
            //supplementaryView.layer.borderWidth = 1.0
        }
        
        let footerRegistration = UICollectionView.SupplementaryRegistration
        <TextSupplementaryView>(elementKind: SupplementaryViewKind.footer.rawValue) {
            (supplementaryView, string, indexPath) in
            supplementaryView.label.text = "Selected Site:"
            supplementaryView.supplementaryViewKind = .footer
            supplementaryView.secondaryLabel.text = "None Selected"
            self.selectedSiteLabel = supplementaryView.secondaryLabel
           // supplementaryView.backgroundColor = .lightGray
           // supplementaryView.layer.borderColor = UIColor.black.cgColor
           // supplementaryView.layer.borderWidth = 1.0
        }
        
        siteDataSource = UICollectionViewDiffableDataSource<Int, NSManagedObjectID>(collectionView: siteCollectionView) {
            (collectionView: UICollectionView, indexPath: IndexPath, item: NSManagedObjectID) -> UICollectionViewCell? in
            // Return the cell.
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: item)
        }
        
        siteDataSource.supplementaryViewProvider = { (view, kind, index) in
            return self.siteCollectionView.dequeueConfiguredReusableSupplementary(
                using: kind == SupplementaryViewKind.header.rawValue ? headerRegistration : footerRegistration, for: index)
        }

        // initial data
        var snapshot = NSDiffableDataSourceSnapshot<Int, NSManagedObjectID>()
        //snapshot.appendSections([0])
        //snapshot.appendItems(Quadrant.allCases.map({ $0.description }))
        
        
        siteDataSource.apply(snapshot, animatingDifferences: false)
    }
}

extension InjectNowViewController: UICollectionViewDelegate{
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let site = viewModel.getSite(forIndexPath: indexPath)
        
        selectedSiteLabel.text = "\(site.section!.bodyPart!.part) + \(site.section) + \(site.subQuadrant)"
        
        selectedSite = site
        
        
    }
    
}
