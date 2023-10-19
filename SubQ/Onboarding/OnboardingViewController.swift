//
//  OnboardingViewController.swift
//  SubQ
//
//  Created by Constantine Thalasinos on 9/27/23.
//

import UIKit
import SnapKit

class OnboardingViewController: UIViewController {
    
    let controllers: [UIViewController]
    
    let viewModel: OnboardingViewModel
                       
    var displayedCellIndex: Int = 0
    
    private var userScroll = false
    
    private var scrollOffset = CGPoint(x: 0, y: 0)
    
    weak var coordinator: OnboardingCoordinator?
    
 /*   lazy var stackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [pageControl, startButton])
        stack.axis = .vertical
        stack.spacing = 10
        
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        return stack
    }()
    
    lazy var startButton: UIButton = {
        
        var buttonConfig = UIButton.Configuration.filled()
        buttonConfig.buttonSize = .large
        buttonConfig.cornerStyle = .capsule
        buttonConfig.title = "Get Started"
        buttonConfig.baseBackgroundColor = .blue
        
        let button =  UIButton(configuration: buttonConfig, primaryAction: startAction)
        button.isEnabled = false
       // button.translatesAutoresizingMaskIntoConstraints = false

        return button
    }()
    
    lazy var startAction: UIAction = {
        return UIAction { _ in
            self.coordinator!.startButtonPressed()
        }
    }()*/
    
    lazy var pageControlAction: UIAction = {
        
        return UIAction { _ in
            /*if self.pageControl.currentPage == self.controllers.count - 1 {
                self.startButton.isEnabled = true
            }*/
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
        
        controllers = [WelcomeViewController(), NotificationsViewController(), BodyPartViewController(viewModel: viewModel), TermsViewController(coordinator: coordinator)]
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //self.navigationItem.title = "SubQ"
        
/*        let image = UIImage(named: "logo")
    
        //let containerView = UIView(frame: CGRect(x: 0, y: 0, width: 137, height: 45))
        
        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: 91.3, height: 30))
        
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        
        imageView.frame = containerView.bounds
        
        containerView.addSubview(imageView)
        
        navigationItem.titleView = containerView*/
        
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

       /* collectionView.snp.makeConstraints { make in
            make.topMargin.left.right.equalToSuperview()
            make.bottomMargin.equalToSuperview().offset(-200)
        }*/
        
      /*  view.addSubview(pageControl)
        pageControl.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(collectionView.snp.bottom).offset(25)
        }*/
        
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
        /*if indexPath.row == 0 {
            cell.contentView.backgroundColor = .blue
        } else if indexPath.row == 1 {
            cell.contentView.backgroundColor = .gray
        } else if indexPath.row == 2 {
            cell.contentView.backgroundColor = .orange
        } else {
            cell.contentView.backgroundColor = .green
        }*/
        
        cell.hostedView = controllers[indexPath.item].view
        
        return cell
    }
    
}

extension OnboardingViewController: UICollectionViewDelegate {
    
}

extension OnboardingViewController: UICollectionViewDelegateFlowLayout{
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        guard let frame = self.view.window?.frame else { return CGSize(width: 0.0, height: 0.0) }
        
       // collectionViewHeight = frame.height
        
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
                print(newIndex)
                displayedCellIndex = newIndex
                pageControl.currentPage = newIndex
                
               /* if newIndex == controllers.count - 1 {
                    startButton.isEnabled = true
                }*/
            }
        
/*         if deltaX >= deltaY{
                scrollView.contentOffset = CGPoint(x: scrollView.contentOffset.x, y: scrollOffset.y)
                
                segmentedControl.moveSegment(toOffset: scrollView.contentOffset.x)
            }
            else{
                scrollView.contentOffset = CGPoint(x: scrollOffset.x, y: scrollView.contentOffset.y)
            }*/
            
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
}
