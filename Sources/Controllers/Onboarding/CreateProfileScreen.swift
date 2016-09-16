////
///  CreateProfileScreen.swift
//

import Photos
import SnapKit
import ImagePickerSheetController


public class CreateProfileScreen: Screen, CreateProfileScreenProtocol {
    public enum ImageTarget {
        case CoverImage
        case Avatar
    }

    struct Size {
        static let insets: CGFloat = 10
        static let headerHeight: CGFloat = 77
        static let promptOffset: CGFloat = 10
        static let avatarOffset: CGFloat = 20
        static let fieldsTopOffset: CGFloat = 40
        static let fieldsInnerOffset: CGFloat = 20
        static let avatarHeight: CGFloat = 220
        static let uploadSize = CGSize(width: 130, height: 40)
    }

    weak var delegate: CreateProfileDelegate?
    var name: String? {
        get { return nameTextView.text }
        set {
            nameTextView.text = newValue
            nameTextView.validationState = (newValue?.isEmpty == false) ? .OKSmall : .None
        }
    }
    var bio: String? {
        get { return bioTextView.text }
        set {
            bioTextView.text = newValue
            bioTextView.validationState = (newValue?.isEmpty == false) ? .OKSmall : .None
        }
    }
    var links: String? {
        get { return linksTextView.text }
        set {
            linksTextView.text = newValue
            linksTextView.validationState = (newValue?.isEmpty == false) ? .OKSmall : .None
        }
    }
    var linksValid: Bool? = nil {
        didSet {
            let newState: ValidationState
            switch linksValid {
            case .None: newState = .None
            case .Some(true): newState = .OKSmall
            case .Some(false): newState = .Error
            }
            linksTextView.validationState = newState
        }
    }
    var coverImage: ImageRegionData? {
        didSet {
            setImage(coverImage, target: .CoverImage, updateDelegate: false)
        }
    }
    var avatarImage: ImageRegionData? {
        didSet {
            setImage(avatarImage, target: .Avatar, updateDelegate: false)
        }
    }

    private var uploading: ImageTarget?

    private let scrollView = UIScrollView()
    private var prevOffset: CGPoint = .zero
    private var scrollViewWidthConstraint: Constraint!
    private let headerLabel = UILabel()

    private let coverImageView = FLAnimatedImageView()
    private let uploadCoverImageButton = StyledButton(style: .Green)
    private let uploadCoverImagePrompt = UILabel()

    private let avatarImageView = FLAnimatedImageView()
    private let uploadAvatarButton = StyledButton(style: .Green)
    private let uploadAvatarPrompt = UILabel()

    private let nameTextView = ClearTextView()
    private let bioTextView = ClearTextView()
    private let linksTextView = ClearTextView()

    override func style() {
        headerLabel.numberOfLines = 0

        coverImageView.backgroundColor = .greyE5()
        coverImageView.contentMode = .ScaleAspectFill
        coverImageView.clipsToBounds = true
        uploadCoverImagePrompt.textAlignment = .Center
        uploadCoverImagePrompt.textColor = .greyA()
        uploadCoverImagePrompt.font = UIFont.defaultFont(12)
        uploadCoverImagePrompt.numberOfLines = 2

        avatarImageView.backgroundColor = .greyE5()
        avatarImageView.clipsToBounds = true
        avatarImageView.contentMode = .Center
        avatarImageView.image = InterfaceImage.ElloGrayLineLogo.normalImage
        uploadAvatarPrompt.textAlignment = .Center
        uploadAvatarPrompt.textColor = .greyA()
        uploadAvatarPrompt.font = UIFont.defaultFont(12)
        uploadAvatarPrompt.numberOfLines = 2

        nameTextView.textColor = .blackColor()
        nameTextView.scrollEnabled = false
        nameTextView.lineColor = .greyE5()
        nameTextView.selectedLineColor = .blackColor()
        nameTextView.placeholderColor = .greyC()
        nameTextView.keyboardAppearance = .Dark

        nameTextView.autocapitalizationType = .Words
        nameTextView.autocorrectionType = .No
        nameTextView.spellCheckingType = .No

        bioTextView.textColor = .blackColor()
        bioTextView.scrollEnabled = false
        bioTextView.lineColor = .greyE5()
        bioTextView.selectedLineColor = .blackColor()
        bioTextView.placeholderColor = .greyC()
        bioTextView.keyboardAppearance = .Dark

        linksTextView.textColor = .blackColor()
        linksTextView.scrollEnabled = false
        linksTextView.lineColor = .greyE5()
        linksTextView.selectedLineColor = .blackColor()
        linksTextView.placeholderColor = .greyC()

        linksTextView.autocapitalizationType = .None
        linksTextView.autocorrectionType = .No
        linksTextView.enablesReturnKeyAutomatically = true
        linksTextView.keyboardAppearance = .Dark
        linksTextView.keyboardType = .URL
        linksTextView.spellCheckingType = .No
    }

