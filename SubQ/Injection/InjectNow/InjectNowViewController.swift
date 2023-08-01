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
        
    let injectionNameLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        return label
    }()
    
    let scheduledLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        return label
    }()
    
    let lastInjectedLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        return label
    }()
    
    let dueDateLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        return label
    }()
    
    let snoozedUntilLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        return label
    }()
    
    
    lazy var injectButton: UIButton = {
        
        var buttonConfig = UIButton.Configuration.filled()
        buttonConfig.buttonSize = .medium
        buttonConfig.cornerStyle = .capsule
        buttonConfig.title = "Inject"
        buttonConfig.baseBackgroundColor = .blue
        
        let action = UIAction { _ in
            self.viewModel.injectionPerformed(site: self.viewModel.selectedSite!)
            self.coordinator!.injectPressed()
            
        }
        return UIButton(configuration: buttonConfig, primaryAction: action)
    }()
    
    lazy var skipButton: UIButton = {
        var buttonConfig = UIButton.Configuration.plain()
        buttonConfig.title = "Skip"
        buttonConfig.baseForegroundColor = .red
        
        let action = UIAction { _ in
            self.viewModel.skipInjection()
            self.coordinator?.dismissViewController()
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
        
       /* injectionNameLabel.text = "injection Name \(viewModel.injection?.name)"
        scheduledLabel.text = "Scheduled"
        lastInjectedLabel.text = "Last Injected"*/
        
        configureInjectionDataStackView(injectionObj: nil, queueObj: nil)
        
        if viewModel.isFromNotification{
            injectionDataStackView.addArrangedSubview(injectionNameLabel)
        }
        injectionDataStackView.addArrangedSubview(scheduledLabel)
        injectionDataStackView.addArrangedSubview(lastInjectedLabel)
        injectionDataStackView.addArrangedSubview(dueDateLabel)
        injectionDataStackView.addArrangedSubview(snoozedUntilLabel)
        
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
               
                self.configureInjectionDataStackView(injectionObj: injection, queueObj: queue)
                
            }.store(in: &cancellables)
            
        }
        
        viewModel.fieldsSelectedPublisher.assign(to: \.isEnabled, on: injectButton)
            .store(in: &cancellables)
        
        //view.addSubview(siteCollectionView)

        // Do any additional setup after loading the view.
    }
    
    init(viewModel: InjectNowViewModel) {
        self.viewModel = viewModel
        
                
        print(viewModel.injectionFromNotification?.objectID)
        
        
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
                self.coordinator!.dismissViewController()
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
    
    func configureInjectionDataStackView(injectionObj: Injection?, queueObj: Queue?){
        
        var injection: Injection?
        
        if !viewModel.isFromNotification{
            if let injectionObj{
                injection = injectionObj
                
                dueDateLabel.text = ""
                snoozedUntilLabel.text = ""
            }
            else if let queueObj{
                injection = queueObj.injection!
                
                dueDateLabel.text = "Due: \(queueObj.dateDue!.fullDateTime)"
                snoozedUntilLabel.text = "Snoozed Until: \(queueObj.snoozedUntil?.fullDateTime ?? "-")"
            }
            injectionNameLabel.text = ""
            selectInjectionButton?.configuration?.title = injection?.descriptionString ?? "Select Injection"
            
        }
        else{
            injection = viewModel.injectionFromNotification!
            injectionNameLabel.text = injection?.descriptionString
            dueDateLabel.text = ""
            snoozedUntilLabel.text = ""
        }
        
        if let injection{
            scheduledLabel.text = "Scheduled \(injection.scheduledString )"
            lastInjectedLabel.text = "Last Injected: \(viewModel.getLastInjectedDate(forInjection: injection)?.fullDateTime ?? "-")"
        }
        
        
        
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
            
            self.dismiss(animated: true)
        
        }))
        
        alert.actions[1].isEnabled = false
        
        present(alert, animated: true)
        
        
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
        
        viewModel.selectedSite = site
        
        
    }
    
}
