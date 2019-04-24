////
///  SettingsScreen.swift
//

import Photos
import SnapKit
import FLAnimatedImage


class SettingsScreen: NavBarScreen, SettingsScreenProtocol {
    struct Size {
        static let coverImageHeight: CGFloat = 200
        static let avatarImageSize: CGFloat = 180
        static let defaultMargin: CGFloat = 15
        static let avatarMargin: CGFloat = 56
        static let profileMargin: CGFloat = 20
        static let profileDescriptionHeight: CGFloat = 100
        static let bioTopOffset: CGFloat = 10
        static let bioBottomOffset: CGFloat = 10
        static let bioHeight: CGFloat = 160
        static let settingsHeight: CGFloat = 50
    }

    weak var delegate: SettingsScreenDelegate?
    var categoriesEnabled: Bool = false { didSet {
        categoriesButton?.isEnabled = categoriesEnabled
        categoriesLabel?.style = categoriesEnabled ? .largeBold : .largeBoldGray
    }}

    private var dynamicSettings: [DynamicSettingCategory]?
    private var categoriesButton: UIControl? { didSet {
        categoriesLabel?.style = categoriesEnabled ? .largeBold : .largeBoldGray
    }}
    private var categoriesLabel: StyledLabel? {
        return categoriesButton?.findSubview()
    }
    private var navigationInsets: UIEdgeInsets = .zero { didSet { updateInsets() }}
    private var bottomInset: CGFloat = 0 { didSet { updateInsets() }}
    private var uploadingProperty: Profile.ImageProperty?

    var username: String? {
        get { return usernameField.textField.text }
        set { usernameField.textField.text = newValue }
    }
    var email: String? {
        get { return emailField.textField.text }
        set { emailField.textField.text = newValue }
    }
    var name: String? {
        get { return nameField.textField.text }
        set { nameField.textField.text = newValue }
    }
    var bio: String? {
        get { return bioTextView.text }
        set { bioTextView.text = newValue }
    }
    var links: String? {
        get { return linksField.textField.text }
        set { linksField.textField.text = newValue }
    }
    var location: String? {
        get { return locationField.textField.text }
        set { locationField.textField.text = newValue }
    }

    private let scrollView = UIScrollView()
    private var widthConstraint: Constraint!
    private let coverImageView = FLAnimatedImageView()
    private let coverImageButton = StyledButton(style: .clearWhite)
    private let avatarImageView = FLAnimatedImageView()
    private let avatarImageButton = StyledButton(style: .clearWhite)

    private let profileLabel = StyledLabel(style: .largeBold)
    private let profileDescription = StyledLabel(style: .lightGray)
    private let usernameField = ElloTextFieldView()
    private let emailField = ElloTextFieldView()
    private let passwordField = ElloTextFieldView()
    private let credentialsButton = UIButton()
    private let nameField = ElloTextFieldView()
    private let bioLabel = StyledLabel(style: .lightGray)
    private let bioTextView = BioTextView()
    private let linksField = ElloTextFieldView()
    private let locationField = ElloTextFieldView()
    private var lastSettingsView: UIView!
    private let dynamicSettingsSpinner = UIView()
    private var dynamicSettingsButtons: [UIControl] = []
    private var settingsLookup: [UIControl: DynamicSettingCategory] = [:]

    override func style() {
        if #available(iOS 11.0, *) {
            scrollView.contentInsetAdjustmentBehavior = .never
        }

        navigationBar.leftItems = [.back]
        navigationBar.rightItems = [.close]
        coverImageView.contentMode = .scaleAspectFill
        coverImageView.clipsToBounds = true
        avatarImageView.contentMode = .scaleAspectFill
        avatarImageView.clipsToBounds = true
        profileDescription.isMultiline = true

        linksField.textField.spellCheckingType = .no
        linksField.textField.autocapitalizationType = .none
        linksField.textField.autocorrectionType = .no
        linksField.textField.keyboardType = .asciiCapable

        locationField.textField.autocorrectionType = .no
        locationField.textField.leftView = UIImageView(image: InterfaceImage.marker.normalImage)
        locationField.textField.leftViewMode = .always

