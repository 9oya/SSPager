//
//  SSPagerView.swift
//  SSPager
//
//  Created by Eido Goya on 2021/09/04.
//

import UIKit

@objc
public protocol SSPagerViewDataSource {
    func numberOfPages(_ pagerView: SSPagerView) -> Int
    
    func pagerView(_ pagerView: SSPagerView, cellForItemAt index: Int) -> SSPagerViewCell
}

@objc
public protocol SSPagerViewDelegate {
    @objc optional func pagerViewDidSelectPage(at index: Int)
    
    @objc optional func pagerViewWillEndDragging(_ scrollView: UIScrollView, targetIndex: Int)
}

public enum SSPagingMode {
    case oneStep
    case scrollable
    case disable
}

public class SSPagerView: UIView {
    public var dataSource: SSPagerViewDataSource?
    public var delegate: SSPagerViewDelegate?
    
    public var automaticSlidingInterval: CGFloat = 0.0 {
        didSet {
            self.cancelTimer()
            if self.automaticSlidingInterval > 0 {
                self.startTimer()
            }
        }
    }
    
    public var interitemSpacing: CGFloat = 0 {
        didSet {
            self.ssPagerViewLayout.minimumInteritemSpacing = interitemSpacing
            self.ssPagerViewLayout.minimumLineSpacing = interitemSpacing
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
    public var pagingMode: SSPagingMode = .oneStep
    public var currentIndex: CGFloat = 0
    
    // MARK: Private properties
    private var ssPagerViewLayout: SSPagerViewLayout!
    private var ssPagerCollectionView: SSPagerCollectionView!
    private let multiple = 7
    private var numberOfItems: Int = 0 {
        didSet {
            if numberOfItems > 0 {
                self.infiniteItemCnt = numberOfItems*multiple
            }
        }
    }
    private var numberOfSections: Int = 1
    private var dequeingSection = 0
    private var timer: Timer?
    private var hasScrolledToCenter: Bool = false
    private var infiniteItemCnt: Int = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCollectionView()
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        setupCollectionView()
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
    
    public func invalidateLayout() {
        self.ssPagerViewLayout.invalidateLayout()
    }
    
    private func setupCollectionView() {
        
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
    
    // MARK: Public methods
    
    public func register(_ cellClass: Swift.AnyClass?, forCellWithReuseIdentifier identifier: String) {
        self.ssPagerCollectionView.register(cellClass, forCellWithReuseIdentifier: identifier)
    }
    
    public func register(_ nib: UINib?, forCellWithReuseIdentifier identifier: String) {
        self.ssPagerCollectionView.register(nib, forCellWithReuseIdentifier: identifier)
    }
    
    public func dequeueReusableCell(withReuseIdentifier identifier: String, at index: Int) -> UICollectionViewCell {
        let indexPath = IndexPath(item: index, section: self.dequeingSection)
        let cell = self.ssPagerCollectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath)
        guard cell.isKind(of: UICollectionViewCell.self) else {
            fatalError("Cell class must be subclass of FSPagerViewCell")
        }
        return cell
    }
    
    public func reloadData() {
        self.ssPagerCollectionView.reloadData()
    }
    
    public func scrollToPage(at index: Int, animated: Bool) {
        let currIdx = Int(currentIndex)
        let idxOfNextPage = currIdx<index ? currIdx+index : currIdx-index
        let nextOffset = nextOffset(scrollView: ssPagerCollectionView,
                                    idxOfNextPage: CGFloat(idxOfNextPage),
                                    widthPerPage: pageWidth(layout: ssPagerViewLayout))
        
        ssPagerCollectionView.setContentOffset(nextOffset, animated: animated)
        
        delegate?.pagerViewWillEndDragging?(ssPagerCollectionView, targetIndex: idxOfNextPage)
    }
    
}

extension SSPagerView: UICollectionViewDataSource {
    
    // MARK: UICollectionViewDataSource
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        guard let dataSource = self.dataSource else {
            return 1
        }
        numberOfItems = dataSource.numberOfPages(self)
        guard numberOfItems > 0 else {
            return 0
        }
        return numberOfSections
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        /// If the iOS version is lower than 14.5`return Int.max` is buggy
        return isInfinite ? infiniteItemCnt : numberOfItems
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        self.dequeingSection = indexPath.section
        let cell = dataSource!.pagerView(self, cellForItemAt: indexPath.item % numberOfItems)
        return cell
    }
    
}

extension SSPagerView: UICollectionViewDelegate {
    
