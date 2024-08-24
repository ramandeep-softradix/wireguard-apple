// SPDX-License-Identifier: MIT
// Copyright © 2018-2023 WireGuard LLC. All Rights Reserved.

import UIKit
import os.log

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    // Main application window
    var window: UIWindow?

    // Reference to the main view controller
    var mainVC: MainViewController?

    // Flag to determine if the app was launched for a specific action
    var isLaunchedForSpecificAction = false

    // Called when the app is about to finish launching
    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Configure global logging with a file path
        Logger.configureGlobal(tagged: "APP", withFilePath: FileManager.logFileURL?.path)

        // Check if the app was launched due to a URL or a shortcut item
        if let launchOptions = launchOptions {
            if launchOptions[.url] != nil || launchOptions[.shortcutItem] != nil {
                isLaunchedForSpecificAction = true
            }
        }

        // Initialize the main window and set its root view controller
        let window = UIWindow(frame: UIScreen.main.bounds)
        self.window = window

        let mainVC = MainViewController()
        window.rootViewController = mainVC
        window.makeKeyAndVisible()

        self.mainVC = mainVC

        return true
    }

    // Handles opening URLs
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        // Pass the URL to the main view controller for processing
        mainVC?.importFromDisposableFile(url: url)
        return true
    }

    // Called when the app becomes active
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Refresh the statuses of all tunnels
        mainVC?.refreshTunnelConnectionStatuses()
    }

    // Called when the app is about to resign active state
    func applicationWillResignActive(_ application: UIApplication) {
        // Create and assign quick action items for the app's home screen
        guard let allTunnelNames = mainVC?.allTunnelNames() else { return }
        application.shortcutItems = QuickActionItem.createItems(allTunnelNames: allTunnelNames)
    }

    // Handles quick action shortcuts
    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        // Ensure the shortcut type matches
        guard shortcutItem.type == QuickActionItem.type else {
            completionHandler(false)
            return
        }
        // Show the detail view for the tunnel associated with the shortcut item
        let tunnelName = shortcutItem.localizedTitle
        mainVC?.showTunnelDetailForTunnel(named: tunnelName, animated: false, shouldToggleStatus: true)
        completionHandler(true)
    }
}

// MARK: - State Restoration

extension AppDelegate {
    // Indicates whether the application state should be saved
    func application(_ application: UIApplication, shouldSaveApplicationState coder: NSCoder) -> Bool {
        return true
    }

    // Indicates whether the application state should be restored
    func application(_ application: UIApplication, shouldRestoreApplicationState coder: NSCoder) -> Bool {
        // Avoid restoring state if the app was launched for a specific action
        return !self.isLaunchedForSpecificAction
    }

    // Provides a view controller for restoration based on its identifier
    func application(_ application: UIApplication, viewControllerWithRestorationIdentifierPath identifierComponents: [String], coder: NSCoder) -> UIViewController? {
        guard let vcIdentifier = identifierComponents.last else { return nil }

        // Handle restoration of tunnel detail view controllers
        if vcIdentifier.hasPrefix("TunnelDetailVC:") {
            let tunnelName = String(vcIdentifier.suffix(vcIdentifier.count - "TunnelDetailVC:".count))
            if let tunnelsManager = mainVC?.tunnelsManager {
                // If tunnelsManager is available, create and return the tunnel detail view controller
//                if let tunnel = tunnelsManager.tunnel(named: tunnelName) {
//                    return TunnelDetailTableViewController(tunnelsManager: tunnelsManager, tunnel: tunnel)
//                }
            } else {
                // Show the tunnel detail view when tunnelsManager becomes available
                mainVC?.showTunnelDetailForTunnel(named: tunnelName, animated: false, shouldToggleStatus: false)
            }
        }
        return nil
    }
}
