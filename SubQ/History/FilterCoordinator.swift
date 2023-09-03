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
        
        //custom detent logic via https://nemecek.be/blog/159/how-to-configure-uikit-bottom-sheet-with-custom-size
        
        if let presentationController = navigationController.presentationController as? UISheetPresentationController {
            presentationController.detents = [.custom(resolver: { context in
                return context.maximumDetentValue * 0.7
            }), .large()]
            presentationController.prefersScrollingExpandsWhenScrolledToEdge = false
        }
        
        navigationController.pushViewController(vc, animated: false)
        
        
        parentNavigationController!.present(navigationController, animated: true)
    }
    
    func applyFilters(sortDateBy: HistoryViewModel.DateSorting, status: History.InjectStatus, type: Injection.InjectionType, startDate: Date, endDate: Date){
        
        viewModel.applyFilters(sortDateBy: sortDateBy, status: status, type: type, startDate: startDate, endDate: endDate)
        
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
