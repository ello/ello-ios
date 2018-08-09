////
///  OmnibarViewController.swift
//

import SwiftyUserDefaults
import PINRemoteImage


class OmnibarViewController: BaseElloViewController {
    override func trackerName() -> String? { return "Omnibar" }
    override func trackerProps() -> [String: Any]? {
        if parentPostId != nil {
            return ["creating": "comment"]
        }
        if editPost != nil {
            return ["editing": "post"]
        }
        if editComment != nil {
            return ["editing": "post"]
        }
        return ["creating": "post"]
    }

    var keyboardWillShowObserver: NotificationObserver?
    var keyboardWillHideObserver: NotificationObserver?
    var previousTab: ElloTab = .defaultTab
    var parentPostId: String?
    var editPost: Post?
    var editComment: ElloComment?
    var rawEditBody: [Regionable]?
    var defaultText: String?
    var category: Category?
    var canGoBack: Bool = true {
        didSet {
            if canGoBack {
                postNotification(StatusBarNotifications.statusBarVisibility, value: true)
            }

            if isViewLoaded {
                screen.canGoBack = canGoBack
            }
        }
    }
    var artistInvite: ArtistInvite?

    typealias CommentSuccessListener = (_ comment: ElloComment) -> Void
    typealias PostSuccessListener = (_ post: Post) -> Void
    var commentSuccessListener: CommentSuccessListener?
    var postSuccessListener: PostSuccessListener?

    var _mockScreen: OmnibarScreenProtocol?
    var screen: OmnibarScreenProtocol {
        set(screen) { _mockScreen = screen }
        get {
            if let mock = _mockScreen { return mock }
            return self.view as! OmnibarScreen
        }
    }

    convenience init(parentPostId postId: String) {
        self.init(nibName: nil, bundle: nil)
        parentPostId = postId
    }

    convenience init(editComment comment: ElloComment) {
        self.init(nibName: nil, bundle: nil)
        editComment = comment
        PostService().loadComment(comment.postId, commentId: comment.id)
            .done { [weak self] comment in
                guard let `self` = self else { return }
                self.rawEditBody = comment.body
                if self.isViewLoaded {
                    self.prepareScreenForEditing(comment.body, isComment: true)
                }
            }
            .ignoreErrors()
    }

    convenience init(editPost post: Post) {
        self.init(nibName: nil, bundle: nil)
        editPost = post
        PostService().loadPost(post.id)
            .done { post in
                self.rawEditBody = post.body
                self.category = post.category

                if self.isViewLoaded {
                    self.prepareScreenForEditing(post.body, isComment: false)
                    self.screen.chosenCategory = post.category
                }
            }
            .ignoreErrors()
    }

    convenience init(parentPostId postId: String, defaultText: String?) {
        self.init(parentPostId: postId)
        self.defaultText = defaultText
    }

    convenience init(defaultText: String?) {
        self.init(nibName: nil, bundle: nil)
        self.defaultText = defaultText
    }

    override func didSetCurrentUser() {
        super.didSetCurrentUser()

        if editPost == nil, editComment == nil, parentPostId == nil, self.category == nil,
            let category = currentUser?.categories?.first
        {
            self.category = category
            if category.tileURL == nil {
                CategoryService().loadCategory(category.slug)
                    .done { category in
                        guard self.category?.id == category.id else { return }
                        self.category = category
                        if self.isViewLoaded {
                            self.screen.chosenCategory = category
                        }
                    }
                    .ignoreErrors()
            }
        }
    }

    func onCommentSuccess(_ listener: @escaping CommentSuccessListener) {
        commentSuccessListener = listener
    }

    func onPostSuccess(_ listener: @escaping PostSuccessListener) {
        postSuccessListener = listener
    }

