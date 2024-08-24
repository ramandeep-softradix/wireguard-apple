// SPDX-License-Identifier: MIT
// Copyright © 2018-2023 WireGuard LLC. All Rights Reserved.

import UIKit

/// A custom UIView that contains a UIButton with a border and rounded corners.
/// The button's title and tap action can be customized.
class BorderedTextButton: UIView {
    // The UIButton contained within this view. It will display the text and handle tap actions.
    let button: UIButton = {
        let button = UIButton(type: .system)
        button.titleLabel?.font = UIFont.preferredFont(forTextStyle: .body) // Set the font to preferred body style
        button.titleLabel?.adjustsFontForContentSizeCategory = true // Ensure font adjusts for accessibility
        return button
    }()

    // Computes the intrinsic content size of the view based on the button's size.
    // Adds extra padding to the width and height to accommodate the border and rounded corners.
    override var intrinsicContentSize: CGSize {
        let buttonSize = button.intrinsicContentSize
        return CGSize(width: buttonSize.width + 32, height: buttonSize.height + 16)
    }

    // The title of the button. This property can be used to get or set the button's title.
    var title: String {
        get { return button.title(for: .normal) ?? "" }
        set(value) { button.setTitle(value, for: .normal) }
    }

    // Closure that gets called when the button is tapped.
    var onTapped: (() -> Void)?

    // Initializer for creating the view programmatically.
    init() {
        super.init(frame: CGRect.zero)

        // Set up the view's appearance with a border and rounded corners.
        layer.borderWidth = 1 // Border width
        layer.cornerRadius = 5 // Corner radius for rounded corners
        layer.borderColor = button.tintColor.cgColor // Border color matches the button's tint color

        // Add the button to the view and set up constraints.
        addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.centerXAnchor.constraint(equalTo: centerXAnchor), // Center button horizontally
            button.centerYAnchor.constraint(equalTo: centerYAnchor)  // Center button vertically
        ])

        // Set up the button tap action.
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
    }

    // Required initializer for loading the view from a storyboard or nib.
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // Method called when the button is tapped. It triggers the `onTapped` closure if it is set.
    @objc func buttonTapped() {
        onTapped?()
    }
}
