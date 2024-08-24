// SPDX-License-Identifier: MIT
// Copyright © 2018-2023 WireGuard LLC. All Rights Reserved.

import UIKit

// MARK: - UITableViewCell Extension

extension UITableViewCell {

    /// A computed property that provides a reuse identifier for the cell class.
    /// The reuse identifier is derived from the class name.
    /// This allows for easy and consistent reuse of cells in a UITableView.
    static var reuseIdentifier: String {
        return NSStringFromClass(self)
    }
}

// MARK: - UITableView Extension

extension UITableView {

    /// Registers a UITableViewCell subclass for reuse with the table view.
    /// - Parameter type: The cell class to register.
    /// The registration uses the class's reuseIdentifier for dequeuing.
    func register<T: UITableViewCell>(_: T.Type) {
        register(T.self, forCellReuseIdentifier: T.reuseIdentifier)
    }

    /// Dequeues a reusable UITableViewCell of a specific subclass.
    /// - Parameter indexPath: The index path for the cell to dequeue.
    /// - Returns: A UITableViewCell of the specified subclass, cast to the expected type.
    /// - Note: This method forces a cast to the specified cell type. Ensure the cell type is correctly registered.
    func dequeueReusableCell<T: UITableViewCell>(for indexPath: IndexPath) -> T {
        // swiftlint:disable:next force_cast
        return dequeueReusableCell(withIdentifier: T.reuseIdentifier, for: indexPath) as! T
    }
}
