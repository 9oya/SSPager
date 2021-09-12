//
//  ViewController.swift
//  SSPagerExample
//
//  Created by Eido Goya on 2021/09/04.
//

import UIKit
import SSPager

class BasicViewController: UIViewController {
    
    var pagerView: SSPagerView!
    var pageControl: UIPageControl!
    let itemColors = [UIColor.red, UIColor.orange, UIColor.yellow, UIColor.green, UIColor.blue, UIColor.gray, UIColor.gray, UIColor.gray, UIColor.gray]
    
    let cellHeight: CGFloat = 300

    override func viewDidLoad() {
        super.viewDidLoad()
        
        pagerView = {
            let pagerView = SSPagerView()
            pagerView.interitemSpacing = 20.0
            pagerView.backgroundColor = .systemGray5
            
            let cellWidth = view.frame.width * 0.7
            pagerView.itemSize = CGSize(width: cellWidth,
                                        height: cellHeight)
            pagerView.contentsInset = UIEdgeInsets(top: 10,
                                                   left: 20,
                                                   bottom: 10,
                                                   right: 20)
             pagerView.isInfinite = true
            // pagerView.automaticSlidingInterval = 1.0
            pagerView.pagingMode = .scrollable
            
            pagerView.register(SSPagerViewCell.self, forCellWithReuseIdentifier: String(describing: SSPagerViewCell.self))
            
            pagerView.dataSource = self
            pagerView.delegate = self
            
            pagerView.translatesAutoresizingMaskIntoConstraints = false
            
            return pagerView
        }()
        
        pageControl = {
            let pageControl = UIPageControl(frame: .zero)
            pageControl.numberOfPages = itemColors.count
            pageControl.currentPage = 0
            pageControl.isUserInteractionEnabled = false
            pageControl.translatesAutoresizingMaskIntoConstraints = false
            return pageControl
        }()
        
        view.addSubview(pagerView)
        view.addSubview(pageControl)
        
        let constraints = [
            pagerView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            pagerView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
            pagerView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            pagerView.heightAnchor.constraint(equalToConstant: cellHeight+20)
        ] + [
            pageControl.centerXAnchor.constraint(equalTo: pagerView.centerXAnchor),
            pageControl.bottomAnchor.constraint(equalTo: pagerView.bottomAnchor, constant: -20)
        ]
        NSLayoutConstraint.activate(constraints)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        pagerView.scrollToPage(at: 3, animated: true)
    }
    
}

extension BasicViewController: SSPagerViewDataSource {
    
    // MARK: SSPagerViewDataSource
    
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

extension BasicViewController: SSPagerViewDelegate {
    
    // MARK: SSPagerViewDelegate
    
    func pagerViewDidSelectPage(at index: Int) {
        print("Page \(index) is selected.")
    }
    
    func pagerViewWillEndDragging(_ scrollView: UIScrollView, targetIndex: Int) {
        pageControl.currentPage = Int(targetIndex % itemColors.count)
    }
    
}

