//
//  CustomPagerCell.swift
//  SSPagerExample
//
//  Created by Eido Goya on 2021/09/16.
//

import UIKit
import SSPager

class CustomPagerCell: SSPagerViewCell {
    
    var titleLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        shadowType = .default
        
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupLayout() {
        titleLabel = {
            let label = UILabel()
            label.textColor = .black
            label.text = "Hello Pager Cell!"
            label.translatesAutoresizingMaskIntoConstraints = false
            return label
        }()
        
        contentView.addSubview(titleLabel)
        
        let constraints = [
            titleLabel.leftAnchor.constraint(equalTo: leftAnchor),
            titleLabel.rightAnchor.constraint(equalTo: rightAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -15)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
}
