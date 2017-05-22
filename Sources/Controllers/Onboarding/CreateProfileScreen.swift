////
///  CreateProfileScreen.swift
//

import Photos
import SnapKit
import ImagePickerSheetController


class CreateProfileScreen: Screen, CreateProfileScreenProtocol {
    enum ImageTarget {
        case coverImage
        case avatar
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
            nameTextView.validationState = (newValue?.isEmpty == false) ? .okSmall : .none
        }
    }
    var bio: String? {
        get { return bioTextView.text }
        set {
            bioTextView.text = newValue
            bioTextView.validationState = (newValue?.isEmpty == false) ? .okSmall : .none
        }
    }
    var links: String? {
        get { return linksTextView.text }
        set {
            linksTextView.text = newValue
            linksTextView.validationState = (newValue?.isEmpty == false) ? .okSmall : .none
        }
    }
    var linksValid: Bool? = nil {
        didSet {
            let newState: ValidationState
            switch linksValid {
            case .none: newState = .none
            case .some(true): newState = .okSmall
            case .some(false): newState = .error
            }
            linksTextView.validationState = newState
        }
    }
    var coverImage: ImageRegionData? {
        didSet {
            setImage(coverImage, target: .coverImage, updateDelegate: false)
        }
    }
    var avatarImage: ImageRegionData? {
        didSet {
            setImage(avatarImage, target: .avatar, updateDelegate: false)
        }
    }

    fileprivate var uploading: ImageTarget?

    fileprivate let scrollView = UIScrollView()
    fileprivate var prevOffset: CGPoint = .zero
    fileprivate var scrollViewWidthConstraint: Constraint!
    fileprivate let headerLabel = UILabel()

    fileprivate let coverImageView = FLAnimatedImageView()
    fileprivate let uploadCoverImageButton = StyledButton(style: .green)
    fileprivate let uploadCoverImagePrompt = UILabel()

    fileprivate let avatarImageView = FLAnimatedImageView()
    fileprivate let uploadAvatarButton = StyledButton(style: .green)
    fileprivate let uploadAvatarPrompt = UILabel()

    fileprivate let nameTextView = ClearTextView()
    fileprivate let bioTextView = ClearTextView()
    fileprivate let linksTextView = ClearTextView()

    override func style() {
        headerLabel.numberOfLines = 0

        coverImageView.backgroundColor = .greyE5()
        coverImageView.contentMode = .scaleAspectFill
        coverImageView.clipsToBounds = true
        uploadCoverImagePrompt.textAlignment = .center
        uploadCoverImagePrompt.textColor = .greyA()
        uploadCoverImagePrompt.font = UIFont.defaultFont(12)
        uploadCoverImagePrompt.numberOfLines = 2

        avatarImageView.backgroundColor = .greyE5()
        avatarImageView.clipsToBounds = true
        avatarImageView.contentMode = .center
        avatarImageView.interfaceImage = .elloGrayLineLogo
        uploadAvatarPrompt.textAlignment = .center
        uploadAvatarPrompt.textColor = .greyA()
        uploadAvatarPrompt.font = UIFont.defaultFont(12)
        uploadAvatarPrompt.numberOfLines = 2

        nameTextView.textColor = .black
        nameTextView.isScrollEnabled = false
        nameTextView.lineColor = .greyE5()
        nameTextView.selectedLineColor = .black
        nameTextView.keyboardAppearance = .dark
        nameTextView.autocapitalizationType = .words
        nameTextView.autocorrectionType = .no
        nameTextView.spellCheckingType = .no

        bioTextView.textColor = .black
        bioTextView.isScrollEnabled = false
        bioTextView.lineColor = .greyE5()
        bioTextView.selectedLineColor = .black
        bioTextView.keyboardAppearance = .dark

        linksTextView.textColor = .black
        linksTextView.isScrollEnabled = false
        linksTextView.lineColor = .greyE5()
        linksTextView.selectedLineColor = .black

        linksTextView.autocapitalizationType = .none
        linksTextView.autocorrectionType = .no
        linksTextView.enablesReturnKeyAutomatically = true
        linksTextView.keyboardAppearance = .dark
        linksTextView.keyboardType = .URL
        linksTextView.spellCheckingType = .no
    }

    override func bindActions() {
        scrollView.delegate = self
        nameTextView.delegate = self
        bioTextView.delegate = self
        linksTextView.delegate = self
        uploadCoverImageButton.addTarget(self, action: #selector(uploadCoverImageAction), for: .touchUpInside)
        uploadAvatarButton.addTarget(self, action: #selector(uploadAvatarAction), for: .touchUpInside)
    }

    override func setText() {
        uploadCoverImageButton.setTitle(InterfaceString.Onboard.UploadCoverButton, for: .normal)
        uploadAvatarButton.setTitle(InterfaceString.Onboard.UploadAvatarButton, for: .normal)
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

        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(self)
        }

        widthAnchor.snp.makeConstraints { make in
            make.leading.trailing.equalTo(scrollView)
            scrollViewWidthConstraint = make.width.equalTo(bounds.size.width).priority(Priority.required).constraint
        }

        headerLabel.setContentCompressionResistancePriority(UILayoutPriorityDefaultLow, for: .horizontal)
        headerLabel.snp.makeConstraints { make in
            make.top.equalTo(scrollView)
            make.leading.trailing.equalTo(scrollView).inset(Size.insets)
            make.height.equalTo(Size.headerHeight)
        }

        coverImageView.snp.makeConstraints { make in
            make.top.equalTo(headerLabel.snp.bottom)
            make.leading.trailing.equalTo(scrollView)
            make.height.equalTo(coverImageView.snp.width).multipliedBy(0.625)
        }
        uploadCoverImageButton.snp.makeConstraints { make in
            make.centerX.centerY.equalTo(coverImageView)
            make.size.equalTo(Size.uploadSize)
        }
        uploadCoverImagePrompt.snp.makeConstraints { make in
            make.centerX.equalTo(uploadCoverImageButton)
            make.top.equalTo(uploadCoverImageButton.snp.bottom).offset(Size.promptOffset)
        }

        avatarImageView.snp.makeConstraints { make in
            make.centerX.equalTo(scrollView)
            make.top.equalTo(coverImageView.snp.bottom).offset(Size.avatarOffset)
            make.width.height.equalTo(Size.avatarHeight)
        }
        uploadAvatarButton.snp.makeConstraints { make in
            make.top.equalTo(avatarImageView.snp.bottom).offset(Size.avatarOffset)
            make.centerX.equalTo(scrollView)
            make.size.equalTo(Size.uploadSize)
        }
        uploadAvatarPrompt.snp.makeConstraints { make in
            make.centerX.equalTo(uploadAvatarButton)
            make.top.equalTo(uploadAvatarButton.snp.bottom).offset(Size.promptOffset)
        }

        nameTextView.snp.makeConstraints { make in
            make.top.equalTo(uploadAvatarPrompt.snp.bottom).offset(Size.fieldsTopOffset)
            make.leading.trailing.equalTo(scrollView).inset(Size.insets)
        }
        bioTextView.snp.makeConstraints { make in
            make.top.equalTo(nameTextView.snp.bottom).offset(Size.fieldsInnerOffset)
            make.leading.trailing.equalTo(scrollView).inset(Size.insets)
        }
        linksTextView.snp.makeConstraints { make in
            make.top.equalTo(bioTextView.snp.bottom).offset(Size.fieldsInnerOffset)
            make.leading.trailing.equalTo(scrollView).inset(Size.insets)
            make.bottom.equalTo(scrollView.snp.bottom).inset(Size.insets)
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        avatarImageView.layer.cornerRadius = avatarImageView.frame.size.width / 2
        scrollViewWidthConstraint.update(offset: bounds.size.width)
    }

    override func resignFirstResponder() -> Bool {
        _ = nameTextView.resignFirstResponder()
        _ = bioTextView.resignFirstResponder()
        _ = linksTextView.resignFirstResponder()
        return true
    }

}

extension CreateProfileScreen {
    func uploadCoverImageAction() {

        _ = resignFirstResponder()
        uploading = .coverImage
        var config = ImagePickerSheetConfig()
        config.addImage = { _ in return InterfaceString.ImagePicker.ChooseImage }
        let pickerSheet = UIImagePickerController.imagePickerSheetForImagePicker(
            config: config,
            callback: openImageSheet)
        pickerSheet.maximumSelection = 1
        delegate?.present(controller: pickerSheet)
    }

    func uploadAvatarAction() {
        _ = resignFirstResponder()
        uploading = .avatar
        var config = ImagePickerSheetConfig()
        config.addImage = { _ in return InterfaceString.ImagePicker.ChooseImage }
        let pickerSheet = UIImagePickerController.imagePickerSheetForImagePicker(
            config: config,
            callback: openImageSheet)
        pickerSheet.maximumSelection = 1
        delegate?.present(controller: pickerSheet)
    }
}

extension CreateProfileScreen: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    func imagePickerController(_ controller: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: Any]) {
        guard
            let uploading = uploading,
            let image = info[UIImagePickerControllerOriginalImage] as? UIImage
        else {
            delegate?.dismissController()
            return
        }

