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
    
    var injection: Injection?
    
    
    /*
    required init(navigationController: UINavigationController, parentCoordinator: Coordinator?, storageProvider: StorageProvider) {
        self.navigationController = navigationController
        self.storageProvider = storageProvider
        self.injectionProvider = InjectionProvider(storageProvider: storageProvider)
        
        viewModel = EditInjectionViewModel(injectionProvider: injectionProvider, injection: nil)
        
    }
    
    required init(navigationController: UINavigationController, parentNavigationController: UINavigationController, parentCoordinator: Coordinator, storageProvider: StorageProvider) {
        self.navigationController = navigationController
        self.parentNavigationController = parentNavigationController
        self.parentCoordinator = parentCoordinator
        self.storageProvider = storageProvider
        self.injectionProvider = InjectionProvider(storageProvider: storageProvider)
        
        viewModel = EditInjectionViewModel(injectionProvider: injectionProvider, injection: nil)
    }*/
    
    init(navigationController: UINavigationController, parentNavigationController: UINavigationController, parentCoordinator: Coordinator, storageProvider: StorageProvider, injectionProvider: InjectionProvider, injection: Injection?) {
        self.navigationController = navigationController
        self.parentNavigationController = parentNavigationController
        self.parentCoordinator = parentCoordinator
        self.storageProvider = storageProvider
        self.injectionProvider = injectionProvider
        self.injection = injection
        
        viewModel = EditInjectionViewModel(injectionProvider: injectionProvider, injection: injection)
    }
    
    func start() {
       // let vc = EditInjectionViewController(viewModel: viewModel)
        
        let vc = EditInjectionTableViewController(viewModel: viewModel)
        
        vc.coordinator = self
        vc.editCoordinator = self
        
        //navigationController.present(vc, animated: true)
        
        navigationController.navigationBar.prefersLargeTitles = true
        
        if let injection = viewModel.injection, let name = injection.name{
            vc.title = "\(name)"
        }
        else{
            vc.title =  "New Injection"
        }
        
        
        navigationController.pushViewController(vc, animated: false)
        
        vc.modalPresentationStyle = .automatic
        
        parentNavigationController!.present(navigationController, animated: true)
        
    }
    
    func cancelEdit(){
        parentNavigationController!.dismiss(animated: true)

        parentCoordinator?.childDidFinish(self)
    }
/*    #warning("might be un used")
    func saveEdit(name: String, dosage: Double, units: Injection.DosageUnits, frequency: [Injection.Frequency], date: Date){
        
        //print("\(name) + \(dosage) + \(units) + \(frequency) + \(date)")
        
        let frequencyString = frequency.map({ $0.rawValue }).joined(separator: ", ")
        
        viewModel.saveInjection(name: name, dosage: dosage, units: units, frequency: frequencyString, time: date)
        
        parentNavigationController!.dismiss(animated: true)
        

        parentCoordinator?.childDidFinish(self)
    }*/
    
    func savePressed(){
        parentNavigationController!.dismiss(animated: true)
        

        parentCoordinator?.childDidFinish(self)
    }
    
    func deleteInjection(){
        parentNavigationController!.dismiss(animated: true)
        
        parentCoordinator?.childDidFinish(self)
    }
    
    func showFrequencyController(){
        let child  = DaysCoordinator(navigationController: UINavigationController(), parentNavigationController: self.navigationController, parentCoordinator: self, storageProvider: storageProvider)
        
        childCoordinators.append(child)
        
        child.viewModel = viewModel
        
        child.start()
    }
    
    
}