    override func bindActions() {
        scrollView.delegate = self
        nameTextView.delegate = self
        bioTextView.delegate = self
        linksTextView.delegate = self
        uploadCoverImageButton.addTarget(self, action: #selector(uploadCoverImageAction), forControlEvents: .TouchUpInside)
        uploadAvatarButton.addTarget(self, action: #selector(uploadAvatarAction), forControlEvents: .TouchUpInside)
    }

    override func setText() {
        uploadCoverImageButton.setTitle(InterfaceString.Onboard.UploadCoverButton, forState: .Normal)
        uploadAvatarButton.setTitle(InterfaceString.Onboard.UploadAvatarButton, forState: .Normal)
        headerLabel.attributedText = NSAttributedString(
            primaryHeader: InterfaceString.Onboard.CreateProfilePrimary,
            secondaryHeader: InterfaceString.Onboard.CreateProfileSecondary
            )
        uploadCoverImagePrompt.text = InterfaceString.Onboard.UploadCoverImagePrompt
        uploadAvatarPrompt.text = InterfaceString.Onboard.UploadAvatarPrompt
        nameTextView.placeholder = InterfaceString.Onboard.NamePlaceholder
        bioTextView.placeholder = InterfaceString.Onboard.BioPlaceholder
        linksTextView.placeholder = InterfaceString.Onboard.LinksPlaceholder
    }

    override func arrange() {
        super.arrange()
        addSubview(scrollView)

        let widthAnchor = UIView()
        scrollView.addSubview(widthAnchor)
        scrollView.addSubview(headerLabel)
        scrollView.addSubview(coverImageView)
        scrollView.addSubview(uploadCoverImageButton)
        scrollView.addSubview(uploadCoverImagePrompt)
        scrollView.addSubview(avatarImageView)
        scrollView.addSubview(uploadAvatarButton)
        scrollView.addSubview(uploadAvatarPrompt)
        scrollView.addSubview(nameTextView)
        scrollView.addSubview(bioTextView)
        scrollView.addSubview(linksTextView)

        scrollView.snp_makeConstraints { make in
            make.edges.equalTo(self)
        }

        widthAnchor.snp_makeConstraints { make in
            make.leading.trailing.equalTo(scrollView)
            scrollViewWidthConstraint = make.width.equalTo(bounds.size.width).priorityRequired().constraint
        }

        headerLabel.setContentCompressionResistancePriority(UILayoutPriorityDefaultLow, forAxis: .Horizontal)
        headerLabel.snp_makeConstraints { make in
            make.top.equalTo(scrollView)
            make.leading.trailing.equalTo(scrollView).inset(Size.insets)
            make.height.equalTo(Size.headerHeight)
        }

        coverImageView.snp_makeConstraints { make in
            make.top.equalTo(headerLabel.snp_bottom)
            make.leading.trailing.equalTo(scrollView)
            make.height.equalTo(coverImageView.snp_width).multipliedBy(0.625)
        }
        uploadCoverImageButton.snp_makeConstraints { make in
            make.centerX.centerY.equalTo(coverImageView)
            make.size.equalTo(Size.uploadSize)
        }
        uploadCoverImagePrompt.snp_makeConstraints { make in
            make.centerX.equalTo(uploadCoverImageButton)
            make.top.equalTo(uploadCoverImageButton.snp_bottom).offset(Size.promptOffset)
        }

        avatarImageView.snp_makeConstraints { make in
            make.centerX.equalTo(scrollView)
            make.top.equalTo(coverImageView.snp_bottom).offset(Size.avatarOffset)
            make.width.height.equalTo(Size.avatarHeight)
        }
        uploadAvatarButton.snp_makeConstraints { make in
            make.top.equalTo(avatarImageView.snp_bottom).offset(Size.avatarOffset)
            make.centerX.equalTo(scrollView)
            make.size.equalTo(Size.uploadSize)
        }
        uploadAvatarPrompt.snp_makeConstraints { make in
            make.centerX.equalTo(uploadAvatarButton)
            make.top.equalTo(uploadAvatarButton.snp_bottom).offset(Size.promptOffset)
        }

        nameTextView.snp_makeConstraints { make in
            make.top.equalTo(uploadAvatarPrompt.snp_bottom).offset(Size.fieldsTopOffset)
            make.leading.trailing.equalTo(scrollView).inset(Size.insets)
        }
        bioTextView.snp_makeConstraints { make in
            make.top.equalTo(nameTextView.snp_bottom).offset(Size.fieldsInnerOffset)
            make.leading.trailing.equalTo(scrollView).inset(Size.insets)
        }
        linksTextView.snp_makeConstraints { make in
            make.top.equalTo(bioTextView.snp_bottom).offset(Size.fieldsInnerOffset)
            make.leading.trailing.equalTo(scrollView).inset(Size.insets)
            make.bottom.equalTo(scrollView.snp_bottom).inset(Size.insets)
        }
    }

    override public func layoutSubviews() {
        super.layoutSubviews()
        avatarImageView.layer.cornerRadius = avatarImageView.frame.size.width / 2
        scrollViewWidthConstraint.updateOffset(bounds.size.width)
    }

    override public func resignFirstResponder() -> Bool {
        nameTextView.resignFirstResponder()
        bioTextView.resignFirstResponder()
        linksTextView.resignFirstResponder()
        return true
    }

}

extension CreateProfileScreen {
    func uploadCoverImageAction() {
        resignFirstResponder()
        uploading = .CoverImage
        var config = ImagePickerSheetConfig()
        config.addImage = { _ in return InterfaceString.ImagePicker.ChooseImage }
        let pickerSheet = UIImagePickerController.imagePickerSheetForImagePicker(
            config: config,
            callback: openImageSheet)
        pickerSheet.maximumSelection = 1
        delegate?.presentController(pickerSheet)
    }

    func uploadAvatarAction() {
        resignFirstResponder()
        uploading = .Avatar
        var config = ImagePickerSheetConfig()
        config.addImage = { _ in return InterfaceString.ImagePicker.ChooseImage }
        let pickerSheet = UIImagePickerController.imagePickerSheetForImagePicker(
            config: config,
            callback: openImageSheet)
        pickerSheet.maximumSelection = 1
        delegate?.presentController(pickerSheet)
    }
}

extension CreateProfileScreen: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    public func imagePickerController(controller: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: AnyObject]) {
        guard let
            uploading = uploading,
            image = info[UIImagePickerControllerOriginalImage] as? UIImage
        else {
            delegate?.dismissController()
            return
        }

