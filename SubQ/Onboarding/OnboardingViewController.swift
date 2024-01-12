//
//  OnboardingViewController.swift
//  SubQ
//
//  Created by Constantine Thalasinos on 9/27/23.
//

import UIKit
import SnapKit
import LocalAuthentication

class OnboardingViewController: UIViewController {
    
    let controllers: [OnboardingChildViewController]
    
    let viewModel: OnboardingViewModel
                       
    var displayedCellIndex: Int = 0
    
    private var userScroll = false
    
    private var scrollOffset = CGPoint(x: 0, y: 0)
    
    weak var coordinator: OnboardingCoordinator?
    
    lazy var pageControlAction: UIAction = {
        
        return UIAction { _ in
            self.moveCollectionView(toCellIndex: self.pageControl.currentPage)
        }
    
    }()
    
    lazy var pageControl: UIPageControl = {
        let control = UIPageControl(frame: .zero, primaryAction: pageControlAction)
        control.numberOfPages = controllers.count
        control.currentPage = 0
        control.currentPageIndicatorTintColor = .label
        control.pageIndicatorTintColor = .gray
        control.allowsContinuousInteraction = false
        
        return control
    }()
    
    private let cellReuseIdentifier = "reuseIdentifier"
    
    private lazy var collectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = CGFloat(0)
        layout.minimumLineSpacing = CGFloat(0)
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.isPagingEnabled = true
        view.translatesAutoresizingMaskIntoConstraints = false
        
        view.showsHorizontalScrollIndicator = false
        
        view.isScrollEnabled = true
        
        view.dataSource = self
        view.delegate = self
        
        
        return view
    }()
    
    init(viewModel: OnboardingViewModel, coordinator: OnboardingCoordinator) {
        self.viewModel = viewModel
        self.coordinator = coordinator
        
        let context = LAContext()
        var error: NSError?
        
        var lockMethod: ScreenLockOnboardingViewController.LockMethod?
        
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            lockMethod = .faceId
        }
            
        else if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
            lockMethod = .passcode
        }
        
        if let lockMethod {
            
            controllers = [WelcomeViewController(), NotificationsViewController(), BodyPartViewController(viewModel: viewModel), ScreenLockOnboardingViewController(enabledLockMethod: lockMethod), TermsViewController(coordinator: coordinator)]
        } else {
            controllers = [WelcomeViewController(), NotificationsViewController(), BodyPartViewController(viewModel: viewModel), TermsViewController(coordinator: coordinator)]

        }
        
        
        super.init(nibName: nil, bundle: nil)
        
        for controller in controllers {
            controller.onboardingViewController = self
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setLogoTitleView()
        
        
        collectionView.register(OnboardingCollectionViewCell.self, forCellWithReuseIdentifier: cellReuseIdentifier)
        
        view.addSubview(collectionView)
        view.backgroundColor = .systemBackground
        
        let guide = view.safeAreaLayoutGuide

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalToSystemSpacingBelow: guide.topAnchor, multiplier: 1.0),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -100)
        ])
        
        view.addSubview(pageControl)
        
        pageControl.snp.makeConstraints { make in
            make.centerX.leftMargin.rightMargin.equalToSuperview()
            make.top.equalTo(collectionView.snp.bottom).offset(25)
        }
        
      

    }
    

}

extension OnboardingViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return controllers.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellReuseIdentifier, for: indexPath) as! OnboardingCollectionViewCell
        
        cell.hostedView = controllers[indexPath.item].view
        
        return cell
    }
    
}

extension OnboardingViewController: UICollectionViewDelegate {
    
}

extension OnboardingViewController: UICollectionViewDelegateFlowLayout{
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        guard let frame = self.view.window?.frame else { return CGSize(width: 0.0, height: 0.0) }

        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
        
    }
}

extension OnboardingViewController: UIScrollViewDelegate{
    
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        scrollOffset = scrollView.contentOffset
        userScroll = true
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        
        if userScroll{
            
        }
        
        userScroll = false
        
    }
   
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let deltaX = abs(scrollOffset.x - scrollView.contentOffset.x)
        let deltaY = abs(scrollOffset.y - scrollView.contentOffset.y)
        
        
        if userScroll{
            
            if let newIndex = getNewSelectedIndex() {
                displayedCellIndex = newIndex
                pageControl.currentPage = newIndex
                
            }
            
        }
        
    }
    
    /*
     checks to see if the user scrolled fully to another segment.
     */
    
    private func getNewSelectedIndex() -> Int?{
        
        let offset = collectionView.contentOffset.x
        
        let cellWidth = collectionView.contentSize.width / CGFloat(controllers.count)
        
        let currentCellStart = displayedCellIndex == 0 ? 0: cellWidth * CGFloat(displayedCellIndex)
        
        let currentCellHalf = (currentCellStart) + cellWidth / 2
            
            //for cases where the user is scrolling to the left
            if offset < currentCellStart{
                
                //can't go any farther left
                guard displayedCellIndex > 0 else { return nil }
                
                let previousIndex = displayedCellIndex - 1
                    
                let previousCellStart = previousIndex == 0 ? 0: cellWidth * CGFloat(previousIndex)
                    
                let previousHalfwayPoint = (previousCellStart) + cellWidth / 2
                    
                if offset <= previousHalfwayPoint{
                    return previousIndex
                }
                else{
                    return nil
                }
               
            }
            //otherwise, we're going right
            else if offset > currentCellStart {

                guard displayedCellIndex < controllers.count - 1 else { return nil }
                
                let nextIndex = displayedCellIndex + 1
                
                let nextCellStart = cellWidth * CGFloat(nextIndex)
                    
                let nextCellHalfwayPoint = (nextCellStart) + cellWidth / 2
                    
                if offset > currentCellHalf{
                    return nextIndex
                }
                else{
                    return nil
                }
                
            }
            else{
                return nil
            }
    }
    
    func moveCollectionView(toCellIndex index: Int) {
        
        let cellWidth = collectionView.contentSize.width / CGFloat(controllers.count)
        
        if index == 0{
            let frame = CGRect(x: 0, y: collectionView.contentOffset.y, width: collectionView.frame.width, height: self.collectionView.frame.height)
            collectionView.scrollRectToVisible(frame, animated: true)
        }
        else{
            let frame = CGRect(x: collectionView.frame.maxX * CGFloat(index), y: collectionView.contentOffset.y, width: collectionView.frame.width, height: self.collectionView.frame.height)

            collectionView.scrollRectToVisible(frame, animated: true)
        }
        
    }
    
    func moveToNextIndex() {
        
        let currentIndex = pageControl.currentPage
        
        if currentIndex < pageControl.numberOfPages - 1 {
            
            let nextIndex = currentIndex + 1
            
            pageControl.currentPage = nextIndex
            
            moveCollectionView(toCellIndex: nextIndex)
            
        }
        
    }
}
