////
///  OmnibarScreen.swift
//

import MobileCoreServices
import FLAnimatedImage
import PINRemoteImage
import Photos


fileprivate let imageManager = PHCachingImageManager()
fileprivate let imageHeight: CGFloat = 150
fileprivate let imageMargin: CGFloat = 1
fileprivate let imageContentHeight = imageHeight + 2 * imageMargin

class OmnibarScreen: UIView, OmnibarScreenProtocol {
    struct Size {
        static let margins = UIEdgeInsets(top: 8, left: 2, bottom: 10, right: 5)
        static let toolbarMargin: CGFloat = 10
        static let toolbarRightPadding: CGFloat = 20
        static let additionalBuyPadding: CGFloat = 5
        static let tableTopInset: CGFloat = 22.5
        static let bottomTextMargin: CGFloat = 1
        static let keyboardButtonSize = CGSize(width: 54, height: 44)
        static let keyboardButtonMargin: CGFloat = 1
    }

    class func canEditRegions(_ regions: [Regionable]?) -> Bool {
        if let regions = regions {
            return regions.count > 0 && regions.all { region in
                return region is TextRegion || region is ImageRegion
            }
        }
        return false
    }

    var autoCompleteVC = AutoCompleteViewController()

    var isComment: Bool = false {
        didSet { updateButtons() }
    }
    var isArtistInviteSubmission: Bool = false {
        didSet { updateButtons() }
    }
    var isEditing = false
    var reordering = false

    var isInteractionEnabled: Bool = true {
        didSet {
            isUserInteractionEnabled = isInteractionEnabled
            boldButton.isUserInteractionEnabled = isInteractionEnabled
            italicButton.isUserInteractionEnabled = isInteractionEnabled
            linkButton.isUserInteractionEnabled = isInteractionEnabled
            keyboardSubmitButton.isUserInteractionEnabled = isInteractionEnabled
        }
    }

    typealias IndexedRegion = (Int?, OmnibarRegion)
    var buyButtonURL: URL? {
        didSet { updateButtons() }
    }
    var regions: [OmnibarRegion] {
        set {
            var regions = newValue
            if let last = regions.last, !last.isText {
                regions.append(.text(""))
            }
            else if regions.count == 0 {
                regions.append(.text(""))
            }
            submitableRegions = regions
            editableRegions = generateEditableRegions(submitableRegions)
            regionsTableView.reloadData()
            updateButtons()
        }
        get { return submitableRegions }
    }
    var submitableRegions: [OmnibarRegion]
    var tableViewRegions: [IndexedRegion] {
        if reordering {
            return reorderableRegions
        }
        else {
            return editableRegions
        }
    }
    var reorderableRegions = [IndexedRegion]()
    var editableRegions = [IndexedRegion]()

    var currentTextPath: IndexPath?

    var submitTitle: String = "" {
        didSet {
            for button in [tabbarSubmitButton, keyboardSubmitButton] {
                button.setTitle(submitTitle, for: .normal)
            }
        }
    }

    var title: String = "" {
        didSet {
            navigationItem.title = title
        }
    }

    let navigationItem = UINavigationItem()

    var canGoBack: Bool = false {
        didSet { setNeedsLayout() }
    }

    var currentUser: User?
    var currentAssets: [PHAsset] = []

// MARK: internal and/or private vars

    weak var delegate: OmnibarScreenDelegate?

    let statusBarUnderlay = UIView(frame: CGRect(x: 0, y: 0, width: 320, height: 20))
    let navigationBar = ElloNavigationBar(frame: .zero)

// MARK: toolbar buttons
    var toolbarButtonViews: [UIView]!
    let buyButton = UIButton()
    let cancelButton = UIButton()
    let reorderButton = UIButton()
    let cameraButton = UIButton()
    let textButton = UIButton()
    let photoAccessoryContainer = UIView()

// MARK: keyboard buttons
    var keyboardButtonViews: [UIView]!
    var keyboardButtonView = UIView()
    let boldButton = UIButton()
    let italicButton = UIButton()
    let linkButton = UIButton()
    let keyboardSubmitButton = UIButton()
    let tabbarSubmitButton = UIButton()

    let regionsTableView = UITableView()
    let textEditingControl = UIControl()
    let textScrollView = UIScrollView()
    let textContainer = UIView()
    let textView: UITextView
    var autoCompleteContainer = UIView()
    var autoCompleteThrottle = debounce(0.4)
    var autoCompleteShowing = false

// MARK: init

    override init(frame: CGRect) {
        submitableRegions = [.text("")]
        textView = OmnibarTextCell.generateTextView()

        super.init(frame: frame)

        backgroundColor = .white
        autoCompleteContainer.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: 0)

