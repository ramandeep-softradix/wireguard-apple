// SPDX-License-Identifier: MIT
// Copyright © 2018-2023 WireGuard LLC. All Rights Reserved.

import UIKit

// ConfirmationAlertPresenter is responsible for presenting a confirmation alert to the user
class ConfirmationAlertPresenter {

    /// Displays a confirmation alert with a given message and button title.
    /// - Parameters:
    ///   - message: The message content to be displayed in the alert.
    ///   - buttonTitle: The title of the confirmation button.
    ///   - sourceObject: The object that provides the source for presenting the alert. It can be a `UIView` or `UIBarButtonItem`.
    ///   - presentingVC: The view controller from which to present the alert.
    ///   - onConfirmed: A closure to be executed when the confirmation button is tapped.
    static func showConfirmationAlert(message: String, buttonTitle: String, from sourceObject: AnyObject, presentingVC: UIViewController, onConfirmed: @escaping (() -> Void)) {
        // Create a destructive action for the confirmation button with the provided title
        let destroyAction = UIAlertAction(title: buttonTitle, style: .destructive) { _ in
            onConfirmed() // Execute the onConfirmed closure when the confirmation button is tapped
        }

        // Create a cancel action for the alert
        let cancelAction = UIAlertAction(title: tr("actionCancel"), style: .cancel)

        // Initialize the UIAlertController with the given message
        let alert = UIAlertController(title: "", message: message, preferredStyle: .actionSheet)
        alert.addAction(destroyAction) // Add the destructive action to the alert
        alert.addAction(cancelAction)  // Add the cancel action to the alert

        // Configure the popover presentation for iPad
        if let sourceView = sourceObject as? UIView {
            alert.popoverPresentationController?.sourceView = sourceView
            alert.popoverPresentationController?.sourceRect = sourceView.bounds
        } else if let sourceBarButtonItem = sourceObject as? UIBarButtonItem {
            alert.popoverPresentationController?.barButtonItem = sourceBarButtonItem
        }

        // Present the alert from the specified view controller
        presentingVC.present(alert, animated: true, completion: nil)
    }
}
