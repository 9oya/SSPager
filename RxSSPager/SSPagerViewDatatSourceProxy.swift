//
//  SSPagerViewDatatSourceProxy.swift
//  RxSSPager
//
//  Created by Eido Goya on 2021/09/11.
//

import UIKit
import RxSwift
import RxCocoa
import SSPager

extension SSPagerView: HasDataSource {
    public typealias DataSource = SSPagerViewDataSource
}

private let ssPagerViewDataSourceNotSet = SSPagerViewDataSourceNotSet()

private final class SSPagerViewDataSourceNotSet: NSObject,
                                                 SSPagerViewDataSource {
    func numberOfItems(_ pagerView: SSPagerView) -> Int {
        return 0
    }
    
    // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
    func pagerView(_ pagerView: SSPagerView, cellForItemAt index: Int) -> UICollectionViewCell {
        rxAbstractMethod(message: dataSourceNotSet)
    }
    
}

public class RxSSPagerViewDataSourceProxy:
    DelegateProxy<SSPagerView, SSPagerViewDataSource>,
    DelegateProxyType,
    SSPagerViewDataSource {
    
    public weak private(set) var ssPagerView: SSPagerView?
    
    public init(ssPagerView: SSPagerView) {
        self.ssPagerView = ssPagerView
        super.init(parentObject: ssPagerView,
                   delegateProxy: RxSSPagerViewDataSourceProxy.self)
    }
    
    public static func registerKnownImplementations() {
        self.register { parent in
            RxSSPagerViewDataSourceProxy(ssPagerView: parent)
        }
    }
    
    private weak var _requiredMethodsDataSource: SSPagerViewDataSource? = ssPagerViewDataSourceNotSet
    
    public func numberOfItems(_ pagerView: SSPagerView) -> Int {
        return (_requiredMethodsDataSource?.numberOfItems(pagerView))!
    }
    
    public func pagerView(_ pagerView: SSPagerView, cellForItemAt index: Int) -> UICollectionViewCell {
        (_requiredMethodsDataSource?.pagerView(pagerView, cellForItemAt: index))!
    }
    
}


/// Swift does not implement abstract methods. This method is used as a runtime check to ensure that methods which intended to be abstract (i.e., they should be implemented in subclasses) are not called directly on the superclass.
func rxAbstractMethod(message: String = "Abstract method", file: StaticString = #file, line: UInt = #line) -> Swift.Never {
    rxFatalError(message, file: file, line: line)
}

func rxFatalError(_ lastMessage: @autoclosure () -> String, file: StaticString = #file, line: UInt = #line) -> Swift.Never  {
    // The temptation to comment this line is great, but please don't, it's for your own good. The choice is yours.
    fatalError(lastMessage(), file: file, line: line)
}

// MARK: Error messages

let dataSourceNotSet = "DataSource not set"
let delegateNotSet = "Delegate not set"
