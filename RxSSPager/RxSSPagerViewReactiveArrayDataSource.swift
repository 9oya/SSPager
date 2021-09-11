//
//  RxSSPagerViewReactiveArrayDataSource.swift
//  RxSSPager
//
//  Created by Eido Goya on 2021/09/11.
//

import UIKit
import RxSwift
import SSPager

class _RxSSPagerViewReactiveArrayDataSource: NSObject,
                                             SSPagerViewDataSource {
    
    func _numberOfItems(_ pagerView: SSPagerView) -> Int {
        0
    }
    
    func numberOfItems(_ pagerView: SSPagerView) -> Int {
        _numberOfItems(pagerView)
    }
    
    func _pagerView(_ pagerView: SSPagerView, cellForItemAt index: Int) -> UICollectionViewCell {
        rxAbstractMethod()
    }
    
    func pagerView(_ pagerView: SSPagerView, cellForItemAt index: Int) -> UICollectionViewCell {
        _pagerView(pagerView, cellForItemAt: index)
    }
    
}

class RxSSPagerViewReactiveArrayDataSourceSequenceWrapper<Sequence: Swift.Sequence>:
    RxSSPagerViewReactiveArrayDataSource<Sequence.Element>,
    RxSSPagerViewDataSourceType {
    
    typealias Element = Sequence
    
    override init(cellFactory: @escaping CellFactory) {
        super.init(cellFactory: cellFactory)
    }
    
    func pagerView(_ pagerView: SSPagerView, observedEvent: Event<Sequence>) {
        Binder(self) { pagerViewDataSource, sectionModels in
            let sections = sectionModels as! Event<Sequence>
            pagerViewDataSource.pagerView(pagerView, observedEvent: sections)
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
    
    override func _pagerView(_ pagerView: SSPagerView, cellForItemAt index: Int) -> UICollectionViewCell {
        cellFactory(pagerView, index, itemModels![index])
    }
    
    
    // recative
    
    func pagerView(_ pagerView: UICollectionView, observedElements: [Element]) {
        self.itemModels = observedElements
        pagerView.reloadData()
        pagerView.collectionViewLayout.invalidateLayout()
    }
}

/// Data source with access to underlying sectioned model.
public protocol SectionedViewDataSourceType {
    /// Returns model at index path.
    ///
    /// In case data source doesn't contain any sections when this method is being called, `RxCocoaError.ItemsNotYetBound(object: self)` is thrown.

    /// - parameter indexPath: Model index path
    /// - returns: Model at index path.
    func model(at indexPath: IndexPath) throws -> Any
}

/// Marks data source as `UICollectionView` reactive data source enabling it to be used with one of the `bindTo` methods.
public protocol RxSSPagerViewDataSourceType /*: UICollectionViewDataSource*/ {
    
    /// Type of elements that can be bound to collection view.
    associatedtype Element
    
    /// New observable sequence event observed.
    ///
    /// - parameter collectionView: Bound collection view.
    /// - parameter observedEvent: Event
    func pagerView(_ pagerView: SSPagerView, observedEvent: Event<Element>)
}
