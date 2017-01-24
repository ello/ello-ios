////
///  SettingsViewController.swift
//

import Foundation

enum SettingsRow: Int {
    case coverImage
    case avatarImage
    case profileDescription
    case credentialSettings
    case name
    case bio
    case links
    case location
    case preferenceSettings
    case unknown
}


class SettingsContainerViewController: BaseElloViewController {
    weak var navigationBar: ElloNavigationBar!
    @IBOutlet weak var navigationBarTopConstraint: NSLayoutConstraint!
    fileprivate var settingsViewController: SettingsViewController?

    func tabBarVisible() -> Bool {
        return !(elloTabBarController?.tabBarHidden ?? true)
    }

    func updateNavBars() {
        if tabBarVisible() {
            showNavBars()
        }
        else {
            hideNavBars()
        }
    }

    func showNavBars() {
        navigationBarTopConstraint.constant = 0
        animate {
            postNotification(StatusBarNotifications.statusBarShouldHide, value: false)
            self.view.layoutIfNeeded()
        }

        if let tableView = settingsViewController?.tableView {
            tableView.contentInset.bottom = ElloTabBar.Size.height
            tableView.scrollIndicatorInsets.bottom = ElloTabBar.Size.height
        }
    }

    func hideNavBars() {
        navigationBarTopConstraint.constant = -ElloNavigationBar.Size.height - 1
        animate {
            postNotification(StatusBarNotifications.statusBarShouldHide, value: true)
            self.view.layoutIfNeeded()
        }

        if let tableView = settingsViewController?.tableView {
            tableView.contentInset.bottom = 0
            tableView.scrollIndicatorInsets.bottom = 0
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SettingsContainerSegue" {
            let settings = segue.destination as! SettingsViewController
            settings.currentUser = currentUser
            settingsViewController = settings
            updateNavBars()
            navigationBar.items = [settings.navigationItem]
            settings.scrollLogic.isShowing = tabBarVisible()
        }
    }

    override func didSetCurrentUser() {
        super.didSetCurrentUser()
        settingsViewController?.currentUser = currentUser
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        let hidden = elloTabBarController?.tabBarHidden ?? UIApplication.shared.isStatusBarHidden
        postNotification(StatusBarNotifications.statusBarShouldHide, value: hidden)
        updateNavBars()
    }
}


class SettingsViewController: UITableViewController, ControllerThatMightHaveTheCurrentUser {

    @IBOutlet weak var avatarImageView: UIView!
    weak var profileDescription: StyledLabel!
    @IBOutlet weak var coverImage: UIImageView!
    @IBOutlet weak var avatarImage: UIImageView!
    var scrollLogic: ElloScrollLogic!
    var appViewController: AppViewController? {
        return (parent as? SettingsContainerViewController)?.appViewController
    }
    var autoCompleteVC = AutoCompleteViewController()
    var locationTextViewSelected = false {
        didSet {
            updateAutoCompleteFrame(animated: true)
        }
    }
    var locationAutoCompleteResultCount = 0 {
        didSet {
            updateAutoCompleteFrame()
        }
    }

    weak var nameTextFieldView: ElloTextFieldView!
    @IBOutlet weak var bioTextView: ElloEditableTextView!
    weak var bioTextCountLabel: StyledLabel!
    @IBOutlet weak var bioTextStatusImage: UIImageView!
    fileprivate var bioTextViewDidChange: (() -> Void)?

    @IBOutlet weak var linksTextFieldView: ElloTextFieldView!
    @IBOutlet weak var locationTextFieldView: ElloTextFieldView!

    var keyboardWillShowObserver: NotificationObserver?
    var keyboardWillHideObserver: NotificationObserver?

    var currentUser: User? {
        didSet {
            credentialSettingsViewController?.currentUser = currentUser
            dynamicSettingsViewController?.currentUser = currentUser
            if isViewLoaded {
                setupUserValues()
            }
        }
    }

    var credentialSettingsViewController: CredentialSettingsViewController?
    var dynamicSettingsViewController: DynamicSettingsViewController?
    var photoSaveCallback: ((UIImage) -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        setupNavigationBar()
        scrollLogic = ElloScrollLogic(
            onShow: { [weak self] in self?.showNavBars() },
            onHide: { [weak self] in self?.hideNavBars() }
        )

        locationTextViewSelected = false
        autoCompleteVC.delegate = self
        autoCompleteVC.view.alpha = 0

        tableView.estimatedRowHeight = 100
    }

    var elloTabBarController: ElloTabBarController? {
        return findViewController { vc in vc is ElloTabBarController } as! ElloTabBarController?
    }
    var containerController: SettingsContainerViewController? {
        return findViewController { vc in vc is SettingsContainerViewController } as! SettingsContainerViewController?
    }