        if let url = info[UIImagePickerControllerReferenceURL] as? URL,
            let asset = PHAsset.fetchAssets(withALAssetURLs: [url], options: nil).firstObject
        {
            processPHAssets([asset])
            delegate?.dismissController()
        }
        else {
            image.copyWithCorrectOrientationAndSize { image in
                if let image = image {
                    self.setImage(ImageRegionData(image: image), target: uploading, updateDelegate: true)
                }

                self.delegate?.dismissController()
            }
        }
    }

    func imagePickerControllerDidCancel(_ controller: UIImagePickerController) {
        delegate?.dismissController()
    }

    func processPHAssets(_ assets: [PHAsset]) {
        guard let uploading = uploading else { return }

        AssetsToRegions.processPHAssets(assets) { (images: [ImageRegionData]) in
            for imageRegion in images {
                self.setImage(imageRegion, target: uploading, updateDelegate: true)
                break
            }
        }
    }

    func setImage(_ imageRegion: ImageRegionData?, target uploading: ImageTarget, updateDelegate: Bool) {
        let imageView: FLAnimatedImageView
        switch uploading {
        case .coverImage:
            imageView = coverImageView
            uploadCoverImageButton.style = (imageRegion == nil) ? .green : .roundedGrayOutline
            if let imageRegion = imageRegion, updateDelegate { delegate?.assign(coverImage: imageRegion) }
        case .avatar:
            imageView = avatarImageView
            uploadAvatarButton.style = (imageRegion == nil) ? .green : .roundedGrayOutline
            if let imageRegion = imageRegion, updateDelegate  { delegate?.assign(avatarImage: imageRegion) }
        }

        if let imageRegion = imageRegion {
            imageView.contentMode = .scaleAspectFill
            if let data = imageRegion.data, imageRegion.contentType == "image/gif" {
                imageView.animatedImage = FLAnimatedImage(animatedGIFData: data as Data!)
            }
            else {
                imageView.image = imageRegion.image
            }
        }
        else if imageView == avatarImageView {
            imageView.contentMode = .center
            imageView.interfaceImage = .elloGrayLineLogo
        }
        else if imageView == coverImageView {
            imageView.image = nil
        }
    }

    func openImageSheet(_ imageSheetResult: ImagePickerSheetResult) {
        switch imageSheetResult {
        case let .controller(imageController):
            imageController.delegate = self
            delegate?.present(controller: imageController)
        case let .images(assets):
            processPHAssets(assets)
        }
    }

}