    // MARK: UICollectionViewDelegate
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.pagerViewDidSelectPage?(at: indexPath.item % numberOfItems)
    }
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        cancelTimer()
    }
    
    public func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        guard let layout = self.ssPagerCollectionView.collectionViewLayout as? UICollectionViewFlowLayout else {
            return
        }
        let widthPerPage = pageWidth(layout: layout)
        let idxOfNextPage = nextIndex(scrollView: scrollView,
                                      offset: targetContentOffset.pointee,
                                      velocity: velocity,
                                      widthPerPage: widthPerPage)
        let offsetOfNextPage = nextOffset(scrollView: scrollView,
                                          idxOfNextPage: idxOfNextPage,
                                          widthPerPage: widthPerPage)
        targetContentOffset.pointee = offsetOfNextPage
        
        delegate?.pagerViewWillEndDragging?(scrollView, targetIndex: Int(idxOfNextPage))
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if timer == nil {
            startTimer()
        }
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard isInfinite else { return }
        let index = currentIndex(offset: scrollView.contentOffset,
                                 inset: scrollView.contentInset,
                                 widthPerPage: pageWidth(layout: ssPagerViewLayout))
        let currIdx = Int(round(index))
        let midStartIdx = multiple/2
        let midNextIdx = (numberOfItems*midStartIdx)+(currIdx%numberOfItems)
        if currIdx <= (numberOfItems*midStartIdx)-1 {
            /**
               ❏ ❏ ◼︎   ❏ ❏ ❏  ❏ ❏ ❏
             -> ❏ ❏ ❏   ❏ ❏ ◼︎  ❏ ❏ ❏
             */
            scrollWithoutAnimation(to: midNextIdx)
        } else if currIdx >= (numberOfItems*midStartIdx)+numberOfItems {
            /**
               ❏ ❏ ❏   ❏ ❏ ❏  ◼︎ ❏ ❏
             -> ❏ ❏ ❏   ◼︎ ❏ ❏  ❏ ❏ ❏
             */
            scrollWithoutAnimation(to: midNextIdx)
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard isInfinite && !hasScrolledToCenter else {
            return
        }
        // Scroll to the center only once when initializing.
        scrollWithoutAnimation(to: numberOfItems * (multiple/2))
        hasScrolledToCenter = true
    }
}

extension SSPagerView {
    
    // MARK: Private methods
    
    /// Calculate the page size using the item size and minimumLineSpacing.
    private func pageWidth(layout: UICollectionViewFlowLayout) -> CGFloat {
        return layout.itemSize.width + layout.minimumLineSpacing
    }
    
    /// Calculate the current index
    private func currentIndex(offset: CGPoint,
                              inset: UIEdgeInsets,
                              widthPerPage: CGFloat) -> CGFloat {
        let index = (offset.x + inset.left) / widthPerPage
        return index
    }
    
    /// Calculate the index of the next page using the scrollView offset.
    private func nextIndex(scrollView: UIScrollView,
                           offset: CGPoint,
                           velocity: CGPoint,
                           widthPerPage: CGFloat) -> CGFloat {
        let contentOffset = scrollView.contentOffset
        let contentInset = scrollView.contentInset
        let index = currentIndex(offset: offset,
                                 inset: contentInset,
                                 widthPerPage: widthPerPage)
        var roundedIndex = round(index)
        
        // Make scrolling smoother.
        if (contentOffset.x > offset.x) && velocity.x < 0 {
            // Scroll to previous <-
            roundedIndex = floor(index)
        } else if (contentOffset.x < offset.x) && velocity.x > 0 {
            // Scroll to next ->
            roundedIndex = ceil(index)
        }
        
        // Apply paging mode.
        switch pagingMode {
        case .oneStep:
            if currentIndex > roundedIndex {
                currentIndex -= 1
                roundedIndex = currentIndex
            } else if currentIndex < roundedIndex {
                currentIndex += 1
                roundedIndex = currentIndex
            }
        case .scrollable, .disable:
            break
        }
        
        return roundedIndex
    }
    
    /// Calculate the index of the next page using current index
    private func nextIndex() -> CGFloat {
        var idxOfNextPage = Int(currentIndex+1.0)
        idxOfNextPage = isInfinite ? idxOfNextPage : idxOfNextPage % self.numberOfItems
        currentIndex += 1
        return CGFloat(idxOfNextPage)
    }
    
    /// Create a scroll offset on the next page.
    private func nextOffset(scrollView: UIScrollView,
                            idxOfNextPage: CGFloat,
                            widthPerPage: CGFloat) -> CGPoint {
        return CGPoint(x: (idxOfNextPage * widthPerPage) - scrollView.contentInset.left,
                       y: -scrollView.contentInset.top)
    }
    
    private func startTimer() {
        guard self.automaticSlidingInterval > 0 && self.timer == nil else {
            return
        }
        self.timer = Timer.scheduledTimer(timeInterval: TimeInterval(self.automaticSlidingInterval),
                                          target: self,
                                          selector: #selector(self.flipNext(sender:)),
                                          userInfo: nil,
                                          repeats: true)
        RunLoop.current.add(self.timer!, forMode: .common)
    }
    
    @objc
    private func flipNext(sender: Timer?) {
        guard let _ = self.superview,
              let _ = self.window,
              self.numberOfItems > 0 else {
            return
        }
        let contentOffset: CGPoint = {
            return nextOffset(scrollView: ssPagerCollectionView,
                              idxOfNextPage: nextIndex(),
                              widthPerPage: pageWidth(layout: ssPagerViewLayout))
        }()
        self.ssPagerCollectionView.setContentOffset(contentOffset, animated: true)
        self.scrollViewDidEndDecelerating(ssPagerCollectionView)
    }
    
    private func cancelTimer() {
        guard self.timer != nil else {
            return
        }
        self.timer!.invalidate()
        self.timer = nil
    }
    
    private func scrollWithoutAnimation(to index: Int) {
        let nextOffset = nextOffset(scrollView: ssPagerCollectionView,
                                    idxOfNextPage: CGFloat(index),
                                    widthPerPage: pageWidth(layout: ssPagerViewLayout))
        currentIndex = CGFloat(index)
        ssPagerCollectionView.setContentOffset(nextOffset, animated: false)
        delegate?.pagerViewWillEndDragging?(ssPagerCollectionView, targetIndex: index)
    }
}
