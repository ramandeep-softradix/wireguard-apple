import UIKit

class TunnelListCell: UITableViewCell {
    // The tunnel object that this cell represents. When set, it binds to the tunnel's properties.
    var tunnel: TunnelContainer? {
        didSet {
            // Bind to the tunnel's name
            nameLabel.text = tunnel?.name ?? ""
            nameObservationToken = tunnel?.observe(\.name) { [weak self] tunnel, _ in
                self?.nameLabel.text = tunnel.name
            }
            // Bind to the tunnel's status and update the cell accordingly
            update(from: tunnel, animated: false)
            statusObservationToken = tunnel?.observe(\.status) { [weak self] tunnel, _ in
                self?.update(from: tunnel, animated: true)
            }
            // Bind to tunnel's on-demand settings
            isOnDemandEnabledObservationToken = tunnel?.observe(\.isActivateOnDemandEnabled) { [weak self] tunnel, _ in
                self?.update(from: tunnel, animated: true)
            }
            hasOnDemandRulesObservationToken = tunnel?.observe(\.hasOnDemandRules) { [weak self] tunnel, _ in
                self?.update(from: tunnel, animated: true)
            }
        }
    }

    // Closure that is called when the switch is toggled
    var onSwitchToggled: ((Bool) -> Void)?

    // UI components
    let nameLabel: UILabel = {
        let nameLabel = UILabel()
        nameLabel.font = UIFont.preferredFont(forTextStyle: .body)
        nameLabel.adjustsFontForContentSizeCategory = true
        nameLabel.numberOfLines = 0
        return nameLabel
    }()

    let onDemandLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.font = UIFont.preferredFont(forTextStyle: .caption2)
        label.adjustsFontForContentSizeCategory = true
        label.numberOfLines = 1
        label.textColor = .secondaryLabel
        return label
    }()

    let busyIndicator: UIActivityIndicatorView = {
        let busyIndicator = UIActivityIndicatorView(style: .medium)
        busyIndicator.hidesWhenStopped = true
        return busyIndicator
    }()

    let statusSwitch = UISwitch()

    // Observers for KVO (Key-Value Observing) to monitor changes in tunnel properties
    private var nameObservationToken: NSKeyValueObservation?
    private var statusObservationToken: NSKeyValueObservation?
    private var isOnDemandEnabledObservationToken: NSKeyValueObservation?
    private var hasOnDemandRulesObservationToken: NSKeyValueObservation?

    // Layout constraints for dynamic UI adjustments
    private var subTitleLabelBottomConstraint: NSLayoutConstraint?
    private var nameLabelBottomConstraint: NSLayoutConstraint?

    // Initializer method
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        // Remove the default accessory (e.g., disclosure arrow)
        accessoryType = .none

        // Add subviews to the content view
        for subview in [statusSwitch, busyIndicator, onDemandLabel, nameLabel] {
            subview.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(subview)
        }

        // Set content compression resistance priority for proper layout handling
        nameLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        onDemandLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)

        // Layout constraints for positioning UI elements within the cell
        let nameLabelBottomConstraint =
            contentView.layoutMarginsGuide.bottomAnchor.constraint(equalToSystemSpacingBelow: nameLabel.bottomAnchor, multiplier: 1)
        nameLabelBottomConstraint.priority = .defaultLow

        NSLayoutConstraint.activate([
            statusSwitch.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            statusSwitch.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            statusSwitch.leadingAnchor.constraint(equalToSystemSpacingAfter: busyIndicator.trailingAnchor, multiplier: 1),
            statusSwitch.leadingAnchor.constraint(equalToSystemSpacingAfter: onDemandLabel.trailingAnchor, multiplier: 1),

            nameLabel.topAnchor.constraint(equalToSystemSpacingBelow: contentView.layoutMarginsGuide.topAnchor, multiplier: 1),
            nameLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: contentView.layoutMarginsGuide.leadingAnchor, multiplier: 1),
            nameLabel.trailingAnchor.constraint(lessThanOrEqualTo: statusSwitch.leadingAnchor),
            nameLabelBottomConstraint,

            onDemandLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            onDemandLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: nameLabel.trailingAnchor, multiplier: 1),

            busyIndicator.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            busyIndicator.leadingAnchor.constraint(greaterThanOrEqualToSystemSpacingAfter: nameLabel.trailingAnchor, multiplier: 1)
        ])

        // Set up the action for the switch toggle event
        statusSwitch.addTarget(self, action: #selector(switchToggled), for: .valueChanged)
    }

    // Required initializer for cases where the cell is loaded from a storyboard or nib
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // Method called when the cell is about to be reused, resets the state
    override func prepareForReuse() {
        super.prepareForReuse()
        reset(animated: false)
    }

    // Handle the cell entering/exiting edit mode, disabling the switch when editing
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        statusSwitch.isEnabled = !editing
    }

    // Action handler for when the switch is toggled by the user
    @objc private func switchToggled() {
        onSwitchToggled?(statusSwitch.isOn)
    }

    // Updates the UI elements based on the tunnel's current state
    private func update(from tunnel: TunnelContainer?, animated: Bool) {
        guard let tunnel = tunnel else {
            reset(animated: animated)
            return
        }
        let status = tunnel.status
        let isOnDemandEngaged = tunnel.isActivateOnDemandEnabled

        // Determine if the switch should be on based on the tunnel's status and on-demand settings
        let shouldSwitchBeOn = ((status != .deactivating && status != .inactive) || isOnDemandEngaged)
        statusSwitch.setOn(shouldSwitchBeOn, animated: true)

        // Adjust the switch's tint color based on the on-demand engagement status
        if isOnDemandEngaged && !(status == .activating || status == .active) {
            statusSwitch.onTintColor = UIColor.systemYellow
        } else {
            statusSwitch.onTintColor = UIColor.systemGreen
        }

        // Enable or disable the switch based on the tunnel's status
        statusSwitch.isUserInteractionEnabled = (status == .inactive || status == .active)

        // Handle the on-demand rules and UI updates for the busy indicator
        if tunnel.hasOnDemandRules {
            onDemandLabel.text = isOnDemandEngaged ? tr("tunnelListCaptionOnDemand") : ""
            busyIndicator.stopAnimating()
            statusSwitch.isUserInteractionEnabled = true
        } else {
            onDemandLabel.text = ""
            if status == .inactive || status == .active {
                busyIndicator.stopAnimating()
            } else {
                busyIndicator.startAnimating()
            }
            statusSwitch.isUserInteractionEnabled = (status == .inactive || status == .active)
        }
    }

    // Resets the UI elements to their default state
    private func reset(animated: Bool) {
        statusSwitch.thumbTintColor = nil
        statusSwitch.setOn(false, animated: animated)
        statusSwitch.isUserInteractionEnabled = false
        busyIndicator.stopAnimating()
    }
}