        coverImageView.backgroundColor = .greyA
        avatarImageView.backgroundColor = .greyA
    }

    override func bindActions() {
        scrollView.delegate = self
        coverImageButton.addTarget(self, action: #selector(coverImageTapped), for: .touchUpInside)
        avatarImageButton.addTarget(self, action: #selector(avatarImageTapped), for: .touchUpInside)
        credentialsButton.addTarget(self, action: #selector(credentialFieldTapped), for: .touchUpInside)

        let updateLocationFunction = debounce(0.5) { [weak self] in
            guard let `self` = self else { return }
            let isFirstResponder = self.locationField.textField.isFirstResponder
            let locationText = self.locationField.textField.text ?? ""
            self.delegate?.locationChanged(isFirstResponder: isFirstResponder, text: locationText)
        }

        locationField.textFieldDidChange = { _ in updateLocationFunction() }
        locationField.firstResponderDidChange = { _ in updateLocationFunction() }
    }

    override func setText() {
        navigationBar.title = InterfaceString.Settings.EditProfile
        coverImageButton.title = InterfaceString.Settings.TapToEdit
        avatarImageButton.title = InterfaceString.Settings.TapToEdit

        profileLabel.text = InterfaceString.Settings.Profile
        profileDescription.text = InterfaceString.Settings.ProfileDescription
        usernameField.title = InterfaceString.Settings.Username
        emailField.title = InterfaceString.Settings.Email
        passwordField.title = InterfaceString.Settings.Password
        nameField.title = InterfaceString.Settings.Name
        bioLabel.text = InterfaceString.Settings.Bio
        linksField.title = InterfaceString.Settings.Links
        locationField.title = InterfaceString.Settings.Location
    }

    override func arrange() {
        let spinner = UIActivityIndicatorView(style: .gray)
        spinner.startAnimating()
        dynamicSettingsSpinner.addSubview(spinner)

        arrange(contentView: scrollView)

        scrollView.addSubview(coverImageView)
        scrollView.addSubview(coverImageButton)
        scrollView.addSubview(avatarImageView)
        scrollView.addSubview(avatarImageButton)

        scrollView.addSubview(profileLabel)
        scrollView.addSubview(profileDescription)
        scrollView.addSubview(usernameField)
        scrollView.addSubview(emailField)
        scrollView.addSubview(passwordField)
        scrollView.addSubview(nameField)
        scrollView.addSubview(credentialsButton)
        scrollView.addSubview(bioLabel)
        scrollView.addSubview(bioTextView)
        scrollView.addSubview(linksField)
        scrollView.addSubview(locationField)

        scrollView.addSubview(dynamicSettingsSpinner)

        let marginGuide = UILayoutGuide()
        scrollView.addLayoutGuide(marginGuide)

        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(self)
        }

        marginGuide.snp.makeConstraints { make in
            make.leading.trailing.equalTo(scrollView).inset(Size.defaultMargin)
        }

        coverImageView.snp.makeConstraints { make in
            make.leading.trailing.top.equalTo(scrollView).priority(Priority.required)
            widthConstraint = make.width.equalTo(frame.width).priority(Priority.required).constraint
            make.height.equalTo(Size.coverImageHeight)
        }
        coverImageButton.snp.makeConstraints { make in
            make.edges.equalTo(coverImageView)
        }
        coverImageButton.setContentHuggingPriority(UILayoutPriority.defaultLow, for: .horizontal)
        coverImageButton.setContentHuggingPriority(UILayoutPriority.defaultLow, for: .vertical)

        avatarImageView.snp.makeConstraints { make in
            make.centerX.equalTo(scrollView)
            make.top.equalTo(coverImageView.snp.bottom).offset(-Size.avatarMargin)
            make.width.height.equalTo(Size.avatarImageSize)
        }
        avatarImageButton.snp.makeConstraints { make in
            make.edges.equalTo(avatarImageView)
        }
        avatarImageButton.setContentHuggingPriority(UILayoutPriority.defaultLow, for: .horizontal)
        avatarImageButton.setContentHuggingPriority(UILayoutPriority.defaultLow, for: .vertical)

        profileLabel.snp.makeConstraints { make in
            make.top.equalTo(avatarImageView.snp.bottom).offset(Size.profileMargin)
            make.leading.equalTo(marginGuide)
        }
        profileDescription.snp.makeConstraints { make in
            make.top.equalTo(profileLabel.snp.bottom)
            make.leading.trailing.equalTo(marginGuide)
            make.height.equalTo(Size.profileDescriptionHeight)
        }
        let credentialsFields: [UIView] = [
            usernameField,
            emailField,
            passwordField,
        ]
        let fields: [UIView] = credentialsFields + [
            nameField,
            bioLabel,
            bioTextView,
            linksField,
            locationField,
        ]
        fields.eachPair { prevField, field in
            field.snp.makeConstraints { make in
                let maker = make.leading.trailing.equalTo(scrollView)

                if field == bioLabel || field == bioTextView {
                    maker.inset(Size.defaultMargin)
                }

                if field == bioTextView {
                    make.top.equalTo(bioLabel.snp.bottom).offset(Size.bioTopOffset)
                    make.height.equalTo(Size.bioHeight)
                }
                else if let prevField = prevField, prevField == bioTextView {
                    make.top.equalTo(prevField.snp.bottom).offset(Size.bioBottomOffset)
                }
                else if let prevField = prevField {
                    make.top.equalTo(prevField.snp.bottom)
                }
                else {
                    make.top.equalTo(profileDescription.snp.bottom)
                }
            }
        }

        credentialsButton.snp.makeConstraints { make in
            make.leading.trailing.equalTo(scrollView)
            make.top.equalTo(credentialsFields.first!)
            make.bottom.equalTo(credentialsFields.last!)
        }

        lastSettingsView = fields.last
        dynamicSettingsSpinner.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalTo(scrollView)
            make.top.equalTo(lastSettingsView.snp.bottom)
            make.height.equalTo(Size.settingsHeight)
        }
        spinner.snp.makeConstraints { make in
            make.center.equalTo(dynamicSettingsSpinner)
        }

        showNavBars(animated: false)
        scrollView.contentOffset.y = ElloNavigationBar.Size.height
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        widthConstraint.update(offset: frame.width)
        avatarImageView.layer.cornerRadius = min(avatarImageView.frame.width, avatarImageView.frame.height) / 2
    }

    override func showNavBars(animated: Bool) {
        super.showNavBars(animated: animated)
        navigationInsets.top = ElloNavigationBar.Size.height
        navigationInsets.bottom = ElloTabBar.Size.height
    }

    override func hideNavBars(animated: Bool) {
        super.hideNavBars(animated: animated)
        navigationInsets.top = 0
        navigationInsets.bottom = 0
    }

    func keyboardUpdated(_ keyboard: Keyboard) {
        bottomInset = keyboard.keyboardBottomInset(inView: self)
    }

    func resignLocationField() {
        _ = locationField.resignFirstResponder()
    }

    private func updateInsets() {
        var insets = navigationInsets
        insets.bottom = max(navigationInsets.bottom, bottomInset)
        scrollView.contentInset = insets
        scrollView.scrollIndicatorInsets = insets
    }

    func scrollToLocation() {
        scrollView.scrollRectToVisible(locationField.frame, animated: true)
    }

    func showError(_ error: String?) {
        guard let error = error else { return }
        let alertController = AlertViewController(confirmation: error)
        self.delegate?.present(controller: alertController)
    }

    func setImage(_ property: Profile.ImageProperty, url: URL?) {
        let imageView = property == .coverImage ? coverImageView : avatarImageView
        imageView.pin_setImage(from: url)
    }

    func setImage(_ property: Profile.ImageProperty, image: UIImage?) {
        let imageView = property == .coverImage ? coverImageView : avatarImageView
        imageView.image = image
    }
}

