//
//  DividerView.swift
//  
//
//  Created by Ruben Nine on 14/07/2020.
//

import UIKit

class DividerView: UIView {
    convenience init(alpha: CGFloat) {
        self.init(frame: .zero)
        self.alpha = alpha
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        isOpaque = false
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }

        context.saveGState()

        context.addRect(CGRect(x: bounds.maxX - 1, y: bounds.minY, width: bounds.maxX, height: bounds.height))
        context.clip()

        let gradient = CGGradient(colorsSpace: CGColorSpace(name: CGColorSpace.sRGB),
                                  colors: [
                                    UIColor.clear.cgColor,
                                    Constants.Color.divider.cgColor,
                                    Constants.Color.divider.cgColor,
                                    UIColor.clear.cgColor
                                  ] as CFArray,
                                  locations: [0.0, 0.1, 0.9, 1.0])!

        context.drawLinearGradient(gradient,
                                   start: CGPoint(x: bounds.midX, y: bounds.minY),
                                   end: CGPoint(x: bounds.midX, y: bounds.maxY),
                                   options: CGGradientDrawingOptions.drawsAfterEndLocation)

        context.restoreGState()
    }
}
