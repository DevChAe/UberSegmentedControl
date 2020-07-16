//
//  SegmentButton.swift
//  
//
//  Created by Ruben Nine on 14/07/2020.
//

import UIKit

class SegmentButton: UIButton {
    var selectedBackgroundTintColor: UIColor?

    override var isSelected: Bool {
        didSet {
            updateBackground()
        }
    }

    override var isHighlighted: Bool {
        didSet {
            // Animate alpha fade
            DispatchQueue.main.asyncAfter(deadline: .now() + Constants.Duration.snappy) {
                UIView.animate(withDuration: Constants.Duration.regular) {
                    if self.isSelected {
                        self.alpha = 1
                    } else {
                        self.alpha = self.isHighlighted ? Constants.Measure.highlightedAlpha : 1
                    }
                }
            }

            // Animate scale
            UIView.animate(withDuration: Constants.Duration.regular) {
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

private extension SegmentButton {
    func setup() {
        layer.cornerRadius = Constants.Measure.segmentCornerRadius
        layer.shadowRadius = Constants.Measure.segmentShadowRadius
        layer.shadowColor = Constants.Color.segmentShadow.cgColor
        layer.shadowOffset = Constants.Measure.segmentShadowOffset
        layer.shadowOpacity = Constants.Measure.segmentShadowOpacity
    }

    func updateBackground() {
        if isSelected, let selectedBackgroundTintColor = selectedBackgroundTintColor {
            backgroundColor = selectedBackgroundTintColor
        } else {
            backgroundColor = .clear
        }
    }
}