    override func loadView() {
        self.view = OmnibarScreen(frame: UIScreen.main.bounds)

        screen.canGoBack = canGoBack

        let communityPickerEditability: OmnibarScreen.CommunityPickerEditability
        if let editPost = editPost {
            if editPost.category != nil {
                communityPickerEditability = .visible
            }
            else {
                communityPickerEditability = .hidden
            }
            screen.title = InterfaceString.Omnibar.EditPostTitle
            screen.submitTitle = InterfaceString.Omnibar.EditPostButton
            screen.isEditing = true
            if let rawEditBody = rawEditBody {
                prepareScreenForEditing(rawEditBody, isComment: false)
            }
        }
        else if editComment != nil {
            communityPickerEditability = .hidden
            screen.title = InterfaceString.Omnibar.EditCommentTitle
            screen.submitTitle = InterfaceString.Omnibar.EditCommentButton
            screen.isEditing = true
            if let rawEditBody = rawEditBody {
                prepareScreenForEditing(rawEditBody, isComment: true)
            }
        }
        else {
            let isComment: Bool
            if parentPostId != nil {
                communityPickerEditability = .hidden
                screen.title = InterfaceString.Omnibar.CreateCommentTitle
                screen.submitTitle = InterfaceString.Omnibar.CreateCommentButton
                isComment = true
            }
            else if let artistInvite = artistInvite {
                communityPickerEditability = .hidden
                screen.title = InterfaceString.Omnibar.CreateArtistInviteSubmission(title: artistInvite.title)
                screen.submitTitle = InterfaceString.Omnibar.CreatePostButton
                isComment = false
            }
            else {
                communityPickerEditability = .editable
                screen.title = ""
                screen.submitTitle = InterfaceString.Omnibar.CreatePostButton
                isComment = false
            }

            let defaultRegions: [Regionable]
            if let text = defaultText {
                defaultRegions = [TextRegion(content: text)]
            }
            else {
                defaultRegions = []
            }
            prepareScreenForEditing(defaultRegions, isComment: isComment)

            if let fileName = omnibarDataName(),
                let data: Data = Tmp.read(fileName), (defaultText ?? "") == ""
            {
                if let omnibarData = NSKeyedUnarchiver.unarchiveObject(with: data) as? OmnibarCacheData {
                    let regions: [OmnibarRegion] = omnibarData.regions.compactMap { obj in
                        if let region = OmnibarRegion.fromRaw(obj) {
                            return region
                        }
                        return nil
                    }
                    _ = Tmp.remove(fileName)
                    screen.regions = regions
                }
            }
        }

        screen.communityPickerEditability = communityPickerEditability
        screen.chosenCategory = self.category
        screen.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        postNotification(StatusBarNotifications.statusBarVisibility, value: true)

        if let previousTab = elloTabBarController?.previousTab {
            self.previousTab = previousTab
        }

        keyboardWillShowObserver = NotificationObserver(notification: Keyboard.Notifications.KeyboardWillShow, block: self.keyboardWillShow)
        keyboardWillHideObserver = NotificationObserver(notification: Keyboard.Notifications.KeyboardWillHide, block: self.keyboardWillHide)
        view.setNeedsLayout()

        let isEditing = (editPost != nil || editComment != nil)
        if isEditing {
            if rawEditBody == nil {
                ElloHUD.showLoadingHudInView(view)
            }
        }
        else {
            let isShowingNarration = elloTabBarController?.shouldShowNarration ?? false
            let isPosting = !screen.isInteractionEnabled
            if !isShowingNarration && !isPosting && presentedViewController == nil {
                // desired behavior: animate the keyboard in when this screen is
                // shown.  without the delay, the keyboard just appears suddenly.
                delay(0) {
                    self.screen.startEditing()
                }
            }
        }

        screen.updateButtons()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        bottomBarController?.setNavigationBarsVisible(true, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        screen.stopEditing()

        if let keyboardWillShowObserver = keyboardWillShowObserver {
            keyboardWillShowObserver.removeObserver()
            self.keyboardWillShowObserver = nil
        }
        if let keyboardWillHideObserver = keyboardWillHideObserver {
            keyboardWillHideObserver.removeObserver()
            self.keyboardWillHideObserver = nil
        }
    }

    func prepareScreenForEditing(_ content: [Regionable], isComment: Bool) {
        var regions: [OmnibarRegion] = []
        var buyButtonURL: URL?
        var downloads: [(Int, URL)] = []  // the 'index' is used to replace the ImageURL region after it is downloaded
        for (index, region) in content.enumerated() {
            if let region = region as? TextRegion,
                let attrdText = ElloAttributedString.parse(region.content)
            {
                regions.append(.attributedText(attrdText))
            }
            else if let region = region as? ImageRegion,
                let url = region.url
            {
                if let imageRegionURL = region.buyButtonURL {
                    buyButtonURL = imageRegionURL
                }
                downloads.append((index, url))
                regions.append(.imageURL(url))
            }
        }
        screen.regions = regions
        screen.isComment = isComment
        screen.isArtistInviteSubmission = artistInvite != nil
        screen.buyButtonURL = buyButtonURL

        let completed = after(downloads.count) {
            ElloHUD.hideLoadingHudInView(self.view)
        }

        for (index, imageURL) in downloads {
            PINRemoteImageManager.shared().downloadImage(with: imageURL, options: []) { result in
                if let animatedImage = result.animatedImage {
                    regions[index] = .imageData(animatedImage.posterImage, animatedImage.data, "image/gif")
                }
                else if let image = result.image {
                    regions[index] = .image(image)
                }
                else {
                    regions[index] = .error(imageURL)
                }
                let tmp = regions
                inForeground {
                    self.screen.regions = tmp
                    completed()
                }
            }
        }
    }

    func keyboardWillShow(_ keyboard: Keyboard) {
        screen.keyboardWillShow()
    }

    func keyboardWillHide(_ keyboard: Keyboard) {
        screen.keyboardWillHide()
    }

    private func goToPreviousTab() {
        elloTabBarController?.selectedTab = previousTab
    }

}

extension OmnibarViewController {

