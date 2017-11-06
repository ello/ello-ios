////
///  SettingsViewController.swift
//

import Photos
import FLAnimatedImage

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
    @IBOutlet var navigationBar: ElloNavigationBar!
    @IBOutlet var navigationBarTopConstraint: NSLayoutConstraint!
    private var settingsViewController: SettingsViewController?

    override func showNavBars() {
        navigationBarTopConstraint.constant = 0
        animate {
            postNotification(StatusBarNotifications.statusBarVisibility, value: true)
            self.view.layoutIfNeeded()
        }

        if let tableView = settingsViewController?.tableView {
            tableView.contentInset.top = ElloNavigationBar.Size.height
            tableView.scrollIndicatorInsets.top = ElloNavigationBar.Size.height
            tableView.contentInset.bottom = ElloTabBar.Size.height
            tableView.scrollIndicatorInsets.bottom = ElloTabBar.Size.height
        }
    }

    override func hideNavBars() {
        navigationBarTopConstraint.constant = -ElloNavigationBar.Size.height
        animate {
            postNotification(StatusBarNotifications.statusBarVisibility, value: false)
            self.view.layoutIfNeeded()
        }

        if let tableView = settingsViewController?.tableView {
            tableView.contentInset.top = 0
            tableView.scrollIndicatorInsets.top = 0
            tableView.contentInset.bottom = 0
            tableView.scrollIndicatorInsets.bottom = 0
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "SettingsContainerSegue" else { return }

        let settings = segue.destination as! SettingsViewController
        settings.currentUser = currentUser
        settingsViewController = settings
        settings.tableView.contentOffset.y = 0
        updateNavBars()

        navigationBar.title = InterfaceString.Settings.EditProfile
        navigationBar.leftItems = [.back]

        if let navigationBarsVisible = navigationBarsVisible {
            settings.scrollLogic.isShowing = navigationBarsVisible
        }
    }

    override func didSetCurrentUser() {
        super.didSetCurrentUser()
        settingsViewController?.currentUser = currentUser
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        let visible = bottomBarController?.navigationBarsVisible ?? !UIApplication.shared.isStatusBarHidden
        postNotification(StatusBarNotifications.statusBarVisibility, value: visible)
        updateNavBars()
    }
}


class SettingsViewController: UITableViewController, ControllerThatMightHaveTheCurrentUser {

    @IBOutlet weak var avatarImageView: UIView!
    @IBOutlet weak var profileDescription: StyledLabel!
    @IBOutlet weak var coverImage: FLAnimatedImageView!
    @IBOutlet weak var avatarImage: FLAnimatedImageView!
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

    @IBOutlet weak var nameTextFieldView: ElloTextFieldView!
    @IBOutlet weak var bioLabel: UILabel!
    @IBOutlet weak var bioTextView: ElloEditableTextView!
    @IBOutlet weak var bioTextCountLabel: StyledLabel!
    @IBOutlet weak var bioTextStatusImage: UIImageView!
    private var bioTextViewDidChange: (() -> Void)?

    @IBOutlet weak var linksTextFieldView: ElloTextFieldView!
    @IBOutlet weak var locationTextFieldView: ElloTextFieldView!

    var keyboardWillShowObserver: NotificationObserver?
    var keyboardDidHideObserver: NotificationObserver?
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
    var photoSaveCallback: ((ImageRegionData) -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        scrollLogic = ElloScrollLogic(
            onShow: { [weak self] in self?.showNavBars() },
            onHide: { [weak self] in self?.hideNavBars() }
        )

        locationTextViewSelected = false
        autoCompleteVC.delegate = self
        autoCompleteVC.view.alpha = 0

        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        }

