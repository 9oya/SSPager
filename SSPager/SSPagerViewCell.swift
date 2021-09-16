//
//  SSPagerViewCell.swift
//  SSPager
//
//  Created by Eido Goya on 2021/09/04.
//

import UIKit

public enum PagerViewCellShadow {
    case none
    case `default`
    case custom(shadowRadius: CGFloat,
                opacity: CGFloat,
                offset: CGSize)
}

open class SSPagerViewCell: UICollectionViewCell {
    
    public var shadowType: PagerViewCellShadow = .none {
        didSet {
            switch shadowType {
            case .none:
                break
            case .default:
                layer.shadowRadius = 10
                layer.shadowOpacity = 0.4
                layer.shadowOffset = CGSize(width: 5, height: 10)
            case let .custom(shadowRadius,
                             opacity,
                             offset):
                layer.shadowRadius = shadowRadius
                layer.shadowOpacity = Float(opacity)
                layer.shadowOffset = offset
            }
        }
    }
    
}
