////
///  SettingsProtocols.swift
//

protocol SettingsGeneratorDelegate: class {
    func currentUserReloaded(_ currentUser: User)
    func dynamicSettingsLoaded(_ settings: [DynamicSettingCategory])
    func categoriesLoaded(_ categories: [Category])
}

protocol SettingsScreenDelegate: class {
    func present(controller: UIViewController)
    func dismissController()
    func saveImage(_ imageRegion: ImageRegionData, property: Profile.ImageProperty)
    func logoutTapped()
    func showCredentialsScreen()
    func showDynamicSettings(_ settings: DynamicSettingCategory)
    func locationChanged(isFirstResponder: Bool, text: String)

    func scrollViewDidScroll(_ scrollView: UIScrollView)
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView)
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate: Bool)
}

protocol SettingsScreenProtocol: class {
    var delegate: SettingsScreenDelegate? { get set }
    var categoriesEnabled: Bool { get set }
    var username: String? { get set }
    var email: String? { get set }
    var name: String? { get set }
    var bio: String? { get set }
    var links: String? { get set }
    var location: String? { get set }

    func showNavBars(animated: Bool)
    func hideNavBars(animated: Bool)
    func scrollToLocation()
    func keyboardUpdated(_ keyboard: Keyboard)
    func resignLocationField()
    func showError(_ error: String?)
    func setImage(_ property: Profile.ImageProperty, url: URL?)
    func setImage(_ property: Profile.ImageProperty, image: UIImage?)
    func updateDynamicSettings(
        _ settings: [DynamicSettingCategory],
        blockCount: Int,
        mutedCount: Int
    )
    func updateAllSettings(blockCount: Int, mutedCount: Int)
}

protocol SettingsCredentialsScreenDelegate: class {
}

protocol SettingsCredentialsScreenProtocol: class {
    var delegate: SettingsCredentialsScreenDelegate? { get set }
    var username: String? { get set }
    var email: String? { get set }
    var password: String? { get set }
    var oldPassword: String? { get set }
    func keyboardUpdated(_ keyboard: Keyboard)
    func showError(_ error: String?)
}

protocol DynamicSettingsScreenDelegate: class {
    var currentUser: User? { get }
}

protocol DynamicSettingsScreenProtocol: class {
    var delegate: DynamicSettingsScreenDelegate? { get set }
    func reload()
}

protocol DynamicSettingCellResponder: class {
    func toggleSetting(_ setting: DynamicSetting, value: Bool)
    func deleteAccount()
}

protocol DynamicSettingsDelegate: class {
    func dynamicSettingsUserChanged(_ user: User)
}