    class func canEditRegions(_ regions: [Regionable]?) -> Bool {
        return OmnibarScreen.canEditRegions(regions)
    }
}

extension OmnibarViewController: ChooseCategoryControllerDelegate {
    func categoryChosen(_ category: Category) {
        Tracker.shared.postIntoCommunityChosen(category)
        self.category = category
        screen.chosenCategory = category
    }
}

extension OmnibarViewController: OmnibarScreenDelegate {

    func clearCommunityTapped() {
        Tracker.shared.postIntoCommunityChosen(nil)
        screen.chosenCategory = nil
        category = nil
    }

    func chooseCommunityTapped() {
        guard let currentUser = currentUser else { return }

        let controller = ChooseCategoryViewController(currentUser: currentUser, category: category, usage: .omnibar)
        controller.delegate = self
        navigationController?.pushViewController(controller, animated: true)
    }

    func cancelTapped() {
        if canGoBack {
            if let fileName = omnibarDataName() {
                var dataRegions = [NSObject]()
                for region in screen.regions {
                    if let rawRegion = region.rawRegion {
                        dataRegions.append(rawRegion)
                    }
                }
                let omnibarData = OmnibarCacheData()
                omnibarData.regions = dataRegions
                let data = NSKeyedArchiver.archivedData(withRootObject: omnibarData)
                _ = Tmp.write(data, to: fileName)
            }

            if parentPostId != nil {
                Tracker.shared.contentCreationCanceled(.comment)
            }
            else if editPost != nil {
                Tracker.shared.contentEditingCanceled(.post)
            }
            else if editComment != nil {
                Tracker.shared.contentEditingCanceled(.comment)
            }
            else {
                Tracker.shared.contentCreationCanceled(.post)
            }
            _ = navigationController?.popViewController(animated: true)
        }
        else {
            Tracker.shared.contentCreationCanceled(.post)
            goToPreviousTab()
        }
    }

    func omnibarPresentController(_ controller: UIViewController) {
        self.present(controller, animated: true, completion: nil)
    }

    func omnibarPushController(_ controller: UIViewController) {
        self.navigationController?.pushViewController(controller, animated: true)
    }

    func omnibarDismissController() {
        self.dismiss(animated: true, completion: nil)
    }

    func submitted(regions: [OmnibarRegion], buyButtonURL: URL?) {
        let content = generatePostRegions(regions)
        guard content.count > 0 else {
            return
        }

        if let authorId = currentUser?.id {
            startPosting(authorId, content, buyButtonURL: buyButtonURL)
        }
        else {
            contentCreationFailed(InterfaceString.App.LoggedOutError)
        }
    }

}

// MARK: Posting the content to API
extension OmnibarViewController {

    func generatePostRegions(_ regions: [OmnibarRegion]) -> [PostEditingService.PostContentRegion] {
        var content: [PostEditingService.PostContentRegion] = []
        for region in regions {
            switch region {
            case let .attributedText(attributedText):
                let textString = attributedText.string
                if textString.count > 5000 {
                    contentCreationFailed(InterfaceString.Omnibar.TooLongError)
                    return []
                }

                let cleanedText = textString.trimmingCharacters(in: CharacterSet.whitespaces)
                if !cleanedText.isEmpty {
                    content.append(.text(ElloAttributedString.render(attributedText)))
                }
            case let .image(image):
                content.append(.image(image))
            case let .imageData(image, data, contentType):
                content.append(.imageData(image, data, contentType))
            default:
                break // there are "non submittable" types from OmnibarRegion, like Spacer and ImageURL
            }
        }
        return content
    }

