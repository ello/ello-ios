////
///  DynamicSettingCategoryViewController.swift
//

class DynamicSettingCategoryViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, ControllerThatMightHaveTheCurrentUser {
    var category: DynamicSettingCategory?
    var currentUser: User?
    weak var delegate: DynamicSettingsDelegate?
    @IBOutlet var navigationBar: ElloNavigationBar?
    @IBOutlet var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        title = category?.label
        setupTableView()
        setupNavigationBar()
    }

    private func setupTableView() {
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 50
        tableView.register(UINib(nibName: "DynamicSettingCell", bundle: .none), forCellReuseIdentifier: "DynamicSettingCell")
    }

    private func setupNavigationBar() {
        navigationBar?.title = category?.label
        navigationBar?.leftItems = [.back]
        postNotification(StatusBarNotifications.statusBarVisibility, value: true)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return category?.settings.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DynamicSettingCell", for: indexPath) as! DynamicSettingCell

        if let setting = category?.settings.safeValue(indexPath.row),
            let user = currentUser
        {
            DynamicSettingCellPresenter.configure(cell, setting: setting, currentUser: user)
            cell.setting = setting
        }
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let setting = category?.settings.safeValue(indexPath.row),
            let user = currentUser
        {
            let isVisible = DynamicSettingCellPresenter.isVisible(setting: setting, currentUser: user)
            if !isVisible {
                return 0
            }
        }

        return UITableViewAutomaticDimension
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
}

extension DynamicSettingCategoryViewController: DynamicSettingCellResponder {

    typealias SettingConfig = (setting: DynamicSetting, indexPath: IndexPath, value: Bool, isVisible: Bool)

    func toggleSetting(_ setting: DynamicSetting, value: Bool) {
        guard
            let currentUser = currentUser,
            let category = self.category,
            let settingKey = Profile.Property(rawValue: setting.key)
        else { return }

        let settings = category.settings
        let visibility = settings.enumerated().map { (index, setting) in
            return (
                setting: setting,
                indexPath: IndexPath(row: index, section: 0),
                value: currentUser.propertyForSettingsKey(key: setting.key),
                isVisible: DynamicSettingCellPresenter.isVisible(setting: setting, currentUser: currentUser)
            )
        }

        var updatedValues: [Profile.Property: Any] = [
            settingKey: value,
        ]
        for anotherSetting in category.settings {
            guard
                let anotherValue = setting.sets(anotherSetting, when: value),
                let anotherKey = Profile.Property(rawValue: anotherSetting.key)
            else { continue }

            updatedValues[anotherKey] = anotherValue
        }

        ProfileService().updateUserProfile(updatedValues)
            .then { [weak self] user -> Void in
                guard let `self` = self else { return }

                self.delegate?.dynamicSettingsUserChanged(user)
                let changedPaths = visibility.filter { config in
                    return self.settingChanged(config, user: user)
                }.map { config in
                    return config.indexPath
                }

                self.tableView.reloadRows(at: changedPaths, with: .automatic)
            }
            .catch { [weak self] _ in
                guard let `self` = self else { return }
                self.tableView.reloadData()
            }
    }

    private func settingChanged(_ config: SettingConfig, user: User) -> Bool {
        let setting = config.setting
        let currVisibility = DynamicSettingCellPresenter.isVisible(setting: setting, currentUser: user)
        let currValue = user.propertyForSettingsKey(key: setting.key)
        return config.isVisible != currVisibility || config.value != currValue
    }

    func deleteAccount() {
        let vc = DeleteAccountConfirmationViewController()
        present(vc, animated: true, completion: .none)
    }
}

extension DynamicSettingCategoryViewController: HasBackButton {
    func backButtonTapped() {
        _ = navigationController?.popViewController(animated: true)
    }
}
