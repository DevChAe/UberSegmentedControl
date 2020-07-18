//
//  UIView+fill.swift
//  
//
//  Created by Ruben Nine on 14/07/2020.
//

import UIKit

private protocol Anchorable {
    var leadingAnchor: NSLayoutXAxisAnchor { get }
    var trailingAnchor: NSLayoutXAxisAnchor { get }
    var topAnchor: NSLayoutYAxisAnchor { get }
    var bottomAnchor: NSLayoutYAxisAnchor { get }
}

extension UIView: Anchorable {}
extension UILayoutGuide: Anchorable {}

extension UIView {
    @discardableResult
    func fill(with view: UIView,
              constant: CGFloat = 0,
              usingGuide layoutGuide: UILayoutGuide? = nil,
              shouldAutoActivate: Bool = false) -> [NSLayoutConstraint]?
    {
        guard !subviews.contains(view) else { return nil }

        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)

        let anchorable: Anchorable = layoutGuide ?? self
        var constraints: [NSLayoutConstraint] = []

        constraints.append(view.leadingAnchor.constraint(equalTo: anchorable.leadingAnchor, constant: constant))
        constraints.append(view.trailingAnchor.constraint(equalTo: anchorable.trailingAnchor, constant: constant))
        constraints.append(view.topAnchor.constraint(equalTo: anchorable.topAnchor, constant: constant))
        constraints.append(view.bottomAnchor.constraint(equalTo: anchorable.bottomAnchor, constant: constant))

        if shouldAutoActivate {
            for constraint in constraints {
                constraint.isActive = true
            }
        }

        return constraints
    }
}
