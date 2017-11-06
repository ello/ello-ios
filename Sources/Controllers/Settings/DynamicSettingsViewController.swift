////
///  DynamicSettingsViewController.swift
//

private let DynamicSettingsCellHeight: CGFloat = 50

protocol DynamicSettingsDelegate: class {
    func dynamicSettingsUserChanged(_ user: User)
}

private enum DynamicSettingsSection: Int {
    case creatorType
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
    var hideLoadingHud: Block = ElloHUD.hideLoadingHud

    var height: CGFloat {
        var totalRows = 0
        for section in 0..<tableView.numberOfSections {
            totalRows += tableView.numberOfRows(inSection: section)
        }
        return DynamicSettingsCellHeight * CGFloat(totalRows)
    }

    private var blockedCountChangedNotification: NotificationObserver?
    private var mutedCountChangedNotification: NotificationObserver?

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
            .then { [weak self] response -> Void in
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
            .catch { [weak self] _ in
                self?.hideLoadingHud()
            }
    }

    private func reloadTables() {
        self.tableView.reloadData()
        (self.parent as? SettingsViewController)?.tableView.reloadData()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return DynamicSettingsSection.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch DynamicSettingsSection(rawValue: section) ?? .unknown {
        case .creatorType: return dynamicCategories.count > 0 ? 1 : 0
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
        case .creatorType:
            cell.textLabel?.text = DynamicSettingCategory.creatorTypeCategory.label

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
        guard let currentUser = currentUser else { return }

        switch DynamicSettingsSection(rawValue: indexPath.section) ?? .unknown {
        case .dynamicSettings, .accountDeletion:
            performSegue(withIdentifier: "DynamicSettingCategorySegue", sender: nil)
        case .creatorType:
            guard let categoryIds = currentUser.profile?.creatorTypeCategoryIds else { return }

            tableView.isUserInteractionEnabled = false
            CategoryService().loadCreatorCategories()
                .then { categories -> Void in
                    let creatorCategories = categoryIds.flatMap { id -> Category? in
                        return categories.find { $0.id == id }
                    }

                    let controller = OnboardingCreatorTypeViewController()
                    controller.delegate = self.delegate
                    controller.currentUser = currentUser
                    let creatorType: Profile.CreatorType
                    if creatorCategories.count > 0 {
                        creatorType = .artist(creatorCategories)
                    }
                    else {
                        creatorType = .fan
                    }
                    controller.creatorType = creatorType
                    self.navigationController?.pushViewController(controller, animated: true)
                }
                .always {
                    tableView.isUserInteractionEnabled = true
                }
        case .blocked:
            let controller = SimpleStreamViewController(endpoint: .currentUserBlockedList, title: InterfaceString.Settings.BlockedTitle)
            controller.streamViewController.noResultsMessages =
                NoResultsMessages(
                    title: InterfaceString.Relationship.BlockedNoResultsTitle,
                    body: InterfaceString.Relationship.BlockedNoResultsBody
                )
            controller.currentUser = currentUser
            navigationController?.pushViewController(controller, animated: true)
        case .muted:
            let controller = SimpleStreamViewController(endpoint: .currentUserMutedList, title: InterfaceString.Settings.MutedTitle)
            controller.streamViewController.noResultsMessages =
                NoResultsMessages(
                    title: InterfaceString.Relationship.MutedNoResultsTitle,
                    body: InterfaceString.Relationship.MutedNoResultsBody
                )
            controller.currentUser = currentUser
            navigationController?.pushViewController(controller, animated: true)
        case .unknown: break
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "DynamicSettingCategorySegue" else { return }

        let controller = segue.destination as! DynamicSettingCategoryViewController
        controller.delegate = delegate
        let selectedIndexPath = tableView.indexPathForSelectedRow

        switch DynamicSettingsSection(rawValue: selectedIndexPath?.section ?? 0) ?? .unknown {
        case .dynamicSettings:
            let index = tableView.indexPathForSelectedRow?.row ?? 0
            controller.category = dynamicCategories[index]

        case .accountDeletion:
            controller.category = DynamicSettingCategory.accountDeletionCategory

        case .creatorType, .blocked, .muted, .unknown:
            break
        }
        controller.currentUser = currentUser
}
}
