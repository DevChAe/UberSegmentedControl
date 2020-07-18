//
//  SegmentButton.swift
//  
//
//  Created by Ruben Nine on 14/07/2020.
//

import UIKit

class SegmentButton: UIButton {
    // MARK: - Internal Properties

    var selectedBackgroundColor: UIColor?

    // MARK: - Lifecycle

    convenience init() {
        self.init(frame: .zero)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - UIButton Overrides

extension SegmentButton {
    override var isSelected: Bool {
        didSet {
            if isSelected && isHighlighted { isHighlighted = false }
            if isSelected != oldValue { updateBackground() }
        }
    }

    override var isHighlighted: Bool {
        didSet {
            guard isHighlighted != oldValue else { return }

            // Animate alpha fade
            UIView.animate(withDuration: Constants.Duration.regular) {
                UIView.setAnimationBeginsFromCurrentState(true)

                if self.isSelected {
                    self.alpha = 1
                } else {
                    self.alpha = self.isHighlighted ? Constants.Measure.highlightedAlpha : 1
                }
            }

            // Animate scale
            UIView.animate(withDuration: Constants.Duration.snappy) {
                UIView.setAnimationBeginsFromCurrentState(true)

                if self.isSelected {
                    self.transform = self.isHighlighted ?
                        CGAffineTransform(scaleX: Constants.Measure.highlightedScale, y: Constants.Measure.highlightedScale) :
                        .identity
                } else {
                    self.transform = .identity
                }
            }
        }
    }
}

// MARK: - Private Functions

private extension SegmentButton {
    func setup() {
        titleLabel?.textAlignment = .center
        titleLabel?.font = Constants.Font.segmentTitleLabel
        tintColor = Constants.Color.label
        setTitleColor(Constants.Color.label, for: .normal)
        adjustsImageWhenHighlighted = false

        layer.cornerRadius = Constants.Measure.segmentCornerRadius
        layer.shadowRadius = Constants.Measure.segmentShadowRadius
        layer.shadowColor = Constants.Color.segmentShadow.cgColor
        layer.shadowOffset = Constants.Measure.segmentShadowOffset
        layer.shadowOpacity = Constants.Measure.segmentShadowOpacity
    }

    func updateBackground() {
        if isSelected, let selectedBackgroundColor = selectedBackgroundColor {
            backgroundColor = selectedBackgroundColor
        } else {
            backgroundColor = .clear
        }
    }
}
