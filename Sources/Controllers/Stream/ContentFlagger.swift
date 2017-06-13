////
///  ContentFlagger.swift
//

class ContentFlagger {

    var contentFlagged: Bool?

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

    enum AlertOption: String {
        case spam = "Spam"
        case violence = "Violence"
        case copyright = "Copyright infringement"
        case threatening = "Threatening"
        case hate = "Hate Speech"
        case adult = "NSFW Content"
        case dontLike = "I don't like it"

        var name: String {
            return self.rawValue
        }

        var kind: String {
            switch self {
            case .spam: return "spam"
            case .violence: return "violence"
            case .copyright: return "copyright"
            case .threatening: return "threatening"
            case .hate: return "hate_speech"
            case .adult: return "adult"
            case .dontLike: return "offensive"
            }
        }

        static let all = [spam, violence, copyright, threatening, hate, adult, dontLike]
    }

    func handler(_ action: AlertAction) {
        let option = AlertOption(rawValue: action.title)
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
                    self.contentFlagged = true
                }
                .catch { error in
                    let message = (error as NSError).elloErrorMessage ?? error.localizedDescription
                    Tracker.shared.contentFlaggingFailed(self.contentType, message: message, contentId: self.flaggableId)
                    self.contentFlagged = false
                }
        }
    }

    func displayFlaggingSheet() {
        guard let presentingController = presentingController else {
            return
        }

        let alertController = AlertViewController(message: "Would you like to flag this content as:", textAlignment: .left)

        for option in AlertOption.all {
            let action = AlertAction(title: option.name, style: .dark, handler: handler)
            alertController.addAction(action)
        }

        let cancelAction = AlertAction(title: InterfaceString.Cancel, style: .light) { _ in
            Tracker.shared.contentFlaggingCanceled(self.contentType, contentId: self.flaggableId)
        }

        alertController.addAction(cancelAction)

        presentingController.present(alertController, animated: true, completion: .none)
    }

}
