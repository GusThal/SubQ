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
    
    struct SupplementaryViewKind{
        static let sectionHeader = "section-header-element-kind"
        static let globalHeader = "global-header-element-kind"
        static let sectionFooter = "section-footer-element-kind"
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
        buttonConfig.baseForegroundColor = .systemRed
        
        let action = UIAction { _ in
            self.viewModel.skipInjection()
            self.injectNowCoordinator?.skipPressed(injection: self.viewModel.injectionFromNotification!)
        }
        
        return UIButton(configuration: buttonConfig, primaryAction: action)
        
    }()
    
    lazy var snoozeButton: UIButton = {
        var buttonConfig = UIButton.Configuration.plain()
        buttonConfig.title = "Snooze"
        buttonConfig.baseForegroundColor = InterfaceDefaults.secondaryColor
        
        let action = UIAction { _ in
            self.snoozeButtonPressed()
        }
        
        return UIButton(configuration: buttonConfig, primaryAction: action)
        
    }()
    
    var screenHeight: CGFloat?
    
    var siteDataSource: UICollectionViewDiffableDataSource<Int, NSManagedObjectID>!
    
    var siteCollectionView: UICollectionView! = nil
    
    var cancellables = Set<AnyCancellable>()
    
    var selectedCellIndexPath: IndexPath?
    
    lazy var selectedSiteLabel = UILabel()
    
    lazy var selectedLabel = UILabel()
    
    lazy var collectionViewFooter = UICollectionReusableView()
    
    
    weak var injectNowCoordinator: InjectNowCoordinator?
    
    weak var coordinator: Coordinator?
    
   // lazy var selectionInjectionViewController = SelectInjectionViewController(viewModel: viewModel)
    
    //var queueCount: Int = 0
    
    
    override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)
             
        screenHeight = self.view.window!.frame.height
        
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
             
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        print("disappear")
        
        UIApplication.shared.isIdleTimerDisabled = false
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        UIApplication.shared.isIdleTimerDisabled = true
        
        setUpNavBar()
        
        injectionDataView.createHierarchy(selectedQueueObject: nil, selectedInjectionObject: nil)
        view.addSubview(injectionDataView)
        
        injectionDataView.snp.makeConstraints { make in
            make.leadingMargin.rightMargin.equalToSuperview()
            make.topMargin.equalToSuperview()
        }
        
        viewModel.fieldsSelectedPublisher.assign(to: \.isEnabled, on: injectButton)
            .store(in: &cancellables)
        
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
            navigationItem.leftBarButtonItem = UIBarButtonItem(customView: skipButton)
        }
        else{
            let action = UIAction { _ in
                self.injectNowCoordinator!.dismissViewController()
            }
            navigationItem.leftBarButtonItem = UIBarButtonItem(systemItem: .close, primaryAction: action)
            
        }
        
        var rightButtonArray = [UIBarButtonItem(customView: injectButton)]
        
        if viewModel.isFromNotification{
        
            rightButtonArray.append(UIBarButtonItem(customView: snoozeButton))
            
        }
        
        navigationItem.rightBarButtonItems = rightButtonArray
        
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

        
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(0.5))
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, repeatingSubitem: item, count: 2)
        
        group.interItemSpacing = .fixed(5)
        group.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 2.5, bottom: 0, trailing: 2.5)
        


        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .groupPaging
        
        section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 0)
        
        let headerFooterSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                     heightDimension: .estimated(44))
        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerFooterSize,
            elementKind: SupplementaryViewKind.sectionHeader, alignment: .top)
        let sectionFooter = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerFooterSize,
            elementKind: SupplementaryViewKind.sectionFooter, alignment: .bottom)
        section.boundarySupplementaryItems = [sectionHeader, sectionFooter]
        
        let globalHeaderSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                      heightDimension: .absolute(44))
        
        let globalHeader = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: globalHeaderSize, elementKind: SupplementaryViewKind.globalHeader, alignment: .top)
        
        globalHeader.pinToVisibleBounds = true
        globalHeader.zIndex = 2
        
        let config = UICollectionViewCompositionalLayoutConfiguration()
        
        config.boundarySupplementaryItems = [globalHeader]

        
        let layout = UICollectionViewCompositionalLayout(section: section)
        layout.configuration = config
        
        return layout
    }
    
}