        if let url = info[UIImagePickerControllerReferenceURL] as? NSURL,
            asset = PHAsset.fetchAssetsWithALAssetURLs([url], options: nil).firstObject as? PHAsset
        {
            processPHAssets([asset])
            delegate?.dismissController()
        }
        else {
            image.copyWithCorrectOrientationAndSize() { image in
                if let image = image {
                    self.setImage(ImageRegionData(image: image), target: uploading, updateDelegate: true)
                }

                self.delegate?.dismissController()
            }
        }
    }

    public func imagePickerControllerDidCancel(controller: UIImagePickerController) {
        delegate?.dismissController()
    }

    func processPHAssets(assets: [PHAsset]) {
        guard let uploading = uploading else { return }

        AssetsToRegions.processPHAssets(assets) { (images: [ImageRegionData]) in
            for imageRegion in images {
                self.setImage(imageRegion, target: uploading, updateDelegate: true)
                break
            }
        }
    }

    func setImage(imageRegion: ImageRegionData?, target uploading: ImageTarget, updateDelegate: Bool) {
        let imageView: FLAnimatedImageView
        switch uploading {
        case .CoverImage:
            imageView = coverImageView
            uploadCoverImageButton.style = (imageRegion == nil) ? .Green : .RoundedGray
            if let imageRegion = imageRegion
                where updateDelegate { delegate?.assignCoverImage(imageRegion) }
        case .Avatar:
            imageView = avatarImageView
            uploadAvatarButton.style = (imageRegion == nil) ? .Green : .RoundedGray
            if let imageRegion = imageRegion
                where updateDelegate  { delegate?.assignAvatar(imageRegion) }
        }

        if let imageRegion = imageRegion {
            imageView.contentMode = .ScaleAspectFill
            if let data = imageRegion.data where imageRegion.contentType == "image/gif" {
                imageView.animatedImage = FLAnimatedImage(animatedGIFData: data)
            }
            else {
                imageView.image = imageRegion.image
            }
        }
        else if imageView == avatarImageView {
            imageView.contentMode = .Center
            imageView.image = InterfaceImage.ElloGrayLineLogo.normalImage
        }
        else if imageView == coverImageView {
            imageView.image = nil
        }
    }

