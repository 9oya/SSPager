//
//  SSPagerView.swift
//  SSPager
//
//  Created by Eido Goya on 2021/09/04.
//

import UIKit

@objc
public protocol SSPagerViewDataSource {
    func numberOfItems(in pagerView: SSPagerView) -> Int
    
    func pagerView(_ pagerView: SSPagerView, cellForItemAt index: Int) -> UICollectionViewCell
}

@objc
public protocol SSPagerViewDelegate {
    @objc optional func pagerViewDidSelectPage(at index: Int)
    
    @objc optional func pagerViewWillEndDragging(_ pagerView: SSPagerView, targetIndex: Int)
}

public class SSPagerView: UIView {
    public var dataSource: SSPagerViewDataSource?
    public var delegate: SSPagerViewDelegate?
    
    public var automaticSlidingInterval: CGFloat = 0.0
    
    public var interitemSpacing: CGFloat = 20 {
        didSet {
            self.ssPagerViewLayout.minimumInteritemSpacing = interitemSpacing
            self.ssPagerViewLayout.invalidateLayout()
        }
    }
    
    public var itemSize: CGSize = CGSize.zero {
        didSet {
            self.ssPagerViewLayout.itemSize = itemSize
            self.ssPagerViewLayout.invalidateLayout()
        }
    }
    
    public var contentsInset: UIEdgeInsets = UIEdgeInsets.init() {
        didSet {
            self.ssPagerCollectionView.contentInset = contentsInset
        }
    }
    
    public var isInfinite: Bool = false
    public var currentIndex: CGFloat = 0
    
    // MARK: Private properties
    private var ssPagerViewLayout: SSPagerViewLayout!
    private var ssPagerCollectionView: SSPagerCollectionView!
    private var numberOfItems: Int = 0
    private var numberOfSections: Int = 1
    private var dequeingSection = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    open override var backgroundColor: UIColor? {
        set {
            ssPagerCollectionView.backgroundColor = newValue
        }
        get {
            ssPagerCollectionView.backgroundColor
        }
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        self.ssPagerCollectionView.frame = self.bounds
    }
    
    private func commonInit() {
        
        ssPagerViewLayout = SSPagerViewLayout()
        ssPagerViewLayout.minimumInteritemSpacing = interitemSpacing
        ssPagerViewLayout.itemSize = itemSize
        
        ssPagerCollectionView = SSPagerCollectionView(frame: frame,
                                             collectionViewLayout: ssPagerViewLayout)
        
        ssPagerCollectionView.delegate = self
        ssPagerCollectionView.dataSource = self
        
        ssPagerCollectionView.decelerationRate = UIScrollView.DecelerationRate.fast
        
        addSubview(ssPagerCollectionView)
    }
}

extension SSPagerView {
    public func register(_ cellClass: Swift.AnyClass?, forCellWithReuseIdentifier identifier: String) {
        self.ssPagerCollectionView.register(cellClass, forCellWithReuseIdentifier: identifier)
    }
    
    public func register(_ nib: UINib?, forCellWithReuseIdentifier identifier: String) {
        self.ssPagerCollectionView.register(nib, forCellWithReuseIdentifier: identifier)
    }
    
    open func dequeueReusableCell(withReuseIdentifier identifier: String, at index: Int) -> UICollectionViewCell {
        let indexPath = IndexPath(item: index, section: self.dequeingSection)
        let cell = self.ssPagerCollectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath)
        guard cell.isKind(of: UICollectionViewCell.self) else {
            fatalError("Cell class must be subclass of FSPagerViewCell")
        }
        return cell
    }
    
    open func reloadData() {
        self.ssPagerCollectionView.reloadData()
    }
}

extension SSPagerView: UICollectionViewDataSource {
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        guard let dataSource = self.dataSource else {
            return 1
        }
        numberOfItems = dataSource.numberOfItems(in: self)
        guard numberOfItems > 0 else {
            return 0
        }
        return numberOfSections
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return isInfinite ? Int.max : numberOfItems
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        self.dequeingSection = indexPath.section
        let cell = dataSource!.pagerView(self, cellForItemAt: indexPath.item % numberOfItems)
        return cell
    }
    
}

extension SSPagerView: UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.pagerViewDidSelectPage?(at: indexPath.item % numberOfItems)
    }
    
    public func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        guard let layout = self.ssPagerCollectionView.collectionViewLayout as? UICollectionViewFlowLayout else {
            return
        }
        
        let widthPerPage = pageWidth(layout: layout)
        
        
        let idxOfNextPage = nextIndex(scrollView: scrollView,
                                      offset: targetContentOffset.pointee,
                                      widthPerPage: widthPerPage)
        
        let offsetOfNextPage = nextOffset(scrollView: scrollView,
                                          idxOfNextPage: idxOfNextPage,
                                          widthPerPage: widthPerPage)
        
        targetContentOffset.pointee = offsetOfNextPage
    }
}

extension SSPagerView {
    
    /// Calculate the page size using the item size and minimumLineSpacing.
    private func pageWidth(layout: UICollectionViewFlowLayout) -> CGFloat {
        return layout.itemSize.width + layout.minimumLineSpacing
    }
    
    private func nextIndex(scrollView: UIScrollView,
                           offset: CGPoint,
                           widthPerPage: CGFloat) -> CGFloat {
        
        func makeSmoother() {
            if scrollView.contentOffset.x > offset.x {
                roundedIndex = (isInfinite && roundedIndex < CGFloat(numberOfItems)) ? floor(index) : roundedIndex
            } else if scrollView.contentOffset.x < offset.x,
                      roundedIndex != 0 {
                roundedIndex = ceil(index)
            } else {
                roundedIndex = round(index)
            }
        }
        
        func makeOneStepPaging() {
            if currentIndex > roundedIndex {
                currentIndex -= 1
                roundedIndex = currentIndex
            } else if currentIndex < roundedIndex {
                currentIndex += 1
                roundedIndex = currentIndex
            }
        }
        
        let index = (offset.x + scrollView.contentInset.left) / widthPerPage
        var roundedIndex = round(index)
        makeSmoother()
        makeOneStepPaging()
        return roundedIndex
    }
    
    private func nextOffset(scrollView: UIScrollView,
                            idxOfNextPage: CGFloat,
                            widthPerPage: CGFloat) -> CGPoint {
        return CGPoint(x: (idxOfNextPage * widthPerPage) - scrollView.contentInset.left,
                       y: -scrollView.contentInset.top)
    }
}

