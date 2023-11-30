//
//  BodyPartViewController.swift
//  SubQ
//
//  Created by Constantine Thalasinos on 9/28/23.
//

import UIKit
import CoreData
import Combine
import Lottie

class BodyPartViewController: UIViewController, OnboardingChildViewController {
    
    
    weak var onboardingViewController: OnboardingViewController?

    let viewModel: OnboardingViewModel
    
    var cancellables = Set<AnyCancellable>()
    
 
    private var dataSource: UICollectionViewDiffableDataSource<Int, NSManagedObjectID>! = nil
    private var collectionView: UICollectionView! = nil
    
    let animationView: LottieAnimationView = {
        
        let view = LottieAnimationView(asset: "body")
        view.translatesAutoresizingMaskIntoConstraints = false
        
        view.loopMode = .loop
        view.animationSpeed = 0.75

        view.play()
        
        return view
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Select Injection Sites"
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 30)

        label.numberOfLines = 0
        
        return label
    }()
    
    let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "(Note: These Can Be Changed Later in Settings)"
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 15)
        label.numberOfLines = 0
        label.textColor = .gray

        return label
    }()
    
    lazy var stackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        stack.axis = .vertical
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.spacing = 10
        return stack
    }()

    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(animationView)
        view.addSubview(stackView)
        
        animationView.snp.makeConstraints { make in
            make.top.leftMargin.rightMargin.equalToSuperview()
            make.height.equalTo(350)
        }
        
        stackView.snp.makeConstraints { make in
            make.leftMargin.rightMargin.equalToSuperview()
            make.top.equalTo(animationView.snp.bottom)
        }
        
        
        configureHierarchy()
        configureDataSource()
        
        viewModel.bodyPartSnapshot
          .sink(receiveValue: { [weak self] snapshot in
            if let snapshot = snapshot {
                
                self?.dataSource.apply(snapshot, animatingDifferences: true)

            }
          })
          .store(in: &cancellables)
        
        
    }
    
    init(viewModel: OnboardingViewModel) {
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}

extension BodyPartViewController{
    
    private func createLayout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout { [unowned self] section, layoutEnvironment in
            var config = UICollectionLayoutListConfiguration(appearance: .insetGrouped)

            config.backgroundColor = .systemBackground
            
            return NSCollectionLayoutSection.list(using: config, layoutEnvironment: layoutEnvironment)
        }
    }
    
    private func configureHierarchy() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: stackView.bottomAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        collectionView.delegate = self
    }
    
    private func configureDataSource() {
        
        
        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, NSManagedObjectID> { [weak self] (cell, indexPath, item) in
            guard let self = self else { return }
            
            var content = cell.defaultContentConfiguration()
            
            let obj = viewModel.bodyPart(at: indexPath)
            
            content.text = obj.part
            
            if viewModel.selectedBodyParts[indexPath.item] {
                cell.accessories = [.checkmark(options: .init(tintColor: InterfaceDefaults.primaryColor))]
            } else {
                cell.accessories = []
            }
            
            
            cell.contentConfiguration = content
            
            var backgroundConfig = UIBackgroundConfiguration.listGroupedCell()
            backgroundConfig.backgroundColor = .secondarySystemBackground
            
            cell.backgroundConfiguration = backgroundConfig

        }
        
        
        dataSource = UICollectionViewDiffableDataSource<Int, NSManagedObjectID>(collectionView: collectionView) {
            (collectionView: UICollectionView, indexPath: IndexPath, item: NSManagedObjectID) -> UICollectionViewCell? in
          
                return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: item)
        }
        
        
        // initial data
        var snapshot = NSDiffableDataSourceSnapshot<Int, NSManagedObjectID>()
        
        snapshot.appendSections([0])
  
        dataSource.apply(snapshot, animatingDifferences: false)
        
    }
}

extension BodyPartViewController: UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let section = indexPath.section
        let item = indexPath.item
        
        let cell = collectionView.cellForItem(at: indexPath) as! UICollectionViewListCell
        
        
        if !cell.accessories.isEmpty{
            cell.accessories = []
            viewModel.selectedBodyParts[item] = false
        } else{
            cell.accessories = [.checkmark(options: .init(tintColor: InterfaceDefaults.primaryColor))]
            viewModel.selectedBodyParts[item] = true
        }
        
        collectionView.deselectItem(at: indexPath, animated: false)
        
    }
    
}

