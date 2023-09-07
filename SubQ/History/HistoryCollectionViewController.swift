//
//  InjectionHistoryViewController.swift
//  SubQ
//
//  Created by Constantine Thalasinos on 5/4/23.
//

import UIKit
import Combine
import CoreData
/*
class HistoryCollectionViewController: UIViewController, Coordinated {
    
    weak var coordinator: Coordinator?
    
    weak var historyCoordinator: HistoryCoordinator?
    
    let viewModel: HistoryViewModel
    
    var dataSource: UICollectionViewDiffableDataSource<Int, NSManagedObjectID>! = nil
    var collectionView: UICollectionView! = nil
    
    var cancellables = Set<AnyCancellable>()
    
    var headerView: ResultsHeaderView?
    
    private let searchController = UISearchController(searchResultsController: nil)
    
    lazy var filterAction = UIAction { _ in
        self.historyCoordinator?.showFilterController()
    }
    
    lazy var editAction = UIAction { _ in
        self.isInEditMode = true
    }
    
    lazy var doneAction = UIAction { _ in
        self.isInEditMode = false
    }
    
    lazy var editButton = UIBarButtonItem(systemItem: .edit, primaryAction: editAction)
    
    lazy var doneButton = UIBarButtonItem(systemItem: .done, primaryAction: doneAction)
    
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
        
        setBarButtons()
        
        configureSearchController()
        configureHierarchy()
        configureDataSource()
        
        viewModel.currentSnapshot.sink { [weak self] snapshot in
            
            if let snapshot = snapshot{
                self?.headerView?.label.text = "\(snapshot.numberOfItems) results"
                
                if snapshot.numberOfItems == 0{
                    self?.navigationItem.leftBarButtonItem?.isEnabled = false
                }
                else{
                    self?.navigationItem.leftBarButtonItem?.isEnabled = true
                }
            }
            
        }.store(in: &cancellables)
        
        viewModel.snapshot
          .sink(receiveValue: { [weak self] snapshot in
            if let snapshot = snapshot {
                
              /*  if snapshot.numberOfItems == 0{
                    self?.navigationItem.leftBarButtonItem?.isEnabled = false
                }
                else{
                    self?.navigationItem.leftBarButtonItem?.isEnabled = true
                }*/
                
                self?.dataSource.apply(snapshot, animatingDifferences: true)
                self?.collectionView.reloadData()
            }
          })
          .store(in: &cancellables)
        // Do any additional setup after loading the view.
    }
    
    init(viewModel: HistoryViewModel){
        
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setBarButtons(){
        
        if !isInEditMode{
            
            navigationItem.leftBarButtonItem = editButton
            navigationItem.rightBarButtonItem = nil
            
            if let dataSource{
                if dataSource.snapshot().numberOfItems == 0{
                    navigationItem.leftBarButtonItem!.isEnabled = false
                }
            }
            
        }
        else{
            navigationItem.leftBarButtonItem = nil
            navigationItem.rightBarButtonItem = doneButton
        }
    }
    
    func presentDeleteAlertController(forHistory history: History){
        let alert = UIAlertController(title: "Delete History", message: "Are you sure you want to delete history entry for \(history.injection!.name!) from \(history.date!)?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { [self] _ in
                
            viewModel.deleteObject(history)
        }))
        
        self.present(alert, animated: true)
    }
    

}

extension HistoryCollectionViewController{
    private func createLayout() -> UICollectionViewLayout {
        var config = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        config.headerMode = .supplementary
        
        config.trailingSwipeActionsConfigurationProvider = { [unowned self] indexPath in

            let history = self.viewModel.object(at: indexPath)
            
            let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { action, sourceView, completion in
                
                presentDeleteAlertController(forHistory: history)
             
                completion(true)
            }
            return .init(actions: [deleteAction])
        }
        
        return UICollectionViewCompositionalLayout.list(using: config)
    }
}

extension HistoryCollectionViewController{
    
    private func configureSearchController(){
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search by injection name"
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        navigationItem.preferredSearchBarPlacement = .stacked
        definesPresentationContext = true
    }
    
    private func configureHierarchy(){
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(collectionView)
        collectionView.delegate = self
    }
    
    private func configureDataSource() {
        
        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, NSManagedObjectID> { [weak self] (cell, indexPath, injectionId) in
            
            guard let history = self?.viewModel.object(at: indexPath) else {
              return
            }
            
            guard let injection = history.injection else { return }
            
            var content = cell.defaultContentConfiguration()
            content.text = "\(history.date!.fullDateTime): \(injection.descriptionString) | \(history.status!)"
            content.secondaryText = "Due: \(history.dueDate!) | Scheduled: \(injection.scheduledString)"
            
            cell.contentConfiguration = content
            
            cell.accessories = [.delete(displayed: .whenEditing, actionHandler: {
                
                self?.presentDeleteAlertController(forHistory: history)
                
            })]
            
        }
        
        let headerRegistration = UICollectionView.SupplementaryRegistration
        <ResultsHeaderView>(elementKind: UICollectionView.elementKindSectionHeader) {
            [unowned self] (headerView, elementKind, indexPath) in
            headerView.filterButton.addAction(filterAction, for: .primaryActionTriggered)
            
            self.headerView = headerView
            
        }
        
        dataSource = UICollectionViewDiffableDataSource<Int, NSManagedObjectID>(collectionView: collectionView) {
            (collectionView: UICollectionView, indexPath: IndexPath, injectionId: NSManagedObjectID) -> UICollectionViewCell? in
            
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: injectionId)
        }
        
        dataSource.supplementaryViewProvider = { (view, kind, index) in
            
            return self.collectionView.dequeueConfiguredReusableSupplementary(
                using:  headerRegistration, for: index)
        }

        // initial data
        var snapshot = NSDiffableDataSourceSnapshot<Int, NSManagedObjectID>()
        snapshot.appendSections([0])
        
        dataSource.apply(snapshot, animatingDifferences: false)
    }
    
}

extension HistoryCollectionViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: false)
        
        let history = viewModel.object(at: indexPath)
        
        if history.statusVal == .injected{
            historyCoordinator?.showHistoryController(forObject: history)
        }
    }
}

extension HistoryCollectionViewController: UISearchResultsUpdating{
    func updateSearchResults(for searchController: UISearchController) {
        
        if let text = searchController.searchBar.text{
            viewModel.performSearch(forText: text)
        }
        
        
    }
    
    
}
*/
