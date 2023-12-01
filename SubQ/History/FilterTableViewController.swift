//
//  FilterTableViewController.swift
//  SubQ
//
//  Created by Constantine Thalasinos on 8/3/23.
//

import UIKit

class FilterTableViewController: UITableViewController, Coordinated {
    
    let viewModel: HistoryViewModel
    
    weak var coordinator: Coordinator?
    
    weak var filterCoordinator: FilterCoordinator?
    
    var footer: FilterTableFooterView?
    
    lazy var cancelAction = UIAction { _ in
        self.filterCoordinator?.dismiss()
    }
    
    enum Section: Int, CaseIterable{
        case sort, status, type, date
    }
    
    let dateCellIdentifier = "dateCellReuseIdentifier"
    let segmentedCellIdentifier = "segmentedCellReuseIdentifier"
    let footerIdentifier = "footerReuseIdentifier"
    
    lazy var dateSegmentedControl = UISegmentedControl()
    lazy var statusSegmentedControl = UISegmentedControl()
    lazy var typeSegmentedControl = UISegmentedControl()
    lazy var startDatePicker = UIDatePicker()
    lazy var endDatePicker = UIDatePicker()
    
    
    lazy var dateAction = UIAction { _ in
        
        self.dismiss(animated: false, completion: nil)
        
        let start = Calendar.current.startOfDay(for: self.startDatePicker.date)
        
        
        let endDateStart = Calendar.current.startOfDay(for: self.endDatePicker.date)
        
        var components = DateComponents()
        components.day = 1
        components.second = -1
        let end = Calendar.current.date(byAdding: components, to: endDateStart)!
        
        if start > end{
            
            let alert = UIAlertController(title: "Invalid Date Range", message: "The start date cannot be greater than the end date.", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { _ in
                //self.dismiss(animated: true)
                var components = DateComponents()
                components.day = 1
                components.second = -1
                let end = Calendar.current.date(byAdding: components, to: Date())!
                
                self.endDatePicker.date = end
            }))
            
            if let popoverController = alert.popoverPresentationController {
                popoverController.sourceView = self.view //to set the source of your alert
                popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0) // you can set this as per your requirement.
                popoverController.permittedArrowDirections = [] //to hide the arrow of any particular direction
            }
            
            self.present(alert, animated: true)
            
        }
       
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(systemItem: .close, primaryAction: cancelAction)
        
        tableView.register(DateRangeTableViewCell.self, forCellReuseIdentifier: dateCellIdentifier)
        
        tableView.register(SegmentedTableViewCell.self, forCellReuseIdentifier: segmentedCellIdentifier)
        
        tableView.register(FilterTableFooterView.self, forHeaderFooterViewReuseIdentifier: footerIdentifier)
        
    }
    
    init(viewModel: HistoryViewModel){
        self.viewModel = viewModel
        
        super.init(style: .insetGrouped)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return Section.allCases.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let sectionVal = Section(rawValue: section)
        
        if sectionVal == .sort{
            return 1
        } else if sectionVal == .status{
            return 1
        } else if sectionVal == .type {
            return 1
        } else {
           return 1
        }
        
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        let sectionVal = Section(rawValue: section)
        
        if sectionVal == .sort{
            return("Sort By")
        } else if sectionVal == .status{
            return("Status")
        } else if sectionVal == .type {
            return("Type")
        } else{
            return("Dates Between")
        }
        
    }
    

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        

        let sectionVal = Section(rawValue: indexPath.section)
        
        if sectionVal == .sort{
            let cell = tableView.dequeueReusableCell(withIdentifier: segmentedCellIdentifier, for: indexPath) as! SegmentedTableViewCell
            
            let allCases = HistoryViewModel.DateSorting.allCases
            
            cell.createSegmentedControl(withItems: allCases.map({ $0.rawValue }))
            
            cell.segmentedControl.selectedSegmentIndex = allCases.firstIndex(of: viewModel.selectedDateSorting)!
            
            dateSegmentedControl = cell.segmentedControl
            
            return cell
            
        } else if sectionVal == .status{
            let cell = tableView.dequeueReusableCell(withIdentifier: segmentedCellIdentifier, for: indexPath) as! SegmentedTableViewCell
            
            let allCases = History.InjectStatus.allCases
            
            cell.createSegmentedControl(withItems: allCases.map({ $0.rawValue }))
            
            cell.segmentedControl.selectedSegmentIndex = allCases.firstIndex(of: viewModel.selectedStatus)!
            
            statusSegmentedControl = cell.segmentedControl
            
            return cell
            
        } else if sectionVal == .type {
            let cell = tableView.dequeueReusableCell(withIdentifier: segmentedCellIdentifier, for: indexPath) as! SegmentedTableViewCell
            
            let allCases = Injection.InjectionType.allCases
            
            cell.createSegmentedControl(withItems: allCases.map({ $0.rawValue }))
            
            cell.segmentedControl.selectedSegmentIndex = allCases.firstIndex(of: viewModel.selectedType)!
            
            typeSegmentedControl = cell.segmentedControl
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: dateCellIdentifier, for: indexPath) as! DateRangeTableViewCell
            
            startDatePicker = cell.startDatePicker
            endDatePicker = cell.endDatePicker
            
            startDatePicker.date = viewModel.selectedStartDate ?? viewModel.oldestDate
            endDatePicker.date = viewModel.selectedEndDate ?? Date()
            
            for picker in [startDatePicker, endDatePicker]{
                picker.maximumDate = Date()
                picker.minimumDate = viewModel.oldestDate
            }
            
            cell.startDatePicker.addAction(dateAction, for: .primaryActionTriggered)
            cell.endDatePicker.addAction(dateAction, for: .primaryActionTriggered)
            
            return cell
        }

      
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        
        cell?.setSelected(false, animated: false)
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        if Section(rawValue: section) == .date{
            footer = tableView.dequeueReusableHeaderFooterView(withIdentifier: footerIdentifier) as! FilterTableFooterView
            
            let resetAction = UIAction { _ in
                self.filterCoordinator?.resetToDefaults()
            }
            
            footer!.resetButton.addAction(resetAction, for: .primaryActionTriggered)
            
            
            let applyAction = UIAction { _ in
                let dateSortString = self.dateSegmentedControl.titleForSegment(at: self.dateSegmentedControl.selectedSegmentIndex)
                
                let dateSorting = HistoryViewModel.DateSorting(rawValue: dateSortString!)!
                
                let statusString = self.statusSegmentedControl.titleForSegment(at: self.statusSegmentedControl.selectedSegmentIndex)
                
                let status = History.InjectStatus(rawValue: statusString!)!
                
                let typeString = self.typeSegmentedControl.titleForSegment(at: self.typeSegmentedControl.selectedSegmentIndex)
                
                let type = Injection.InjectionType(rawValue: typeString!)!
                
                
                self.filterCoordinator?.applyFilters(sortDateBy: dateSorting, status: status, type: type, startDate: self.startDatePicker.date, endDate: self.endDatePicker.date)
                
                
            }
            footer!.applyButton.addAction(applyAction, for: .primaryActionTriggered)
            
            return footer
        }
        
        return nil
    }
    

}
