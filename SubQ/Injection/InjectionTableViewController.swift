//
//  InjectionTableViewController.swift
//  SubQ
//
//  Created by Constantine Thalasinos on 8/20/23.
//

import UIKit
import Combine
import CoreData

class InjectionTableViewController: UIViewController, Coordinated {
    
    enum EditAction: String {
        case created = "created", deleted = "deleted", updated = "updated"
    }
    
    let reuseIdentifier = "reuse-id"
    
    weak var coordinator: Coordinator?
    
    weak var injectionCoordinator: InjectionCoordinator?
    
    var dataSource: InjectionDiffableDataSource! = nil

    var tableView: UITableView! = nil
    
    let viewModel: InjectionViewModel
    
    var cancellables = Set<AnyCancellable>()
    
    class InjectionDiffableDataSource: UITableViewDiffableDataSource<Int, NSManagedObjectID> {
        
        weak var viewController: InjectionTableViewController?
        
        override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
            if editingStyle == .delete{
                
                let injection = viewController!.viewModel.object(at: indexPath)
                
                viewController?.presentDeleteAlertController(forInjection: injection)
            }
        }
        
    }

    
    
    
    //UIViewController already has an "isEditing property"
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
        
        view.backgroundColor = .systemBackground
    
        
        setBarButtons()
        
        configureHierarchy()
        configureDataSource()
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 50
        
        viewModel.snapshot
          .sink(receiveValue: { [weak self] snapshot in
            if let snapshot = snapshot {
                if snapshot.numberOfItems == 0{
                    self?.navigationItem.leftBarButtonItem?.isEnabled = false
                }
                else{
                    self?.navigationItem.leftBarButtonItem?.isEnabled = true
                }
                
              self?.dataSource.apply(snapshot, animatingDifferences: true)
            self?.tableView.reloadData()
            }
          })
          .store(in: &cancellables)

        // Do any additional setup after loading the view.
    }
    
    private func setBarButtons(){
        
        if !isInEditMode{
            
            navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editButtonPressed))
            
            if let dataSource{
                if dataSource.snapshot().numberOfItems == 0{
                    navigationItem.leftBarButtonItem!.isEnabled = false
                }
            }
            
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonPressed))
        }
        else{
            navigationItem.leftBarButtonItem = nil
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonPressed))
        }
    }
    
    @objc func editButtonPressed(_ sender: Any){
        print("edit")
        isInEditMode = true
    }
    
    @objc func addButtonPressed(_ sender: Any){
        print("add")
        injectionCoordinator!.addInjection()
    }
    
    @objc func doneButtonPressed(_ sender: Any){
        print("done")
        isInEditMode = false
    }
    
    init(viewModel: InjectionViewModel){
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
   /* func showConfirmationView(injectionDescriptionString: String, action: EditAction) {
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.layer.cornerRadius = 10
        containerView.layer.masksToBounds = true
        
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.text = "\(injectionDescriptionString) \(action.rawValue)."
        label.font = UIFont.systemFont(ofSize: 13)
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .center
        label.numberOfLines = 0
        
        
        if action == .deleted {
            label.backgroundColor = .systemRed
            containerView.backgroundColor = .systemRed
        } else {
            label.backgroundColor = .systemBlue
            containerView.backgroundColor = .systemBlue
        }
        
        containerView.addSubview(label)
        label.snp.makeConstraints { make in
            make.trailing.bottom.equalToSuperview().offset(-7)
            make.leading.top.equalToSuperview().offset(7)
        }
        
        view.addSubview(containerView)
        
        containerView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottomMargin.equalToSuperview().offset(-60)
            
        }
        
        UIView.transition(with: containerView, duration: 5,
                          options: .transitionCrossDissolve,
                          animations: {
                        containerView.alpha = 0
            
        }) { _ in
            label.removeFromSuperview()
            containerView.removeFromSuperview()
        }
        
    }*/

}

