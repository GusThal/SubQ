//
//  FrequencyCoordinator.swift
//  SubQ
//
//  Created by Constantine Thalasinos on 5/13/23.
//

import Foundation
import UIKit

class DaysCoordinator: ModalChildCoordinator{
    
    
    weak var parentNavigationController: UINavigationController?
    
    weak var parentCoordinator: Coordinator?
    
    var storageProvider: StorageProvider
    
    var viewModel: EditInjectionViewModel?
    
    init(navigationController: UINavigationController, parentNavigationController: UINavigationController, parentCoordinator: Coordinator, storageProvider: StorageProvider) {
        self.navigationController = navigationController
        self.parentNavigationController = parentNavigationController
        self.parentCoordinator = parentCoordinator
        self.storageProvider = storageProvider
    }
    
    
    var childCoordinators = [Coordinator]()
    
    var navigationController: UINavigationController
    
    
    
    func start() {
        
        print(viewModel!.selectedDayCellIndex)
        
        let selectedDays = viewModel!.frequencies[viewModel!.selectedDayCellIndex].days
        
        let vc = DaysViewController(selectedFrequency: selectedDays)
    
        vc.coordinator = self
        vc.frequencyCoordinator = self

        vc.title = "Days"
        
        navigationController.navigationBar.prefersLargeTitles = true
        
        navigationController.pushViewController(vc, animated: false)
        
        vc.modalPresentationStyle = .automatic
        
    
        
        parentNavigationController!.present(navigationController, animated: true)
    }
    
    func done(isDailySelected: Bool, selectedDays: [Bool]){
        parentNavigationController!.dismiss(animated: true)

        parentCoordinator?.childDidFinish(self)
        
        guard let viewModel else { return }
        
        
        
        if isDailySelected{
            viewModel.frequencies[viewModel.selectedDayCellIndex].days = [.daily]
            viewModel.currentValueSelectedDay.value = [.daily]
        }

        else{
            viewModel.frequencies[viewModel.selectedDayCellIndex].days = []
            viewModel.currentValueSelectedDay.value = []

            
            for (i, day) in viewModel.days.enumerated(){
                
                if selectedDays[i]{
                    viewModel.frequencies[viewModel.selectedDayCellIndex].days?.append(day)
                    viewModel.currentValueSelectedDay.value.append(day)

                }
                
            }
            
        }
        
    }
    
    
}
