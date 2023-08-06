//
//  FrequencyCoordinator.swift
//  SubQ
//
//  Created by Constantine Thalasinos on 5/13/23.
//

import Foundation
import UIKit

class FrequencyCoordinator: ModalChildCoordinator{
    
    
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
        let vc = FrequencyViewController(selectedFrequency: viewModel!.selectedFrequency)
        vc.coordinator = self
        vc.frequencyCoordinator = self
        
        //navigationController.present(vc, animated: true)
        
        vc.title = "Frequency"
        
        navigationController.navigationBar.prefersLargeTitles = true
        
        navigationController.pushViewController(vc, animated: false)
        
        vc.modalPresentationStyle = .automatic
        
    
        
        parentNavigationController!.present(navigationController, animated: true)
    }
    
    func done(isDailySelected: Bool, isAsNeededSelected: Bool, selectedDays: [Bool]){
        parentNavigationController!.dismiss(animated: true)

        parentCoordinator?.childDidFinish(self)
        
        guard let viewModel else { return }
        
        
        
        if isDailySelected{
            viewModel.selectedFrequency = [.daily]
        }
        else if isAsNeededSelected{
            viewModel.selectedFrequency = [.asNeeded]
        }
        else{
            
            viewModel.selectedFrequency = []
            
            for (i, day) in viewModel.days.enumerated(){
                
                if selectedDays[i]{
                    viewModel.selectedFrequency.append(day)
                }
                
            }
            
        }
        
    }
    
    
}