        editableRegions = generateEditableRegions(submitableRegions)
        setupAutoComplete()
        setupNavigationBar()
        setupToolbarButtons()
        setupTableViews()
        setupKeyboardViews()
        setupViewHierarchy()

        regionsTableView.addObserver(self, forKeyPath: "contentSize", options: [.new], context: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        regionsTableView.removeObserver(self, forKeyPath: "contentSize", context: nil)
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        let sup = { super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context) }
        guard let keyPath = keyPath, let change = change else {
            sup()
            return
        }

        switch keyPath {
        case "contentSize":
            if let contentSize = (change[NSKeyValueChangeKey.newKey] as? NSValue)?.cgSizeValue {
                let contentHeight: CGFloat = ceil(contentSize.height) + regionsTableView.contentInset.bottom
                let height: CGFloat = max(0, regionsTableView.frame.height - contentHeight)
                let y = regionsTableView.frame.height - height - regionsTableView.contentInset.bottom
                textEditingControl.frame = CGRect(
                    x: 0,
                    y: y,
                    width: self.frame.width,
                    height: height
                    )
            }
        default:
            sup()
        }
    }

    override func didMoveToWindow() {
        if window == nil, photoAccessoryContainer.superview != nil {
            photoAccessoryContainer.removeFromSuperview()
        }
        else if let window = window, photoAccessoryContainer.window != window {
            window.addSubview(photoAccessoryContainer)
        }
    }