    private func startPosting(_ authorId: String, _ content: [PostEditingService.PostContentRegion], buyButtonURL: URL?) {
        let service: PostEditingService
        let didGoToPreviousTab: Bool
        let alertText: String

        if let parentPostId = parentPostId {
            alertText = InterfaceString.Omnibar.CreatingComment
            service = PostEditingService(parentPostId: parentPostId)
            didGoToPreviousTab = false
        }
        else if let editPost = editPost {
            alertText = InterfaceString.Omnibar.UpdatingPost
            service = PostEditingService(editPostId: editPost.id)
            didGoToPreviousTab = false
        }
        else if let editComment = editComment {
            alertText = InterfaceString.Omnibar.UpdatingComment
            service = PostEditingService(editComment: editComment)
            didGoToPreviousTab = false
        }
        else {
            alertText = InterfaceString.Omnibar.CreatingPost
            service = PostEditingService()

            if artistInvite == nil {
                goToPreviousTab()
                didGoToPreviousTab = true
            }
            else {
                didGoToPreviousTab = false
            }
        }

        startSpinner()
        NotificationBanner.displayAlert(message: alertText)
        postNotification(NewContentNotifications.pause, value: ())

        service.create(
            content: content,
            buyButtonURL: buyButtonURL,
            categoryId: category?.id,
            artistInviteId: artistInvite?.id
            )
            .done { postOrComment in
                if self.editPost != nil || self.editComment != nil {
                    URLCache.shared.removeAllCachedResponses()
                }

                self.emitSuccess(postOrComment, didGoToPreviousTab: didGoToPreviousTab)
            }
            .catch { error in
                self.stopSpinner()
                self.contentCreationFailed(error.elloErrorMessage ?? error.localizedDescription)

                if let vc = self.parent as? ElloTabBarController, didGoToPreviousTab {
                    vc.selectedTab = .omnibar
                }
            }
            .finally {
                postNotification(NewContentNotifications.resume, value: ())
            }
    }

    private func emitSuccess(_ postOrComment: Any, didGoToPreviousTab: Bool) {
        if let comment = postOrComment as? ElloComment {
            self.emitCommentSuccess(comment)
        }
        else if let post = postOrComment as? Post {
            self.emitPostSuccess(post, didGoToPreviousTab: didGoToPreviousTab)
        }

        postNotification(HapticFeedbackNotifications.successfulUserEvent, value: ())
    }

    private func emitCommentSuccess(_ comment: ElloComment) {
        if editComment != nil {
            Tracker.shared.commentEdited(comment)
            postNotification(CommentChangedNotification, value: (comment, .replaced))
            stopSpinner()
        }
        else {
            ContentChange.updateCommentCount(comment, delta: 1)
            Tracker.shared.commentCreated(comment)
            postNotification(CommentChangedNotification, value: (comment, .create))

            if let post = comment.parentPost {
                PostService().loadPost(post.id)
                    .done { post in
                        ElloLinkedStore.shared.setObject(post, forKey: post.id, type: .postsType)
                        postNotification(PostChangedNotification, value: (post, .watching))
                        self.stopSpinner()
                    }
                    .catch { _ in
                        self.stopSpinner()
                    }
            }
            else {
                stopSpinner()
            }
        }

        if let listener = commentSuccessListener {
            listener(comment)
        }
    }

    private func emitPostSuccess(_ post: Post, didGoToPreviousTab: Bool) {
        stopSpinner()

        if editPost != nil {
            Tracker.shared.postEdited(post, category: category)
            postNotification(PostChangedNotification, value: (post, .replaced))
        }
        else {
            if let user = currentUser, let postsCount = user.postsCount {
                user.postsCount = postsCount + 1
                postNotification(CurrentUserChangedNotification, value: user)
            }

            Tracker.shared.postCreated(post, category: category)
            if let artistInviteSlug = artistInvite?.slug {
                Tracker.shared.artistInviteSubmitted(slug: artistInviteSlug)
            }
            postNotification(PostChangedNotification, value: (post, .create))
        }

        if let listener = postSuccessListener {
            listener(post)
        }

        self.screen.resetAfterSuccessfulPost()

        if didGoToPreviousTab {
            NotificationBanner.dismissAlert()
            NotificationBanner.displayAlert(message: InterfaceString.Omnibar.CreatedPost)
        }
    }

    func startSpinner() {
        ElloHUD.showLoadingHudInView(view)
        screen.isInteractionEnabled = false
    }

    func stopSpinner() {
        ElloHUD.hideLoadingHudInView(self.view)
        self.screen.isInteractionEnabled = true
    }

    func contentCreationFailed(_ errorMessage: String) {
        let contentType: ContentType
        if parentPostId == nil && editComment == nil {
            contentType = .post
        }
        else {
            contentType = .comment
        }
        Tracker.shared.contentCreationFailed(contentType, message: errorMessage)
        screen.reportError("Could not create \(contentType.rawValue)", errorMessage: errorMessage)
    }

}

extension OmnibarViewController {
    func omnibarDataName() -> String? {
        if let postId = parentPostId {
            return "omnibar_v2_comment_\(postId)"
        }
        else if editPost != nil || editComment != nil {
            return nil
        }
        else {
            return "omnibar_v2_post"
        }
    }
}
