//
//  StackViewGestureHandler.swift
//  
//
//  Created by Ruben Nine on 15/07/2020.
//

import UIKit

class StackViewGestureHandler {
    let stackView: UIStackView
    var hoveringView: UIView?
    var beginPoint: CGPoint?

    init(stackView: UIStackView) {
        self.stackView = stackView
    }

    func handle(recognizer: UIPanGestureRecognizer) -> UIView? {
        defer {
            switch recognizer.state {
            case .ended, .cancelled, .failed:
                hoveringView = nil
                beginPoint = nil
            default:
                break
            }
        }

        let targetPoint = calculateTargetPoint(using: recognizer)

        for view in stackView.arrangedSubviews {
            if view.frame.contains(targetPoint), hoveringView != view {
                hoveringView = view
                return view
            }
        }

        return nil
    }

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

