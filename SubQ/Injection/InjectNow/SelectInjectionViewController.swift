//
//  SelectInjectionViewController.swift
//  SubQ
//
//  Created by Constantine Thalasinos on 7/15/23.
//

import UIKit
import CoreData
import Combine

class SelectInjectionViewController: UIViewController {
    
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
    
    var isInEditMode: Bool = false{
        didSet{
            
            setBarButtons()
            
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
        
       viewModel.injectionSnapshot
            .sink(receiveValue: { [weak self] snapshot in
              if let snapshot = snapshot {
                 
                  self?.applySnapshot(snapshot, toSection: Section.injection)
              }
            })
            .store(in: &cancellables)

        viewModel.queueSnapshot
          .sink(receiveValue: { [weak self] snapshot in
            if let snapshot = snapshot {
               
                
                self?.applySnapshot(snapshot, toSection: Section.queue)
                //only needs to be called when this snapshot updates, not when the injections do.
                self?.setBarButtons()
            }
          })
          .store(in: &cancellables)
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
                    }
                    
                    navigationItem.leftBarButtonItem = UIBarButtonItem(systemItem: .edit, primaryAction: editAction)
                    navigationItem.rightBarButtonItem = nil
                    
                }
                else{
                    navigationItem.leftBarButtonItem = nil
                    
                    let doneAction = UIAction { _ in
                        self.isInEditMode = false
                    }
                    
                    navigationItem.rightBarButtonItem = UIBarButtonItem(systemItem: .done, primaryAction: doneAction)
                }
            }
        }
    }
    
}

extension SelectInjectionViewController{
    func createLayout() -> UICollectionViewLayout {
        var config = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        config.headerMode = .firstItemInSection
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
        dataSource.apply(sectionSnapshot, to: section.rawValue)
        
    }
    
    func configureDataSource() {
        
        
        let headerRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, Item> { (cell, indexPath, item) in
            var content = cell.defaultContentConfiguration()
            content.text = item.title
            cell.contentConfiguration = content
            
            cell.accessories = [.outlineDisclosure()]
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
            content.text = "\(injection.name!) \(injection.dosage!) \(injection.units!)"
            content.secondaryText = "\(injection.daysVal.map({ $0.shortened}).joined(separator: ", "))"
            
            
            if injection.daysVal != [Injection.Frequency.asNeeded] {
                if let time = injection.prettyTime{
                    content.secondaryText!.append(" | \(time)")
                }
            }
            
            if indexPath.section == Section.queue.rawValue{
                
                content.secondaryText?.append(" | Missed: \(queueObject!.dateDue!.fullDateTime)")
                
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
        

        // initial data
        var snapshot = NSDiffableDataSourceSnapshot<Int, Item>()
        
        let sections = [Section.queue.rawValue, Section.injection.rawValue]
        
        snapshot.appendSections(sections)
        
        dataSource.apply(snapshot, animatingDifferences: false)
    }
}

extension SelectInjectionViewController: UICollectionViewDelegate{
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let cell = collectionView.cellForItem(at: indexPath) as! UICollectionViewListCell
        
        if indexPath.section == Section.queue.rawValue{
            
            let path = IndexPath(item: indexPath.item-1, section: indexPath.section)
            
            viewModel.selectedInjection = nil
            viewModel.selectedQueueObject = viewModel.getQueueObject(forIndexPath: path)
            
        }
        else{
            
            if let snapshot = viewModel.typeSafeInjectionSnapshot{
                //-1 on the index because the first row is always a header.
                let id =  snapshot.itemIdentifiers[indexPath.row-1]
                
                let injection = viewModel.getInjection(withObjectID: id)
                
                viewModel.selectedInjection = injection
                viewModel.selectedQueueObject = nil
                
            }
        }
        
        cell.accessories = [.checkmark()]
        
        
        
        selectInjectionCoordinator?.dismiss()
    }
    
}