extension InjectionTableViewController{
    func configureHierarchy() {
        tableView = UITableView(frame: view.bounds, style: .insetGrouped)
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        tableView.register(InjectionTableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
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
    
    func configureDataSource() {
        
        // data source
        
        dataSource = InjectionDiffableDataSource(tableView: tableView) { (tableView, indexPath, injectionId) -> UITableViewCell? in
            
            let injection = self.viewModel.object(at: indexPath)
            
            let cell = tableView.dequeueReusableCell(withIdentifier: self.reuseIdentifier, for: indexPath) as! InjectionTableViewCell
            
            cell.setInjection(injection)
            cell.mode = .normal
            
            if injection.typeVal == .scheduled && !injection.areNotificationsEnabled {
                cell.isInjectionDisabled = true
            } else{
                cell.isInjectionDisabled = false
            }
            
           // let cell = tableView.dequeueReusableCell(withIdentifier: self.reuseIdentifier, for: indexPath)
            
            cell.accessoryView = nil
            
           /* var content = cell.defaultContentConfiguration()
            
            content.text = injection.descriptionString
            
            content.secondaryText = injection.scheduledString
            
            if !injection.areNotificationsEnabled && injection.typeVal == .scheduled {
                 content.textProperties.color = .gray
                 content.secondaryTextProperties.color = .gray
             }
             else{
                 content.textProperties.color = .label
                 content.secondaryTextProperties.color = .label
             }
            
            cell.contentConfiguration = content*/
            
            if injection.typeVal == .scheduled {
                cell.accessoryView = self.createNotificationSwitchAccessoryView(forInjection: injection)
            }

            return cell
        }
        
        dataSource.viewController = self
        
        // initial data
        
        var snapshot = NSDiffableDataSourceSnapshot<Int, NSManagedObjectID>()
        snapshot.appendSections([0])
        
        dataSource.apply(snapshot, animatingDifferences: false)
    }
    
    func createNotificationSwitchAccessoryView(forInjection injection: Injection) -> UISwitch{
        let notificationSwitch = UISwitch()
        
        notificationSwitch.isOn = injection.areNotificationsEnabled
        
        let action = UIAction { _ in
            
            let updatedStatusString = injection.areNotificationsEnabled ? "disable" : "enable"
            
            let alert = UIAlertController(title: "Disable Notifications", message: "Are you sure you want to \(updatedStatusString) notifications for \(injection.descriptionString) | \(injection.scheduledString)?", preferredStyle: .actionSheet)
            
            if injection.areNotificationsEnabled{
                alert.message?.append("\n\n (note, You will still be able to select this injection via the Inject Now tab & and any notifications currently snoozed will be disabled.)")
            }
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { [self] _ in
                notificationSwitch.setOn(injection.areNotificationsEnabled, animated: true)
            }))
            
            alert.addAction(UIAlertAction(title: "Confirm", style: .destructive, handler: { [self] _ in
                    
                self.viewModel.updateAreNotificationsEnabled(forInjection: injection, withValue: !injection.areNotificationsEnabled)
                
                if injection.areNotificationsEnabled{
                    NotificationManager.scheduleNotifications(forInjection: injection)
                }
                else{
                    NotificationManager.removeExistingNotifications(forInjection: injection, removeQueued: true)
                }
            }))
            
            self.present(alert, animated: true)
            
        }
        
        notificationSwitch.addAction(action, for: .primaryActionTriggered)
        
        return notificationSwitch
    }
}

extension InjectionTableViewController: UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        
        cell?.setSelected(false, animated: true)
        
        let injection = self.viewModel.object(at: indexPath)
        
        injectionCoordinator?.editInjection(injection)
        
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { action, view, handler in
            self.presentDeleteAlertController(forInjection: self.viewModel.object(at: indexPath))
        }
        
        deleteAction.backgroundColor = .red
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        configuration.performsFirstActionWithFullSwipe = true
        
        return configuration
    }
    
    func presentDeleteAlertController(forInjection injection: Injection){
        let alert = UIAlertController(title: "Delete Injection", message: "Are you sure you want to delete \(injection.name!) \(injection.dosage!) \(injection.units!)? \n\n Note, this will also delete any snoozed/queued instances of this injection.", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {[self] _ in
            tableView.reloadData()
        }))
        
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { [self] _ in
                
            self.viewModel.deleteInjection(injection)
        }))
        
        self.present(alert, animated: true)
    }
    
    
}
