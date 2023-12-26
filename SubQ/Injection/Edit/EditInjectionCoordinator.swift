//
//  EditInjectionCoordinator.swift
//  SubQ
//
//  Created by Constantine Thalasinos on 5/8/23.
//

import UIKit
import WidgetKit

class EditInjectionCoordinator: ModalChildCoordinator{

    
    var childCoordinators = [Coordinator]()
    
    var navigationController: UINavigationController
    
    weak var parentNavigationController: UINavigationController?
    
    weak var parentCoordinator: Coordinator?
    
    var storageProvider: StorageProvider
    
    let viewModel: EditInjectionViewModel
    
    let injectionProvider: InjectionProvider
    
    var injection: Injection?
    
    

    
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
        let vc = EditInjectionTableViewController(viewModel: viewModel)
        
        vc.coordinator = self
        vc.editCoordinator = self
        
        navigationController.navigationBar.prefersLargeTitles = true
        navigationController.navigationBar.largeTitleTextAttributes = InterfaceDefaults.navigationBarLargeTextAttributes
        
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
    
    func reloadWidgetTimelines() {
        WidgetCenter.shared.reloadTimelines(ofKind: InterfaceDefaults.widgetKind)
    }
    
    func cancelEdit(){
        parentNavigationController!.dismiss(animated: true)

        parentCoordinator?.childDidFinish(self)
    }
    
    func savePressed(injectionDescriptionString: String, action: InjectionTableViewController.EditAction){
        parentNavigationController!.dismiss(animated: true)
        
        let injectionTableVC = parentNavigationController!.topViewController as! InjectionTableViewController
        
        var str = injectionDescriptionString
        
        str.append(" \(action.rawValue)")
        
        injectionTableVC.showConfirmationView(message: str, color: .systemBlue)
        
        reloadWidgetTimelines()

        parentCoordinator?.childDidFinish(self)
    }
    
    func deleteInjection(injectionDescriptionString: String){
        parentNavigationController!.dismiss(animated: true)
        
        let injectionTableVC = parentNavigationController!.topViewController as! InjectionTableViewController
        
        var str = injectionDescriptionString
        
        str.append(" \(InjectionTableViewController.EditAction.deleted.rawValue)")
        

        injectionTableVC.showConfirmationView(message: str, color: .systemRed)
        
        reloadWidgetTimelines()
        
        parentCoordinator?.childDidFinish(self)
    }
    
    func showFrequencyController(){
        let child  = DaysCoordinator(navigationController: UINavigationController(), parentNavigationController: self.navigationController, parentCoordinator: self, storageProvider: storageProvider)
        
        childCoordinators.append(child)
        
        child.viewModel = viewModel
        
        child.start()
    }
    
    
}
