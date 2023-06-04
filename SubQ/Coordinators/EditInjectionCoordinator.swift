//
//  EditInjectionCoordinator.swift
//  SubQ
//
//  Created by Constantine Thalasinos on 5/8/23.
//

import UIKit

class EditInjectionCoordinator: ModalChildCoordinator{

    
    var childCoordinators = [Coordinator]()
    
    var navigationController: UINavigationController
    
    weak var parentNavigationController: UINavigationController?
    
    weak var parentCoordinator: Coordinator?
    
    var storageProvider: StorageProvider
    
    let viewModel: EditInjectionViewModel
    
    let injectionProvider: InjectionProvider
    
    
    
    required init(navigationController: UINavigationController, parentCoordinator: Coordinator?, storageProvider: StorageProvider) {
        self.navigationController = navigationController
        self.storageProvider = storageProvider
        self.injectionProvider = InjectionProvider(storageProvider: storageProvider)
        
        viewModel = EditInjectionViewModel(storageProvider: storageProvider, injection: nil)
        
    }
    
    required init(navigationController: UINavigationController, parentNavigationController: UINavigationController, parentCoordinator: Coordinator, storageProvider: StorageProvider) {
        self.navigationController = navigationController
        self.parentNavigationController = parentNavigationController
        self.parentCoordinator = parentCoordinator
        self.storageProvider = storageProvider
        self.injectionProvider = InjectionProvider(storageProvider: storageProvider)
        
        viewModel = EditInjectionViewModel(storageProvider: storageProvider, injection: nil)
    }
    
    func start() {
        let vc = EditInjectionViewController(viewModel: viewModel)
        vc.coordinator = self
        
        //navigationController.present(vc, animated: true)
        
        navigationController.pushViewController(vc, animated: false)
        
        vc.modalPresentationStyle = .automatic
        
        parentNavigationController!.present(navigationController, animated: true)
        
    }
    
    func cancelEdit(){
        parentNavigationController!.dismiss(animated: true)

        parentCoordinator?.childDidFinish(self)
    }
    
    func saveEdit(name: String, dosage: Double, units: Injection.DosageUnits, frequency: [Injection.Frequency], date: Date){
        
        print("\(name) + \(dosage) + \(units) + \(frequency) + \(date)")
        
       injectionProvider.saveInjection(name: name, dosage: dosage, units: units, frequency: frequency, time: date)
        
        parentNavigationController!.dismiss(animated: true)
        

        parentCoordinator?.childDidFinish(self)
    }
    
    func showFrequencyController(){
        let child  = FrequencyCoordinator(navigationController: UINavigationController(), parentNavigationController: self.navigationController, parentCoordinator: self, storageProvider: storageProvider)
        
        childCoordinators.append(child)
        
        child.viewModel = viewModel
        
        child.start()
    }
    
    
}
