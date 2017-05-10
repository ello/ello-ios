////
///  EditorialCell.swift
//

import SnapKit


class EditorialCell: UICollectionViewCell {

    struct Size {
        static let aspect: CGFloat = 1
        static let defaultMargin: CGFloat = 40
        static let subtitleButtonMargin: CGFloat = 36
        static let bgMargins = UIEdgeInsets(bottom: 1)
        static let buttonsMargin: CGFloat = 30
    }

    struct Config {
        var title: String?
        var subtitle: String?
        init() {}
    }

    var config = Config() {
        didSet {
            updateConfig()
        }
    }

    fileprivate let bg = UIView()
    fileprivate let titleLabel = StyledLabel(style: .giantWhite)

    override init(frame: CGRect) {
        super.init(frame: frame)
        style()
        bindActions()
        arrange()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func style() {
        bg.backgroundColor = .black
        titleLabel.numberOfLines = 0
    }

    func bindActions() {
    }

    func updateConfig() {
        titleLabel.text = config.title
    }

    func arrange() {
        contentView.addSubview(bg)
        contentView.addSubview(titleLabel)

        bg.snp.makeConstraints { make in
            make.edges.equalTo(contentView).inset(Size.bgMargins)
        }

        titleLabel.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(contentView).inset(Size.defaultMargin)
        }
    }

}

extension EditorialCell {

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
        }
    }

    var classType: UICollectionViewCell.Type {
        switch self {
        case .post: return EditorialPostCell.self
        case .external: return EditorialExternalCell.self
        case .postStream: return EditorialPostStreamCell.self
        }
    }
}


class EditorialPostCell: EditorialCell {
    static let reuseIdentifier = "EditorialPostCell"

    fileprivate let buttonsContainer = UIView()
    fileprivate let subtitleLabel = StyledLabel(style: .largeWhite)
    fileprivate let heartButton = UIButton()
    fileprivate let commentButton = UIButton()
    fileprivate let repostButton = UIButton()
    fileprivate let shareButton = UIButton()

    override func style() {
        super.style()

        subtitleLabel.numberOfLines = 0
        heartButton.setImage(.heartOutline, imageStyle: .white, for: .normal)
        commentButton.setImage(.commentsOutline, imageStyle: .white, for: .normal)
        repostButton.setImage(.repost, imageStyle: .white, for: .normal)
        shareButton.setImage(.share, imageStyle: .white, for: .normal)
    }

    override func bindActions() {
        super.bindActions()
    }

    override func updateConfig() {
        super.updateConfig()

        subtitleLabel.text = config.subtitle
    }

    override func arrange() {
        super.arrange()

        contentView.addSubview(buttonsContainer)
        contentView.addSubview(subtitleLabel)
        buttonsContainer.addSubview(heartButton)
        buttonsContainer.addSubview(commentButton)
        buttonsContainer.addSubview(repostButton)
        buttonsContainer.addSubview(shareButton)

        buttonsContainer.snp.makeConstraints { make in
            make.leading.bottom.trailing.equalTo(contentView).inset(Size.defaultMargin)
        }

        let buttons = [heartButton, commentButton, repostButton]
        buttons.eachPair { prevButton, button in
            button.snp.makeConstraints { make in
                make.top.bottom.equalTo(buttonsContainer)
            }

            if let prevButton = prevButton {
                button.snp.makeConstraints { make in
                    make.leading.equalTo(prevButton.snp.trailing).offset(Size.buttonsMargin)
                }
            }
            else {
            button.snp.makeConstraints { make in
                make.leading.equalTo(buttonsContainer)
            }
            }
        }

        shareButton.snp.makeConstraints { make in
            make.trailing.top.bottom.equalTo(buttonsContainer)
        }

        subtitleLabel.snp.makeConstraints { make in
            make.leading.equalTo(contentView).inset(Size.defaultMargin)
            make.trailing.lessThanOrEqualTo(contentView).inset(Size.defaultMargin).priority(Priority.required)
            make.bottom.equalTo(buttonsContainer.snp.top).offset(-Size.subtitleButtonMargin)
        }
    }
}


class EditorialPostStreamCell: EditorialCell {
    static let reuseIdentifier = "EditorialPostStreamCell"
}


class EditorialExternalCell: EditorialCell {
    static let reuseIdentifier = "EditorialExternalCell"

    fileprivate let subtitleLabel = StyledLabel(style: .largeWhite)

    override func style() {
        super.style()

        subtitleLabel.numberOfLines = 0
    }

    override func bindActions() {
        super.bindActions()
    }

    override func updateConfig() {
        super.updateConfig()

        subtitleLabel.text = config.subtitle
    }

    override func arrange() {
        super.arrange()

        contentView.addSubview(subtitleLabel)

        subtitleLabel.snp.makeConstraints { make in
            make.leading.bottom.equalTo(contentView).inset(Size.defaultMargin)
            make.trailing.lessThanOrEqualTo(contentView).inset(Size.defaultMargin).priority(Priority.required)
        }
    }
}