// MARK: View setup code

    fileprivate func setupAutoComplete() {
        autoCompleteVC.view.frame = autoCompleteContainer.frame
        autoCompleteVC.delegate = self
        autoCompleteContainer.addSubview(autoCompleteVC.view)
    }

    // TODO: use elloNavigationItem, move into OmnibarViewController.loadView
    fileprivate func setupNavigationBar() {
        let backItem = UIBarButtonItem.backChevronWithTarget(self, action: #selector(backAction))
        navigationItem.leftBarButtonItem = backItem
        navigationItem.fixNavBarItemPadding()
        navigationBar.items = [navigationItem]

        statusBarUnderlay.frame.size.width = frame.width
        statusBarUnderlay.backgroundColor = .black
        statusBarUnderlay.autoresizingMask = [.flexibleWidth, .flexibleBottomMargin]
        addSubview(statusBarUnderlay)
    }

    // buttons that make up the "toolbar"
    fileprivate func setupToolbarButtons() {
        buyButton.contentEdgeInsets = UIEdgeInsets(top: 4, left: 11, bottom: 4, right: 3)
        buyButton.adjustsImageWhenDisabled = false
        buyButton.adjustsImageWhenHighlighted = false
        buyButton.setImages(.addBuyButton)
        buyButton.setImage(.addBuyButton, imageStyle: .disabled, for: .disabled)
        buyButton.isEnabled = false
        buyButton.addTarget(self, action: #selector(buyButtonTapped), for: .touchUpInside)

        cancelButton.contentEdgeInsets = UIEdgeInsets(tops: 4, sides: 9.5)
        cancelButton.setImages(.x)
        cancelButton.addTarget(self, action: #selector(cancelEditingAction), for: .touchUpInside)

        reorderButton.contentEdgeInsets = UIEdgeInsets(tops: 4, sides: 9.5)
        reorderButton.setImages(.reorder)
        reorderButton.addTarget(self, action: #selector(toggleReorderingTable), for: .touchUpInside)

        cameraButton.contentEdgeInsets = UIEdgeInsets(tops: 4, sides: 3.5)
        cameraButton.setImages(.camera)
        cameraButton.addTarget(self, action: #selector(cameraButtonTapped), for: .touchUpInside)

        textButton.setAttributedTitle(NSAttributedString(string: "T", attributes: [
            NSFontAttributeName: UIFont.defaultItalicFont(),
            NSForegroundColorAttributeName: UIColor.greyA
        ]), for: .normal)
        textButton.addTarget(self, action: #selector(textButtonTapped), for: .touchUpInside)
        textButton.isHidden = true

        for button in [tabbarSubmitButton, keyboardSubmitButton] {
            button.backgroundColor = .black
            button.setImages(.pencil, white: true)
            button.setTitle(InterfaceString.Omnibar.CreatePostButton, for: .normal)
            button.setTitleColor(.white, for: .normal)
            button.setTitleColor(.grey6, for: .disabled)
            button.titleLabel?.font = UIFont.defaultFont()
            button.contentEdgeInsets.left = -5
            button.imageEdgeInsets.right = 5
            button.addTarget(self, action: #selector(submitAction), for: .touchUpInside)
            button.frame.size.height = Size.keyboardButtonSize.height
        }
    }

    // The textContainer is the outer gray background.  The text view is
    // configured to fill that container (only the container and the text view
    // insets are modified in layoutSubviews)
    fileprivate func setupTableViews() {
        regionsTableView.dataSource = self
        regionsTableView.delegate = self
        regionsTableView.separatorStyle = .none
        regionsTableView.register(OmnibarTextCell.self, forCellReuseIdentifier: OmnibarTextCell.reuseIdentifier)
        regionsTableView.register(OmnibarImageCell.self, forCellReuseIdentifier: OmnibarImageCell.reuseIdentifier)
        regionsTableView.register(OmnibarImageDownloadCell.self, forCellReuseIdentifier: OmnibarImageDownloadCell.reuseIdentifier)
        regionsTableView.register(UITableViewCell.self, forCellReuseIdentifier: OmnibarRegion.OmnibarSpacerCell)
        regionsTableView.register(OmnibarErrorCell.self, forCellReuseIdentifier: OmnibarErrorCell.reuseIdentifier)

        textEditingControl.addTarget(self, action: #selector(startEditingLast), for: .touchUpInside)
        regionsTableView.addSubview(textEditingControl)

        textScrollView.delegate = self
        let stopEditingTapGesture = UITapGestureRecognizer(target: self, action: #selector(stopEditing))
        textScrollView.addGestureRecognizer(stopEditingTapGesture)
        let stopEditingSwipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(stopEditing))
        stopEditingSwipeGesture.direction = .down
        textScrollView.addGestureRecognizer(stopEditingSwipeGesture)
        textScrollView.clipsToBounds = true
        textContainer.backgroundColor = .white

        textView.clipsToBounds = false
        textView.isEditable = true
        textView.allowsEditingTextAttributes = false
        textView.isSelectable = true
        textView.delegate = self
        textView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        textView.spellCheckingType = .yes
        textView.autocorrectionType = .yes
    }

    fileprivate func setupKeyboardViews() {
        keyboardButtonViews = [
            boldButton,
            italicButton,
            linkButton,
        ]

        keyboardButtonView.backgroundColor = .greyC
        for button in keyboardButtonViews as [UIView] {
            button.backgroundColor = .greyA
            button.frame.size = Size.keyboardButtonSize
        }

        boldButton.addTarget(self, action: #selector(boldButtonTapped), for: .touchUpInside)
        boldButton.setAttributedTitle(NSAttributedString(string: "B", attributes: [
            NSFontAttributeName: UIFont.defaultBoldFont(),
            NSForegroundColorAttributeName: UIColor.white
        ]), for: .normal)
        boldButton.setAttributedTitle(NSAttributedString(string: "B", attributes: [
            NSFontAttributeName: UIFont.defaultBoldFont(),
            NSForegroundColorAttributeName: UIColor.grey6
        ]), for: .highlighted)
        boldButton.setAttributedTitle(NSAttributedString(string: "B", attributes: [
            NSFontAttributeName: UIFont.defaultBoldFont(),
            NSForegroundColorAttributeName: UIColor.black
            ]), for: .selected)

        italicButton.addTarget(self, action: #selector(italicButtonTapped), for: .touchUpInside)
        italicButton.setAttributedTitle(NSAttributedString(string: "I", attributes: [
            NSFontAttributeName: UIFont.defaultItalicFont(),
            NSForegroundColorAttributeName: UIColor.white
        ]), for: .normal)
        italicButton.setAttributedTitle(NSAttributedString(string: "I", attributes: [
            NSFontAttributeName: UIFont.defaultItalicFont(),
            NSForegroundColorAttributeName: UIColor.grey6
        ]), for: .highlighted)
        italicButton.setAttributedTitle(NSAttributedString(string: "I", attributes: [
            NSFontAttributeName: UIFont.defaultItalicFont(),
            NSForegroundColorAttributeName: UIColor.black
            ]), for: .selected)

        linkButton.addTarget(self, action: #selector(linkButtonTapped), for: .touchUpInside)
        linkButton.isEnabled = false
        linkButton.setImage(.link, imageStyle: .white, for: .normal)
        linkButton.setImage(.breakLink, imageStyle: .white, for: .selected)
    }

    fileprivate func setupViewHierarchy() {
        let views = [
            regionsTableView,
            textScrollView,
            navigationBar,
            cancelButton,
        ]
        for view in views as [UIView] {
            self.addSubview(view)
        }

        toolbarButtonViews = [
            buyButton,
            reorderButton,
            cameraButton,
        ]
        for button in toolbarButtonViews as [UIView] {
            self.addSubview(button)
        }
        self.addSubview(textButton)

        for button in keyboardButtonViews as [UIView] {
            keyboardButtonView.addSubview(button)
        }

        addSubview(tabbarSubmitButton)
        keyboardButtonView.addSubview(keyboardSubmitButton)

        textScrollView.addSubview(textContainer)
        textScrollView.addSubview(textView)
        textView.inputAccessoryView = keyboardButtonView
        textScrollView.isHidden = true
    }

// MARK: Generate regions

    func generateEditableRegions(_ regions: [OmnibarRegion]) -> [IndexedRegion] {
        var editableRegions = [IndexedRegion]()
        for (index, region) in regions.enumerated() {
            if index > 0 {
                editableRegions.append((nil, .spacer))
            }
            editableRegions.append((index, region))
            if let path = currentTextPath, path.row == editableRegions.count - 1 {
                textView.attributedText = region.text
            }
        }
        return editableRegions
    }

// MARK: Public interface

    func resetAfterSuccessfulPost() {
        resetEditor()
    }

    // called on a user action that should resign the keyboard
    func stopEditing() {
        resignKeyboard()
        editingCanceled()
    }

// MARK: Internal, but might need to be testable

    // called whenever the keyboard is dismissed, by user or system
    fileprivate func editingCanceled() {
        textScrollView.isHidden = true
        textScrollView.scrollsToTop = false
        regionsTableView.scrollsToTop = true
        currentTextPath = nil
    }

    fileprivate func updateCurrentText(_ text: NSAttributedString) {
        if let path = currentTextPath {
            updateText(text, atPath: path)
        }
    }

    func updateText(_ text: NSAttributedString, atPath path: IndexPath) {
        let newRegion: OmnibarRegion = .attributedText(text)
        let (index, _) = editableRegions[path.row]
        if let index = index {
            submitableRegions[index] = newRegion
            editableRegions[path.row] = (index, newRegion)

            regionsTableView.reloadData()
            updateEditingAtPath(path, scrollPosition: .bottom)
        }
    }

    func startEditingAtPath(_ path: IndexPath) {
        if let (_, region) = tableViewRegions.safeValue(path.row), region.isText {
            currentTextPath = path
            textScrollView.isHidden = false
            textScrollView.contentOffset = regionsTableView.contentOffset
            textScrollView.contentInset = regionsTableView.contentInset
            textScrollView.scrollIndicatorInsets = regionsTableView.scrollIndicatorInsets
            textScrollView.scrollsToTop = true
            regionsTableView.scrollsToTop = false
            textView.attributedText = region.text
            updateEditingAtPath(path)
        }
    }

    func updateEditingAtPath(_ path: IndexPath, scrollPosition: UITableViewScrollPosition = .middle) {
        let rect = regionsTableView.rectForRow(at: path)
        textScrollView.contentSize = regionsTableView.contentSize
        textView.frame = OmnibarTextCell.boundsForTextView(rect)
        textContainer.frame = textView.frame.grow(all: 10)
        _ = textView.becomeFirstResponder()
    }

    func startEditingLast() {
        var lastTextRow: Int?
        for (row, indexedRegion) in editableRegions.enumerated() where indexedRegion.1.isText {
            lastTextRow = row
        }

        if let lastTextRow = lastTextRow {
            startEditingAtPath(IndexPath(row: lastTextRow, section: 0))
        }
    }

    func startEditing() {
        var firstTextRow: Int?
        for (row, indexedRegion) in editableRegions.enumerated() where indexedRegion.1.isText {
            firstTextRow = row
            break
        }

        if let firstTextRow = firstTextRow {
            startEditingAtPath(IndexPath(row: firstTextRow, section: 0))
        }
    }

    func toggleReorderingTable() {
        reorderingTable(!reordering)
    }

    fileprivate func generateReorderableRegions(_ regions: [OmnibarRegion]) -> [IndexedRegion] {
        let nonEmptyRegions = regions.filter { region in
            return region.isEditable && !region.isEmpty
        }
        return nonEmptyRegions.map { (region: OmnibarRegion) -> IndexedRegion in
            return (nil, region)
        }
    }

    fileprivate func convertReorderableRegions(_ reorderableRegions: [IndexedRegion]) -> [OmnibarRegion] {
        var regions = [OmnibarRegion]()
        var buffer = ElloAttributedString.style("")
        var lastRegionIsText = false
        for (_, region) in reorderableRegions {
            switch region {
            case let .attributedText(text):
                buffer = buffer.joinWithNewlines(text)
                lastRegionIsText = true
            case .imageData, .image:
                if buffer.string.characters.count > 0 {
                    regions.append(.attributedText(buffer))
                }
                regions.append(region)
                buffer = ElloAttributedString.style("")
                lastRegionIsText = false
            default: break
            }
        }
        if buffer.string.characters.count > 0 {
            regions.append(.attributedText(buffer))
        }
        else if !lastRegionIsText {
            regions.append(.text(""))
        }
        return regions
    }

    func reorderingTable(_ reordering: Bool) {
        if reordering {
            reorderableRegions = generateReorderableRegions(submitableRegions)
            if reorderableRegions.count == 0 { return }

            stopEditing()
            reorderButton.setImages(.check)
            reorderButton.isSelected = true
        }
        else {
            submitableRegions = convertReorderableRegions(reorderableRegions)
            editableRegions = generateEditableRegions(submitableRegions)
            reorderButton.setImages(.reorder)
            reorderButton.isSelected = false
        }

        self.reordering = reordering
        regionsTableView.setEditing(reordering, animated: true)
        updateButtons()
        regionsTableView.reloadData()
    }

    func reportError(_ title: String, error: NSError) {
        let errorMessage = error.elloErrorMessage ?? error.localizedDescription
        reportError(title, errorMessage: errorMessage)
    }

    func reportError(_ title: String, errorMessage: String) {
        let alertController = AlertViewController(message: "\(title)\n\n\(errorMessage)\n\nIf you are uploading multiple images, this error could be due to slow internet and/or too many images.")

        let cancelAction = AlertAction(title: InterfaceString.OK, style: .light, handler: .none)
        alertController.addAction(cancelAction)

        delegate?.omnibarPresentController(alertController)
    }

// MARK: Keyboard events - animate layout update in conjunction with keyboard animation

    func keyboardWillShow() {
        resetToImageButton()

        self.setNeedsLayout()
        animateWithKeyboard {
            self.layoutIfNeeded()
        }
    }

    func keyboardWillHide() {
        self.setNeedsLayout()
        animateWithKeyboard {
            self.layoutIfNeeded()
        }
    }

    func resignKeyboard() {
        _ = textView.resignFirstResponder()
        regions = regions.filter { !$0.isEmpty }
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let screenTop: CGFloat
        if canGoBack {
            postNotification(StatusBarNotifications.statusBarVisibility, value: true)
            navigationBar.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: ElloNavigationBar.Size.height)
            screenTop = navigationBar.frame.height
            statusBarUnderlay.isHidden = true
        }
        else {
            screenTop = CGFloat(20)
            navigationBar.frame = .zero
            statusBarUnderlay.isHidden = false
        }

        let toolbarTop = screenTop + Size.margins.top
        var buttonX = frame.width - Size.margins.right
        for view in toolbarButtonViews.reversed() {
            view.frame.size = view.intrinsicContentSize
            buttonX -= view.frame.size.width + Size.toolbarRightPadding
            view.frame.origin = CGPoint(x: buttonX, y: toolbarTop)
        }
        textButton.frame = cameraButton.frame

        buyButton.frame = buyButton.frame.shift(left: Size.additionalBuyPadding)

        let cancelButtonSize = cancelButton.intrinsicContentSize
        cancelButton.frame = CGRect(x: Size.margins.left, y: toolbarTop, width: cancelButtonSize.width, height: cancelButtonSize.height)

        regionsTableView.frame = CGRect(x: 0, y: cancelButton.frame.maxY + Size.toolbarMargin, right: bounds.size.width, bottom: bounds.size.height)
        textScrollView.frame = regionsTableView.frame

        var bottomInset = Keyboard.shared.keyboardBottomInset(inView: self)

        if bottomInset == 0 {
            bottomInset = ElloTabBar.Size.height + Size.keyboardButtonSize.height
        }
        else {
            bottomInset += Size.keyboardButtonSize.height
        }

        regionsTableView.contentInset.top = Size.tableTopInset
        regionsTableView.contentInset.bottom = bottomInset
        regionsTableView.scrollIndicatorInsets.bottom = bottomInset
        synchronizeScrollViews()

        keyboardButtonView.frame.size = CGSize(width: frame.width, height: Size.keyboardButtonSize.height)
        tabbarSubmitButton.frame.size = CGSize(width: frame.width, height: Size.keyboardButtonSize.height)

        if Keyboard.shared.active {
            tabbarSubmitButton.frame.origin.y = frame.height
        }
        else {
            tabbarSubmitButton.frame.origin.y = frame.height - ElloTabBar.Size.height - Size.keyboardButtonSize.height
        }

        var x = CGFloat(0)
        for view in keyboardButtonViews {
            view.frame.origin.x = x
            x += view.frame.size.width
            x += Size.keyboardButtonMargin
        }
        let remainingCameraWidth = frame.width - x
        keyboardSubmitButton.frame.origin.x = keyboardButtonView.frame.width - remainingCameraWidth
        keyboardSubmitButton.frame.size.width = remainingCameraWidth

        photoAccessoryContainer.frame.size.width = frame.width
        photoAccessoryContainer.frame.origin.x = 0
        photoAccessoryContainer.frame.origin.y = frame.height - Keyboard.shared.keyboardBottomInset(inView: self) - photoAccessoryContainer.frame.height
    }

    func synchronizeScrollViews() {
        textScrollView.contentSize = regionsTableView.contentSize
        textScrollView.contentInset = regionsTableView.contentInset
        textScrollView.scrollIndicatorInsets = regionsTableView.scrollIndicatorInsets
    }

    fileprivate func resetEditor() {
        textView.text = ""
        submitableRegions = [.text("")]
        editableRegions = generateEditableRegions(submitableRegions)
        hideAutoComplete(textView)
        stopEditing()
        updateButtons()
        regionsTableView.reloadData()
    }

    func updateButtons() {
        if !hasImage() && buyButtonURL != nil {
            buyButtonURL = nil  // this calls updateButtons() again
            return
        }

        let canSubmit = !reordering && canPost()
        keyboardSubmitButton.isEnabled = canSubmit
        tabbarSubmitButton.isEnabled = canSubmit

        let canAddBuyButtonLink = !reordering && hasImage()
        buyButton.isEnabled = canAddBuyButtonLink
        buyButton.isHidden = isComment || isArtistInviteSubmission

        if buyButtonURL == nil {
            buyButton.setImages(.addBuyButton)
        }
        else {
            buyButton.setImages(.setBuyButton)
        }
    }

// MARK: Button Actions

    func backAction() {
        delegate?.omnibarCancel()
    }

    func cancelEditingAction() {
        if reordering {
            reorderingTable(false)
        }
        else if canPost() && !isEditing {
            let alertController = AlertViewController()

            let deleteAction = AlertAction(title: InterfaceString.Delete, style: ActionStyle.dark, handler: { _ in
                self.resetEditor()
            })
            alertController.addAction(deleteAction)

            let cancelAction = AlertAction(title: InterfaceString.Cancel, style: .light, handler: .none)
            alertController.addAction(cancelAction)

            delegate?.omnibarPresentController(alertController)
        }
        else {
            delegate?.omnibarCancel()
        }
    }

    func submitAction() {
        if canPost() {
            stopEditing()
            delegate?.omnibarSubmitted(submitableRegions, buyButtonURL: buyButtonURL)
        }
    }

    func buyButtonTapped() {
        let vc = BuyButtonLinkViewController(buyButtonURL: buyButtonURL)
        vc.delegate = self
        delegate?.omnibarPresentController(vc)
    }

    func boldButtonTapped() {
        let font = textView.typingAttributes[NSFontAttributeName] as? UIFont
        let fontName = (font ?? UIFont.editorFont()).fontName

        let newFont: UIFont
        switch fontName {
        case UIFont.editorFont().fontName:
            newFont = UIFont.editorBoldFont()
            boldButton.isSelected = true
        case UIFont.editorItalicFont().fontName:
            newFont = UIFont.editorBoldItalicFont()
            boldButton.isSelected = true
        case UIFont.editorBoldFont().fontName:
            newFont = UIFont.editorFont()
            boldButton.isSelected = false
        case UIFont.editorBoldItalicFont().fontName:
            newFont = UIFont.editorItalicFont()
            boldButton.isSelected = false
        default:
            newFont = UIFont.editorBoldFont()
            boldButton.isSelected = true
        }

        applyFont(newFont)
    }

    func italicButtonTapped() {
        let font = textView.typingAttributes[NSFontAttributeName] as? UIFont
        let fontName = (font ?? UIFont.editorFont()).fontName

        let newFont: UIFont
        switch fontName {
        case UIFont.editorFont().fontName:
            newFont = UIFont.editorItalicFont()
            italicButton.isSelected = true
        case UIFont.editorItalicFont().fontName:
            newFont = UIFont.editorFont()
            italicButton.isSelected = false
        case UIFont.editorBoldFont().fontName:
            newFont = UIFont.editorBoldItalicFont()
            italicButton.isSelected = true
        case UIFont.editorBoldItalicFont().fontName:
            newFont = UIFont.editorBoldFont()
            italicButton.isSelected = false
        default:
            newFont = UIFont.editorItalicFont()
            italicButton.isSelected = true
        }

        applyFont(newFont)
    }

    func applyFont(_ newFont: UIFont) {
        if let selection = textView.selectedTextRange, !selection.isEmpty
        {
            let range = textView.selectedRange
            let currentText = NSMutableAttributedString(attributedString: textView.attributedText)
            let attributes = [NSFontAttributeName: newFont]
            currentText.addAttributes(attributes, range: textView.selectedRange)
            textView.attributedText = currentText
            textView.selectedRange = range

            updateCurrentText(currentText)
        }
        else {
            textView.typingAttributes = ElloAttributedString.attrs([
                NSFontAttributeName: newFont,
            ])
        }
    }

    func linkButtonTapped() {
        var range = textView.selectedRange
        guard range.location != NSNotFound else { return }

        if range.length == 0 {
            range.location -= 1

            var effectiveRange: NSRange? = NSRange(location: 0, length: 0)
            if textView.textStorage.attribute(NSLinkAttributeName, at: range.location, effectiveRange: &effectiveRange!) != nil,
                let effectiveRange = effectiveRange
            {
                range = effectiveRange
            }
        }
        guard range.length > 0 else { return }

        let currentAttrs = textView.textStorage.attributes(at: range.location, effectiveRange: nil)
        if currentAttrs[NSLinkAttributeName] != nil {
            textView.textStorage.removeAttribute(NSLinkAttributeName, range: range)
            textView.textStorage.removeAttribute(NSUnderlineStyleAttributeName, range: range)
            linkButton.isSelected = false
        }
        else {
            requestLinkURL { url in
                guard let url = url else {
                    return
                }

                self.textView.textStorage.addAttributes([
                    NSLinkAttributeName: url,
                    NSUnderlineStyleAttributeName: NSUnderlineStyle.styleSingle.rawValue,
                    ], range: range)
                self.linkButton.isSelected = true
                self.linkButton.isEnabled = true
                self.updateCurrentText(self.textView.textStorage)
            }
        }

        linkButton.isEnabled = textView.selectedRange.length > 0
    }

    func requestLinkURL(_ handler: @escaping (URL?) -> Void) {
        let alertController = AlertViewController()

        let urlAction = AlertAction(title: InterfaceString.Omnibar.EnterURL, style: .urlInput)
        alertController.addAction(urlAction)

        let okCancelAction = AlertAction(title: "", style: .okCancel) { _ in
            if let urlString = alertController.actionInputs.safeValue(0) {
                handler(URL.shorthand(urlString))
            }
        }
        alertController.addAction(okCancelAction)

        delegate?.omnibarPresentController(alertController)
    }

// MARK: Post logic

    func canPost() -> Bool {
        return submitableRegions.any { !$0.isEmpty }
    }

    func hasImage() -> Bool {
        return submitableRegions.any { $0.isImage }
    }

// MARK: Images

    // Notes on UITableView animations: since the modal is used here, the
    // animations only added complicated logic, no visual "bonus".  `reloadData`
    // is the way to go on this one.
    func addImage(_ image: UIImage?, data: Data? = nil, type: String? = nil) {
        guard let image = image else {
            return
        }

        if let region = submitableRegions.last, region.isEmpty {
            let lastIndex = submitableRegions.count - 1
            submitableRegions.remove(at: lastIndex)
        }

        if let data = data, let type = type {
            submitableRegions.append(.imageData(image, data, type))
        }
        else {
            submitableRegions.append(.image(image))
        }
        submitableRegions.append(.text(""))
        editableRegions = generateEditableRegions(submitableRegions)
        reorderableRegions = generateReorderableRegions(submitableRegions)

        regionsTableView.reloadData()
        regionsTableView.scrollToRow(at: IndexPath(row: self.tableViewRegions.count - 1, section: 0), at: .none, animated: true)

        updateButtons()
    }

    func userSetCurrentImageURL(_ imageURL: URL) {
        _ = PINRemoteImageManager.shared().downloadImage(with: imageURL, options: []) { result in
            if let image = result.image {
                self.addImage(image)
            }
        }
    }

// MARK: Camera / Image Picker

    func cameraButtonTapped() {
        cameraButton.isHidden = true
        textButton.isHidden = false
        stopEditing()

        let status = UIImagePickerController.alreadyDeterminedStatus()
        if let status = status {
            showKeyboardImages(isAuthorized: status == .authorized)
        }
        else {
            UIImagePickerController.requestStatus()
                .thenFinally { status in
                    self.showKeyboardImages(isAuthorized: status == .authorized)
                }
                .ignoreErrors()
        }
    }

    private func resetToImageButton() {
        currentAssets = []
        cameraButton.isHidden = false
        textButton.isHidden = true
        setPhotoAccessoryView(nil)
    }

    func textButtonTapped() {
        resetToImageButton()
    }

    private func showKeyboardImages(isAuthorized: Bool) {
        guard isAuthorized else { return }

        showKeyboardSpinner()
        loadPhotos()
    }

    fileprivate func setPhotoAccessoryView(_ view: UIView?) {
        for subview in photoAccessoryContainer.subviews {
            subview.removeFromSuperview()
        }

        if let view = view {
            photoAccessoryContainer.addSubview(view)
            photoAccessoryContainer.frame.size.height = view.frame.size.height
        }
        else {
            photoAccessoryContainer.frame.size.height = 0
        }
        setNeedsLayout()
    }

    private func showKeyboardSpinner() {
        let spinner = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        spinner.startAnimating()
        let view = UIView(frame: CGRect(x: 0, y: 0, width: frame.width, height: imageContentHeight))
        spinner.center = view.center
        spinner.autoresizingMask = [.flexibleTopMargin, .flexibleBottomMargin, .flexibleLeftMargin, .flexibleRightMargin]
        view.addSubview(spinner)
        view.backgroundColor = UIColor.white.withAlphaComponent(0.5)
        setPhotoAccessoryView(view)
    }

    private func loadPhotos() {
        var assetsInfo: [(Int, PHAsset)] = []
        let (afterAll, done) = afterN {
            assetsInfo.sort { $0.0 < $1.0 }
            let onlyAssets = assetsInfo.map { $0.1 }
            self.createImageViews(assets: onlyAssets)
        }

        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        options.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.image.rawValue)

        let fetchLimit = 200
        options.fetchLimit = fetchLimit

        let requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = false
        requestOptions.deliveryMode = .fastFormat

        let result = PHAsset.fetchAssets(with: options)
        result.enumerateObjects(options: [], using: { asset, index, _ in
            let next = afterAll()
            imageManager.requestImageData(for: asset, options: requestOptions) { data, _, _, _ in
                defer { next() }
                guard data != nil else { return }
                assetsInfo.append((index, asset))
            }
        })
        done()
    }

    private func image(forAsset asset: PHAsset) -> UIImage? {
        let requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = true
        requestOptions.deliveryMode = .fastFormat

        let targetSize = size(forAsset: asset, scale: UIScreen.main.scale)
        var retVal: UIImage?
        if asset.representsBurst {
            imageManager.requestImageData(for: asset, options: requestOptions) { data, _, _, _ in
                retVal = data.flatMap { UIImage(data: $0) }
            }
        }
        else {
            imageManager.requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFill, options: requestOptions) { image, _ in
                retVal = image
            }
        }

        return retVal
    }

    private func size(forAsset asset: PHAsset, scale: CGFloat = 1) -> CGSize {
        let proportion = CGFloat(asset.pixelWidth) / CGFloat(asset.pixelHeight)
        let imageWidth = floor(proportion * imageHeight)
        return CGSize(width: scale * imageWidth, height: scale * imageHeight)
    }

    private func createImageViews(assets: [PHAsset]) {
        let scrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: frame.width, height: imageContentHeight))
        scrollView.backgroundColor = .white
        currentAssets = []

        let extraButtonsSize = CGSize(width: 50, height: imageContentHeight)
        let cameraButton = UIButton()
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        cameraButton.setImage(.camera, imageStyle: .normal, for: .normal)
        cameraButton.frame = CGRect(x: 0, y: 0, width: extraButtonsSize.width, height: extraButtonsSize.height / 2)
        cameraButton.backgroundColor = .white
        cameraButton.addTarget(self, action: #selector(openNativeCameraTapped), for: .touchUpInside)
        scrollView.addSubview(cameraButton)

        let libraryButton = UIButton()
        libraryButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.photoLibrary)
        libraryButton.setImage(.browse, imageStyle: .normal, for: .normal)
        libraryButton.frame = CGRect(x: 0, y: extraButtonsSize.height / 2, width: extraButtonsSize.width, height: extraButtonsSize.height / 2)
        libraryButton.backgroundColor = .white
        libraryButton.addTarget(self, action: #selector(openNativeLibraryTapped), for: .touchUpInside)
        scrollView.addSubview(libraryButton)

        var x: CGFloat = extraButtonsSize.width, y: CGFloat = 1
        for asset in assets {
            guard let image = image(forAsset: asset) else { continue }

            x += imageMargin
            let size = self.size(forAsset: asset)

            let imageButton = UIButton()
            imageButton.setImage(image, for: .normal)
            imageButton.contentMode = .scaleAspectFit
            imageButton.clipsToBounds = true
            imageButton.frame = CGRect(x: x, y: y, width: size.width, height: size.height)
            imageButton.addTarget(self, action: #selector(selectedImage(_:)), for: .touchUpInside)

            currentAssets.append(asset)
            scrollView.addSubview(imageButton)

            x += size.width
        }

        let contentWidth = x + imageMargin
        scrollView.contentSize = CGSize(width: contentWidth, height: imageContentHeight)
        setPhotoAccessoryView(scrollView)
    }

    @objc
    func openNativeCameraTapped() {
        let controller = UIImagePickerController.elloCameraPickerController
        delegate?.omnibarPresentController(controller)
        resetToImageButton()
    }

    @objc
    func openNativeLibraryTapped() {
        let controller = UIImagePickerController.elloPhotoLibraryPickerController
        delegate?.omnibarPresentController(controller)
        resetToImageButton()
    }

    @objc
    private func selectedImage(_ sender: UIButton) {
        guard
            let superview = sender.superview,
            let index = superview.subviews.index(of: sender),
            let asset = currentAssets.safeValue(index)
        else { return }

        stopEditing()
        textButtonTapped()
        AssetsToRegions.processPHAssets([asset]) { imageData in
            for imageDatum in imageData {
                self.addImage(imageDatum.image, data: imageDatum.data, type: imageDatum.contentType)
            }
        }
    }

}
