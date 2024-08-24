// SPDX-License-Identifier: MIT
// Copyright © 2018-2023 WireGuard LLC. All Rights Reserved.

import UIKit
import os.log

// ErrorPresenter handles displaying error alerts to the user
class ErrorPresenter: ErrorPresenterProtocol {

    /// Displays an error alert with a given title and message
    /// - Parameters:
    ///   - title: The title of the alert
    ///   - message: The message of the alert
    ///   - sourceVC: The view controller from which to present the alert. Must be of type `UIViewController`.
    ///   - onPresented: A closure to be executed after the alert is presented
    ///   - onDismissal: A closure to be executed after the alert is dismissed
    static func showErrorAlert(title: String, message: String, from sourceVC: AnyObject?, onPresented: (() -> Void)?, onDismissal: (() -> Void)?) {
        // Ensure the sourceVC is of type UIViewController
        guard let sourceVC = sourceVC as? UIViewController else { return }

        // Create an "OK" action for the alert
        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
            onDismissal?() // Call the dismissal closure when the "OK" button is pressed
        }

        // Create the alert controller with the given title and message
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(okAction) // Add the "OK" action to the alert

        // Present the alert from the source view controller
        sourceVC.present(alert, animated: true, completion: onPresented) // Call the presentation closure when the alert is presented
    }
}
