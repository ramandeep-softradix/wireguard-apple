// SPDX-License-Identifier: MIT
// Copyright © 2018-2023 WireGuard LLC. All Rights Reserved.

import UIKit

/**
 * The `QuickActionItem` class is used to create dynamic home screen quick actions for an iOS app.
 * This class subclasses `UIApplicationShortcutItem` to represent quick actions that users can access
 * by long-pressing the app icon on the home screen. Each quick action allows users to quickly activate
 * and view a specific WireGuard tunnel.
 *
 * - Note: iOS currently supports showing up to 4 quick action items, but this number might increase in the future.
 */
class QuickActionItem: UIApplicationShortcutItem {

    /// A constant string used to identify the type of quick action.
    static let type = "WireGuardTunnelActivateAndShow"

    /**
     * Initializes a `QuickActionItem` with the given tunnel name.
     *
     * - Parameter tunnelName: The name of the tunnel to be displayed in the quick action.
     */
    init(tunnelName: String) {
        super.init(type: QuickActionItem.type, localizedTitle: tunnelName, localizedSubtitle: nil, icon: nil, userInfo: nil)
    }

    /**
     * Creates an array of `QuickActionItem` instances based on the list of all available tunnel names.
     * It generates quick action items for the most recently activated tunnels and fills any remaining slots
     * with other available tunnels.
     *
     * - Parameter allTunnelNames: A list of all available tunnel names.
     * - Returns: An array of `QuickActionItem` instances, with up to 10 items.
     */
    static func createItems(allTunnelNames: [String]) -> [QuickActionItem] {
        let numberOfItems = 10
        // Fetch up to `numberOfItems` recently activated tunnels.
        var tunnelNames = RecentTunnelsTracker.recentlyActivatedTunnelNames(limit: numberOfItems)
        let numberOfSlotsRemaining = numberOfItems - tunnelNames.count

        // If there are remaining slots, add more tunnels from the list of all tunnel names.
        if numberOfSlotsRemaining > 0 {
            let moreTunnels = allTunnelNames.filter { !tunnelNames.contains($0) }.prefix(numberOfSlotsRemaining)
            tunnelNames.append(contentsOf: moreTunnels)
        }

        // Map tunnel names to `QuickActionItem` instances.
        return tunnelNames.map { QuickActionItem(tunnelName: $0) }
    }
}