extension CreateProfileScreen: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn nsrange: NSRange, replacementText: String) -> Bool {
        var text = textView.text ?? ""
        let originalText = text
        if let range = text.rangeFromNSRange(nsrange) {
            text.replaceSubrange(range, with: replacementText)
        }

        switch textView {
        case nameTextView:
            if replacementText == "\n" {
                text = originalText
            }
            nameTextView.validationState = delegate?.assign(name: text) ?? .none

            if replacementText == "\n" {
                _ = nameTextView.resignFirstResponder()
                _ = bioTextView.becomeFirstResponder()
                return false
            }
        case bioTextView:
            bioTextView.validationState = delegate?.assign(bio: text) ?? .none
        case linksTextView:
            linksTextView.validationState = delegate?.assign(links: text) ?? .none
        default: break
        }

        return true
    }

    func textViewDidChange(_ textView: UITextView) {
        (textView as? ClearTextView)?.textDidChange()
    }

    func textViewDidChangeSelection(_ textView: UITextView) {
        let range = textView.selectedRange
        textView.scrollRangeToVisible(range)
    }
}

extension CreateProfileScreen: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView == self.scrollView else { return }

        let delta = scrollView.contentOffset.y - prevOffset.y
        prevOffset = scrollView.contentOffset
        if delta == -25 {
            scrollView.contentOffset.y += 55
        }
    }
}
