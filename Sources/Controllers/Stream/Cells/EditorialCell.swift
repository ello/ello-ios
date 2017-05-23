////
///  EditorialCell.swift
//

import SnapKit


@objc
protocol EditorialResponder: class {
    func submitInvite(cell: UICollectionViewCell, emails: String)
    func submitJoin(cell: UICollectionViewCell, email: String, username: String, password: String)
}


class EditorialCell: UICollectionViewCell {

    struct Size {
        static let aspect: CGFloat = 1
        static let smallTopMargin: CGFloat = 28
        static let defaultMargin = UIEdgeInsets(top: 18, left: 18, bottom: 17, right: 15)
        static let textFieldMargin: CGFloat = 10
        static let arrowMargin: CGFloat = 17
        static let subtitleButtonMargin: CGFloat = 36
        static let bgMargins = UIEdgeInsets(bottom: 1)
        static let buttonsMargin: CGFloat = 30
        static let buttonHeight: CGFloat = 48
    }

    struct Config {
        struct Join {
            var email: String?
            var username: String?
            var password: String?
        }
        struct Invite {
            var emails: String
            var sent: Bool
        }
        var title: String?
        var subtitle: String?
        var imageURL: URL?
        var specsImage: UIImage?
        var join: Join?
        var invite: Invite?
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
        gradientLayer.frame = CGRect(origin: .zero, size: gradientView.frame.size)
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
