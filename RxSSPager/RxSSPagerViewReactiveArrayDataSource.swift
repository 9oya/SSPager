//
//  RxSSPagerViewReactiveArrayDataSource.swift
//  RxSSPager
//
//  Created by Eido Goya on 2021/09/11.
//

import UIKit
import RxSwift

class _RxSSPagerViewReactiveArrayDataSource: NSObject,
                                             SSPagerViewDataSource {
    
    func _numberOfItems(_ pagerView: SSPagerView) -> Int {
        0
    }
    
    func numberOfPages(_ pagerView: SSPagerView) -> Int {
        _numberOfItems(pagerView)
    }
    
    func _pagerView(_ pagerView: SSPagerView, cellForItemAt index: Int) -> SSPagerViewCell {
        rxAbstractMethod()
    }
    
    func pagerView(_ pagerView: SSPagerView, cellForItemAt index: Int) -> SSPagerViewCell {
        _pagerView(pagerView, cellForItemAt: index)
    }
    
}

/// Marks data source as `UICollectionView` reactive data source enabling it to be used with one of the `bindTo` methods.
public protocol RxSSPagerViewDataSourceType /*: UICollectionViewDataSource*/ {
    
    /// Type of elements that can be bound to collection view.
    associatedtype Element
    
    /// New observable sequence event observed.
    ///
    /// - parameter pagerView: Bound pager view.
    /// - parameter observedEvent: Event
    func pagerView(_ pagerView: SSPagerView, observedEvent: Event<Element>)
}

class RxSSPagerViewReactiveArrayDataSourceSequenceWrapper<Sequence: Swift.Sequence>:
    RxSSPagerViewReactiveArrayDataSource<Sequence.Element>,
    RxSSPagerViewDataSourceType {
    
    typealias Element = Sequence
    
    override init(cellFactory: @escaping CellFactory) {
        super.init(cellFactory: cellFactory)
    }
    
    func pagerView(_ pagerView: SSPagerView, observedEvent: Event<Sequence>) {
        Binder(self) { pagerViewDataSource, sequence in
            let elements = Array(sequence)
            pagerViewDataSource.pagerView(pagerView, observedElements: elements)
        }.on(observedEvent)
    }
}

class RxSSPagerViewReactiveArrayDataSource<Element>:
    _RxSSPagerViewReactiveArrayDataSource {
    
    typealias CellFactory = (SSPagerView, Int, Element) -> SSPagerViewCell
    
    var itemModels: [Element]?
    
    var cellFactory: CellFactory
    
    init(cellFactory: @escaping CellFactory) {
        self.cellFactory = cellFactory
    }
    
    // data source
    
    override func _numberOfItems(_ pagerView: SSPagerView) -> Int {
        itemModels?.count ?? 0
    }
    
    override func _pagerView(_ pagerView: SSPagerView, cellForItemAt index: Int) -> SSPagerViewCell {
        cellFactory(pagerView, index, itemModels![index])
    }
    
    // recative
    
    func pagerView(_ pagerView: SSPagerView, observedElements: [Element]) {
        self.itemModels = observedElements
        pagerView.reloadData()
        pagerView.invalidateLayout()
    }
}
