//
//  FilterCoordinator.swift
//  SubQ
//
//  Created by Constantine Thalasinos on 8/3/23.
//

import Foundation
import UIKit

class FilterCoordinator: ModalChildCoordinator{
    var parentNavigationController: UINavigationController?
    
    let viewModel: HistoryViewModel
    
    var childCoordinators = [Coordinator]()
    
    var navigationController: UINavigationController
    
    var parentCoordinator: Coordinator?
    
    var storageProvider: StorageProvider
    
    init(navigationController: UINavigationController, parentNavigationController: UINavigationController, parentCoordinator: Coordinator, storageProvider: StorageProvider, viewModel: HistoryViewModel) {
        
        self.navigationController = navigationController
        self.parentNavigationController = parentNavigationController
        self.parentCoordinator = parentCoordinator
        self.storageProvider = storageProvider
        self.viewModel = viewModel
        
    }
    
    
    
    func start() {
        let vc = FilterTableViewController(viewModel: viewModel)
        
        
        vc.coordinator = self
        vc.filterCoordinator = self
        
       // navigationController.modalPresentationStyle = .pageSheet
        
       
        vc.title = "Filter"
        
        if let presentationController = navigationController.presentationController as? UISheetPresentationController {
            presentationController.detents = [.medium(), .large()]
            presentationController.prefersScrollingExpandsWhenScrolledToEdge = false
        }
        
        navigationController.pushViewController(vc, animated: false)
        
        
        parentNavigationController!.present(navigationController, animated: true)
    }
    
    func applyFilters(sortDateBy: HistoryViewModel.DateSorting, status: History.InjectStatus, startDate: Date, endDate: Date){
        
        viewModel.applyFilters(sortDateBy: sortDateBy, status: status, startDate: startDate, endDate: endDate)
        
        dismiss()
    }
    
    func resetToDefaults(){
        
        viewModel.applyDefaultFilters()
        
        dismiss()
    }
    
    func dismiss(){
        parentNavigationController!.dismiss(animated: true)
        parentCoordinator?.childDidFinish(self)
    }
    
    
}