        tableView.estimatedRowHeight = 100
    }

    var bottomBarController: BottomBarController? {
        return findViewController { vc in vc is BottomBarController } as! BottomBarController?
    }
    var containerController: SettingsContainerViewController? {
        return findViewController { vc in vc is SettingsContainerViewController } as! SettingsContainerViewController?
    }

    func showNavBars() {
        if let bottomBarController = bottomBarController {
            bottomBarController.setNavigationBarsVisible(true, animated: true)
        }

        containerController?.showNavBars()
    }

    func hideNavBars() {
        if let bottomBarController = bottomBarController {
            bottomBarController.setNavigationBarsVisible(false, animated: true)
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

        ProfileService().loadCurrentUser()
            .then { [weak self] user -> Void in
                guard let `self` = self else { return }
                self.updateCurrentUser(user)
            }
            .always {
                hideHud()
            }

        setupViews()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let superview = view.superview {
            superview.addSubview(autoCompleteVC.view)
            updateAutoCompleteFrame()
        }

        keyboardWillShowObserver = NotificationObserver(notification: Keyboard.Notifications.KeyboardWillShow, block: self.keyboardWillShow)
        keyboardDidHideObserver = NotificationObserver(notification: Keyboard.Notifications.KeyboardDidHide, block: self.keyboardDidHide)
        keyboardWillHideObserver = NotificationObserver(notification: Keyboard.Notifications.KeyboardWillHide, block: self.keyboardWillHide)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        autoCompleteVC.view.removeFromSuperview()

        keyboardWillShowObserver?.removeObserver()
        keyboardWillShowObserver = nil
        keyboardDidHideObserver?.removeObserver()
        keyboardDidHideObserver = nil
        keyboardWillHideObserver?.removeObserver()
        keyboardWillHideObserver = nil
    }

    private func updateCurrentUser(_ user: User) {
        appViewController?.currentUser = user
        postNotification(SettingChangedNotification, value: user)
    }

    private func setupUserValues() {
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

        if currentUser?.profile?.isCommunity == true {
            bioLabel.text = InterfaceString.Settings.CommunityInfo
        }
        else {
            bioLabel.text = InterfaceString.Settings.Bio
        }

        bioTextView.attributedText = NSAttributedString(defaults: currentUser?.profile?.shortBio ?? "")
        nameTextFieldView.textField.text = currentUser?.name

        if let links = currentUser?.externalLinksList {
            let urls = links.map { $0.url.absoluteString }
            linksTextFieldView.textField.text = urls.joined(separator: ", ")
        }

        if let location = currentUser?.location {
            locationTextFieldView.textField.text = location
        }
    }

    private func setupViews() {
        tableView.addSubview(autoCompleteVC.view)
        avatarImageView.layer.cornerRadius = avatarImageView.frame.width / 2
        containerController?.showNavBars()
        setupDefaultValues()
        setupUserValues()
    }

    @IBAction
    func searchButtonTapped() {
        containerController?.searchButtonTapped()
    }

    private func setupDefaultValues() {
        setupNameTextField()
        setupBioTextField()
        setupLinksTextField()
        setupLocationTextField()

        profileDescription.text = InterfaceString.Settings.ProfileDescription
    }

    private func setupNameTextField() {
        nameTextFieldView.label.text = InterfaceString.Settings.Name
        nameTextFieldView.textField.keyboardAppearance = .dark
        nameTextFieldView.textField.text = currentUser?.name

        let updateNameFunction = debounce(0.5) { [weak self] in
            guard let `self` = self else { return }
            let name = self.nameTextFieldView.textField.text ?? ""
            ProfileService().updateUserProfile([.name: name])
                .then { [weak self] user -> Void in
                    guard let `self` = self else { return }

                    self.updateCurrentUser(user)
                    self.nameTextFieldView.setState(.ok)
                }
                .catch { _ in
                    self.nameTextFieldView.setState(.error)
                }
        }

        nameTextFieldView.textFieldDidChange = { _ in
            self.nameTextFieldView.setState(.loading)
            updateNameFunction()
        }
    }

    private func setupBioTextField() {
        bioTextView.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 30)
        bioTextView.keyboardAppearance = .dark
        bioTextView.delegate = self

        bioTextViewDidChange = debounce(0.5) { [weak self] in
            guard
                let `self` = self,
                let bio = self.bioTextView.text
            else { return }

            ProfileService().updateUserProfile([.bio: bio])
                .then { [weak self] user -> Void in
                    guard let `self` = self else { return }

                    self.updateCurrentUser(user)
                    self.bioTextStatusImage.image = ValidationState.ok.imageRepresentation
                }
                .catch { _ in
                    self.bioTextStatusImage.image = ValidationState.error.imageRepresentation
                }
        }
    }

    private func setupLinksTextField() {
        linksTextFieldView.label.text = InterfaceString.Settings.Links
        linksTextFieldView.textField.spellCheckingType = .no
        linksTextFieldView.textField.autocapitalizationType = .none
        linksTextFieldView.textField.autocorrectionType = .no
        linksTextFieldView.textField.keyboardAppearance = .dark
        linksTextFieldView.textField.keyboardType = .asciiCapable

        let updateLinksFunction = debounce(0.5) { [weak self] in
            guard
                let `self` = self,
                let links = self.linksTextFieldView.textField.text
            else { return }

            ProfileService().updateUserProfile([.links: links])
                .then { [weak self] user -> Void in
                    guard let `self` = self else { return }

                    self.updateCurrentUser(user)
                    self.linksTextFieldView.setState(.ok)
                }
                .catch { _ in
                    self.linksTextFieldView.setState(.error)
                }
        }

        linksTextFieldView.textFieldDidChange = { _ in
            self.linksTextFieldView.setState(.loading)
            updateLinksFunction()
        }
    }

    private func setupLocationTextField() {
        locationTextFieldView.label.text = InterfaceString.Settings.Location
        locationTextFieldView.textField.keyboardAppearance = .dark
        locationTextFieldView.textField.autocorrectionType = .no
        locationTextFieldView.textField.leftView = UIImageView(image: InterfaceImage.marker.normalImage)
        locationTextFieldView.textField.leftViewMode = .always

        let updateLocationFunction = debounce(0.5) { [weak self] in
            guard
                let `self` = self,
                let location = self.locationTextFieldView.textField.text
            else { return }

            if location != self.currentUser?.location {
                ProfileService().updateUserProfile([.location: location])
                    .then { [weak self] user -> Void in
                        guard let `self` = self else { return }

                        self.updateCurrentUser(user)
                        let isValid = self.locationTextFieldView.textField.text?.isEmpty == false
                        self.locationTextFieldView.setState(isValid ? .ok : .none)
                    }
                    .catch { _ in
                        self.locationTextFieldView.setState(.error)
                    }
            }

            self.autoCompleteVC.load(AutoCompleteMatch(type: .location, range: location.startIndex ..< location.endIndex, text: location)) { count in
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

        case "DynamicSettingsSegue":
            dynamicSettingsViewController = segue.destination as? DynamicSettingsViewController
            dynamicSettingsViewController?.currentUser = currentUser
            dynamicSettingsViewController?.delegate = self

        default: break
        }
    }

    @IBAction
    func logOutTapped() {
        Tracker.shared.tappedLogout()
        postNotification(AuthenticationNotifications.userLoggedOut, value: ())
    }

    @IBAction
    func coverImageTapped() {
        photoSaveCallback = { imageRegion in
            _ = ElloHUD.showLoadingHud()
            ProfileService().updateUserCoverImage(imageRegion)
                .then { [weak self] url, _ -> Void in
                    guard let `self` = self else { return }

                    if let user = self.currentUser {
                        let asset = Asset(url: url)
                        user.coverImage = asset

                        postNotification(CurrentUserChangedNotification, value: user)
                    }

                    if imageRegion.isAnimatedGif {
                        self.coverImage.pin_setImage(from: url)
                    }
                    else {
                        self.coverImage.image = imageRegion.image
                    }
                    self.alertUserOfImageProcessing(InterfaceString.Settings.CoverImageUploaded)
                }
                .always {
                    ElloHUD.hideLoadingHud()
                }
        }
        openImagePicker()
    }

    @IBAction
    func avatarImageTapped() {
        photoSaveCallback = { imageRegion in
            _ = ElloHUD.showLoadingHud()
            ProfileService().updateUserAvatarImage(imageRegion)
                .then { [weak self] url, _ -> Void in
                    guard let `self` = self else { return }

                    if let user = self.currentUser {
                        let asset = Asset(url: url)
                        user.avatar = asset

                        postNotification(CurrentUserChangedNotification, value: user)
                    }

                    if imageRegion.isAnimatedGif {
                        self.avatarImage.pin_setImage(from: url)
                    }
                    else {
                        self.avatarImage.image = imageRegion.image
                    }
                    self.alertUserOfImageProcessing(InterfaceString.Settings.AvatarUploaded)
                }
                .always {
                    ElloHUD.hideLoadingHud()
                }
        }
        openImagePicker()
    }

    private func openImagePicker() {
        let alertViewController = UIImagePickerController.alertControllerForImagePicker { imagePicker in
            imagePicker.delegate = self
            self.present(imagePicker, animated: true, completion: .none)
        }

        if let alertViewController = alertViewController {
            present(alertViewController, animated: true, completion: .none)
        }
    }

    private func alertUserOfImageProcessing(_ message: String) {
        let alertController = AlertViewController(message: message)
        let action = AlertAction(title: InterfaceString.OK, style: .light, handler: .none)
        alertController.addAction(action)
        present(alertController, animated: true, completion: .none)
    }
}

