////
///  DynamicSettingsViewController.swift
//

private let DynamicSettingsCellHeight: CGFloat = 50

protocol DynamicSettingsDelegate: class {
    func dynamicSettingsUserChanged(_ user: User)
}

private enum DynamicSettingsSection: Int {
    case dynamicSettings
    case blocked
    case muted
    case accountDeletion
    case unknown

    static var count: Int {
        return DynamicSettingsSection.unknown.rawValue
    }
}

class DynamicSettingsViewController: UITableViewController {
    var hasBlocked: Bool {
        if let blockedCount = currentUser?.profile?.blockedCount {
            return blockedCount > 0
        }
        return false
    }
    var hasMuted: Bool {
        if let mutedCount = currentUser?.profile?.mutedCount {
            return mutedCount > 0
        }
        return false
    }

    var dynamicCategories: [DynamicSettingCategory] = []
    var currentUser: User?
    weak var delegate: DynamicSettingsDelegate?
    var hideLoadingHud: BasicBlock = ElloHUD.hideLoadingHud

    var height: CGFloat {
        var totalRows = 0
        for section in 0..<tableView.numberOfSections {
            totalRows += tableView.numberOfRows(inSection: section)
        }
        return DynamicSettingsCellHeight * CGFloat(totalRows)
    }

    fileprivate var blockedCountChangedNotification: NotificationObserver?
    fileprivate var mutedCountChangedNotification: NotificationObserver?

    deinit {
        blockedCountChangedNotification?.removeObserver()
        mutedCountChangedNotification?.removeObserver()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        blockedCountChangedNotification = NotificationObserver(notification: BlockedCountChangedNotification) { [unowned self] userId, delta in
            self.currentUser?.profile?.blockedCount += delta
            self.reloadTables()
        }
        mutedCountChangedNotification = NotificationObserver(notification: MutedCountChangedNotification) { [unowned self] userId, delta in
            self.currentUser?.profile?.mutedCount += delta
            self.reloadTables()
        }

        tableView.scrollsToTop = false
        tableView.rowHeight = DynamicSettingsCellHeight

        StreamService().loadStream(endpoint: .profileToggles)
            .onSuccess { [weak self] response in
                guard let `self` = self else { return }

                self.hideLoadingHud()

                switch response {
                case let .jsonables(jsonables, _):
                    guard let categories = jsonables as? [DynamicSettingCategory] else { return }

                    self.dynamicCategories = categories.reduce([]) { categoryArr, category in
                        category.settings = category.settings.reduce([]) { settingsArr, setting in
                            if self.currentUser?.hasProperty(key: setting.key) == true {
                                return settingsArr + [setting]
                            }
                            return settingsArr
                        }
                        if category.settings.count > 0 {
                            return categoryArr + [category]
                        }
                        return categoryArr
                    }

                    self.reloadTables()
                case .empty: break
                }
            }
            .onFail { [weak self] _ in
                self?.hideLoadingHud()
            }
    }

    fileprivate func reloadTables() {
        self.tableView.reloadData()
        (self.parent as? SettingsViewController)?.tableView.reloadData()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return DynamicSettingsSection.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch DynamicSettingsSection(rawValue: section) ?? .unknown {
        case .dynamicSettings: return dynamicCategories.count
        case .blocked: return hasBlocked ? 1 : 0
        case .muted: return hasMuted ? 1 : 0
        case .accountDeletion: return 1
        case .unknown: return 0
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PreferenceCell", for: indexPath)

        switch DynamicSettingsSection(rawValue: indexPath.section) ?? .unknown {
        case .dynamicSettings:
            let category = dynamicCategories[indexPath.row]
            cell.textLabel?.text = category.label

        case .blocked:
            cell.textLabel?.text = DynamicSettingCategory.blockedCategory.label

        case .muted:
            cell.textLabel?.text = DynamicSettingCategory.mutedCategory.label

        case .accountDeletion:
            cell.textLabel?.text = DynamicSettingCategory.accountDeletionCategory.label

        case .unknown: break
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch DynamicSettingsSection(rawValue: indexPath.section) ?? .unknown {
        case .dynamicSettings, .accountDeletion:
            performSegue(withIdentifier: "DynamicSettingCategorySegue", sender: nil)
        case .blocked:
            if let currentUser = currentUser {
                let controller = SimpleStreamViewController(endpoint: .currentUserBlockedList, title: InterfaceString.Settings.BlockedTitle)
                controller.streamViewController.noResultsMessages =
                    NoResultsMessages(
                        title: InterfaceString.Relationship.BlockedNoResultsTitle,
                        body: InterfaceString.Relationship.BlockedNoResultsBody
                    )
                controller.currentUser = currentUser
                navigationController?.pushViewController(controller, animated: true)
            }
        case .muted:
            if let currentUser = currentUser {
                let controller = SimpleStreamViewController(endpoint: .currentUserMutedList, title: InterfaceString.Settings.MutedTitle)
                controller.streamViewController.noResultsMessages =
                    NoResultsMessages(
                        title: InterfaceString.Relationship.MutedNoResultsTitle,
                        body: InterfaceString.Relationship.MutedNoResultsBody
                    )
                controller.currentUser = currentUser
                navigationController?.pushViewController(controller, animated: true)
            }
        case .unknown: break
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "DynamicSettingCategorySegue" {
            let controller = segue.destination as! DynamicSettingCategoryViewController
            controller.delegate = delegate
            let selectedIndexPath = tableView.indexPathForSelectedRow

            switch DynamicSettingsSection(rawValue: selectedIndexPath?.section ?? 0) ?? .unknown {
            case .dynamicSettings:
                let index = tableView.indexPathForSelectedRow?.row ?? 0
                controller.category = dynamicCategories[index]

            case .blocked:
                controller.category = DynamicSettingCategory.blockedCategory

            case .muted:
                controller.category = DynamicSettingCategory.mutedCategory

            case .accountDeletion:
                controller.category = DynamicSettingCategory.accountDeletionCategory

            case .unknown: break
            }
            controller.currentUser = currentUser
        }
    }
}