    func showNavBars() {
        if let tabBarController = self.elloTabBarController {
            tabBarController.setTabBarHidden(false, animated: true)
        }

        containerController?.showNavBars()
    }

    func hideNavBars() {
        if let tabBarController = self.elloTabBarController {
            tabBarController.setTabBarHidden(true, animated: true)
        }

        containerController?.hideNavBars()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        _ = ElloHUD.showLoadingHud()

        let hideHud = after(2) {
            ElloHUD.hideLoadingHud()
        }
        if let dynamicSettingsViewController = dynamicSettingsViewController {
            dynamicSettingsViewController.hideLoadingHud = hideHud
        }
        else {
            hideHud()
        }

        ProfileService().loadCurrentUser(success: { user in
            self.updateCurrentUser(user)
            hideHud()
        }, failure: { error in
            hideHud()
        })

        setupViews()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let superview = view.superview {
            superview.addSubview(autoCompleteVC.view)
            updateAutoCompleteFrame()
        }

        keyboardWillShowObserver = NotificationObserver(notification: Keyboard.Notifications.KeyboardWillShow, block: self.keyboardWillShow)
        keyboardWillHideObserver = NotificationObserver(notification: Keyboard.Notifications.KeyboardWillHide, block: self.keyboardWillHide)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        autoCompleteVC.view.removeFromSuperview()

        keyboardWillShowObserver?.removeObserver()
        keyboardWillShowObserver = nil
        keyboardWillHideObserver?.removeObserver()
        keyboardWillHideObserver = nil
    }

    fileprivate func updateCurrentUser(_ user: User) {
        appViewController?.currentUser = user
        postNotification(SettingChangedNotification, value: user)
    }

    fileprivate func setupUserValues() {
        if let cachedImage = TemporaryCache.load(.coverImage) {
            coverImage.image = cachedImage
        }
        else if let imageURL = currentUser?.coverImageURL(viewsAdultContent: true, animated: true) {
            coverImage.pin_setImage(from: imageURL as URL!)
        }

        if let cachedImage = TemporaryCache.load(.avatar) {
            avatarImage.image = cachedImage
        }
        else if let imageURL = currentUser?.avatar?.large?.url {
            avatarImage.pin_setImage(from: imageURL as URL!)
        }

        bioTextView.attributedText = ElloAttributedString.style(currentUser?.profile?.shortBio ?? "")
        nameTextFieldView.textField.text = currentUser?.name

        if let links = currentUser?.externalLinksList {
            let urls = links.map { $0.url.absoluteString }
            linksTextFieldView.textField.text = urls.joined(separator: ", ")
        }

        if let location = currentUser?.location {
            locationTextFieldView.textField.text = location
        }
    }

    fileprivate func setupViews() {
        tableView.addSubview(autoCompleteVC.view)
        avatarImageView.layer.cornerRadius = avatarImageView.frame.width / 2
        containerController?.showNavBars()
        setupDefaultValues()
        setupUserValues()
    }

