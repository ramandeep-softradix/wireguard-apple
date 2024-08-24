// SPDX-License-Identifier: MIT
// Copyright © 2018-2023 WireGuard LLC. All Rights Reserved.

import UIKit

// Main view controller managing the split view interface with a master-detail layout
class MainViewController: UISplitViewController {

    // Manager for handling tunnels
    var tunnelsManager: TunnelsManager?

    // Closure called when the tunnels manager is ready
    var onTunnelsManagerReady: ((TunnelsManager) -> Void)?

    // Reference to the master view controller displaying the list of tunnels
    var tunnelsListVC: TunnelsListTableViewController?

    // Initializer to set up the split view controller with a master-detail layout
    init() {
        // Create a dummy detail view controller and navigation controller
        let detailVC = UIViewController()
        detailVC.view.backgroundColor = .systemBackground
        let detailNC = UINavigationController(rootViewController: detailVC)

        // Create the master view controller for the list of tunnels
        let masterVC = TunnelsListTableViewController()
        let masterNC = UINavigationController(rootViewController: masterVC)

        tunnelsListVC = masterVC

        // Initialize UISplitViewController with master and detail view controllers
        super.init(nibName: nil, bundle: nil)

        viewControllers = [ masterNC, detailNC ]

        restorationIdentifier = "MainVC"
        masterNC.restorationIdentifier = "MasterNC"
        detailNC.restorationIdentifier = "DetailNC"
    }

    // Required initializer for loading from storyboard or nib files
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Set the delegate for UISplitViewController
        delegate = self

        // Ensure both master and detail view controllers are visible on iPad, even in portrait mode
        preferredDisplayMode = .allVisible

        // Create and configure the tunnels manager
        TunnelsManager.create { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .failure(let error):
                // Display error if tunnels manager creation fails
                ErrorPresenter.showErrorAlert(error: error, from: self)
            case .success(let tunnelsManager):
                // Successfully created tunnels manager, configure it and notify the master view controller
                self.tunnelsManager = tunnelsManager
                self.tunnelsListVC?.setTunnelsManager(tunnelsManager: tunnelsManager)

                // Set the activation delegate for tunnels manager
                tunnelsManager.activationDelegate = self

                // Call the completion handler if set
                self.onTunnelsManagerReady?(tunnelsManager)
                self.onTunnelsManagerReady = nil
            }
        }
    }

    // Returns a list of tunnel names managed by the tunnels manager
    func allTunnelNames() -> [String]? {
        guard let tunnelsManager = self.tunnelsManager else { return nil }
        return tunnelsManager.mapTunnels { $0.name }
    }
}

// MARK: - TunnelsManagerActivationDelegate

extension MainViewController: TunnelsManagerActivationDelegate {

    // Handle activation attempt failure
    func tunnelActivationAttemptFailed(tunnel: TunnelContainer, error: TunnelsManagerActivationAttemptError) {
        ErrorPresenter.showErrorAlert(error: error, from: self)
    }

    // Handle activation attempt success
    func tunnelActivationAttemptSucceeded(tunnel: TunnelContainer) {
        // No additional action needed on success
    }

    // Handle activation failure
    func tunnelActivationFailed(tunnel: TunnelContainer, error: TunnelsManagerActivationError) {
        ErrorPresenter.showErrorAlert(error: error, from: self)
    }

    // Handle activation success
    func tunnelActivationSucceeded(tunnel: TunnelContainer) {
        // No additional action needed on success
    }
}

// MARK: - Tunnel Management and Actions

extension MainViewController {

    // Refresh the connection statuses of all tunnels
    func refreshTunnelConnectionStatuses() {
        if let tunnelsManager = tunnelsManager {
            tunnelsManager.refreshStatuses()
        }
    }

    // Show the detail view for a specific tunnel and optionally toggle its activation status
    func showTunnelDetailForTunnel(named tunnelName: String, animated: Bool, shouldToggleStatus: Bool) {
        let showTunnelDetailBlock: (TunnelsManager) -> Void = { [weak self] tunnelsManager in
            guard let self = self else { return }
            guard let tunnelsListVC = self.tunnelsListVC else { return }
            if let tunnel = tunnelsManager.tunnel(named: tunnelName) {
//                tunnelsListVC.showTunnelDetail(for: tunnel, animated: animated)
                if shouldToggleStatus {
                    if tunnel.status == .inactive {
                        tunnelsManager.startActivation(of: tunnel)
                    } else if tunnel.status == .active {
                        tunnelsManager.startDeactivation(of: tunnel)
                    }
                }
            }
        }
        if let tunnelsManager = tunnelsManager {
            showTunnelDetailBlock(tunnelsManager)
        } else {
            onTunnelsManagerReady = showTunnelDetailBlock
        }
    }

    // Import tunnel configuration from a disposable file
    func importFromDisposableFile(url: URL) {
        let importFromFileBlock: (TunnelsManager) -> Void = { [weak self] tunnelsManager in
            TunnelImporter.importFromFile(urls: [url], into: tunnelsManager, sourceVC: self, errorPresenterType: ErrorPresenter.self) {
                // Delete the file after importing
                _ = FileManager.deleteFile(at: url)
            }
        }
        if let tunnelsManager = tunnelsManager {
            importFromFileBlock(tunnelsManager)
        } else {
            onTunnelsManagerReady = importFromFileBlock
        }
    }
}

// MARK: - UISplitViewControllerDelegate

extension MainViewController: UISplitViewControllerDelegate {

    // Handle the collapse of the secondary (detail) view controller onto the primary (master) view controller
    func splitViewController(_ splitViewController: UISplitViewController,
                             collapseSecondary secondaryViewController: UIViewController,
                             onto primaryViewController: UIViewController) -> Bool {
        // On iPhone, if the secondary view controller is just a UIViewController (empty), show only the primary view controller
        let detailVC = (secondaryViewController as? UINavigationController)?.viewControllers.first
        let isDetailVCEmpty: Bool
        if let detailVC = detailVC {
            isDetailVCEmpty = (type(of: detailVC) == UIViewController.self)
        } else {
            isDetailVCEmpty = true
        }
        return isDetailVCEmpty
    }
}