extension SettingsScreen {
    func updateDynamicSettings(_ dynamicSettings: [DynamicSettingCategory], blockCount: Int, mutedCount: Int) {
        self.dynamicSettings = dynamicSettings
        updateAllSettings(blockCount: blockCount, mutedCount: mutedCount)
    }

    func updateAllSettings(blockCount: Int, mutedCount: Int) {
        guard let dynamicSettings = dynamicSettings else { return }

        if dynamicSettingsSpinner.superview != nil {
            dynamicSettingsSpinner.removeFromSuperview()
        }

        for button in dynamicSettingsButtons {
            settingsLookup[button] = nil
            button.removeFromSuperview()
        }
        categoriesButton = nil

        var allDynamicSettings = [DynamicSettingCategory.creatorTypeCategory] + dynamicSettings

        if blockCount > 0 {
            allDynamicSettings.append(DynamicSettingCategory.blockedCategory)
        }

        if mutedCount > 0 {
            allDynamicSettings.append(DynamicSettingCategory.mutedCategory)
        }

        allDynamicSettings.append(DynamicSettingCategory.accountDeletionCategory)

        dynamicSettingsButtons = allDynamicSettings.map { settings in
            let button = SettingsScreen.generateSettingsView(settings: settings)
            if settings.section == .creatorType {
                button.isEnabled = categoriesEnabled
                self.categoriesButton = button
            }
            button.addTarget(self, action: #selector(dynamicSettingsTapped(_:)), for: .touchUpInside)
            settingsLookup[button] = settings
            return button
        }

        dynamicSettingsButtons.eachPair { prevButton, button, isLast in
            scrollView.addSubview(button)
            button.snp.makeConstraints { make in
                make.leading.trailing.equalTo(scrollView)
                make.height.equalTo(Size.settingsHeight)

                if let prevButton = prevButton {
                    make.top.equalTo(prevButton.snp.bottom)
                }
                else {
                    make.top.equalTo(lastSettingsView.snp.bottom)
                }

                if isLast {
                    make.bottom.equalTo(scrollView)
                }
            }
        }
    }
}

extension SettingsScreen: UIScrollViewDelegate {
    @objc
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        delegate?.scrollViewDidScroll(scrollView)
    }