    fileprivate func setupNavigationBar() {
        let backItem = UIBarButtonItem.backChevronWithTarget(self, action: #selector(SettingsViewController.backAction))
        navigationItem.leftBarButtonItem = backItem
        navigationItem.title = InterfaceString.Settings.EditProfile
        navigationItem.fixNavBarItemPadding()

        navigationItem.rightBarButtonItem = UIBarButtonItem(image: .search, target: self, action: #selector(SettingsViewController.searchButtonTapped))
    }

    @IBAction func searchButtonTapped() {
        containerController?.searchButtonTapped()
    }

    fileprivate func setupDefaultValues() {
        setupNameTextField()
        setupBioTextField()
        setupLinksTextField()
        setupLocationTextField()

        profileDescription.text = InterfaceString.Settings.ProfileDescription
    }

    fileprivate func setupNameTextField() {
        nameTextFieldView.label.text = InterfaceString.Settings.Name
        nameTextFieldView.textField.text = currentUser?.name

        let updateNameFunction = debounce(0.5) { [weak self] in
            guard let `self` = self else { return }
            let name = self.nameTextFieldView.textField.text ?? ""
            ProfileService().updateUserProfile(["name": name as AnyObject], success: { user in
                self.updateCurrentUser(user)
                self.nameTextFieldView.setState(.ok)
            }, failure: { _, _ in
                self.nameTextFieldView.setState(.error)
            })
        }

        nameTextFieldView.textFieldDidChange = { _ in
            self.nameTextFieldView.setState(.loading)
            updateNameFunction()
        }
    }

    fileprivate func setupBioTextField() {
        bioTextView.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 30)
        bioTextView.delegate = self

        bioTextViewDidChange = debounce(0.5) { [weak self] in
            guard let `self` = self, let bio = self.bioTextView.text else { return }
            ProfileService().updateUserProfile(["unsanitized_short_bio": bio as AnyObject], success: { user in
                self.updateCurrentUser(user)
                self.bioTextStatusImage.image = ValidationState.ok.imageRepresentation
            }, failure: { _, _ in
                self.bioTextStatusImage.image = ValidationState.error.imageRepresentation
            })
        }
    }

    fileprivate func setupLinksTextField() {
        linksTextFieldView.label.text = InterfaceString.Settings.Links
        linksTextFieldView.textField.spellCheckingType = .no
        linksTextFieldView.textField.autocapitalizationType = .none
        linksTextFieldView.textField.autocorrectionType = .no
        linksTextFieldView.textField.keyboardAppearance = .dark
        linksTextFieldView.textField.keyboardType = .asciiCapable

        let updateLinksFunction = debounce(0.5) { [weak self] in
            guard let `self` = self, let links = self.linksTextFieldView.textField.text else { return }
            ProfileService().updateUserProfile(["external_links": links as AnyObject], success: { user in
                self.updateCurrentUser(user)
                self.linksTextFieldView.setState(.ok)
            }, failure: { _, _ in
                self.linksTextFieldView.setState(.error)
            })
        }

        linksTextFieldView.textFieldDidChange = { _ in
            self.linksTextFieldView.setState(.loading)
            updateLinksFunction()
        }
    }

    fileprivate func setupLocationTextField() {
        locationTextFieldView.label.text = InterfaceString.Settings.Location
        locationTextFieldView.textField.keyboardAppearance = .dark
        locationTextFieldView.textField.autocorrectionType = .no
        locationTextFieldView.textField.leftView = UIImageView(image: InterfaceImage.marker.normalImage)
        locationTextFieldView.textField.leftViewMode = .always

        let updateLocationFunction = debounce(0.5) { [weak self] in
            guard let `self` = self, let location = self.locationTextFieldView.textField.text else { return }
            if location != self.currentUser?.location {
                ProfileService().updateUserProfile(["location": location as AnyObject], success: { user in
                    self.updateCurrentUser(user)
                    guard let count = self.locationTextFieldView.textField.text?.characters.count, count > 0 else {
                        self.locationTextFieldView.setState(.none)
                        return
                    }
                    self.locationTextFieldView.setState(.ok)
                }, failure: { _, _ in
                    self.locationTextFieldView.setState(.error)
                })
            }

            self.autoCompleteVC.load(AutoCompleteMatch(type: .location, range: location.characters.startIndex..<location.characters.endIndex, text: location)) { count in
                guard location == self.locationTextFieldView.textField.text else { return }

                self.locationAutoCompleteResultCount = count
            }
        }

        locationTextFieldView.textFieldDidChange = { [weak self] text in
            guard let `self` = self else { return }
            self.locationTextFieldView.setState(.loading)
            updateLocationFunction()
        }

        locationTextFieldView.firstResponderDidChange = { [weak self] isFirstResponder in
            guard let `self` = self else { return }
            self.locationTextViewSelected = isFirstResponder
            updateLocationFunction()
        }
    }

    func backAction() {
        _ = navigationController?.popViewController(animated: true)
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch SettingsRow(rawValue: indexPath.row) ?? .unknown {
        case .coverImage: return 200
        case .avatarImage: return 250
        case .profileDescription: return 130
        case .credentialSettings: return credentialSettingsViewController?.height ?? 0
        case .name: return nameTextFieldView.height
        case .bio: return 200
        case .links: return linksTextFieldView.height
        case .location: return locationTextFieldView.height
        case .preferenceSettings: return dynamicSettingsViewController?.height ?? 0
        case .unknown: return 0
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier ?? "" {
        case "CredentialSettingsSegue":
            credentialSettingsViewController = segue.destination as? CredentialSettingsViewController
            credentialSettingsViewController?.currentUser = currentUser
            credentialSettingsViewController?.delegate = self

        case "DynamicSettingsSegue":
            dynamicSettingsViewController = segue.destination as? DynamicSettingsViewController
            dynamicSettingsViewController?.currentUser = currentUser
            dynamicSettingsViewController?.delegate = self

        default: break
        }
    }

    @IBAction func logOutTapped() {
        Tracker.shared.tappedLogout()
        postNotification(AuthenticationNotifications.userLoggedOut, value: ())
    }

    @IBAction func coverImageTapped() {
        photoSaveCallback = { image in
            _ = ElloHUD.showLoadingHud()
            ProfileService().updateUserCoverImage(ImageRegionData(image: image), success: { url, _ in
                ElloHUD.hideLoadingHud()
                if let user = self.currentUser {
                    let asset = Asset(url: url, image: image)
                    user.coverImage = asset

                    postNotification(CurrentUserChangedNotification, value: user)
                }
                self.coverImage.image = image
                self.alertUserOfImageProcessing(InterfaceString.Settings.CoverImageUploaded)
            }, failure: { _, _ in
                ElloHUD.hideLoadingHud()
            })
        }
        openImagePicker()
    }

    @IBAction func avatarImageTapped() {
        photoSaveCallback = { image in
            _ = ElloHUD.showLoadingHud()
            ProfileService().updateUserAvatarImage(ImageRegionData(image: image), success: { url, _ in
                ElloHUD.hideLoadingHud()
                if let user = self.currentUser {
                    let asset = Asset(url: url, image: image)
                    user.avatar = asset

                    postNotification(CurrentUserChangedNotification, value: user)
                }
                self.avatarImage.image = image
                self.alertUserOfImageProcessing(InterfaceString.Settings.AvatarUploaded)
            }, failure: { _, _ in
                ElloHUD.hideLoadingHud()
            })
        }
        openImagePicker()
    }

    fileprivate func openImagePicker() {
        let alertViewController = UIImagePickerController.alertControllerForImagePicker { imagePicker in
            imagePicker.delegate = self
            self.present(imagePicker, animated: true, completion: .none)
        }

        if let alertViewController = alertViewController {
            logPresentingAlert("SettingsViewController")
            present(alertViewController, animated: true, completion: .none)
        }
    }

    fileprivate func alertUserOfImageProcessing(_ message: String) {
        let alertController = AlertViewController(message: message)
        let action = AlertAction(title: InterfaceString.OK, style: .light, handler: .none)
        alertController.addAction(action)
        logPresentingAlert("SettingsViewController")
        present(alertController, animated: true, completion: .none)
    }
}

extension SettingsViewController {
    func keyboardWillShow(_ keyboard: Keyboard) {
        updateAutoCompleteFrame(animated: true)
    }

    func keyboardWillHide(_ keyboard: Keyboard) {
        updateAutoCompleteFrame(animated: true)
    }
}

extension SettingsViewController: CredentialSettingsDelegate, DynamicSettingsDelegate {
    func dynamicSettingsUserChanged(_ user: User) {
        updateCurrentUser(user)
    }
    func credentialSettingsUserChanged(_ user: User) {
        updateCurrentUser(user)
    }

    func credentialSettingsDidUpdate() {
        tableView.beginUpdates()
        tableView.endUpdates()
    }
}

extension SettingsViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            image.copyWithCorrectOrientationAndSize() { image in
                if let image = image {
                    self.photoSaveCallback?(image)
                }
                self.dismiss(animated: true, completion: .none)
            }
        }
        else {
            self.dismiss(animated: true, completion: .none)
        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: .none)
    }
}

