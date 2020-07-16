//
//  UIView+fill.swift
//  
//
//  Created by Ruben Nine on 14/07/2020.
//

import UIKit

extension UIView {
    @discardableResult
    func fill(with view: UIView, usingMarginsGuide: Bool = false, shouldAutoActivate: Bool = false) -> [NSLayoutConstraint]? {
        guard !subviews.contains(view) else { return nil }

        view.translatesAutoresizingMaskIntoConstraints = false

        addSubview(view)

        var constraints: [NSLayoutConstraint] = []

        if usingMarginsGuide {
            constraints.append(view.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor))
            constraints.append(view.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor))
            constraints.append(view.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor))
            constraints.append(view.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor))
        } else {
            constraints.append(view.leadingAnchor.constraint(equalTo: leadingAnchor))
            constraints.append(view.trailingAnchor.constraint(equalTo: trailingAnchor))
            constraints.append(view.topAnchor.constraint(equalTo: topAnchor))
            constraints.append(view.bottomAnchor.constraint(equalTo: bottomAnchor))
        }

        if shouldAutoActivate {
            for constraint in constraints {
                constraint.isActive = true
            }
        }

        return constraints
    }
}

