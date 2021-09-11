//
//  SSPagerViewDelegateProxy.swift
//  RxSSPager
//
//  Created by Eido Goya on 2021/09/11.
//

import UIKit
import RxSwift
import RxCocoa
import SSPager

extension SSPagerView: HasDelegate { }

class RxSSPagerViewDelegateProxy: DelegateProxy<SSPagerView, SSPagerViewDelegate>,
                                  DelegateProxyType, SSPagerViewDelegate {
    
    weak public private(set) var ssPagerView: SSPagerView?
    
    public init(ssPagerView: SSPagerView) {
        self.ssPagerView = ssPagerView
        super.init(parentObject: ssPagerView,
                   delegateProxy: RxSSPagerViewDelegateProxy.self)
    }
    
    static func registerKnownImplementations() {
        register { parent in
            RxSSPagerViewDelegateProxy(ssPagerView: parent)
        }
    }
    
}
