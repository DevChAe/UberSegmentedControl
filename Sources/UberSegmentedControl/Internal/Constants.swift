//
//  File.swift
//  
//
//  Created by Ruben Nine on 16/07/2020.
//

import UIKit

struct Constants {
    struct Color {}
    struct Measure {}
    struct Margins {}
    struct Duration {}
}

extension Constants.Color {
    static let divider: UIColor = {
        if #available(iOS 13.0, *) {
            return .secondarySystemFill
        } else {
            return .black
        }
    }()

    static let selectedSegmentTint: UIColor = {
        if #available(iOS 13.0, *) {
            return UIColor { (traits) -> UIColor in
                if traits.userInterfaceStyle == .dark {
                    return UIColor.white.withAlphaComponent(0.28)
                } else {
                    return .white
                }
            }
        } else {
            return .white
        }
    }()

    static let label: UIColor = {
        if #available(iOS 13.0, *) {
            return .label
        } else {
            return .black
        }
    }()

    static let background: UIColor = {
        if #available(iOS 13.0, *) {
            return .tertiarySystemFill
        } else {
            return UIColor.black.withAlphaComponent(0.25)
        }
    }()

    static let segmentShadow: UIColor = .black
}

extension Constants.Measure {
    static let cornerRadius: CGFloat = 8
    static let spacingBetweenSegments: CGFloat = 5
    static let highlightedScale: CGFloat = 0.95
    static let highlightedAlpha: CGFloat = 0.25
    static let segmentCornerRadius: CGFloat = 6
    static let segmentShadowRadius: CGFloat = 4
    static let segmentShadowOpacity: Float = 0.1
    static let segmentShadowOffset = CGSize(width: 0, height: 3)
    static let segmentHeight: CGFloat = 32
}

extension Constants.Margins {
    static let dividerInsets = UIEdgeInsets(top: 6, left: 0, bottom: 6, right: 0)
    static let segmentInsets = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
    static let titleEdgeInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 0)
}

extension Constants.Duration {
    static let snappy: TimeInterval = 0.125
    static let regular: TimeInterval = 0.500
}
