//
//  InjectionHistoryViewController.swift
//  SubQ
//
//  Created by Constantine Thalasinos on 5/4/23.
//

import UIKit
import Combine
import CoreData

class HistoryViewController: UIViewController, Coordinated {
    
    weak var coordinator: Coordinator?
    
    weak var historyCoordinator: HistoryCoordinator?
    
    let viewModel: HistoryViewModel
    
    var dataSource: UICollectionViewDiffableDataSource<Int, NSManagedObjectID>! = nil
    var collectionView: UICollectionView! = nil
    
    var cancellables = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()
        
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
    
    init(viewModel: HistoryViewModel){
        
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    


}

extension HistoryViewController{
    private func createLayout() -> UICollectionViewLayout {
        var config = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        
        return UICollectionViewCompositionalLayout.list(using: config)
    }
}

extension HistoryViewController{
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
            
            guard let site = history.site else { return }
            
            var content = cell.defaultContentConfiguration()
            content.text = "\(history.date!.fullDateTime): \(site.subQuadrantVal) of \(site.section!.quadrantVal) of \(site.section!.bodyPart!.part!)"
            content.secondaryText = "\(injection.name!) \(injection.dosage!) \(injection.units!) | \(injection.daysVal.map({ $0.shortened}).joined(separator: ", "))"
            
            
            if injection.daysVal != [Injection.Frequency.asNeeded] {
                if let time = injection.prettyTime{
                    content.secondaryText!.append(" | \(time)")
                }
            }
            
            
            cell.contentConfiguration = content
            
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
    
}

extension HistoryViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: false)
    }
}
