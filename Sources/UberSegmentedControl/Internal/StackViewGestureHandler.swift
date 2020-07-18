//
//  StackViewGestureHandler.swift
//  
//
//  Created by Ruben Nine on 15/07/2020.
//

import UIKit

class StackViewGestureHandler {
    // MARK: - Private Properties

    private let stackView: UIStackView
    private let tracksMultiple: Bool

    private var trackedButton: UIButton?
    private var beginPoint: CGPoint?
    private var currentGestures = Set<UIGestureRecognizer>()
    private var recognizedButtons = Set<UIButton>()

    private var highlightedButton: UIButton? {
        willSet {
            if highlightedButton != newValue { highlightedButton?.isHighlighted = false }
        }

        didSet {
            if highlightedButton != oldValue { highlightedButton?.isHighlighted = true }
        }
    }

    // MARK: - Lifecycle

    init(stackView: UIStackView, tracksMultiple: Bool = false) {
        self.stackView = stackView
        self.tracksMultiple = tracksMultiple
    }
}

// MARK: - Internal Functions

extension StackViewGestureHandler {
    func handle(recognizer: UIGestureRecognizer) -> UIButton? {
        currentGestures.insert(recognizer)

        defer {
            switch recognizer.state {
            case .ended, .cancelled, .failed:
                currentGestures.remove(recognizer)

                if currentGestures.isEmpty {
                    highlightedButton?.isHighlighted = false
                    highlightedButton = nil
                    trackedButton = nil
                    beginPoint = nil
                    recognizedButtons.removeAll()
                }
            default:
                break
            }
        }

        let targetPoint: CGPoint

        if let panRecognizer = recognizer as? UIPanGestureRecognizer {
            targetPoint = calculateTargetPoint(using: panRecognizer)
        } else {
            targetPoint = recognizer.location(in: stackView)
        }

        let buttons = stackView.arrangedSubviews.compactMap { $0 as? UIButton }

        for button in buttons {
            if button.frame.contains(targetPoint) {
                if recognizedButtons.isEmpty, trackedButton == nil, button.isSelected {
                    // Store tracked button
                    trackedButton = button
                }

                highlightedButton = button

                switch recognizer {
                case is UILongPressGestureRecognizer:
                    // Ignore long press gesture until gesture ends.
                    guard recognizer.state != .began, recognizer.state != .changed else { continue }
                case is UIPanGestureRecognizer:
                    // Ignore pan gesture if tracking single button and there is no tracked button.
                    if !tracksMultiple, trackedButton == nil { continue }
                default:
                    break
                }

                if !recognizedButtons.contains(button) {
                    if tracksMultiple { recognizedButtons.insert(button) }

                    return button
                }
            }
        }

        return nil
    }
}

// MARK: - Private Functions

private extension StackViewGestureHandler {
    func calculateTargetPoint(using recognizer: UIPanGestureRecognizer) -> CGPoint {
        let beginPoint = self.beginPoint ?? recognizer.location(in: stackView)
        let translation = recognizer.translation(in: stackView)

        if self.beginPoint == nil {
            self.beginPoint = beginPoint
        }

        let transform: CGAffineTransform

        if stackView.axis == .horizontal {
            // Ignore y translation
            transform = CGAffineTransform(translationX: translation.x, y: 0)
        } else {
            // Ignore x translation
            transform = CGAffineTransform(translationX: 0, y: translation.y)
        }

        return beginPoint.applying(transform)
    }
}

