//
//  InjectNowDataStackView.swift
//  SubQ
//
//  Created by Constantine Thalasinos on 9/8/23.
//

import UIKit
import SnapKit
import Combine

class InjectNowDataView: UIView {
    
    class DataView: UIView {
        var fieldLabel: UILabel
        var dataLabel: UILabel
        
        init(fieldLabel: UILabel, dataLabel: UILabel) {
            self.fieldLabel = fieldLabel
            self.dataLabel = dataLabel
            
            super.init(frame: .zero)
            
            addSubview(fieldLabel)
            addSubview(dataLabel)
            
            fieldLabel.snp.makeConstraints { make in
                make.leadingMargin.topMargin.equalToSuperview()
            }
            
            dataLabel.snp.makeConstraints { make in
                make.top.equalTo(fieldLabel.snp.bottom)
                make.leadingMargin.bottomMargin.rightMargin.equalToSuperview()
            }
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
    
    enum LabelField{
        case description, scheduled, lastInjected, nextInjection, originalDueDate, snoozedUntil
        
        var labelText: String {
            switch self{
            case .description: return "Injection:"
            case .scheduled: return "Scheduled:"
            case .lastInjected: return "Last Injected:"
            case .nextInjection: return "Next Due:"
            case .originalDueDate: return "Originally Due:"
            case .snoozedUntil: return "Snoozed Until:"
            }
        }
    }
    
    var cancellables = Set<AnyCancellable>()
    
    var viewModel: InjectNowViewModel
    var coordinator: InjectNowCoordinator
    
    var isFromNotification: Bool
    
    var fieldViews = [UIView]()
    
    let injectionDataStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.alignment = .leading
        view.distribution = .fill
        view.spacing = 5
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    lazy var selectInjectionButton: BadgeButton = {
        let action = UIAction { _ in
            
            self.coordinator.showSelectInjectionViewController()
        }
        
        
        let button = BadgeButton(primaryAction: action)
        
        button.configurationUpdateHandler = { [unowned self] button in
            
            var config: UIButton.Configuration!
            
            if self.viewModel.selectedInjection == nil && self.viewModel.selectedQueueObject == nil{
                config = UIButton.Configuration.bordered()
                
                config.title = "Select Injection"
                
                config.baseForegroundColor = .label
                config.background.strokeColor = .label
                config.baseBackgroundColor = .systemBackground
            }
            else{
                
                config = UIButton.Configuration.filled()
                config.baseBackgroundColor = InterfaceDefaults.primaryColor
                config.baseForegroundColor = .white
                
                
                config.title = viewModel.selectedInjection == nil ? viewModel.selectedQueueObject!.injection!.descriptionString : viewModel.selectedInjection!.descriptionString
            }
            config.cornerStyle = .large
            
            config.imagePlacement = .trailing
            let imageConfig = UIImage.SymbolConfiguration(pointSize: 10)
            config.image = UIImage(systemName: "chevron.down", withConfiguration: imageConfig)
            

            button.configuration = config
        }

        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    init(viewModel: InjectNowViewModel, coordinator: InjectNowCoordinator) {
        self.viewModel = viewModel
        self.coordinator = coordinator
        self.isFromNotification = viewModel.isFromNotification
        
        super.init(frame: .zero)
        
        if !isFromNotification {
            Publishers.Zip(viewModel.$selectedInjection, viewModel.$selectedQueueObject)
                .sink { injection, queue in
                    self.createHierarchy(selectedQueueObject: queue, selectedInjectionObject: injection)
                }.store(in: &cancellables)
            
            viewModel.queueCount
                .assign(to: \.badgeCount, on: self.selectInjectionButton)
                .store(in: &cancellables)
        }
        
        addSubview(injectionDataStackView)
        injectionDataStackView.snp.makeConstraints { make in
            make.margins.equalToSuperview()
        }
        
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createHierarchy(selectedQueueObject: Queue?, selectedInjectionObject: Injection?){
        
        for subView in injectionDataStackView.arrangedSubviews {
            subView.removeFromSuperview()
        }
        
        fieldViews = [UIView]()
        
        var injection: Injection!
        var queueObject: Queue?
        
        if let selectedQueueObject {
            injection = selectedQueueObject.injection
            queueObject = selectedQueueObject
        } else if let selectedInjectionObject{
            injection = selectedInjectionObject
        } else {
            injection = viewModel.injectionFromNotification
            
            if let obj = viewModel.queueObjectFromNotification {
                queueObject = obj
            }
        }
        
        if isFromNotification {
            let descriptionView = createView(for: .description, text: injection.descriptionString)
            fieldViews.append(descriptionView)
            injectionDataStackView.addArrangedSubview(descriptionView)
        } else {
            injectionDataStackView.addArrangedSubview(selectInjectionButton)
            selectInjectionButton.setNeedsUpdateConfiguration()
        }
        
        if let injection {
            
            var scheduleString = ""
            
            if injection.typeVal == .scheduled {
                for frequency in injection.sortedFrequencies! {
                    var text = ""
                    //bullet with an extra white space after
                    if injection.sortedFrequencies!.count > 1 {
                        text = "\u{2022} "
                    }
                    
                    text.append("\(frequency.scheduledString)\n")
                    
                    scheduleString.append(text)
                }
                //get rid of last newline.
                scheduleString.removeLast()
            } else if injection.typeVal == .asNeeded {
                scheduleString = injection.typeVal.rawValue
            }
            
            let scheduledView = createView(for: .scheduled, text: scheduleString)
            injectionDataStackView.addArrangedSubview(scheduledView)
            fieldViews.append(scheduledView)
            
            let lastInjectedView = createView(for: .lastInjected, text: viewModel.getLastInjectedDate(forInjection: injection)?.fullDateTime ?? "never")
            injectionDataStackView.addArrangedSubview(lastInjectedView)
            fieldViews.append(lastInjectedView)
            
            if injection.typeVal == .scheduled {
                
                let nextInjectionView = createView(for: .nextInjection, text: injection.nextInjection!.timeUntil)
                injectionDataStackView.addArrangedSubview(nextInjectionView)
                fieldViews.append(nextInjectionView)
                
                Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                    nextInjectionView.dataLabel.text = "\(injection.nextInjection!.timeUntil)"
                }
            }
            
            if let queueObject {
                
                let originalDueDateLabel = createView(for: .originalDueDate, text: queueObject.dateDue!.fullDateTime)
                injectionDataStackView.addArrangedSubview(originalDueDateLabel)
                
                if let snoozed = queueObject.snoozedUntil {
                    let snoozedUntilLabel = createView(for: .snoozedUntil, text: queueObject.snoozedUntil!.fullDateTime)
                    injectionDataStackView.addArrangedSubview(snoozedUntilLabel)
                }
            }
        }
        
        
        
    }
    
    private func createView(for field: LabelField, text: String) -> DataView {
        let fieldLabel = UILabel()
        fieldLabel.text = field.labelText
        fieldLabel.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        fieldLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let dataLabel = UILabel()
        dataLabel.font = UIFont.systemFont(ofSize: 14)
        dataLabel.translatesAutoresizingMaskIntoConstraints = false
        dataLabel.text = text
        dataLabel.numberOfLines = 0
        
        let fieldView = DataView(fieldLabel: fieldLabel, dataLabel: dataLabel)
        fieldView.translatesAutoresizingMaskIntoConstraints = false
        
        
        return fieldView
    }
    
    
    
    
    
    
    

}
