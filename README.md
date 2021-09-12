# SSPager

[![Languages](https://img.shields.io/badge/language-swift%205.0-FF69B4.svg?style=plastic)](#) 
[![Platform](https://img.shields.io/badge/platform-iOS%20-blue.svg?style=plastic)](https://github.com/9oya/SSPager)
[![Version](https://img.shields.io/cocoapods/v/SSPager.svg?style=plastic)](https://github.com/9oya/SSPager)
[![SPM compatible](https://img.shields.io/badge/SPM-compatible-FF9966.svg?style=plastic)](https://swift.org/package-manager/)

Super Simple Pager

## Example

To run the example project, clone the repo, and run `pod install` from the SSPagerExample directory first.

## Installation

### [CocoaPods](https://guides.cocoapods.org/using/using-cocoapods.html)

SSPager is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'SSPager'
```


### [Swift Package Manager](https://github.com/apple/swift-package-manager)

Create a `Package.swift` file.

```swift
// swift-tools-version:5.4

import PackageDescription

let package = Package(
  name: "SSPager",
  dependencies: [
    .package(url: "https://github.com/9oya/SSPager.git", from: "1.0.0")
  ],
  targets: [
      .target(
          name: "SSPager",
          path: "SSPager"
      )
  ]
)
```


## Usage

```swift
@IBOutlet weak var pagerView: SSPagerView!
```

```swift
pagerView.dataSource = self
pagerView.delegate = self
```

### DataSource

```swift
func numberOfItems(_ pagerView: SSPagerView) -> Int

func pagerView(_ pagerView: SSPagerView, cellForItemAt index: Int) -> UICollectionViewCell
```

### Paging

```swift
pagerView.interitemSpacing = 20.0
```

```swift
pagerView.isInfinite = true
```

```swift
pagerView.automaticSlidingInterval = 2.0
```

```swift
pagerView.pagingMode = .oneStepPaging // .scrollable
```

```swift
public func scrollToPage(at index: Int, animated: Bool)
```

```swift
let cellWidth = view.frame.width * 0.7
let cellHeight = view.frame.height * 0.7  
pagerView.itemSize = CGSize(width: cellWidth,
                            height: cellHeight)
```

```swift
let cellWidth = view.frame.width * 0.7
let cellHeight = view.frame.height * 0.7
pagerView.contentsInset = UIEdgeInsets(top: 100,
                                       left: (view.bounds.width - cellWidth) / 2,
                                       bottom: 100,
                                       right: (view.bounds.width - cellWidth) / 2)

// pagerView.contentsInset = UIEdgeInsets(top: 100,
//                                        left: 20,
//                                        bottom: 100,
//                                        right: 20)
```

### Delegate

```swift
func pagerViewDidSelectPage(at index: Int)

func pagerViewWillEndDragging(_ scrollView: UIScrollView, targetIndex: Int)
```

### Rx

SSPager provide a subspec **SSPager/Rx**
```ruby
pod 'SSPager/Rx'
```

```swift
@IBOutlet weak var pagerView: SSPagerView!
```

```swift
// You don't need to set...
// pagerView.dataSource = self
// pagerView.delegate = self
```

```swift
pagerView.register(SSPagerViewCell.self, forCellWithReuseIdentifier: String(describing: SSPagerViewCell.self))
```

#### Binding:


```swift
// let itemColors = [UIColor.red, UIColor.orange, UIColor.yellow, UIColor.green, UIColor.blue]

Observable.just(itemColors)
    .bind(to: pagerView.rx.pages(cellIdentifier: defaultCellId)) 
    { idx, color, cell in
        cell.backgroundColor = color
    }
    .disposed(by: disposeBag)
        
pagerView.rx.pageSelected
    .bind(onNext: { idx in
        print("Page \(idx) is selected.")
    })
    .disposed(by: disposeBag)
```

## Author

Eido Goya, eido9oya@gmail.com

## License

SSPager is available under the MIT license. See the LICENSE file for more info.
