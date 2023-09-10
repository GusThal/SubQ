//
//  SelectInjectionTableViewController.swift
//  SubQ
//
//  Created by Constantine Thalasinos on 8/21/23.
//

import UIKit
import CoreData
import Combine

class SelectInjectionTableViewController: UIViewController, Coordinated {
    
    private class InjectionDiffableDataSource: UITableViewDiffableDataSource<Int, NSManagedObjectID> {
        
        weak var viewController: SelectInjectionTableViewController?
        
        override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
            
            section == Section.injection.rawValue ?  "Injections that currently have an instance in queue cannot be selected." : "Queued injections are ones that were missed or snoozed."
        }
        
        override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
            Section(rawValue: section)?.description
        }
        
        override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
            Section(rawValue: indexPath.section) == .queue ? true : false
        }
        
        
       override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
            if editingStyle == .delete{
                
                print("delete")
                
                viewController!.presentDeleteAlertController(forQueueObject: viewController!.viewModel.getQueueObject(forIndexPath: indexPath))
                
                
               /* let injection = viewController!.viewModel.object(at: indexPath)
                
                viewController?.presentDeleteAlertController(forInjection: injection)*/
            }
        }
        
    }
    
    
    enum Section: Int{
        case queue, injection
        var description: String {
            switch self {
            case .queue: return "Queued Injections"
            case .injection: return "Your Injections"
            }
        }
    }
    
    let reuseIdentifier = "reuse-id"
    
    let injectionReuseIdentifier = "injectionReuseIdentifier"
    
    let queueReuseIdentifier = "queueReuseIdentifier"
    
    private var dataSource: InjectionDiffableDataSource!
    
    var tableView: UITableView! = nil
    
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
                tableView.setEditing(true, animated: true)
            }
            else{
                tableView.setEditing(false, animated: true)
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
                
                self?.applySnapshots(queueSnapshot: queueSnapshot, injectionSnapshot: injectionSnapshot)
                
                if let queueSnapshot {
                    self?.setBarButtons()
                    
                    if queueSnapshot.numberOfItems == 0{
                        isQueueEmpty = true
                    }
                }
                
                if let injectionSnapshot {
                    if injectionSnapshot.numberOfItems == 0{
                        isInjectionEmpty = true
                    }
                }
                
               /* if let queueSnapshot{
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
                }*/
                
                
                self?.tableView.reloadData()
                
                if isQueueEmpty && isInjectionEmpty{
                    self?.displayNoInjectionView()
                }
                else{
                    self?.containerView.removeFromSuperview()
                }
            
        }.store(in: &cancellables)

        // Do any additional setup after loading the view.
    }
    
    func displayNoInjectionView(){
        
        containerView.addSubview(noInjectionStackView)
        
        noInjectionStackView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        view.insertSubview(containerView, aboveSubview: tableView)
        
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
                
                NotificationManager.removeExistingNotifications(forInjection: object.injection!, snoozedUntil: snoozedUntil, originalDateDue: object.dateDue, frequency: nil)
                
            }
            
            viewModel.delete(queueObject: object)
            
            
        
        }))
        
        self.present(alert, animated: true)
    }
    
    private func setBarButtons(){
        
        if let dataSource{
            
            if dataSource.snapshot().numberOfItems(inSection: Section.queue.rawValue) > 0{
                
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

extension SelectInjectionTableViewController{
    func configureHierarchy() {
        tableView = UITableView(frame: view.bounds, style: .insetGrouped)
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.register(InjectionTableViewCell.self, forCellReuseIdentifier: injectionReuseIdentifier)
        tableView.register(SelectQueueObjectTableViewCell.self, forCellReuseIdentifier: queueReuseIdentifier)
        tableView.delegate = self
        view.addSubview(tableView)
    }
    
    func applySnapshots(queueSnapshot: NSDiffableDataSourceSnapshot<Int, NSManagedObjectID>?, injectionSnapshot: NSDiffableDataSourceSnapshot<Int, NSManagedObjectID>?) {
        
        var snapshot = NSDiffableDataSourceSnapshot<Int, NSManagedObjectID>()
        
        
        snapshot.appendSections([Section.queue.rawValue, Section.injection.rawValue])
        
        
        if let queueSnapshot{
            
            var items = [NSManagedObjectID]()
            
            for objectID in queueSnapshot.itemIdentifiers{
                items.append(objectID)
            }
            
            snapshot.appendItems(items, toSection: Section.queue.rawValue)
        }
        
        if let injectionSnapshot{
            
            var items = [NSManagedObjectID]()
            
            for objectID in injectionSnapshot.itemIdentifiers{
                items.append(objectID)
            }
            
            snapshot.appendItems(items, toSection: Section.injection.rawValue)
        }
        
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
 /*   func applySnapshot(_ snapshot: NSDiffableDataSourceSnapshot<Int, NSManagedObjectID>, toSection section: Section){
        
        
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
        
        
        
    }*/
    
    func configureDataSource() {
        
  
        dataSource = InjectionDiffableDataSource(tableView: tableView) { (tableView, indexPath, objectID) -> UITableViewCell? in
                
                
            var injection: Injection
                
            var queueObject: Queue?
                
            if indexPath.section == Section.queue.rawValue{
                    
                let path = IndexPath(item: indexPath.item, section: indexPath.section)
                    
                queueObject = self.viewModel.getQueueObject(forIndexPath: path)
                    
                injection = queueObject!.injection!
            }
            else{
 
                injection = self.viewModel.getInjection(withObjectID: objectID)
            }
                
                
            if indexPath.section == Section.queue.rawValue{
                
                let cell = tableView.dequeueReusableCell(withIdentifier: self.queueReuseIdentifier, for: indexPath) as! SelectQueueObjectTableViewCell
                
                cell.accessoryType = .none
                
                cell.setQueueObject(queueObject!)
                
                cell.mode = .small
                
                if let selectedQueue = self.viewModel.selectedQueueObject{
                    if selectedQueue == queueObject {
                        cell.accessoryType = .checkmark
                    }
                }
                
                    
               /* var content = cell.defaultContentConfiguration()
                content.text = injection.descriptionString
                content.secondaryText = injection.scheduledString
                    
                content.secondaryText?.append(" | Missed: \(queueObject!.dateDue!.fullDateTime)")
                    
                if let snoozedUntil = queueObject?.snoozedUntil{
                    content.secondaryText?.append("| Snoozed until: \(snoozedUntil)")
                }
                    
                if let selectedQueue = self.viewModel.selectedQueueObject{
                    if selectedQueue == queueObject {
                        cell.accessoryType = .checkmark
                    }
                }
                
                cell.contentConfiguration = content*/
                
                return cell
                    
            }
            else{
                
                let cell = tableView.dequeueReusableCell(withIdentifier: self.injectionReuseIdentifier, for: indexPath) as! InjectionTableViewCell
                cell.accessoryType = .none
                
                cell.setInjection(injection)
                cell.mode = .small
                
                    
                if self.viewModel.isInjectionInQueue(injectionManagedID: injection.objectID){
                    cell.isInjectionDisabled = true
                } else {
                    cell.isInjectionDisabled = false
                }
                    
                if let selectedInjection = self.viewModel.selectedInjection{
                    if selectedInjection == injection{
                        cell.accessoryType = .checkmark
                    }
                }
                
                return cell
            }
                
                
        }
        
        dataSource.viewController = self

        // initial data
        var snapshot = NSDiffableDataSourceSnapshot<Int, NSManagedObjectID>()
        
        let sections = [Section.queue.rawValue, Section.injection.rawValue]
        
        snapshot.appendSections(sections)
        
        dataSource.apply(snapshot, animatingDifferences: false)
    }
}

extension SelectInjectionTableViewController: UITableViewDelegate{
    
    func isCellDisabled(indexPath: IndexPath) -> Bool {
        if Section(rawValue: indexPath.section) == .injection{
            
            if let snapshot = viewModel.typeSafeInjectionSnapshot{
                let id =  snapshot.itemIdentifiers[indexPath.row]
                
                if viewModel.isInjectionInQueue(injectionManagedID: id){
                    return true
                }
                else{
                    return false
                }
            }
            else{
                return false
            }
            
        }
        else{
            return false
        }
    }
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        !isCellDisabled(indexPath: indexPath)

    }
    
/*    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        
        let cell = tableView.cellForRow(at: indexPath)
        
        if isCellDisabled(indexPath: indexPath) {
            cell?.selectionStyle = .none
            
        } else {
            
        }
    }*/
    
  /*  func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        isCellDisabled(indexPath: indexPath)
        
    }*/
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = tableView.cellForRow(at: indexPath)
        
        guard !isCellDisabled(indexPath: indexPath) else { return }
        
        if indexPath.section == Section.queue.rawValue{
            
            //let path = IndexPath(item: indexPath.item-1, section: indexPath.section)
            
            viewModel.selectedInjection = nil
            viewModel.selectedQueueObject = viewModel.getQueueObject(forIndexPath: indexPath)
            
            let injection = viewModel.selectedQueueObject!.injection!
            
            
            //it's possible a person could have had a scheduled injection, missed a dose, and changed it to "As needed"
            //so there'd still be a queued injection for that.
            if injection.typeVal == .scheduled{
                
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
                let id =  snapshot.itemIdentifiers[indexPath.row]
                
                let injection = viewModel.getInjection(withObjectID: id)
                
                    
                    viewModel.selectedInjection = injection
                    viewModel.selectedQueueObject = nil
                    
                    if injection.typeVal == .scheduled{
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
        
        cell?.accessoryType = .checkmark
        tableView.reloadData()
        
       
    }
    
    
}

