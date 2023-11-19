//
//  TermsViewController.swift
//  SubQ
//
//  Created by Constantine Thalasinos on 9/28/23.
//

import UIKit
import Lottie
import Combine

class TermsViewController: UIViewController {
    
    let coordinator: OnboardingCoordinator
    
    private var dataSource: UICollectionViewDiffableDataSource<Int, String>! = nil
    private var collectionView: UICollectionView! = nil
    
    @Published var isDisclaimerSelected = false
    @Published var isTermsSelected = false
    
    private var cancellables = Set<AnyCancellable>()
    
    let animationView: LottieAnimationView = {
        
        let view = LottieAnimationView(asset: "terms")
        view.translatesAutoresizingMaskIntoConstraints = false
        
        view.loopMode = .playOnce
        view.animationSpeed = 0.75
        view.contentMode = .scaleAspectFit
        
        view.play()
        
        return view
    }()
    
    
    
    let attributedString: NSAttributedString = {
        let str = NSMutableAttributedString(string: "By tapping 'Get Started' you agree to our Terms of Service.")
        str.addAttribute(.link, value: "https://sites.google.com/view/subq-app/home", range: NSRange(location: 42, length: 17))
        str.addAttribute(.foregroundColor, value: UIColor.label, range: NSRange(location: 0, length: str.length))
        str.addAttribute(.font, value: UIFont.systemFont(ofSize: 17), range: NSRange(location: 0, length: str.length))
        
        return str
    }()
    
    
    lazy var startButton: UIButton = {
        
        var buttonConfig = UIButton.Configuration.filled()
        buttonConfig.buttonSize = .large
        buttonConfig.cornerStyle = .capsule
        buttonConfig.title = "Get Started"
        buttonConfig.baseBackgroundColor = InterfaceDefaults.primaryColor
        
        let button =  UIButton(configuration: buttonConfig, primaryAction: startAction)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isEnabled = false

        return button
    }()
    
    lazy var startAction: UIAction = {
        return UIAction { _ in
            self.coordinator.startButtonPressed()
        }
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        Publishers.CombineLatest($isTermsSelected, $isDisclaimerSelected).sink { [self] terms, disclaimer in

            startButton.isEnabled = terms && disclaimer
        }.store(in: &cancellables)

        
        
        view.addSubview(animationView)
        
        animationView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview()
            make.height.equalTo(300)
        }
        
        view.addSubview(startButton)
        
        startButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.bottomMargin.equalToSuperview().offset(-25)
        }
        
        configureHierarchy()
        configureDataSource()
        
        //textView.text = "hello"f
        
   /*     view.addSubview(textView)
        textView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.edges.equalToSuperview()
        }
    */
    }
    
    init(coordinator: OnboardingCoordinator) {
        self.coordinator = coordinator
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}


extension TermsViewController {
    private func createLayout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout { [unowned self] section, layoutEnvironment in
            var config = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
            config.backgroundColor = .systemBackground
            config.showsSeparators = false
            
            return NSCollectionLayoutSection.list(using: config, layoutEnvironment: layoutEnvironment)
        }
    }
    
    private func configureHierarchy() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        //collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.allowsMultipleSelection = true
        collectionView.isScrollEnabled = false
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(animationView.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(startButton.snp.top)
        }
        
       /* NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: view.centerYAnchor),
            collectionView.bottomAnchor.constraint(equalToSystemSpacingBelow: startButton.topAnchor, multiplier: 1)
        ])*/
        
        collectionView.delegate = self
    }
    
    private func configureDataSource() {
        
        
        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, String> { [weak self] (cell, indexPath, item) in
            guard let self = self else { return }
            
            var content = cell.defaultContentConfiguration()
            
            content.text = item
            
            
            cell.contentConfiguration = content
            
            
            cell.accessories = [.multiselect(displayed: .always, options: .init(tintColor: InterfaceDefaults.primaryColor))]
            
            var backgroundConfig = UIBackgroundConfiguration.listGroupedCell()
            backgroundConfig.backgroundColor = .systemBackground
            
            cell.backgroundConfiguration = backgroundConfig

        }
        
        let linkCellRegistration = UICollectionView.CellRegistration<LinkCollectionViewListCell, String> { [weak self] (cell, indexPath, item) in
            guard let self = self else { return }
            

            cell.attributedText = attributedString
            
            var backgroundConfig = UIBackgroundConfiguration.listGroupedCell()
            backgroundConfig.backgroundColor = .systemBackground
            
            cell.backgroundConfiguration = backgroundConfig
            
            
            
            cell.accessories = [.multiselect(displayed: .always, options: .init(tintColor: InterfaceDefaults.primaryColor))]

        }
        

        
        
        
        dataSource = UICollectionViewDiffableDataSource<Int, String>(collectionView: collectionView) {
            (collectionView: UICollectionView, indexPath: IndexPath, item: String) -> UICollectionViewCell? in
            
            if indexPath.item == 0 {
                return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: item)
            } else {
                return collectionView.dequeueConfiguredReusableCell(using: linkCellRegistration, for: indexPath, item: item)
            }
          
                
        }
        
        
        // initial data
        var snapshot = NSDiffableDataSourceSnapshot<Int, String>()
        
        /*snapshot.appendSections([0])
        snapshot.appendItems([Injection.Frequency.asNeeded])*/
        snapshot.appendSections([0])
        snapshot.appendItems([InterfaceDefaults.disclaimerString])
        snapshot.appendItems(["Value 2"])
        //snapshot.appendItems(viewModel.bodyParts)
        
        dataSource.apply(snapshot, animatingDifferences: false)
        
    }
}

extension TermsViewController: UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let item = indexPath.item
        
        let cell = collectionView.cellForItem(at: indexPath) as! UICollectionViewListCell
        
        if item == 0 {
            isDisclaimerSelected = true
        } else {
            isTermsSelected = true
        }
        
       // collectionView.deselectItem(at: indexPath, animated: false)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let item = indexPath.item
        
        let cell = collectionView.cellForItem(at: indexPath) as! UICollectionViewListCell
        
        if item == 0 {
            isDisclaimerSelected = false
        } else {
            isTermsSelected = false
        }
    }
    
}