extension SettingsViewController {
    class func instantiateFromStoryboard() -> SettingsViewController {
        return UIStoryboard(name: "Settings", bundle: Bundle(for: AppDelegate.self)).instantiateInitialViewController() as! SettingsViewController
    }
}

extension SettingsViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        let characterCount = textView.text.lengthOfBytes(using: String.Encoding.ascii)
        bioTextCountLabel.text = "\(characterCount)"
        bioTextCountLabel.isHidden = characterCount <= 192
        bioTextStatusImage.image = ValidationState.loading.imageRepresentation
        bioTextViewDidChange?()
    }
}


// strangely, we have to "override" these delegate methods, but the parent class
// UITableViewController doesn't implement them.
extension SettingsViewController {

    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollLogic.scrollViewDidScroll(scrollView)
    }

    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        scrollLogic.scrollViewWillBeginDragging(scrollView)
    }

    override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate: Bool) {
        scrollLogic.scrollViewDidEndDragging(scrollView, willDecelerate: willDecelerate)
    }

}

extension SettingsViewController: AutoCompleteDelegate {
    func updateAutoCompleteFrame(animated: Bool = false) {
        guard isViewLoaded else { return }

        let rowHeight: CGFloat = AutoCompleteCell.Size.height
        let maxHeight: CGFloat = 3.5 * rowHeight
        let height: CGFloat = min(maxHeight, CGFloat(locationAutoCompleteResultCount) * rowHeight)
        let inset = Keyboard.shared.keyboardBottomInset(inView: view) + height
        let y = view.frame.height - inset
        if Keyboard.shared.active {
            tableView.contentInset.bottom = inset
        }
        else {
            containerController?.updateNavBars()
        }
        animateWithKeyboard(animated: animated) {
            self.autoCompleteVC.view.alpha = (self.locationTextViewSelected && self.locationAutoCompleteResultCount > 0) ? 1 : 0
            self.autoCompleteVC.view.frame = CGRect(x: 0, y: y, width: self.view.frame.width, height: height)
        }
    }

    func autoComplete(_ controller: AutoCompleteViewController, itemSelected item: AutoCompleteItem) {
        guard let name = item.result.name else { return }

        locationTextFieldView.textField.text = name
        _ = locationTextFieldView.resignFirstResponder()
    }
}
