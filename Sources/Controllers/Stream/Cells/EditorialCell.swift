////
///  EditorialCell.swift
//

import SnapKit


@objc
protocol EditorialResponder: class {
    func submitInvite(cell: UICollectionViewCell, emails: String)
    func submitJoin(cell: UICollectionViewCell, email: String, username: String, password: String)
    func lovesTapped(post: Post, cell: EditorialPostCell)
    func commentTapped(post: Post, cell: EditorialPostCell)
    func repostTapped(post: Post, cell: EditorialPostCell)
    func shareTapped(post: Post, cell: EditorialPostCell)
}


class EditorialCell: UICollectionViewCell {

    struct Size {
        static let aspect: CGFloat = 1
        static let smallTopMargin: CGFloat = 28
        static let defaultMargin = UIEdgeInsets(top: 18, left: 18, bottom: 17, right: 15)
        static let textFieldMargin: CGFloat = 10
        static let pageControlMargin: CGFloat = 18
        static let postStreamLabelMargin: CGFloat = 20
        static let subtitleButtonMargin: CGFloat = 36
        static let bgMargins = UIEdgeInsets(bottom: 1)
        static let buttonsMargin: CGFloat = 30
        static let buttonHeight: CGFloat = 48
        static let minFieldHeight: CGFloat = 50
        static let fieldHeight: CGFloat = 64
    }

    struct Config {
        struct PostStream {
            let postConfigs: [Config]
        }

        var title: String?
        var subtitle: String?
        var imageURL: URL?
        var specsImage: UIImage?

        var join: Editorial.JoinInfo?
        var invite: Editorial.InviteInfo?
        var post: Post?
        var postStream: PostStream?

        init() {}
    }

    var config = Config() {
        didSet {
            updateConfig()
        }
    }

    fileprivate let bg = UIView()
    fileprivate let gradientView = UIView()
    fileprivate var gradientLayer = EditorialCell.generateGradientLayer()
    fileprivate let imageView = UIImageView()
    var editorialContentView: UIView { return bg }

    override init(frame: CGRect) {
        super.init(frame: frame)
        style()
        bindActions()
        arrange()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private static func generateGradientLayer() -> CAGradientLayer {
        let layer = CAGradientLayer()
        layer.locations = [0, 1]
        layer.colors = [
            UIColor(hex: 0x000000, alpha: 0.8).cgColor,
            UIColor(hex: 0x000000, alpha: 0.4).cgColor,
        ]
        layer.startPoint = CGPoint(x: 0.5, y: 1)
        layer.endPoint = CGPoint(x: 0.5, y: 0.43)
        return layer
    }

    func style() {
        bg.clipsToBounds = true
        bg.backgroundColor = .black
        gradientView.layer.addSublayer(gradientLayer)
        imageView.contentMode = .scaleAspectFill
    }

    func bindActions() {
    }

    func updateConfig() {
        if let url = config.imageURL {
            imageView.pin_setImage(from: url)
        }
        else {
            imageView.image = config.specsImage
        }
    }

    func arrange() {
        contentView.addSubview(bg)
        bg.addSubview(imageView)
        imageView.addSubview(gradientView)

        bg.snp.makeConstraints { make in
            make.edges.equalTo(contentView).inset(Size.bgMargins)
        }
        imageView.snp.makeConstraints { make in
            make.edges.equalTo(bg)
        }
        gradientView.snp.makeConstraints { make in
            make.edges.equalTo(imageView)
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layoutIfNeeded()
        CATransaction.begin()
        CATransaction.setValue(true, forKey: kCATransactionDisableActions)
        gradientLayer.frame = CGRect(origin: .zero, size: gradientView.frame.size)
        CATransaction.commit()
    }

    override func prepareForReuse() {
        config = Config()
    }
}

extension Editorial.Kind {
    var reuseIdentifier: String {
        switch self {
        case .post: return "EditorialPostCell"
        case .external: return "EditorialExternalCell"
        case .postStream: return "EditorialPostStreamCell"
        case .invite: return "EditorialInviteCell"
        case .join: return "EditorialJoinCell"
        }
    }

    var classType: UICollectionViewCell.Type {
        switch self {
        case .post: return EditorialPostCell.self
        case .external: return EditorialExternalCell.self
        case .postStream: return EditorialPostStreamCell.self
        case .invite: return EditorialInviteCell.self
        case .join: return EditorialJoinCell.self
        }
    }
}

extension EditorialCell.Config {
    static func fromEditorial(_ editorial: Editorial) -> EditorialCell.Config {
        var config = EditorialCell.Config()
        config.title = editorial.title
        config.subtitle = editorial.subtitle
        config.invite = editorial.invite
        config.join = editorial.join
        config.post = editorial.post

        if let posts = editorial.posts {
            let postConfigs = posts.map { editorialPost in
                return EditorialCell.Config.fromPost(editorialPost)
            }
            config.postStream = EditorialCell.Config.PostStream(postConfigs: postConfigs)
        }

        if let postImageURL = editorial.post?.firstImageURL {
            config.imageURL = postImageURL
        }
        else if let asset = editorial.images[.size1x1],
            let imageURL = asset.largeOrBest?.url
        {
            config.imageURL = imageURL
        }

        return config
    }

    static func fromPost(_ post: Ello.Post) -> EditorialCell.Config {
        var config = EditorialCell.Config()
        config.title = ""
        config.subtitle = ""
        config.post = post

        if let postImageURL = post.firstImageURL {
            config.imageURL = postImageURL
        }

        return config
    }
}
