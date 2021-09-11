//
//  BasicViewController+Rx.swift
//  SSPagerExample
//
//  Created by Eido Goya on 2021/09/11.
//

import UIKit
import RxSwift
import RxCocoa
import SSPager

class RxBasicViewController: UIViewController {
    
    var pagerView: SSPagerView!
    
    let itemColors = [UIColor.red, UIColor.orange, UIColor.yellow, UIColor.green, UIColor.blue]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pagerView = {
            let pagerView = SSPagerView()
            pagerView.interitemSpacing = 20.0
            pagerView.backgroundColor = .systemGray5
            
            let cellWidth = view.frame.width * 0.7
            let cellHeight = view.frame.height * 0.7
            
            pagerView.itemSize = CGSize(width: cellWidth,
                                        height: cellHeight)
//            pagerView.contentsInset = UIEdgeInsets(top: 100,
//                                                   left: (view.bounds.width - cellWidth) / 2,
//                                                   bottom: 100,
//                                                   right: (view.bounds.width - cellWidth) / 2)
            pagerView.contentsInset = UIEdgeInsets(top: 100,
                                                   left: 20,
                                                   bottom: 100,
                                                   right: 20)
//            pagerView.isInfinite = true
            
            
            pagerView.register(SSPagerViewCell.self, forCellWithReuseIdentifier: String(describing: SSPagerViewCell.self))
            
//            pagerView.dataSource = self
//            pagerView.delegate = self
            
            pagerView.translatesAutoresizingMaskIntoConstraints = false
            
            return pagerView
        }()
        
        view.addSubview(pagerView)
        
        let constraints = [
            pagerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            pagerView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            pagerView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
            pagerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
        
        bindRx()
    }
    
    func bindRx() {
        Observable.just(itemColors)
    }
}
