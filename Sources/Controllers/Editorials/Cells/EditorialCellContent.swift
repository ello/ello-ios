////
///  EditorialCellContent.swift
//

import SnapKit
import FLAnimatedImage


@objc
protocol EditorialCellResponder: class {
    func editorialTapped(cell: EditorialCell)
}


@objc
protocol EditorialPostStreamResponder: class {
    func editorialTapped(index: Int, cell: EditorialCell)
}


@objc
protocol EditorialToolsResponder: class {
    func submitInvite(cell: UICollectionViewCell, emails: String)
    func submitJoin(cell: UICollectionViewCell, email: String, username: String, password: String)
    func lovesTapped(post: Post, cell: EditorialPostCell)
    func commentTapped(post: Post, cell: EditorialPostCell)
    func repostTapped(post: Post, cell: EditorialPostCell)
    func shareTapped(post: Post, cell: EditorialPostCell)
}


class EditorialCellContent: View {

    struct Size {
        static let aspect: CGFloat = 1
        static let smallTopMargin: CGFloat = 28
        static let defaultMargin = UIEdgeInsets(top: 18, left: 18, bottom: 17, right: 15)
        static let textFieldMargin: CGFloat = 10
        static let joinMargin: CGFloat = 1
        static let pageControlMargin: CGFloat = 18
        static let postStreamLabelMargin: CGFloat = 56
        static let subtitleButtonMargin: CGFloat = 12
        static let bgMargins = UIEdgeInsets(bottom: 1)
        static let buttonsMargin: CGFloat = 30
        static let buttonHeight: CGFloat = 48
        static let minFieldHeight: CGFloat = 45
        static let maxFieldHeight: CGFloat = 64
        static let minInviteTextHeight: CGFloat = 60
    }

    struct Config {
        var title: String?
        var author: String?
        var subtitle: String?
        var imageURL: URL?
        var specsImage: UIImage?

        var join: Editorial.JoinInfo?
        var invite: Editorial.InviteInfo?
        var post: Post?
        var postStreamConfigs: [Config]?

        init() {}
    }

    var config = Config() {
        didSet {
            updateConfig()
        }
    }

    private let bg = UIView()
    private let gradientView = UIView()
    private let gradientLayer = EditorialCellContent.generateGradientLayer()
    private let imageView = FLAnimatedImageView()
    private let loadingView = UIView()
    private let spinner = GradientLoadingView()
    var editorialContentView: UIView { return bg }
    let doubleTapGesture = UITapGestureRecognizer()
    let singleTapGesture = UITapGestureRecognizer()
    var editorialCell: EditorialCell!

    private static func generateGradientLayer() -> CAGradientLayer {
        return EditorialGradientLayer()
    }

    override func style() {
        bg.clipsToBounds = true
        bg.backgroundColor = .black
        gradientView.layer.addSublayer(gradientLayer)
        imageView.contentMode = .scaleAspectFill
        loadingView.backgroundColor = .greyA
        spinner.startAnimating()
    }

