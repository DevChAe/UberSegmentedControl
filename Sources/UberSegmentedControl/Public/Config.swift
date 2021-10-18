//
//  Config.swift
//  
//
//  Created by Ruben Nine on 18/10/21.
//

import UIKit

/// A config object that may be provided to `UberSegmentedControl` upon initialization.
public struct Config: Equatable {
    /// The `UIFont` to use for each segment in the `UberSegmentedControl`.
    public let font: UIFont

    /// The `UIColor` to use for each segment in the `UberSegmentedControl`.
    public let tintColor: UIColor

    /// Whether the `UberSegmentedControl` supports multiple selection.
    public internal(set) var allowsMultipleSelection: Bool

    /// Default font.
    public static let defaultFont = Constants.Font.segmentTitleLabel

    /// Default tint color.
    public static let defaultTintColor = Constants.Color.label

    /// Initializes a new `Config` object with any user-provided options.
    public init(font: UIFont = Config.defaultFont,
                tintColor: UIColor = Config.defaultTintColor,
                allowsMultipleSelection: Bool = false) {
        self.font = font
        self.tintColor = tintColor
        self.allowsMultipleSelection = allowsMultipleSelection
    }
}
