//
//  FrequencyCoordinator.swift
//  SubQ
//
//  Created by Constantine Thalasinos on 5/13/23.
//

import Foundation
import UIKit

class FrequencyCoordinator: ModalChildCoordinator{
    
    required init(navigationController: UINavigationController, parentCoordinator: Coordinator?, storageProvider: StorageProvider) {
        self.navigationController = navigationController
        self.storageProvider = storageProvider
    }
    
    weak var parentNavigationController: UINavigationController?
    
    weak var parentCoordinator: Coordinator?
    
    var storageProvider: StorageProvider
    
    var viewModel: EditInjectionViewModel?
    
    required init(navigationController: UINavigationController, parentNavigationController: UINavigationController, parentCoordinator: Coordinator, storageProvider: StorageProvider) {
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
        
        //navigationController.present(vc, animated: true)
        
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