    override func bindActions() {
        doubleTapGesture.numberOfTapsRequired = 2
        doubleTapGesture.addTarget(self, action: #selector(doubleTapped(_:)))
        addGestureRecognizer(doubleTapGesture)

        singleTapGesture.numberOfTapsRequired = 1
        singleTapGesture.addTarget(self, action: #selector(tappedEditorial))
        singleTapGesture.require(toFail: doubleTapGesture)
        addGestureRecognizer(singleTapGesture)
    }

    override func arrange() {
        addSubview(bg)
        bg.addSubview(loadingView)
        loadingView.addSubview(spinner)
        bg.addSubview(imageView)
        bg.addSubview(gradientView)

        bg.snp.makeConstraints { make in
            make.edges.equalTo(self).inset(Size.bgMargins)
        }
        loadingView.snp.makeConstraints { make in
            make.edges.equalTo(bg)
        }
        spinner.snp.makeConstraints { make in
            make.center.equalTo(loadingView)
        }
        imageView.snp.makeConstraints { make in
            make.edges.equalTo(bg)
        }
        gradientView.snp.makeConstraints { make in
            make.edges.equalTo(bg)
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        bg.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height - 1)
        gradientView.frame = bg.bounds

        // I think embedding an EditorialPostCell inside the scrollview of EditorialPostStreamCell
        // results in weird behavior in layoutSubviews, where the frames are not yet set.  this
        // method was getting called with the `gradientView` always having a zero-sized frame.
        layoutIfNeeded()

        // prevents animating the gradient view (it was "growing out" from the corner because it
        // starts with a frame of .zero)
        CATransaction.begin()
        CATransaction.setValue(true, forKey: kCATransactionDisableActions)
        gradientLayer.frame = CGRect(origin: .zero, size: gradientView.frame.size)
        CATransaction.commit()
    }

    func prepareForReuse() {
        config = Config()
    }

    func updateConfig() {
        if let url = config.imageURL {
            self.spinner.isVisible = true
            self.spinner.startAnimating()
            imageView.pin_setImage(from: url) { result in
                self.spinner.stopAnimating()
            }
        }
        else {
            self.spinner.isHidden = true
            imageView.image = config.specsImage
        }
    }
}

extension EditorialCellContent {
    @objc
    func doubleTapped(_ gesture: UIGestureRecognizer) {
        guard let appViewController: AppViewController = findResponder() else { return }
        let location = gesture.location(in: appViewController.view)

        let responder: StreamEditingResponder? = findResponder()
        responder?.cellDoubleTapped(cell: self.editorialCell, location: location)
    }

    @objc
    func tappedEditorial() {
        let responder: EditorialCellResponder? = findResponder()
        responder?.editorialTapped(cell: self.editorialCell)
    }
}

extension Editorial.Kind {
    var reuseIdentifier: String {
        switch self {
        case .post: return "EditorialPostCell"
        case .internal: return "EditorialInternalCell"
        case .external: return "EditorialExternalCell"
        case .sponsored: return "EditorialSponsoredCell"
        case .postStream: return "EditorialPostStreamCell"
        case .invite: return "EditorialInviteCell"
        case .join: return "EditorialJoinCell"
        case .unknown: return "unknown"
        }
    }

    var classType: EditorialCellContent.Type {
        switch self {
        case .post: return EditorialPostCell.self
        case .internal: return EditorialInternalCell.self
        case .external: return EditorialExternalCell.self
        case .sponsored: return EditorialSponsoredCell.self
        case .postStream: return EditorialPostStreamCell.self
        case .invite: return EditorialInviteCell.self
        case .join: return EditorialJoinCell.self
        case .unknown: return EditorialCellContent.self
        }
    }
}

extension EditorialCellContent.Config {
    static func fromEditorial(_ editorial: Editorial) -> EditorialCellContent.Config {
        var config = EditorialCellContent.Config()
        config.invite = editorial.invite
        config.join = editorial.join
        config.post = editorial.post

        if let posts = editorial.posts {
            let postConfigs = posts.map { editorialPost in
                return EditorialCellContent.Config.fromPost(editorialPost, editorial: editorial)
            }
            config.postStreamConfigs = postConfigs
            config.title = ""
            config.subtitle = ""
        }
        else {
            config.title = editorial.title
            config.subtitle = editorial.renderedSubtitle
        }

        let size: Editorial.Size
        let width = Globals.windowSize.width
        if width > 500 {
            size = .size2x2
        }
        else {
            size = .size1x1
        }

        if let asset = editorial.images[size],
            let imageURL = asset.largeOrBest?.url
        {
            config.imageURL = imageURL
        }
        else if let postImageURL = editorial.post?.firstImageURL {
            config.imageURL = postImageURL
        }

        return config
    }

    static func fromPost(_ post: Ello.Post, editorial: Editorial) -> EditorialCellContent.Config {
        var config = EditorialCellContent.Config()
        if let author = post.author {
            config.author = author.atName
        }
        config.title = editorial.title
        config.subtitle = editorial.renderedSubtitle
        config.post = post

        if let postImageURL = post.firstImageURL {
            config.imageURL = postImageURL
        }

        return config
    }
}
