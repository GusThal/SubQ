//
//  SelectInjectionViewController.swift
//  SubQ
//
//  Created by Constantine Thalasinos on 7/15/23.
//

import UIKit
import CoreData
import Combine

class SelectInjectionViewController: UIViewController, Coordinated {
    
    private struct Item: Hashable{
        let title: String?
        let objectID: NSManagedObjectID?
        
    }
    
    enum Section: Int{
        case queue, injection
        var description: String {
            switch self {
            case .queue: return "Queued Injections"
            case .injection: return "Scheduled Injections"
            }
        }
    }
    
    private var dataSource: UICollectionViewDiffableDataSource<Int, Item>!
    
    var collectionView: UICollectionView! = nil
    
    var cancellables = Set<AnyCancellable>()
    
    let viewModel: InjectNowViewModel
    
    weak var coordinator: Coordinator?
    
    weak var selectInjectionCoordinator: SelectInjectionCoordinator?
    
    lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
        
    }()
    
    lazy var noInjectionStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [noInjectionsLabel, scheduleInjectionnButton])
        stack.axis = .vertical
        stack.backgroundColor = .white
        stack.distribution = .equalSpacing
        stack.spacing = CGFloat(10)
    
        
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        return stack
    }()
    
    let noInjectionsLabel: UILabel = {
        let label = UILabel()
        label.text = "You currently have no scheduled injections."
        label.textAlignment = .center
        
        label.backgroundColor = .green
        
        return label
    }()
    
    lazy var scheduleInjectionnButton: UIButton = {
        let action = UIAction { _ in
            self.selectInjectionCoordinator?.scheduleInjectionPressed()
        }
        
        
        let button = UIButton(primaryAction: action)
        
        button.configurationUpdateHandler = { [unowned self] button in
            
            var config: UIButton.Configuration!
            
            if self.viewModel.selectedInjection == nil && self.viewModel.selectedQueueObject == nil{
                config = UIButton.Configuration.plain()
                
                config.title = "Schedule"
                config.baseForegroundColor = .blue
            }
            
            button.configuration = config
        }

        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
   
    
    var isInEditMode: Bool = false{
        didSet{
            
           // setBarButtons()
            
            if isInEditMode{
                collectionView.isEditing = true
            }
            else{
                collectionView.isEditing = false
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureHierarchy()
        configureDataSource()

        
        Publishers.Zip(viewModel.injectionSnapshot, viewModel.currentSnapshot)
            .sink { [weak self] injectionSnapshot, queueSnapshot in
                
                var isQueueEmpty = false
                var isInjectionEmpty = false
                
                if let queueSnapshot{
                    self?.applySnapshot(queueSnapshot, toSection: Section.queue)
                    //only needs to be called when this snapshot updates, not when the injections do.
                    self?.setBarButtons()
                    
                    if queueSnapshot.numberOfItems == 0{
                        isQueueEmpty = true
                    }
                }
                
                if let injectionSnapshot{
                    self?.applySnapshot(injectionSnapshot, toSection: Section.injection)
                    
                    if injectionSnapshot.numberOfItems == 0{
                        isInjectionEmpty = true
                    }
                }
                
                
                self?.collectionView.reloadData()
                
                if isQueueEmpty && isInjectionEmpty{
                    self?.displayNoInjectionView()
                }
                else{
                    self?.containerView.removeFromSuperview()
                }
            
        }.store(in: &cancellables)
        
  /*     viewModel.injectionSnapshot
            .sink(receiveValue: { [weak self] snapshot in
              if let snapshot = snapshot {
                 
                  self?.applySnapshot(snapshot, toSection: Section.injection)
                  
                  self?.collectionView.reloadData()

              }
            })
            .store(in: &cancellables)*/

 /*       viewModel.queueSnapshot
          .sink(receiveValue: { [weak self] snapshot in
            if let snapshot = snapshot {
                
                print("Number of queue \(snapshot.numberOfItems)")
                
                self?.applySnapshot(snapshot, toSection: Section.queue)
                //only needs to be called when this snapshot updates, not when the injections do.
                self?.setBarButtons()
                
                self?.collectionView.reloadData()
            }
          })
          .store(in: &cancellables)*/
        
   /*     viewModel.currentSnapshot
            .sink { [weak self] snapshot in
            
            print("updated \(Date()) + \(snapshot?.itemIdentifiers)")
            
            if let snapshot = snapshot{
                self?.applySnapshot(snapshot, toSection: Section.queue)
                //only needs to be called when this snapshot updates, not when the injections do.
                self?.setBarButtons()
    
                self?.collectionView.reloadData()
                
            }
        }.store(in: &cancellables)*/
    }
    
    func displayNoInjectionView(){
        
        containerView.addSubview(noInjectionStackView)
        
        noInjectionStackView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        view.insertSubview(containerView, aboveSubview: collectionView)
        
        containerView.snp.makeConstraints { make in
            make.topMargin.equalToSuperview()
            make.leading.trailing.bottom.equalToSuperview()
        }
        
       
        print(noInjectionStackView.frame)
        
    }
    
    init(viewModel: InjectNowViewModel){
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func presentDeleteAlertController(forQueueObject object: Queue){
        let alert = UIAlertController(title: "Delete Queue Object", message: "Are you sure you want to delete  \(object.injection!.name!), missed on \(object.dateDue?.fullDateTime) from the queue?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { [self] _ in
            
            
            if let snoozedUntil = object.snoozedUntil{
                
                NotificationManager.removeExistingNotifications(forInjection: object.injection!, snoozedUntil: snoozedUntil, originalDateDue: object.dateDue)
                
            }
            
            viewModel.delete(queueObject: object)
            
            
        
        }))
        
        self.present(alert, animated: true)
    }
    
    private func setBarButtons(){
        
        if let dataSource{
            
            //greater than 1 because we have an expandable header item in the section
            if dataSource.snapshot().numberOfItems(inSection: Section.queue.rawValue) > 1{
                
                if !isInEditMode{
                    
                    let editAction = UIAction { _ in
                        self.isInEditMode = true
                        self.setBarButtons()
                    }
                    
                    navigationItem.leftBarButtonItem = UIBarButtonItem(systemItem: .edit, primaryAction: editAction)
                    navigationItem.rightBarButtonItem = nil
                    
                }
                else{
                    navigationItem.leftBarButtonItem = nil
                    
                    let doneAction = UIAction { _ in
                        self.isInEditMode = false
                        self.setBarButtons()
                    }
                    
                    navigationItem.rightBarButtonItem = UIBarButtonItem(systemItem: .done, primaryAction: doneAction)
                }
            }
            else{
                navigationItem.leftBarButtonItem = nil
                navigationItem.rightBarButtonItem = nil
                               
                isInEditMode = false
            }
        }
    }
    
}

extension SelectInjectionViewController{
    func createLayout() -> UICollectionViewLayout {
        var config = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        config.headerMode = .firstItemInSection
        config.footerMode = .supplementary
        return UICollectionViewCompositionalLayout.list(using: config)
    }
}

extension SelectInjectionViewController{
    func configureHierarchy() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
       
        collectionView.backgroundColor = .systemGreen
        collectionView.delegate = self
        view.addSubview(collectionView)
        
    }
    
    func applySnapshot(_ snapshot: NSDiffableDataSourceSnapshot<Int, NSManagedObjectID>, toSection section: Section){
        
        
        var sectionSnapshot = NSDiffableDataSourceSectionSnapshot<Item>()
        
        let title = section.description
        
        let headerItem = Item(title: title, objectID: nil)
        sectionSnapshot.append([headerItem])
        
        var items = [Item]()
        
        for objectID in snapshot.itemIdentifiers{
            
            items.append(Item(title: nil, objectID: objectID))
            
        }
        
        sectionSnapshot.append(items, to: headerItem)
        sectionSnapshot.expand([headerItem])
        dataSource.apply(sectionSnapshot, to: section.rawValue, animatingDifferences: true)
        
    }
    
    func configureDataSource() {
        
        
        let headerRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, Item> { (cell, indexPath, item) in
            var content = cell.defaultContentConfiguration()
            content.text = item.title
            cell.contentConfiguration = content
            
            cell.accessories = [.outlineDisclosure()]
        }
        
        let footerRegistration = UICollectionView.SupplementaryRegistration
        <UICollectionViewListCell>(elementKind: UICollectionView.elementKindSectionFooter) {
            [unowned self] (footerView, elementKind, indexPath) in
            
            // Configure footer view content
            var configuration = footerView.defaultContentConfiguration()
            
            if indexPath.section == Section.queue.rawValue{

                configuration.text = "Queued injections are ones that were missed or snoozed."
                
            }
            else{
                configuration.text = "Scheduled Injections that are currently in queue cannot be selected."
            }
            
            footerView.contentConfiguration = configuration
        }
        
        
        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, Item> { (cell, indexPath, item) in
            

           var injection: Injection
            
           var queueObject: Queue?
            
           if indexPath.section == Section.queue.rawValue{
               
               //because we have the first row of the section as a header, we need to subtract 1 to not go out of range.
               let path = IndexPath(item: indexPath.item-1, section: indexPath.section)
               
               queueObject = self.viewModel.getQueueObject(forIndexPath: path)
               
               injection = queueObject!.injection!
            }
            else{
               // let index = IndexPath(item: indexPath.item, section: 0)
                
                injection = self.viewModel.getInjection(withObjectID: item.objectID!)
            }
            
            
            var content = cell.defaultContentConfiguration()
            content.text = injection.descriptionString
            content.secondaryText = injection.scheduledString
            
            if indexPath.section == Section.queue.rawValue{
                
                content.secondaryText?.append(" | Missed: \(queueObject!.dateDue!.fullDateTime)")
                
                if let snoozedUntil = queueObject?.snoozedUntil{
                    content.secondaryText?.append("| Snoozed until: \(snoozedUntil)")
                }
                
                
                
                cell.accessories = [.delete(displayed: .whenEditing, actionHandler: {
                    
                    self.presentDeleteAlertController(forQueueObject: queueObject!)
                    
                })]
                
                if let selectedQueue = self.viewModel.selectedQueueObject{
                    
                    if selectedQueue == queueObject{
                        cell.accessories.append(.checkmark(displayed: .always))
                    }
                }
            
            }
            else{
                cell.accessories = []
                
                if self.viewModel.isInjectionInQueue(injectionManagedID: injection.objectID){
                    content.textProperties.color = .gray
                    content.secondaryTextProperties.color = .gray
                }
                
                if let selectedInjection = self.viewModel.selectedInjection{
                    if selectedInjection == injection{
                        cell.accessories.append(.checkmark(displayed: .always))
                    }
                }
            }
            
            cell.contentConfiguration = content
  
        }
        
        
        dataSource = UICollectionViewDiffableDataSource<Int, Item>(collectionView: collectionView) {
            (collectionView: UICollectionView, indexPath: IndexPath, item: Item) -> UICollectionViewCell? in
            // Return the cell.
            
            if indexPath.item == 0 {
                return collectionView.dequeueConfiguredReusableCell(using: headerRegistration, for: indexPath, item: item)
            } else {
                return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: item)
            }
        
        }
        
        dataSource.supplementaryViewProvider = { (view, kind, index) in
            
            return self.collectionView.dequeueConfiguredReusableSupplementary(
                using:  footerRegistration, for: index)
        }
        

        // initial data
        var snapshot = NSDiffableDataSourceSnapshot<Int, Item>()
        
        let sections = [Section.queue.rawValue, Section.injection.rawValue]
        
        snapshot.appendSections(sections)
        
        dataSource.apply(snapshot, animatingDifferences: false)
    }
}

