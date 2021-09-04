//
//  SSPagerViewCell.swift
//  SSPager
//
//  Created by Eido Goya on 2021/09/04.
//

import UIKit

public class SSPagerViewCell: UICollectionViewCell {
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.cornerRadius = 3.0
        layer.shadowRadius = 10
        layer.shadowOpacity = 0.4
        layer.shadowOffset = CGSize(width: 5, height: 10)
        self.clipsToBounds = false
    }
}