    func openImageSheet(imageSheetResult: ImagePickerSheetResult) {
        switch imageSheetResult {
        case let .Controller(imageController):
            imageController.delegate = self
            delegate?.presentController(imageController)
        case let .Images(assets):
            processPHAssets(assets)
        }
    }

}

extension CreateProfileScreen: UITextViewDelegate {
    public func textView(textView: UITextView, shouldChangeTextInRange nsrange: NSRange, replacementText: String) -> Bool {
        var text = textView.text ?? ""
        let originalText = text
        if let range = text.rangeFromNSRange(nsrange) {
            text.replaceRange(range, with: replacementText)
        }

        switch textView {
        case nameTextView:
            if replacementText == "\n" {
                text = originalText
            }
            delegate?.assignName(text)
            nameTextView.validationState = text.isEmpty ? .None : .OKSmall

            if replacementText == "\n" {
                nameTextView.resignFirstResponder()
                bioTextView.becomeFirstResponder()
                return false
            }
        case bioTextView:
            delegate?.assignBio(text)
            bioTextView.validationState = text.isEmpty ? .None : .OKSmall
        case linksTextView:
            delegate?.assignLinks(text)
            linksTextView.validationState = text.isEmpty ? .None : .OKSmall
        default: break
        }

        return true
    }

    public func textViewDidChange(textView: UITextView) {
        (textView as? ClearTextView)?.textDidChange()
    }

    public func textViewDidChangeSelection(textView: UITextView) {
        let range = textView.selectedRange
        textView.scrollRangeToVisible(range)
    }
}

extension CreateProfileScreen: UIScrollViewDelegate {
    public func scrollViewDidScroll(scrollView: UIScrollView) {
        guard scrollView == self.scrollView else { return }

        let delta = scrollView.contentOffset.y - prevOffset.y
        prevOffset = scrollView.contentOffset
        if delta == -25 {
            scrollView.contentOffset.y = scrollView.contentOffset.y + 55
        }
    }
}