extension SelectInjectionViewController: UICollectionViewDelegate{
    
    func isCellDisabled(indexPath: IndexPath) -> Bool {
        if Section(rawValue: indexPath.section) == .injection{
            //-1 on the index because the first row is always a header.
            
            if let snapshot = viewModel.typeSafeInjectionSnapshot{
                let id =  snapshot.itemIdentifiers[indexPath.row-1]
                
                if viewModel.isInjectionInQueue(injectionManagedID: id){
                    return false
                }
                else{
                    return true
                }
            }
            else{
                return true
            }
            
        }
        else{
            return true
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        isCellDisabled(indexPath: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        isCellDisabled(indexPath: indexPath)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let cell = collectionView.cellForItem(at: indexPath) as! UICollectionViewListCell
        
    /*    if indexPath.section == Section.queue.rawValue{
            
            let path = IndexPath(item: indexPath.item-1, section: indexPath.section)
            
            viewModel.selectedInjection = nil
            viewModel.selectedQueueObject = viewModel.getQueueObject(forIndexPath: path)
            
            let injection = viewModel.selectedQueueObject!.injection!
            
            
            //it's possible a person could have had a scheduled injection, missed a dose, and changed it to "As needed"
            //so there'd still be a queued injection for that.
            if !injection.daysVal.contains(.asNeeded){
                
                let alert = UIAlertController(title: "Queued Injection Selected", message: "You selected  \(injection.name!) \(injection.dosage!) \(injection.units!). This injection is scheduled for \(injection.nextInjection!.timeUntil). You will still receive a notification.", preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { _ in
                    self.dismiss(animated: true)
                }))
                
                self.present(alert, animated: true)
            }
            else{
                selectInjectionCoordinator?.dismiss()
            }
            
            
        }
        else{
            
            if let snapshot = viewModel.typeSafeInjectionSnapshot{
                //-1 on the index because the first row is always a header.
                let id =  snapshot.itemIdentifiers[indexPath.row-1]
                
                let injection = viewModel.getInjection(withObjectID: id)
                
                    
                    viewModel.selectedInjection = injection
                    viewModel.selectedQueueObject = nil
                    
                    if !injection.daysVal.contains(.asNeeded){
                        let alert = UIAlertController(title: "Scheduled Injection Selected", message: "You selected  \(injection.name!) \(injection.dosage!) \(injection.units!), scheduled \(injection.scheduledString), and due in \(injection.nextInjection!.timeUntil). You will still receive a notification.", preferredStyle: .alert)
                        
                        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { _ in
                            self.dismiss(animated: true)
                        }))
                        
                        self.present(alert, animated: true)
                    }
                    else{
                        selectInjectionCoordinator?.dismiss()
                    }
            }
        }
        
        cell.accessories = [.checkmark()]
        collectionView.reloadData()
        
        */
        
       
    }
    
    func presentAlertControllerForSelection(){
        
    }
    
}