extension InjectNowViewController{
    func configureHierarchy() {
        siteCollectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        siteCollectionView.translatesAutoresizingMaskIntoConstraints = false
        siteCollectionView.backgroundColor = .systemBackground
        siteCollectionView.delegate = self
        view.addSubview(siteCollectionView)
        
        let collectionViewHeight = screenHeight! * 0.6
        
        NSLayoutConstraint.activate([
            siteCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            siteCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            siteCollectionView.topAnchor.constraint(equalTo: injectionDataView.bottomAnchor),
            siteCollectionView.heightAnchor.constraint(equalToConstant: collectionViewHeight)
        ])
    }
    func configureDataSource() {
        let cellRegistration = UICollectionView.CellRegistration<SiteCollectionViewCell, NSManagedObjectID> { (cell, indexPath, item) in
            
            let site = self.viewModel.getSite(forIndexPath: indexPath)
            // Populate the cell with our item description.
            cell.site = site
            
            if let selected = self.selectedCellIndexPath {
                if selected == indexPath {
                    cell.setSelected(to: true)
                }
            }
            
            cell.contentView.layer.cornerRadius = 5

        }
        
        let globalHeaderRegistration = UICollectionView.SupplementaryRegistration
        <TextSupplementaryView>(elementKind: SupplementaryViewKind.globalHeader) {
            (supplementaryView, string, indexPath) in
            supplementaryView.label.text = "Injection Sites"

        }
        
        let sectionHeaderRegistration = UICollectionView.SupplementaryRegistration<OrientationCollectionHeader>(elementKind: SupplementaryViewKind.sectionHeader) { supplementaryView, elementKind, indexPath in
            
        }
        
        let sectionFooterRegistration = UICollectionView.SupplementaryRegistration
        <VerticalStackLabelFooterView>(elementKind: SupplementaryViewKind.sectionFooter) {
            (supplementaryView, string, indexPath) in
            supplementaryView.label.text = "Selected Site:"
           // supplementaryView.supplementaryViewKind = .footer
            supplementaryView.secondaryLabel.text = "None Selected"
            self.selectedSiteLabel = supplementaryView.secondaryLabel
            self.selectedLabel = supplementaryView.label
            self.collectionViewFooter = supplementaryView

        }
        
        siteDataSource = UICollectionViewDiffableDataSource<Int, NSManagedObjectID>(collectionView: siteCollectionView) {
            (collectionView: UICollectionView, indexPath: IndexPath, item: NSManagedObjectID) -> UICollectionViewCell? in
            // Return the cell.
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: item)
        }
        
        siteDataSource.supplementaryViewProvider = { (view, kind, index) in
            
            if kind == SupplementaryViewKind.globalHeader {
                return self.siteCollectionView.dequeueConfiguredReusableSupplementary(using: globalHeaderRegistration, for: index)
            } else if kind == SupplementaryViewKind.sectionHeader {
                return self.siteCollectionView.dequeueConfiguredReusableSupplementary(using: sectionHeaderRegistration, for: index)
            } else {
                return self.siteCollectionView.dequeueConfiguredReusableSupplementary(using: sectionFooterRegistration, for: index)
            }
        }

        // initial data
        var snapshot = NSDiffableDataSourceSnapshot<Int, NSManagedObjectID>()
        
        
        siteDataSource.apply(snapshot, animatingDifferences: false)
    }
}

extension InjectNowViewController: UICollectionViewDelegate{
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let cell = collectionView.cellForItem(at: indexPath) as! SiteCollectionViewCell
        
        selectedCellIndexPath = indexPath
        
        cell.setSelected(to: true)
        
        let site = viewModel.getSite(forIndexPath: indexPath)
        
        selectedSiteLabel.text = "\(site.subQuadrantVal.description) of \(site.section!.quadrantVal.description) of \(site.section!.bodyPart!.part!) "
       
        selectedSiteLabel.textColor = .systemGreen
        
        viewModel.selectedSite = site
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? SiteCollectionViewCell else { return }
        
        cell.setSelected(to: false)
    }
    
}
