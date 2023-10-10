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

class InjectNowViewController: UIViewController, Coordinated {
    
    enum SupplementaryViewKind: String{
        case header = "header", footer = "footer"
    }
        
    let viewModel: InjectNowViewModel
    
    lazy var injectionDataView: InjectNowDataView = {
        let view = InjectNowDataView(viewModel: viewModel, coordinator: injectNowCoordinator!)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    
    lazy var injectButton: UIButton = {
        
        var buttonConfig = UIButton.Configuration.filled()
        buttonConfig.buttonSize = .medium
        buttonConfig.cornerStyle = .capsule
        buttonConfig.title = "Inject"
        buttonConfig.baseBackgroundColor = InterfaceDefaults.primaryColor
        
        let action = UIAction { _ in
            
            var injection: Injection!
            
            if self.viewModel.isFromNotification {
                injection = self.viewModel.injectionFromNotification
                
            } else {
                if let obj = self.viewModel.selectedQueueObject {
                   injection = obj.injection!
                } else {
                    injection = self.viewModel.selectedInjection!
                }
            }
            
            self.injectNowCoordinator!.injectPressed(injection: injection)
            self.viewModel.injectionPerformed(site: self.viewModel.selectedSite!)
            
        }
        return UIButton(configuration: buttonConfig, primaryAction: action)
    }()
    
    lazy var skipButton: UIButton = {
        var buttonConfig = UIButton.Configuration.plain()
        buttonConfig.title = "Skip"
        buttonConfig.baseForegroundColor = .red
        
        let action = UIAction { _ in
            self.viewModel.skipInjection()
            self.injectNowCoordinator?.skipPressed(injection: self.viewModel.injectionFromNotification!)
        }
        
        return UIButton(configuration: buttonConfig, primaryAction: action)
        
    }()
    
    lazy var snoozeButton: UIButton = {
        var buttonConfig = UIButton.Configuration.plain()
        buttonConfig.title = "Snooze"
        buttonConfig.baseForegroundColor = .orange
        
        let action = UIAction { _ in
            self.snoozeButtonPressed()
        }
        
        return UIButton(configuration: buttonConfig, primaryAction: action)
        
    }()
    
 
    
    var siteDataSource: UICollectionViewDiffableDataSource<Int, NSManagedObjectID>!
    
    var siteCollectionView: UICollectionView! = nil
    
    var cancellables = Set<AnyCancellable>()
    
    lazy var selectedSiteLabel = UILabel()
    
    
    weak var injectNowCoordinator: InjectNowCoordinator?
    
    weak var coordinator: Coordinator?
    
    lazy var selectionInjectionViewController = SelectInjectionViewController(viewModel: viewModel)
    
    //var queueCount: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        setUpNavBar()
            
          /*  viewModel.queueCount
                .sink { count in
                    self.queueCount = count
                    self.selectInjectionButton.setNeedsUpdateConfiguration()
            }.store(in: &cancellables)*/
        
        
        //view.translatesAutoresizingMaskIntoConstraints = false
        
       /* injectionNameLabel.text = "injection Name \(viewModel.injection?.name)"
        scheduledLabel.text = "Scheduled"
        lastInjectedLabel.text = "Last Injected"*/
        
        injectionDataView.createHierarchy(selectedQueueObject: nil, selectedInjectionObject: nil)
        view.addSubview(injectionDataView)
        
        injectionDataView.snp.makeConstraints { make in
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
        
        viewModel.fieldsSelectedPublisher.assign(to: \.isEnabled, on: injectButton)
            .store(in: &cancellables)
        
        //view.addSubview(siteCollectionView)

        // Do any additional setup after loading the view.
    }
    
    init(viewModel: InjectNowViewModel) {
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUpNavBar(){
        if viewModel.isFromNotification{
            /*let button = UIBarButtonItem(title: "Skip", style: .done, target: self, action: nil)
            
            button.tintColor = .systemRed
            navigationItem.leftBarButtonItem = button*/
            
            navigationItem.leftBarButtonItem = UIBarButtonItem(customView: skipButton)
        }
        else{
            let action = UIAction { _ in
                self.injectNowCoordinator!.dismissViewController()
            }
            navigationItem.leftBarButtonItem = UIBarButtonItem(systemItem: .close, primaryAction: action)
            
        }
        
        
        //let injectButton = UIBarButtonItem(customView: button)
        
        var rightButtonArray = [UIBarButtonItem(customView: injectButton)]
        
        if viewModel.isFromNotification{
        
            rightButtonArray.append(UIBarButtonItem(customView: snoozeButton))
            
        }
        
        navigationItem.rightBarButtonItems = rightButtonArray
        
           // navigationItem.rightBarButtonItems = [UIBarButtonItem(customView: injectButton), UIBarButtonItem(customView: snoozeButton)]
        
        //navigationItem.rightBarButtonItem = injectButton
        
        navigationItem.title = viewModel.isFromNotification ?"Injection Time!" : "Inject Now"
    }
    

    
    func snoozeButtonPressed(){
        
        let alert = UIAlertController(title: "Snooze", message: "For How Many Minutes? (you will receive a notification)", preferredStyle: .alert)
        
        alert.addTextField { [unowned alert] textField in
            textField.keyboardType = .numberPad
            textField.placeholder = "Minutes"
            
            textField.textPublisher().sink { text in
                alert.actions[1].isEnabled = text.trimmingCharacters(in: .whitespacesAndNewlines) == "" ? false : true
            }.store(in: &self.cancellables)
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in

        }))
        
        alert.addAction(UIAlertAction(title: "Snooze", style: .default, handler: { [unowned alert] _ in
            
            let text = alert.textFields![0].text!.trimmingCharacters(in: .whitespacesAndNewlines)
            
            
            self.viewModel.snoozeInjection(forMinutes: text)
            
            //self.dismiss(animated: true)
            
            //self.injectNowCoordinator?.dismissViewController()
            
            self.injectNowCoordinator?.snoozedPressed(injection: self.viewModel.injectionFromNotification!)
        
        }))
        
        alert.actions[1].isEnabled = false
        
        present(alert, animated: true)
        
        
    }
    


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
            siteCollectionView.topAnchor.constraint(equalTo: injectionDataView.bottomAnchor),
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
        
        viewModel.selectedSite = site
        
        
    }
    
}
