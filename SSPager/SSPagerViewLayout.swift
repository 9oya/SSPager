//
//  SSPagerViewLayout.swift
//  SSPager
//
//  Created by Eido Goya on 2021/09/04.
//

import UIKit

class SSPagerViewLayout: UICollectionViewFlowLayout {
    
    private var pagerView: SSPagerView? {
        return self.collectionView?.superview?.superview as? SSPagerView
    }
    
    override func prepare() {
        
        scrollDirection = .horizontal
    }
    
    override init() {
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
