//
//  InjectionCollectionViewController.swift
//  SubQ
//
//  Created by Constantine Thalasinos on 5/4/23.
//

import UIKit
import Combine
import CoreData

class InjectionViewController: UIViewController, Coordinated {
    
    weak var coordinator: Coordinator?
    
    weak var injectionCoordinator: InjectionCoordinator?
    
    var dataSource: UICollectionViewDiffableDataSource<Int, NSManagedObjectID>! = nil
    var collectionView: UICollectionView! = nil
    
    let viewModel: InjectionViewModel
    
    var cancellables = Set<AnyCancellable>()
    
    //UIViewController already has an "isEditing property"
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
        
        view.backgroundColor = .purple
        
        setBarButtons()
        
        configureHierarchy()
        configureDataSource()
        
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
                self?.collectionView.reloadData()
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
    
    func presentDeleteAlertController(forInjection injection: Injection){
        let alert = UIAlertController(title: "Delete Injection", message: "Are you sure you want to delete \(injection.name!)? \n\n Note, this will also delete any snoozed/queued instances of this injection.", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { [self] _ in
                
            viewModel.deleteInjection(injection)
        }))
        
        self.present(alert, animated: true)
    }
    
    init(viewModel: InjectionViewModel){
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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

extension InjectionViewController{
    private func createLayout() -> UICollectionViewLayout {
        var config = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        
        config.trailingSwipeActionsConfigurationProvider = { [unowned self] indexPath in

            let injection = self.viewModel.object(at: indexPath)
            
            let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { action, sourceView, completion in
                
                
                self.presentDeleteAlertController(forInjection: injection)
                
              //  self.viewModel.deleteInjection(injection)
                completion(true)
            }
            return .init(actions: [deleteAction])
        }

        
        return UICollectionViewCompositionalLayout.list(using: config)
    }
}

extension InjectionViewController{
    private func configureHierarchy(){
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(collectionView)
        collectionView.delegate = self
    }
    
    private func configureDataSource() {
        
        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, NSManagedObjectID> { [weak self] (cell, indexPath, injectionId) in
            
            guard let injection = self?.viewModel.object(at: indexPath) else {
              return
            }
            
            var content = cell.defaultContentConfiguration()
            content.text = injection.descriptionString
            
            content.secondaryText = injection.scheduledString
            
           /* if !injection.areNotificationsEnabled && injection.daysVal != [.asNeeded]{
                content.textProperties.color = .gray
                content.secondaryTextProperties.color = .gray
            }
            else{
                content.textProperties.color = .label
                content.secondaryTextProperties.color = .label
            }*/
            
            cell.contentConfiguration = content
            cell.accessories = [.delete(displayed: .whenEditing, actionHandler: {
                self?.presentDeleteAlertController(forInjection: injection)
                
                //self?.viewModel.deleteInjection(injection)
            })]
            
            /*if injection.daysVal != [.asNeeded]{
                let switchAccessory = self!.createNotificationSwitchAccessoryView(forInjection: injection)
                cell.accessories.append(.customView(configuration: switchAccessory))
            }*/
        }
        
        dataSource = UICollectionViewDiffableDataSource<Int, NSManagedObjectID>(collectionView: collectionView) {
            (collectionView: UICollectionView, indexPath: IndexPath, injectionId: NSManagedObjectID) -> UICollectionViewCell? in
            
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: injectionId)
        }

        // initial data
        var snapshot = NSDiffableDataSourceSnapshot<Int, NSManagedObjectID>()
        snapshot.appendSections([0])
        
        dataSource.apply(snapshot, animatingDifferences: false)
    }
    
    func createNotificationSwitchAccessoryView(forInjection injection: Injection) -> UICellAccessory.CustomViewConfiguration{
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
                    NotificationManager.removeExistingNotifications(forInjection: injection)
                }
            }))
            
            self.present(alert, animated: true)
            
        }
        
        notificationSwitch.addAction(action, for: .primaryActionTriggered)
        
        return UICellAccessory.CustomViewConfiguration(customView: notificationSwitch, placement: .trailing(displayed: .whenNotEditing), reservedLayoutWidth: .actual)
    }
    
    
}

extension InjectionViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: false)
        
        let injection = self.viewModel.object(at: indexPath)
        
        injectionCoordinator?.editInjection(injection)
    }
}
