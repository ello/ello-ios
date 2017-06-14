////
///  DynamicSettingCategoryViewController.swift
//

class DynamicSettingCategoryViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, ControllerThatMightHaveTheCurrentUser {
    var category: DynamicSettingCategory?
    var currentUser: User?
    weak var delegate: DynamicSettingsDelegate?
    @IBOutlet weak var tableView: UITableView!
    weak var navBar: ElloNavigationBar!

    override func viewDidLoad() {
        super.viewDidLoad()

        title = category?.label
        setupTableView()
        setupNavigationBar()
    }

    fileprivate func setupTableView() {
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 50
        tableView.register(UINib(nibName: "DynamicSettingCell", bundle: .none), forCellReuseIdentifier: "DynamicSettingCell")
    }

    fileprivate func setupNavigationBar() {
        let backItem = UIBarButtonItem.backChevronWithTarget(self, action: #selector(DynamicSettingCategoryViewController.backAction))
        navigationItem.leftBarButtonItem = backItem
        navigationItem.title = category?.label
        navigationItem.fixNavBarItemPadding()
        navBar.items = [navigationItem]
        postNotification(StatusBarNotifications.statusBarShouldHide, value: false)
    }

    func backAction() {
        _ = navigationController?.popViewController(animated: true)
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
            let category = self.category else { return }
        let settings = category.settings

        let visibility = settings.enumerated().map { (index, setting) in
            return (
                setting: setting,
                indexPath: IndexPath(row: index, section: 0),
                value: currentUser.propertyForSettingsKey(key: setting.key),
                isVisible: DynamicSettingCellPresenter.isVisible(setting: setting, currentUser: currentUser)
            )
        }

        var updatedValues: [String: Any] = [
            setting.key: value,
        ]

        for anotherSetting in category.settings {
            if let anotherValue = setting.sets(anotherSetting, when: value) {
                updatedValues[anotherSetting.key] = anotherValue
            }
        }

        ProfileService().updateUserProfile(updatedValues)
            .thenFinally { [weak self] user in
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

    fileprivate func settingChanged(_ config: SettingConfig, user: User) -> Bool {
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
