//
//  SSPagerView+Rx.swift
//  RxSSPager
//
//  Created by Eido Goya on 2021/09/07.
//

import UIKit
import RxSwift
import RxCocoa

public extension Reactive where Base: SSPagerView {
    
    func pages<Sequence: Swift.Sequence,
               Source: ObservableType>(_ source: Source)
    -> (_ cellFactory: @escaping (SSPagerView, Int, Sequence.Element) -> SSPagerViewCell)
    -> Disposable where Source.Element == Sequence {
        return { cellFactory in
            let dataSource = RxSSPagerViewReactiveArrayDataSourceSequenceWrapper<Sequence>(cellFactory: cellFactory)
            return self.pages(dataSource: dataSource)(source)
        }
    }
    
    func pages<Sequence: Swift.Sequence,
               Cell: SSPagerViewCell,
               Source: ObservableType>(cellIdentifier: String, cellType: Cell.Type = Cell.self)
    -> (_ source: Source)
    -> (_ configureCell: @escaping (Int, Sequence.Element, Cell) -> Void)
    -> Disposable where Source.Element == Sequence {
        return { source in
            return { configureCell in
                let dataSource = RxSSPagerViewReactiveArrayDataSourceSequenceWrapper<Sequence> { pv, idx, page in
                    let index = idx
                    let cell = pv.dequeueReusableCell(withReuseIdentifier: cellIdentifier, at: index) as! Cell
                    configureCell(idx, page, cell)
                    return cell
                }
                
                return self.pages(dataSource: dataSource)(source)
            }
        }
    }

    func pages<
        DataSource: RxSSPagerViewDataSourceType & SSPagerViewDataSource,
        Source: ObservableType>
    (dataSource: DataSource)
    -> (_ source: Source)
    -> Disposable where DataSource.Element == Source.Element
    {
        return { source in
            _ = self.delegate
            return source.subscribeProxyDataSource(ofObject: self.base,
                                                   dataSource: dataSource,
                                                   retainDataSource: true)
            { [weak pagerView = self.base] (_: RxSSPagerViewDataSourceProxy, event) -> Void in
                guard let pagerView: SSPagerView = pagerView else { return }
                dataSource.pagerView(pagerView, observedEvent: event)
            }
        }
    }
    
}

public extension Reactive where Base: SSPagerView {
    
    var dataSource: DelegateProxy<SSPagerView, SSPagerViewDataSource> {
        RxSSPagerViewDataSourceProxy.proxy(for: base)
    }
    
    func setDataSource(_ dataSource: SSPagerViewDataSource) -> Disposable {
        RxSSPagerViewDataSourceProxy.installForwardDelegate(dataSource,
                                                            retainDelegate: false,
                                                            onProxyForObject: self.base)
    }
    
    var delegate: DelegateProxy<SSPagerView, SSPagerViewDelegate> {
        RxSSPagerViewDelegateProxy.proxy(for: base)
    }
    
    var pageSelected: ControlEvent<Int> {
        let source = delegate.methodInvoked(#selector(SSPagerViewDelegate.pagerViewDidSelectPage(at:)))
            .map { a in
                return try castOrThrow(Int.self, a.first as Any)
            }
        
        return ControlEvent(events: source)
    }
}


private func castOrThrow<T>(_ resultType: T.Type, _ object: Any) throws -> T {
    guard let returnValue = object as? T else {
        throw RxCocoaError.castingError(object: object, targetType: resultType)
    }

    return returnValue
}

extension ObservableType {
    func subscribeProxyDataSource<DelegateProxy: DelegateProxyType>
    (ofObject object: DelegateProxy.ParentObject,
     dataSource: DelegateProxy.Delegate,
     retainDataSource: Bool,
     binding: @escaping (DelegateProxy, Event<Element>) -> Void)
    -> Disposable where DelegateProxy.ParentObject: UIView
                        , DelegateProxy.Delegate: AnyObject {
        
        let proxy = DelegateProxy.proxy(for: object)
        let unregisterDelegate = DelegateProxy.installForwardDelegate(dataSource, retainDelegate: retainDataSource, onProxyForObject: object)

        // Do not perform layoutIfNeeded if the object is still not in the view heirarchy
        if object.window != nil {
            // this is needed to flush any delayed old state (https://github.com/RxSwiftCommunity/RxDataSources/pull/75)
            object.layoutIfNeeded()
        }

        let subscription = self.asObservable()
            .observe(on:MainScheduler())
            .catch { error in
                return Observable.empty()
            }
            // source can never end, otherwise it would release the subscriber, and deallocate the data source
            .concat(Observable.never())
            .take(until: object.rx.deallocated)
            .subscribe { [weak object] (event: Event<Element>) in

                if let object = object {
                    assert(proxy === DelegateProxy.currentDelegate(for: object),
                           "Proxy changed from the time it was first set.\nOriginal: \(proxy)\nExisting: \(String(describing: DelegateProxy.currentDelegate(for: object)))")
                }
                
                binding(proxy, event)
                
                switch event {
                case .error(_):
                    unregisterDelegate.dispose()
                case .completed:
                    unregisterDelegate.dispose()
                default:
                    break
                }
            }
            
        return Disposables.create { [weak object] in
            subscription.dispose()

            if object?.window != nil {
                object?.layoutIfNeeded()
            }

            unregisterDelegate.dispose()
        }
    }
}
