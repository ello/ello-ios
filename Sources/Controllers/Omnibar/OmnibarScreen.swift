////
///  OmnibarScreen.swift
//

import SnapKit
import SVGKit
import MobileCoreServices
import FLAnimatedImage
import PINRemoteImage
import Photos


private let imageManager = PHCachingImageManager()
private let imageHeight: CGFloat = 150
private let imageMargin: CGFloat = 2
private let imageContentHeight = imageHeight + 2 * imageMargin
private let imageFetchLimit = 25

class OmnibarScreen: Screen, OmnibarScreenProtocol {
    struct Size {
        static let margins = UIEdgeInsets(top: 8, left: 2, bottom: 10, right: 10)
        static let toolbarMargin = UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 0)
        static let toolbarButtonSpacing: CGFloat = 20
        static let additionalBuyPadding: CGFloat = 5
        static let tableTopInset: CGFloat = 22.5
        static let keyboardContainerMargin = UIEdgeInsets(all: 10)
        static let clearCommunityMargin: CGFloat = 15
        static let keyboardContainerSpacing: CGFloat = 10
        static let keyboardButtonsMargin = UIEdgeInsets(top: 13, left: 10, bottom: 13, right: 10)
        static let keyboardButtonSize = CGSize(width: 40, height: 40)
        static let keyboardButtonSpacing: CGFloat = 5
    }

    class func canEditRegions(_ regions: [Regionable]?) -> Bool {
        if let regions = regions {
            return regions.count > 0 && regions.all { region in
                return region is TextRegion || region is ImageRegion
            }
        }
        return false
    }

    enum CommunityPickerEditability {
        case editable
        case visible
        case hidden
    }

    weak var delegate: OmnibarScreenDelegate?

    var isComment: Bool = false {
        didSet { updateButtons() }
    }
    var isArtistInviteSubmission: Bool = false {
        didSet { updateButtons() }
    }
    var isEditing = false
    var isReordering = false
    var communityPickerEditability: CommunityPickerEditability = .editable {
        didSet { updateChooseCommunityButton() }
    }
    var chosenCategory: Category? {
        didSet { updateChooseCommunityButton() }
    }

    var isInteractionEnabled: Bool = true {
        didSet {
            isUserInteractionEnabled = isInteractionEnabled
            boldButton.isUserInteractionEnabled = isInteractionEnabled
            italicButton.isUserInteractionEnabled = isInteractionEnabled
            linkButton.isUserInteractionEnabled = isInteractionEnabled
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
        if isReordering {
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
            submitButton.title = submitTitle
        }
    }

    var title: String = "" {
        didSet {
            navigationBar.title = title
        }
    }

    var canGoBack: Bool = false {
        didSet {
            toolbarPinToNavConstraint.set(isActivated: canGoBack)
            toolbarPinToTopConstraint.set(isActivated: !canGoBack)
            navigationBar.isVisible = canGoBack
            statusBar.isHidden = canGoBack

            setNeedsLayout()
        }
    }

    private var toolbarPinToTopConstraint: Constraint!
    private var toolbarPinToNavConstraint: Constraint!

    var currentAssets: [PHAsset] = []
    var imageButtons: [UIButton] = []

    var autoCompleteVC = AutoCompleteViewController()

    let statusBar = StatusBar()
    let navigationBar = ElloNavigationBar()

    private let toolbarContainer = Container()
    private let cancelButton = UIButton()
    private let buyButton = UIButton()
    private let reorderButton = UIButton()
    private let addImageButton = UIButton()
    private let cancelImageButton = UIButton()

    let photoAccessoryContainer = Container()
    let imagesScrollView = UIScrollView()
    let nativeCameraButton = UIButton()
    let nativeLibraryButton = UIButton()
    let nativeAdditionalImagesButton = UIButton()

    private let keyboardButtonsEffect = UIVisualEffectView()
    private var keyboardButtonsContainer: UIView { return keyboardButtonsEffect.contentView }
    let boldButton = StyledButton(style: .boldButton)
    let italicButton = StyledButton(style: .italicButton)
    let linkButton = StyledButton(style: .linkButton)
    private let chooseCommunityButton = StyledButton(style: .roundedBlackOutline)
    private let currentCommunityButton = UIButton()
    private let currentCommunityLabel = StyledLabel(style: .chosenCommunityButton)
    private let clearCommunityButton = UIButton()
    private let submitButton = StyledButton(style: .green)
    private var styleButtonsVisibleConstraint: Constraint!
    private var styleButtonsHiddenConstraint: Constraint!
    private var communityButtonVisibleConstraint: Constraint!
    private var communityButtonsStackedConstraint: Constraint!
    private var communityButtonHiddenConstraint: Constraint!

    let regionsTableView = UITableView()
    private let textEditingControl = UIControl()
    let textScrollView = UIScrollView()
    let textContainer = Container()
    let textView: UITextView

    var autoCompleteContainer = Container()
    var autoCompleteThrottle = debounce(0.4)
    var autoCompleteShowing = false

    private var contentSizeObservation: NSKeyValueObservation?

    required init(frame: CGRect) {
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
        setupImageViews()

        contentSizeObservation = regionsTableView.observe(\UITableView.contentSize) { [weak self] tableView, change in
            guard let `self` = self else { return }
            let contentSize = tableView.contentSize
            let regionsTableView = self.regionsTableView

            let contentHeight: CGFloat = ceil(contentSize.height) + regionsTableView.contentInset.bottom
            let height: CGFloat = max(0, regionsTableView.frame.height - contentHeight)
            let y = regionsTableView.frame.height - height - regionsTableView.contentInset.bottom
            self.textEditingControl.frame = CGRect(
                x: 0,
                y: y,
                width: self.frame.width,
                height: height
            )
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didMoveToWindow() {
        if window == nil, photoAccessoryContainer.superview != nil {
            photoAccessoryContainer.removeFromSuperview()
        }
        else if let window = window, photoAccessoryContainer.window != window {
            window.addSubview(photoAccessoryContainer)
        }
    }

    private func setupAutoComplete() {
        autoCompleteVC.view.frame = autoCompleteContainer.bounds
        autoCompleteVC.delegate = self
        autoCompleteContainer.addSubview(autoCompleteVC.view)
    }

    private func setupNavigationBar() {
        navigationBar.leftItems = [.back]
        addSubview(navigationBar)
        navigationBar.snp.makeConstraints { make in
            make.leading.trailing.top.equalTo(self)
            make.height.equalTo(ElloNavigationBar.Size.height)
        }

        addSubview(statusBar)
        statusBar.snp.makeConstraints { make in
            make.leading.trailing.top.equalTo(self)
        }
    }

    // buttons that make up the "toolbar"
    private func setupToolbarButtons() {
        cancelButton.contentEdgeInsets = UIEdgeInsets(tops: 4, sides: 9.5)
        cancelButton.setImages(.x, style: .selected)
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)

        buyButton.contentEdgeInsets = UIEdgeInsets(top: 4, left: 7, bottom: 4, right: 7)
        buyButton.adjustsImageWhenDisabled = false
        buyButton.adjustsImageWhenHighlighted = false
        buyButton.setImages(.addBuyButton, style: .selected)
        buyButton.setImage(.addBuyButton, imageStyle: .disabled, for: .disabled)
        buyButton.isEnabled = false
        buyButton.addTarget(self, action: #selector(buyButtonTapped), for: .touchUpInside)

        reorderButton.contentEdgeInsets = UIEdgeInsets(tops: 4, sides: 9.5)
        reorderButton.setImages(.reorder, style: .selected)
        reorderButton.addTarget(self, action: #selector(toggleReorderingTable), for: .touchUpInside)
        reorderButton.isEnabled = false

        addImageButton.contentEdgeInsets = UIEdgeInsets(tops: 4, sides: 3.5)
        addImageButton.setImages(.photoPicker, style: .selected)
        addImageButton.addTarget(self, action: #selector(addImageButtonTapped), for: .touchUpInside)
        addImageButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.photoLibrary)

        cancelImageButton.setImages(.textPicker, style: .selected)
        cancelImageButton.addTarget(self, action: #selector(cancelImageButtonTapped), for: .touchUpInside)
        cancelImageButton.isHidden = true

        let line = Line(color: .greyF2)

        addSubview(toolbarContainer)
        toolbarContainer.snp.makeConstraints { make in
            make.leading.trailing.equalTo(self)
            toolbarPinToTopConstraint = make.top.equalTo(self).offset(StatusBar.Size.height + Size.margins.top).constraint
            toolbarPinToNavConstraint = make.top.equalTo(navigationBar.snp.bottom).constraint
        }
        toolbarContainer.addSubview(cancelButton)
        toolbarContainer.addSubview(buyButton)
        toolbarContainer.addSubview(reorderButton)
        toolbarContainer.addSubview(addImageButton)
        toolbarContainer.addSubview(cancelImageButton)
        toolbarContainer.addSubview(line)

        cancelButton.snp.makeConstraints { make in
            make.leading.equalTo(toolbarContainer).inset(Size.margins)
            make.top.bottom.equalTo(toolbarContainer).inset(Size.toolbarMargin)
        }
        addImageButton.snp.makeConstraints { make in
            make.trailing.equalTo(toolbarContainer).inset(Size.margins)
            make.top.bottom.equalTo(toolbarContainer).inset(Size.toolbarMargin)
        }
        reorderButton.snp.makeConstraints { make in
            make.top.bottom.equalTo(toolbarContainer).inset(Size.toolbarMargin)
            make.trailing.equalTo(addImageButton.snp.leading).offset(-Size.toolbarButtonSpacing)
        }
        buyButton.snp.makeConstraints { make in
            make.top.bottom.equalTo(toolbarContainer).inset(Size.toolbarMargin)
            make.trailing.equalTo(reorderButton.snp.leading).offset(-Size.toolbarButtonSpacing - Size.additionalBuyPadding)
        }
        cancelImageButton.snp.makeConstraints { make in
            make.edges.equalTo(addImageButton)
        }
        line.snp.makeConstraints { make in
            make.leading.trailing.equalTo(toolbarContainer)
            make.bottom.equalTo(toolbarContainer)
        }
    }

    // The textContainer is the outer gray background.  The text view is
    // configured to fill that container (only the container and the text view
    // insets are modified in layoutSubviews)
    private func setupTableViews() {
        if #available(iOS 11.0, *) {
            regionsTableView.contentInsetAdjustmentBehavior = .never
        }
        regionsTableView.dataSource = self
        regionsTableView.delegate = self
        regionsTableView.separatorStyle = .none
        regionsTableView.register(OmnibarTextCell.self, forCellReuseIdentifier: OmnibarTextCell.reuseIdentifier)
        regionsTableView.register(OmnibarImageCell.self, forCellReuseIdentifier: OmnibarImageCell.reuseIdentifier)
        regionsTableView.register(OmnibarImageDownloadCell.self, forCellReuseIdentifier: OmnibarImageDownloadCell.reuseIdentifier)
        regionsTableView.register(UITableViewCell.self, forCellReuseIdentifier: OmnibarRegion.OmnibarSpacerCell)
        regionsTableView.register(OmnibarErrorCell.self, forCellReuseIdentifier: OmnibarErrorCell.reuseIdentifier)
        regionsTableView.contentInset.top = Size.tableTopInset
        regionsTableView.estimatedRowHeight = 0
        regionsTableView.estimatedSectionHeaderHeight = 0
        regionsTableView.estimatedSectionFooterHeight = 0
        addSubview(regionsTableView)

        regionsTableView.snp.makeConstraints { make in
            make.leading.trailing.equalTo(self)
            make.top.equalTo(toolbarContainer.snp.bottom)
            make.bottom.equalTo(self)
        }

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
        addSubview(textScrollView)

        textScrollView.snp.makeConstraints { make in
            make.edges.equalTo(regionsTableView)
        }

        textScrollView.addSubview(textContainer)
        textScrollView.addSubview(textView)
        textScrollView.isHidden = true

        textView.clipsToBounds = false
        textView.isEditable = true
        textView.allowsEditingTextAttributes = false
        textView.isSelectable = true
        textView.delegate = self
        textView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        textView.spellCheckingType = .yes
        textView.autocorrectionType = .yes
    }

    private func setupKeyboardViews() {
        keyboardButtonsEffect.effect = UIBlurEffect(style: .light)
        addSubview(keyboardButtonsEffect)
        keyboardButtonsEffect.snp.makeConstraints { make in
            make.leading.trailing.equalTo(self)
            make.bottom.equalTo(keyboardAnchor.snp.top)
            make.bottom.lessThanOrEqualTo(self).offset(-ElloTabBar.Size.height)
        }

        boldButton.addTarget(self, action: #selector(boldButtonTapped), for: .touchUpInside)
        boldButton.title = "B"

        italicButton.addTarget(self, action: #selector(italicButtonTapped), for: .touchUpInside)
        italicButton.title = "I"

        linkButton.addTarget(self, action: #selector(linkButtonTapped), for: .touchUpInside)
        linkButton.isEnabled = false
        linkButton.setImage(.link, imageStyle: .white, for: .normal)
        linkButton.setImage(.breakLink, imageStyle: .white, for: .selected)

        currentCommunityButton.imageView?.contentMode = .scaleAspectFill
        currentCommunityButton.clipsToBounds = true
        currentCommunityButton.layer.cornerRadius = 5

        currentCommunityLabel.textAlignment = .center
        if let svgkImage = InterfaceImage.x.whiteSVGK {
            svgkImage.size = CGSize(width: 20, height: 20)
            clearCommunityButton.setImage(InterfaceImage.toUIImage(svgkImage), for: .normal)
            clearCommunityButton.contentMode = .center
        }
        chooseCommunityButton.addTarget(self, action: #selector(chooseCommunityButtonTapped), for: .touchUpInside)
        currentCommunityButton.addTarget(self, action: #selector(currentCommunityButtonTapped), for: .touchUpInside)
        clearCommunityButton.addTarget(self, action: #selector(clearCommunityButtonTapped), for: .touchUpInside)

        submitButton.setImage(.pencil, imageStyle: .white, for: .normal)
        submitButton.setImage(.pencil, imageStyle: .selected, for: .highlighted)
        submitButton.title = InterfaceString.Omnibar.CreatePostButton
        submitButton.contentEdgeInsets.left = -5
        submitButton.imageEdgeInsets.right = 5
        submitButton.addTarget(self, action: #selector(submitButtonTapped), for: .touchUpInside)

        keyboardButtonsContainer.addSubview(chooseCommunityButton)
        keyboardButtonsContainer.addSubview(currentCommunityButton)
        currentCommunityButton.addSubview(currentCommunityLabel)
        keyboardButtonsContainer.addSubview(clearCommunityButton)
        keyboardButtonsContainer.addSubview(boldButton)
        keyboardButtonsContainer.addSubview(italicButton)
        keyboardButtonsContainer.addSubview(linkButton)
        keyboardButtonsContainer.addSubview(submitButton)

        [boldButton, italicButton, linkButton].eachPair { prevButton, button, isLast in
            button.snp.makeConstraints { make in
                make.bottom.equalTo(keyboardButtonsContainer).inset(Size.keyboardButtonsMargin)
                make.size.equalTo(Size.keyboardButtonSize)

                if isLast {
                    make.trailing.equalTo(submitButton.snp.leading).offset(-Size.keyboardButtonsMargin.right)
                    styleButtonsHiddenConstraint = make.trailing.equalTo(keyboardButtonsContainer.snp.leading).constraint
                }

                if let prevButton = prevButton {
                    make.leading.equalTo(prevButton.snp.trailing).offset(Size.keyboardButtonSpacing)
                }
                else {
                    styleButtonsVisibleConstraint = make.leading.equalTo(keyboardButtonsContainer).inset(Size.keyboardButtonsMargin).constraint
                }
            }
        }
        styleButtonsVisibleConstraint.deactivate()

        chooseCommunityButton.snp.makeConstraints { make in
            communityButtonVisibleConstraint = make.top.equalTo(keyboardButtonsContainer).inset(Size.keyboardContainerMargin).constraint
            make.leading.trailing.equalTo(keyboardButtonsContainer).inset(Size.keyboardContainerMargin)
            make.height.equalTo(Size.keyboardButtonSize.height)
        }

        currentCommunityButton.snp.makeConstraints { make in
            make.edges.equalTo(chooseCommunityButton)
        }

        clearCommunityButton.snp.makeConstraints { make in
            make.top.bottom.trailing.equalTo(currentCommunityButton)
            make.width.equalTo(currentCommunityButton.snp.height)
        }

        currentCommunityLabel.snp.makeConstraints { make in
            make.edges.equalTo(currentCommunityButton)
        }

        submitButton.snp.makeConstraints { make in
            communityButtonHiddenConstraint = make.top.equalTo(keyboardButtonsContainer).inset(Size.keyboardContainerMargin).constraint
            communityButtonsStackedConstraint = make.top.equalTo(chooseCommunityButton.snp.bottom).offset(Size.keyboardContainerSpacing).constraint
            make.bottom.trailing.equalTo(keyboardButtonsContainer).inset(Size.keyboardContainerMargin)
            make.height.equalTo(Size.keyboardButtonSize.height)
        }

        updateChooseCommunityButton()
    }

    private func updateChooseCommunityButton() {
        let communityPickerVisible = communityPickerEditability != .hidden
        let communityPickerEditable = communityPickerEditability == .editable
        communityButtonVisibleConstraint.set(isActivated: communityPickerVisible)
        communityButtonsStackedConstraint.set(isActivated: communityPickerVisible)
        communityButtonHiddenConstraint.set(isActivated: !communityPickerVisible)
        currentCommunityButton.isEnabled = communityPickerEditable
        chooseCommunityButton.isEnabled = communityPickerEditable
        clearCommunityButton.isEnabled = communityPickerEditable

        if let chosenCategory = chosenCategory {
            chooseCommunityButton.isHidden = true
            clearCommunityButton.isVisible = communityPickerEditable
            currentCommunityButton.isVisible = true
            currentCommunityButton.pin_setImage(from: chosenCategory.tileURL)
            currentCommunityLabel.text = chosenCategory.name
        }
        else {
            chooseCommunityButton.isVisible = communityPickerVisible
            clearCommunityButton.isHidden = true
            currentCommunityButton.isHidden = true
            chooseCommunityButton.title = InterfaceString.Omnibar.ChooseCommunity
        }
    }

    private func setupImageViews() {
        imagesScrollView.backgroundColor = .white

        nativeCameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        nativeCameraButton.setImage(.camera, imageStyle: .selected, for: .normal)
        nativeCameraButton.setImage(.camera, imageStyle: .selected, for: .selected)
        nativeCameraButton.backgroundColor = .greyF2

        nativeLibraryButton.setImage(.library, imageStyle: .selected, for: .normal)
        nativeLibraryButton.setImage(.library, imageStyle: .selected, for: .selected)
        nativeLibraryButton.backgroundColor = .greyF2

        let extraButtonsSize = CGSize(width: 60, height: (imageContentHeight - 3 * imageMargin) / 2)
        nativeCameraButton.frame = CGRect(x: imageMargin, y: imageMargin, width: extraButtonsSize.width, height: extraButtonsSize.height)
        nativeCameraButton.addTarget(self, action: #selector(openNativeCameraTapped), for: .touchUpInside)
        imagesScrollView.addSubview(nativeCameraButton)

        nativeLibraryButton.frame = CGRect(x: imageMargin, y: nativeCameraButton.frame.maxY + imageMargin, width: extraButtonsSize.width, height: extraButtonsSize.height)
        nativeLibraryButton.addTarget(self, action: #selector(openNativeLibraryTapped), for: .touchUpInside)
        imagesScrollView.addSubview(nativeLibraryButton)

        nativeAdditionalImagesButton.setImage(.dots, imageStyle: .normal, for: .normal)
        nativeAdditionalImagesButton.backgroundColor = .white
        nativeAdditionalImagesButton.addTarget(self, action: #selector(openNativeLibraryTapped), for: .touchUpInside)
        nativeAdditionalImagesButton.frame = CGRect(x: 0, y: imageMargin, width: extraButtonsSize.width, height: extraButtonsSize.height * 2 + imageMargin)
        imagesScrollView.addSubview(nativeAdditionalImagesButton)
    }

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

    func resetAfterSuccessfulPost() {
        resetEditor()
    }

    // called on a user action that should resign the keyboard
    @objc
    func stopEditing() {
        resignKeyboard()
        editingCanceled()
        toggleStylingButtons(visible: false)
    }

    // called whenever the keyboard is dismissed, by user or system
    private func editingCanceled() {
        textScrollView.isHidden = true
        textScrollView.scrollsToTop = false
        regionsTableView.scrollsToTop = true
        currentTextPath = nil
    }

    private func updateCurrentText(_ text: NSAttributedString) {
        if let path = currentTextPath {
            updateText(text, atPath: path)
        }
    }

    func updateText(_ text: NSAttributedString, atPath path: IndexPath) {
        guard
            let (_index, _) = editableRegions.safeValue(path.row),
            let index = _index
        else { return }

        let newRegion: OmnibarRegion = .attributedText(text)
        submitableRegions[index] = newRegion
        editableRegions[path.row] = (index, newRegion)

        regionsTableView.beginUpdates()
        regionsTableView.reloadRows(at: [path], with: .automatic)
        regionsTableView.endUpdates()
        updateEditingAtPath(path, scrollPosition: .bottom)
    }

    func startEditingAtPath(_ path: IndexPath) {
        guard let (_, region) = tableViewRegions.safeValue(path.row), region.isText else { return }

        currentTextPath = path
        textScrollView.isVisible = true
        textScrollView.contentOffset = regionsTableView.contentOffset
        textScrollView.contentInset = regionsTableView.contentInset
        textScrollView.scrollIndicatorInsets = regionsTableView.scrollIndicatorInsets
        textScrollView.scrollsToTop = true
        regionsTableView.scrollsToTop = false
        textView.attributedText = region.text
        updateEditingAtPath(path)
        textViewDidChangeSelection(textView)
    }

    func updateEditingAtPath(_ path: IndexPath, scrollPosition: UITableView.ScrollPosition = .middle) {
        guard let cell = regionsTableView.cellForRow(at: path) else { return }

        let rect = cell.frame//regionsTableView.rectForRow(at: path)
        textScrollView.contentSize = regionsTableView.contentSize
        textView.frame = OmnibarTextCell.boundsForTextView(rect)
        textContainer.frame = textView.frame.grow(all: 10)
        _ = textView.becomeFirstResponder()
    }

    @objc
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

    @objc
    func toggleReorderingTable() {
        reorderingTable(!isReordering)
    }

    private func generateReorderableRegions(_ regions: [OmnibarRegion]) -> [IndexedRegion] {
        let nonEmptyRegions = regions.filter { region in
            return region.isEditable && !region.isEmpty
        }
        return nonEmptyRegions.map { (region: OmnibarRegion) -> IndexedRegion in
            return (nil, region)
        }
    }

    private func convertReorderableRegions(_ reorderableRegions: [IndexedRegion]) -> [OmnibarRegion] {
        var regions = [OmnibarRegion]()
        var buffer = NSAttributedString(defaults: "")
        var lastRegionIsText = false
        for (_, region) in reorderableRegions {
            switch region {
            case let .attributedText(text):
                buffer = buffer.joinWithNewlines(text)
                lastRegionIsText = true
            case .imageData, .image:
                if !buffer.string.isEmpty {
                    regions.append(.attributedText(buffer))
                }
                regions.append(region)
                buffer = NSAttributedString(defaults: "")
                lastRegionIsText = false
            default: break
            }
        }
        if !buffer.string.isEmpty {
            regions.append(.attributedText(buffer))
        }
        else if !lastRegionIsText {
            regions.append(.text(""))
        }
        return regions
    }

    func reorderingTable(_ isReordering: Bool) {
        if isReordering {
            reorderableRegions = generateReorderableRegions(submitableRegions)
            if reorderableRegions.count == 0 { return }

            stopEditing()
            reorderButton.setImages(.check)
            reorderButton.isSelected = true
        }
        else {
            submitableRegions = convertReorderableRegions(reorderableRegions)
            editableRegions = generateEditableRegions(submitableRegions)
            reorderButton.setImages(.reorder, style: .selected)
            reorderButton.isSelected = false
        }

        self.isReordering = isReordering
        regionsTableView.setEditing(isReordering, animated: true)
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
        if !Keyboard.shared.isAdjusting {
            resetToImageButton()
        }

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

        var bottomInset = Keyboard.shared.keyboardBottomInset(inView: self)

        if bottomInset == 0 {
            bottomInset = ElloTabBar.Size.height
        }

        let keyboardContainerHeight: CGFloat
        if communityPickerEditability == .hidden {
            keyboardContainerHeight = Size.keyboardContainerMargin.tops + Size.keyboardButtonSize.height
        }
        else {
            keyboardContainerHeight = Size.keyboardContainerMargin.tops + 2 * Size.keyboardButtonSize.height + Size.keyboardContainerSpacing
        }
        bottomInset += keyboardContainerHeight

        regionsTableView.contentInset.bottom = bottomInset
        regionsTableView.scrollIndicatorInsets.bottom = bottomInset
        synchronizeScrollViews()

        photoAccessoryContainer.frame.size.width = frame.width
        photoAccessoryContainer.frame.origin.x = 0
        photoAccessoryContainer.frame.origin.y = frame.height - Keyboard.shared.keyboardBottomInset(inView: self) - photoAccessoryContainer.frame.height
    }

    func synchronizeScrollViews() {
        textScrollView.contentSize = regionsTableView.contentSize
        textScrollView.contentInset = regionsTableView.contentInset
        textScrollView.scrollIndicatorInsets = regionsTableView.scrollIndicatorInsets
    }

    private func resetEditor() {
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

        let canSubmit = !isReordering && canPost()
        submitButton.isEnabled = canSubmit

        let canAddBuyButtonLink = !isReordering && hasImage()
        buyButton.isEnabled = canAddBuyButtonLink
        buyButton.isHidden = isComment || isArtistInviteSubmission
        reorderButton.isEnabled = submitableRegions.count > 1

        if buyButtonURL == nil {
            buyButton.setImages(.addBuyButton, style: .selected)
        }
        else {
            buyButton.setImages(.setBuyButton)
        }
    }

// MARK: Button Actions

    @objc
    func cancelButtonTapped() {
        if isReordering {
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
            delegate?.cancelTapped()
        }
    }

    @objc
    func submitButtonTapped() {
        guard canPost() else { return }

        stopEditing()
        delegate?.submitted(regions: submitableRegions, buyButtonURL: buyButtonURL)
    }

    @objc
    func chooseCommunityButtonTapped() {
        delegate?.chooseCommunityTapped()
    }

    @objc
    func currentCommunityButtonTapped() {
        delegate?.chooseCommunityTapped()
    }

    @objc
    func clearCommunityButtonTapped() {
        delegate?.clearCommunityTapped()
    }

    @objc
    func buyButtonTapped() {
        let vc = BuyButtonLinkViewController(buyButtonURL: buyButtonURL)
        vc.delegate = self
        delegate?.omnibarPresentController(vc)
    }

    @objc
    func boldButtonTapped() {
        let font = textView.typingAttributes[.font] as? UIFont
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

    @objc
    func italicButtonTapped() {
        let font = textView.typingAttributes[.font] as? UIFont
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
            currentText.addAttributes([.font: newFont], range: textView.selectedRange)
            textView.attributedText = currentText
            textView.selectedRange = range

            updateCurrentText(currentText)
        }
        else {
            textView.typingAttributes = NSAttributedString.defaultAttrs([
                .font: newFont,
            ])
        }
    }

    @objc
    func linkButtonTapped() {
        var range = textView.selectedRange
        guard range.location != NSNotFound else { return }

        if range.length == 0 {
            range.location -= 1

            var effectiveRange: NSRange? = NSRange(location: 0, length: 0)
            if textView.textStorage.attribute(.link, at: range.location, effectiveRange: &effectiveRange!) != nil,
                let effectiveRange = effectiveRange
            {
                range = effectiveRange
            }
        }
        guard range.length > 0 else { return }

        let currentAttrs = textView.textStorage.attributes(at: range.location, effectiveRange: nil)
        if currentAttrs[.link] != nil {
            textView.textStorage.removeAttribute(.link, range: range)
            textView.textStorage.removeAttribute(.underlineStyle, range: range)
            linkButton.isSelected = false
        }
        else {
            requestLinkURL { url in
                guard let url = url else {
                    return
                }

                self.textView.textStorage.addAttributes([
                    .link: url,
                    .underlineStyle: NSUnderlineStyle.single.rawValue,
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

        let okCancelAction = AlertAction(style: .okCancel) { _ in
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
        PINRemoteImageManager.shared().downloadImage(with: imageURL, options: []) { result in
            if let image = result.image {
                self.addImage(image)
            }
        }
    }

// MARK: Camera / Image Picker

    @objc
    func addImageButtonTapped() {
        addImageButton.isHidden = true
        cancelImageButton.isVisible = true
        keyboardButtonsEffect.isHidden = true
        stopEditing()

        UIImagePickerController.requestStatus()
            .done { status in
                self.showKeyboardImages(isAuthorized: status == .authorized)
            }
            .ignoreErrors()
    }

    private func resetToImageButton() {
        currentAssets = []
        addImageButton.isVisible = true
        cancelImageButton.isHidden = true
        keyboardButtonsEffect.isVisible = true
        setPhotoAccessoryView(nil)
    }

    @objc
    func cancelImageButtonTapped() {
        resetToImageButton()
    }

    func toggleStylingButtons(visible: Bool) {
        styleButtonsVisibleConstraint.set(isActivated: visible)
        styleButtonsHiddenConstraint.set(isActivated: !visible)

        elloAnimate {
            self.layoutIfNeeded()
        }
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
            view.autoresizingMask = [.flexibleWidth, .flexibleTopMargin]
        }
        else {
            photoAccessoryContainer.frame.size.height = 0
        }
        setNeedsLayout()
    }

    private func showKeyboardSpinner() {
        let spinner = UIActivityIndicatorView(style: .gray)
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
        options.fetchLimit = imageFetchLimit + 1

        let requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = false
        requestOptions.deliveryMode = .fastFormat

        Globals.fetchAssets(with: options) { asset, index in
            let next = afterAll()
            imageManager.requestImageData(for: asset, options: requestOptions) { data, _, _, _ in
                defer { next() }
                guard data != nil else { return }
                assetsInfo.append((index, asset))
            }
        }
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
        guard assets.count > 0 else {
            setPhotoAccessoryView(nil)
            return
        }

        imagesScrollView.frame = CGRect(x: 0, y: 0, width: frame.width, height: imageContentHeight)
        currentAssets = []

        for view in imageButtons {
            view.removeFromSuperview()
        }

        imageButtons = []
        var x: CGFloat = nativeCameraButton.frame.maxX, y: CGFloat = imageMargin
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
            imageButtons.append(imageButton)
            imagesScrollView.addSubview(imageButton)

            x += size.width
        }

        if assets.count > imageFetchLimit {
            nativeAdditionalImagesButton.isVisible = true
            nativeAdditionalImagesButton.frame.origin.x = x

            x += nativeAdditionalImagesButton.frame.width
        }
        else if nativeAdditionalImagesButton.superview != nil {
            nativeAdditionalImagesButton.isHidden = true
        }

        let contentWidth = x + imageMargin
        imagesScrollView.contentSize = CGSize(width: contentWidth, height: imageContentHeight)
        setPhotoAccessoryView(imagesScrollView)
    }

    @objc
    func openNativeCameraTapped() {
        let controller = UIImagePickerController.elloCameraPickerController
        controller.delegate = self
        delegate?.omnibarPresentController(controller)
        resetToImageButton()
    }

    @objc
    func openNativeLibraryTapped() {
        let controller = UIImagePickerController.elloPhotoLibraryPickerController
        controller.delegate = self
        delegate?.omnibarPresentController(controller)
        resetToImageButton()
    }

    @objc
    private func selectedImage(_ sender: UIButton) {
        guard
            let index = imageButtons.firstIndex(of: sender),
            let asset = currentAssets.safeValue(index)
        else { return }

        stopEditing()
        cancelImageButtonTapped()
        AssetsToRegions.processPHAssets([asset]) { imageData in
            for imageDatum in imageData {
                self.addImage(imageDatum.image, data: imageDatum.data, type: imageDatum.contentType)
            }
        }
    }

}

extension OmnibarScreen: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        guard
            let image = info[.originalImage] as? UIImage
        else {
            delegate?.omnibarDismissController()
            return
        }

        if let url = info[.referenceURL] as? URL,
            let asset = PHAsset.fetchAssets(withALAssetURLs: [url], options: nil).firstObject
        {
            AssetsToRegions.processPHAssets([asset]) { imageData in
                for imageDatum in imageData {
                    self.addImage(imageDatum.image, data: imageDatum.data, type: imageDatum.contentType)
                }
            }
            delegate?.omnibarDismissController()
        }
        else {
            image.copyWithCorrectOrientationAndSize { image in
                if let image = image {
                    self.addImage(image, data: nil, type: nil)
                }

                self.delegate?.omnibarDismissController()
            }
        }
    }

    func imagePickerControllerDidCancel(_ controller: UIImagePickerController) {
        delegate?.omnibarDismissController()
    }
}

extension OmnibarScreen: HasBackButton {
    func backButtonTapped() {
        delegate?.cancelTapped()
    }
}

extension StyledButton.Style {
    static let boldButton = StyledButton.Style(
        backgroundColor: .greyE5, selectedBackgroundColor: .black,
        titleColor: .white,
        font: .defaultBoldFont(),
        cornerRadius: .pill
        )
    static let italicButton = StyledButton.Style(
        backgroundColor: .greyE5, selectedBackgroundColor: .black,
        titleColor: .white,
        font: .defaultItalicFont(),
        cornerRadius: .pill
        )
    static let linkButton = StyledButton.Style(
        backgroundColor: .greyE5, selectedBackgroundColor: .black,
        titleColor: .white,
        cornerRadius: .pill
        )
}

extension OmnibarScreen {
    class Specs {
        weak var target: OmnibarScreen!
        var addImageButton: UIButton! { return target.addImageButton }
        var cancelImageButton: UIButton! { return target.cancelImageButton }
        var submitButton: UIButton! { return target.submitButton }
        var buyButton: UIButton! { return target.buyButton }
        var cancelButton: UIButton! { return target.cancelButton }
        var toolbarContainer: Container! { return target.toolbarContainer }

        init(_ target: OmnibarScreen) {
            self.target = target
        }
    }

    public func specs() -> Specs {
        return Specs(self)
    }
}
