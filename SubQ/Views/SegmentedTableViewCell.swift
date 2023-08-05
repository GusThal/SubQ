//
//  InjectionStatusTableViewCell.swift
//  SubQ
//
//  Created by Constantine Thalasinos on 8/3/23.
//

import UIKit
import SnapKit

class SegmentedTableViewCell: UITableViewCell {
    
    lazy var segmentedControl =  UISegmentedControl()
        
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        
    }
    
    func createSegmentedControl(withItems items: [String]){
        
        segmentedControl = UISegmentedControl(items: items)
        segmentedControl.selectedSegmentIndex = 0
        
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(segmentedControl)
        
        segmentedControl.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
