//
//  HistoryTableViewController.swift
//  SubQ
//
//  Created by Constantine Thalasinos on 8/24/23.
//

import UIKit
import Combine
import CoreData

class HistoryTableViewController: UIViewController, Coordinated {
    
    class HistoryDataSource: UITableViewDiffableDataSource<Int, NSManagedObjectID> {
        weak var viewController: HistoryTableViewController?
        
        override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
            if editingStyle == .delete{
                
                let history = viewController!.viewModel.object(at: indexPath)
                
                viewController!.presentDeleteAlertController(forHistory: history)
            }
        }
        
    }
    
    weak var coordinator: Coordinator?
    weak var historyCoordinator: HistoryCoordinator?
    
    let viewModel: HistoryViewModel
    
    var dataSource: HistoryDataSource! = nil
    var tableView: UITableView! = nil
    
    var cancellables = Set<AnyCancellable>()
    
    var headerView: ResultsHeaderView?
    
    let reuseIdentifier = "reuse-id"
    
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
                tableView.setEditing(true, animated: true)
            }
            else{
                tableView.setEditing(false, animated: true)
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
               // self?.tableView.reloadData()
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
        let alert = UIAlertController(title: "Delete History", message: "Are you sure you want to delete history entry for \(history.injection!.name!) from \(history.date!)?", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { [self] _ in
                
            viewModel.deleteObject(history)
        }))
        
        self.present(alert, animated: true)
    }
    

    
}

extension HistoryTableViewController {
    
    private func configureSearchController(){
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search by injection name"
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        navigationItem.preferredSearchBarPlacement = .stacked
        definesPresentationContext = true
    }
    
    private func configureHierarchy() {
        tableView = UITableView(frame: view.bounds, style: .insetGrouped)
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        tableView.register(HistoryTableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.delegate = self
       // tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
       /* NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])*/
    }
    
    private func configureDataSource() {
        
        dataSource = HistoryDataSource(tableView: tableView) { (tableView, indexPath, injectionId) -> HistoryTableViewCell? in
        
            
             let history = self.viewModel.object(at: indexPath)
            
            guard let injection = history.injection else { return nil }
            
            let cell = tableView.dequeueReusableCell(withIdentifier: self.reuseIdentifier, for: indexPath) as! HistoryTableViewCell
            cell.setHistory(history)
            
            /*var content = cell.defaultContentConfiguration()
            content.text = "\(history.date!.fullDateTime): \(injection.descriptionString) | \(history.status!)"
            content.secondaryText = "Due: \(history.dueDate!) | Scheduled: \(injection.scheduledString)"
            
            cell.contentConfiguration = content*/
    
            return cell
        }
        
        dataSource.viewController = self

        // initial data
        var snapshot = NSDiffableDataSourceSnapshot<Int, NSManagedObjectID>()
        snapshot.appendSections([0])
        
        dataSource.apply(snapshot, animatingDifferences: false)
    }
    
}

extension HistoryTableViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        
        cell?.setSelected(false, animated: true)
        
        let history = viewModel.object(at: indexPath)
        
        if history.statusVal == .injected{
            historyCoordinator?.showHistoryController(forObject: history)
        }
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { action, view, handler in
            self.presentDeleteAlertController(forHistory: self.viewModel.object(at: indexPath))
        }
        
        deleteAction.backgroundColor = .red
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        configuration.performsFirstActionWithFullSwipe = true
        
        return configuration
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = ResultsHeaderView()
        headerView.filterButton.addAction(filterAction, for: .primaryActionTriggered)
        
        self.headerView = headerView
        
        return headerView
        
    }
}

extension HistoryTableViewController: UISearchResultsUpdating{
    func updateSearchResults(for searchController: UISearchController) {
        
        if let text = searchController.searchBar.text{
            viewModel.performSearch(forText: text)
        }
        
        
    }
    
    
}