    @objc
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        delegate?.scrollViewWillBeginDragging(scrollView)
    }

    @objc
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate: Bool) {
        delegate?.scrollViewDidEndDragging(scrollView, willDecelerate: willDecelerate)
    }
}

extension SettingsScreen {
    @objc
    func coverImageTapped() {
        uploadingProperty = .coverImage
        openImagePicker()
    }

    @objc
    func avatarImageTapped() {
        uploadingProperty = .avatar
        openImagePicker()
    }

    private func openImagePicker() {
        let alertController = UIImagePickerController.alertControllerForImagePicker { imagePicker in
            imagePicker.delegate = self
            self.delegate?.present(controller: imagePicker)
        }

        if let alertController = alertController {
            self.delegate?.present(controller: alertController)
        }
    }

    @objc
    func logoutTapped() {
        delegate?.logoutTapped()
    }

    @objc
    func credentialFieldTapped() {
        delegate?.showCredentialsScreen()
    }

    @objc
    func dynamicSettingsTapped(_ sender: UIButton) {
        guard let settings = settingsLookup[sender] else { return }
        delegate?.showDynamicSettings(settings)
    }
}

extension SettingsScreen {
    static func generateSettingsView(settings: DynamicSettingCategory) -> UIControl {
        let label = StyledLabel(style: .largeBold)
        label.text = settings.label

        let line = Line(color: .greyF2)

        let chevron = UIImageView()
        chevron.setInterfaceImage(.forwardChevron, style: .normal)

        let view = UIControl()
        view.addSubview(label)
        view.addSubview(line)
        view.addSubview(chevron)

        label.snp.makeConstraints { make in
            make.leading.equalTo(view).inset(Size.defaultMargin)
            make.centerY.equalTo(view)
        }
        line.snp.makeConstraints { make in
            make.leading.trailing.equalTo(view).inset(Size.defaultMargin)
            make.bottom.equalTo(view)
        }
        chevron.snp.makeConstraints { make in
            make.centerY.equalTo(view)
            make.trailing.equalTo(view).inset(Size.defaultMargin)
        }
        return view
    }
}

extension SettingsScreen: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        guard
            let delegate = delegate,
            let uploadingProperty = self.uploadingProperty
        else { return }

        self.uploadingProperty = nil
        delegate.dismissController()

        if let url = info[.referenceURL] as? URL,
            let asset = PHAsset.fetchAssets(withALAssetURLs: [url], options: nil).firstObject
        {
            AssetsToRegions.processPHAssets([asset]) { (images: [ImageRegionData]) in
                guard let imageRegion = images.first else { return }
                delegate.saveImage(imageRegion, property: uploadingProperty)
            }
        }
        else if let image = info[.originalImage] as? UIImage {
            image.copyWithCorrectOrientationAndSize { image in
                guard let image = image else { return }
                delegate.saveImage(ImageRegionData(image: image), property: uploadingProperty)
            }
        }

    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        uploadingProperty = nil
        delegate?.dismissController()
    }
}
