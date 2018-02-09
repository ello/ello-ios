////
///  ContentFlagger.swift
//

class ContentFlagger {

    var isContentFlagged: Bool?

    weak var presentingController: UIViewController?
    let flaggableId: String
    let contentType: ContentType
    var commentPostId: String?

    init(presentingController: UIViewController, flaggableId: String, contentType: ContentType, commentPostId: String? = nil) {
        self.presentingController = presentingController
        self.flaggableId = flaggableId
        self.contentType = contentType
        self.commentPostId = commentPostId
    }

    func handler(_ action: AlertAction) {
        let option = UserFlag(rawValue: action.title)
        if let option = option {
            let endPoint: ElloAPI
            switch contentType {
            case .post:
                endPoint = .flagPost(postId: flaggableId, kind: option.kind)
            case .comment:
                endPoint = .flagComment(postId: commentPostId!, commentId: flaggableId, kind: option.kind)
            case .user:
                endPoint = .flagUser(userId: flaggableId, kind: option.kind)
            }

            ContentFlaggingService().flagContent(endPoint)
                .then { _ -> Void in
                    Tracker.shared.contentFlagged(self.contentType, flag: option, contentId: self.flaggableId)
                    self.isContentFlagged = true
                }
                .catch { error in
                    let message = error.elloErrorMessage ?? error.localizedDescription
                    Tracker.shared.contentFlaggingFailed(self.contentType, message: message, contentId: self.flaggableId)
                    self.isContentFlagged = false
                }
        }
    }

    func displayFlaggingSheet() {
        guard let presentingController = presentingController else {
            return
        }

        let alertController = AlertViewController(message: "Would you like to flag this content as:", buttonAlignment: .left)

        for option in UserFlag.all {
            let action = AlertAction(title: option.name, style: .dark, handler: handler)
            alertController.addAction(action)
        }

        let cancelAction = AlertAction(title: InterfaceString.Cancel, style: .light) { _ in
            Tracker.shared.contentFlaggingCanceled(self.contentType, contentId: self.flaggableId)
        }

        alertController.addAction(cancelAction)

        presentingController.present(alertController, animated: true, completion: nil)
    }

}
