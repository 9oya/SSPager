//
//  BannerViewController.swift
//  SSPagerExample
//
//  Created by Eido Goya on 2021/09/12.
//

import UIKit
import SSPager

class BannerViewController: UIViewController {
    
    var pagerView: SSPagerView!
    
    let itemColors = [UIColor.red, UIColor.orange, UIColor.yellow, UIColor.green, UIColor.blue]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        pagerView = {
            let pagerView = SSPagerView()
            pagerView.interitemSpacing = 0
            pagerView.backgroundColor = .systemGray5
            
            let cellWidth = view.frame.width
            let cellHeight = view.frame.height
            pagerView.itemSize = CGSize(width: cellWidth,
                                        height: cellHeight)
            pagerView.contentsInset = UIEdgeInsets(top: 0,
                                                   left: 0,
                                                   bottom: 0,
                                                   right: 0)
            pagerView.isInfinite = true
            pagerView.automaticSlidingInterval = 3.0
            
            
            pagerView.register(SSPagerViewCell.self, forCellWithReuseIdentifier: String(describing: SSPagerViewCell.self))
            
            pagerView.dataSource = self
            pagerView.delegate = self
            
            pagerView.translatesAutoresizingMaskIntoConstraints = false
            
            return pagerView
        }()
        
        view.addSubview(pagerView)
        
        let constraints = [
            pagerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            pagerView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            pagerView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
            pagerView.heightAnchor.constraint(equalToConstant: 200)
        ]
        NSLayoutConstraint.activate(constraints)
    }
}

extension BannerViewController: SSPagerViewDataSource {
    func numberOfItems(_ pagerView: SSPagerView) -> Int {
        itemColors.count
    }
    
    func pagerView(_ pagerView: SSPagerView, cellForItemAt index: Int) -> UICollectionViewCell {
        guard let cell = pagerView.dequeueReusableCell(withReuseIdentifier: String(describing: SSPagerViewCell.self), at: index) as? SSPagerViewCell else {
            fatalError()
        }
        cell.alpha = 0.5
        cell.backgroundColor = itemColors[index]
        return cell
    }
}

extension BannerViewController: SSPagerViewDelegate {
    func pagerViewDidSelectPage(at index: Int) {
        print("Page selected at \(index)")
    }
}
