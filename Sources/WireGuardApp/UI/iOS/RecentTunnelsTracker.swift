// SPDX-License-Identifier: MIT
// Copyright © 2018-2023 WireGuard LLC. All Rights Reserved.

import Foundation

/// A class responsible for tracking recently activated tunnels in user defaults.
/// This includes handling tunnel activations, removals, renaming, and cleanup of old entries.
class RecentTunnelsTracker {

    // Key used to store the list of recently activated tunnel names in user defaults.
    private static let keyRecentlyActivatedTunnelNames = "recentlyActivatedTunnelNames"
    // Maximum number of tunnels to keep track of.
    private static let maxNumberOfTunnels = 10

    // A computed property to obtain the shared user defaults for storing recent tunnel data.
    private static var userDefaults: UserDefaults? {
        guard let appGroupId = FileManager.appGroupId else {
            wg_log(.error, staticMessage: "Cannot obtain app group ID from bundle for tracking recently used tunnels")
            return nil
        }
        guard let userDefaults = UserDefaults(suiteName: appGroupId) else {
            wg_log(.error, staticMessage: "Cannot obtain shared user defaults for tracking recently used tunnels")
            return nil
        }
        return userDefaults
    }

    /// Handles the activation of a tunnel by updating the list of recently activated tunnels.
    /// - Parameter tunnelName: The name of the tunnel that was activated.
    static func handleTunnelActivated(tunnelName: String) {
        guard let userDefaults = RecentTunnelsTracker.userDefaults else { return }
        var recentTunnels = userDefaults.stringArray(forKey: keyRecentlyActivatedTunnelNames) ?? []
        if let existingIndex = recentTunnels.firstIndex(of: tunnelName) {
            // Remove the tunnel if it already exists in the list.
            recentTunnels.remove(at: existingIndex)
        }
        // Insert the activated tunnel at the beginning of the list.
        recentTunnels.insert(tunnelName, at: 0)
        // Ensure the list does not exceed the maximum number of tunnels.
        if recentTunnels.count > maxNumberOfTunnels {
            recentTunnels.removeLast(recentTunnels.count - maxNumberOfTunnels)
        }
        userDefaults.set(recentTunnels, forKey: keyRecentlyActivatedTunnelNames)
    }

    /// Handles the removal of a tunnel by updating the list of recently activated tunnels.
    /// - Parameter tunnelName: The name of the tunnel that was removed.
    static func handleTunnelRemoved(tunnelName: String) {
        guard let userDefaults = RecentTunnelsTracker.userDefaults else { return }
        var recentTunnels = userDefaults.stringArray(forKey: keyRecentlyActivatedTunnelNames) ?? []
        if let existingIndex = recentTunnels.firstIndex(of: tunnelName) {
            // Remove the tunnel from the list.
            recentTunnels.remove(at: existingIndex)
            userDefaults.set(recentTunnels, forKey: keyRecentlyActivatedTunnelNames)
        }
    }

    /// Handles the renaming of a tunnel by updating the list of recently activated tunnels.
    /// - Parameters:
    ///   - oldName: The current name of the tunnel.
    ///   - newName: The new name of the tunnel.
    static func handleTunnelRenamed(oldName: String, newName: String) {
        guard let userDefaults = RecentTunnelsTracker.userDefaults else { return }
        var recentTunnels = userDefaults.stringArray(forKey: keyRecentlyActivatedTunnelNames) ?? []
        if let existingIndex = recentTunnels.firstIndex(of: oldName) {
            // Update the tunnel name in the list.
            recentTunnels[existingIndex] = newName
            userDefaults.set(recentTunnels, forKey: keyRecentlyActivatedTunnelNames)
        }
    }

    /// Cleans up the list of recently activated tunnels by removing entries not in the provided set.
    /// - Parameter tunnelNamesToKeep: A set of tunnel names to retain in the list.
    static func cleanupTunnels(except tunnelNamesToKeep: Set<String>) {
        guard let userDefaults = RecentTunnelsTracker.userDefaults else { return }
        var recentTunnels = userDefaults.stringArray(forKey: keyRecentlyActivatedTunnelNames) ?? []
        let oldCount = recentTunnels.count
        // Remove tunnels not in the set of names to keep.
        recentTunnels.removeAll { !tunnelNamesToKeep.contains($0) }
        if oldCount != recentTunnels.count {
            userDefaults.set(recentTunnels, forKey: keyRecentlyActivatedTunnelNames)
        }
    }

    /// Retrieves a limited list of recently activated tunnel names.
    /// - Parameter limit: The maximum number of tunnel names to return.
    /// - Returns: An array of recently activated tunnel names, limited to the specified number.
    static func recentlyActivatedTunnelNames(limit: Int) -> [String] {
        guard let userDefaults = RecentTunnelsTracker.userDefaults else { return [] }
        var recentTunnels = userDefaults.stringArray(forKey: keyRecentlyActivatedTunnelNames) ?? []
        if limit < recentTunnels.count {
            // Trim the list to the specified limit.
            recentTunnels.removeLast(recentTunnels.count - limit)
        }
        return recentTunnels
    }
}