extension SettingsViewController {
    func keyboardWillShow(_ keyboard: Keyboard) {
        updateAutoCompleteFrame(animated: true)
    }

    func keyboardDidHide(_ keyboard: Keyboard) {
        containerController?.updateNavBars()
    }

    func keyboardWillHide(_ keyboard: Keyboard) {
        updateAutoCompleteFrame(animated: true)
    }
}

extension SettingsViewController: CredentialSettingsResponder, DynamicSettingsDelegate {
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

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: Any]) {
        if let url = info[UIImagePickerControllerReferenceURL] as? URL,
            let asset = PHAsset.fetchAssets(withALAssetURLs: [url], options: nil).firstObject
        {
            AssetsToRegions.processPHAssets([asset]) { (images: [ImageRegionData]) in
                guard let imageRegion = images.first else { return }
                self.photoSaveCallback?(imageRegion)
            }

            dismiss(animated: true, completion: .none)
        }
        else if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            image.copyWithCorrectOrientationAndSize { image in
                if let image = image {
                    let imageRegion = ImageRegionData(image: image)
                    self.photoSaveCallback?(imageRegion)
                }
                self.dismiss(animated: true, completion: .none)
            }
        }
        else {
            dismiss(animated: true, completion: .none)
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
        if locationTextViewSelected && Keyboard.shared.active {
            tableView.contentInset.bottom = inset
        }
        else if !Keyboard.shared.active {
            containerController?.updateNavBars()
        }

        animateWithKeyboard(animated: animated) {
            self.autoCompleteVC.view.alpha = (self.locationTextViewSelected && self.locationAutoCompleteResultCount > 0) ? 1 : 0
            self.autoCompleteVC.view.frame = CGRect(x: 0, y: y, width: self.view.frame.width, height: height)
        }

        if locationTextViewSelected,
            let cell = locationTextFieldView.findParentView({ $0 is UITableViewCell })
        {
            tableView.scrollRectToVisible(cell.frame, animated: true)
        }
    }

    func autoComplete(_ controller: AutoCompleteViewController, itemSelected item: AutoCompleteItem) {
        guard let name = item.result.name else { return }

        locationTextFieldView.textField.text = name
        _ = locationTextFieldView.resignFirstResponder()
    }
}
