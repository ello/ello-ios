////
///  ElloTextView.swift
//

protocol ElloTextViewDelegate: class {
    func textViewTapped(_ link: String, object: ElloAttributedObject)
    func textViewTappedDefault()
}

enum ElloAttributedObject {
    case attributedPost(post: Post)
    case attributedComment(comment: ElloComment)
    case attributedArtistInvite(artistInvite: ArtistInvite)
    case attributedUser(user: User)
    case attributedCategory(category: Category)
    case attributedCategoryPartial(category: CategoryPartial)
    case attributedUserId(userId: String)
    case unknown

    static func generate(_ link: String, _ object: Any?) -> ElloAttributedObject {
        switch link {
        case "user", "followers", "following":
            if let user = object as? User { return ElloAttributedObject.attributedUser(user: user) }
        case "post":
            if let post = object as? Post { return ElloAttributedObject.attributedPost(post: post) }
        case "comment":
            if let comment = object as? ElloComment {
                return ElloAttributedObject.attributedComment(comment: comment)
            }
        case "artistInvite":
            if let artistInvite = object as? ArtistInvite {
                return ElloAttributedObject.attributedArtistInvite(artistInvite: artistInvite)
            }
        case "category":
            if let category = object as? Category {
                return ElloAttributedObject.attributedCategory(category: category)
            }
        case "categoryPartial":
            if let category = object as? CategoryPartial {
                return ElloAttributedObject.attributedCategoryPartial(category: category)
            }
        case "userId":
            if let userId = object as? String {
                return ElloAttributedObject.attributedUserId(userId: userId)
            }
        default: break
        }
        return .unknown
    }
}

class ElloTextView: UITextView {

    var customFont: UIFont?

    weak var textViewDelegate: ElloTextViewDelegate?

    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        internalInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        internalInit()
    }

    func clearText() {
        attributedText = NSAttributedString(string: "")
    }

    private func defaultAttrs() -> [NSAttributedString.Key: Any] {
        return [
            .font: self.customFont ?? UIFont.defaultFont(),
            .foregroundColor: UIColor.greyA,
        ]
    }

    private func internalInit() {
        setDefaults()
        addTarget()
    }

    private func setDefaults() {
        // some default styling
        font = UIFont.defaultFont()
        textColor = UIColor.greyA
        textContainer.lineFragmentPadding = 0
        // makes this like a UILabel
        text = ""
        isEditable = false
        isSelectable = false
        isScrollEnabled = false
        scrollsToTop = false
        attributedText = NSAttributedString(string: "")
        textContainerInset = UIEdgeInsets.zero
        allowsEditingTextAttributes = false
        backgroundColor = .white
    }

    private func addTarget() {
        let recognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(ElloTextView.textViewTapped(_:))
        )
        recognizer.numberOfTapsRequired = 1
        recognizer.numberOfTouchesRequired = 1
        addGestureRecognizer(recognizer)
    }

    @objc
    func textViewTapped(_ gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: self)
        if self.frame.at(origin: .zero).contains(location) {
            if let range = characterRange(at: location),
                let pos = closestPosition(to: location, within: range),
                let style = textStyling(at: pos, in: .forward),
                let link = style[ElloAttributedText.Link] as? String
            {
                let object: Any? = style[ElloAttributedText.Object]
                let attributedObject = ElloAttributedObject.generate(link, object)
                textViewDelegate?.textViewTapped(link, object: attributedObject)
                return
            }

            textViewDelegate?.textViewTappedDefault()
        }
    }
}
