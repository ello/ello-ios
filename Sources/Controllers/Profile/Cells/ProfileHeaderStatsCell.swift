////
///  ProfileHeaderStatsCell.swift
//
// swiftlint:disable comma

class ProfileHeaderStatsCell: ProfileHeaderCell {
    static let reuseIdentifier = "ProfileHeaderStatsCell"

    struct Size {
        static let height: CGFloat = 60
        static let horizontalMargin: CGFloat = 47
        static let horizontalInset: CGFloat = -3
        static let verticalMargin: CGFloat = 1
        static let countVerticalOffset: CGFloat = 15
        static let captionVerticalOffset: CGFloat = 3
        static let grayInsets: CGFloat = 15
    }

    var postsCount: String {
        get { return postsCountLabel.text ?? "" }
        set { postsCountLabel.text = newValue }
    }
    var followingCount: String {
        get { return followingCountLabel.text ?? "" }
        set { followingCountLabel.text = newValue }
    }
    var followersCount: String {
        get { return followersCountLabel.text ?? "" }
        set { followersCountLabel.text = newValue }
    }
    var lovesCount: String {
        get { return lovesCountLabel.text ?? "" }
        set { lovesCountLabel.text = newValue }
    }
    var followingEnabled = true
    var followersEnabled = true

    private let postsCountLabel = UILabel()
    private let followingCountLabel = UILabel()
    private let followersCountLabel = UILabel()
    private let lovesCountLabel = UILabel()
    private var countLabels: [UILabel] {
        return [postsCountLabel, followingCountLabel, followersCountLabel, lovesCountLabel]
    }

    private let postsCaptionLabel = UILabel()
    private let followingCaptionLabel = UILabel()
    private let followersCaptionLabel = UILabel()
    private let lovesCaptionLabel = UILabel()
    private var captionLabels: [UILabel] {
        return [postsCaptionLabel, followingCaptionLabel, followersCaptionLabel, lovesCaptionLabel]
    }

    private let postsButton = UIButton()
    private let followingButton = UIButton()
    private let followersButton = UIButton()
    private let lovesButton = UIButton()

    private var allThreeViews: [(count: UILabel, caption: UILabel, button: UIButton)] { return [
        (postsCountLabel,     postsCaptionLabel,     postsButton),
        (followingCountLabel, followingCaptionLabel, followingButton),
        (followersCountLabel, followersCaptionLabel, followersButton),
        (lovesCountLabel,     lovesCaptionLabel,     lovesButton),
    ]}

    private let grayLine = UIView()
    var grayLineVisible: Bool {
        get { return !grayLine.isHidden }
        set { grayLine.isVisible = newValue }
    }

    override func style() {
        backgroundColor = .white

        for countLabel in countLabels {
            countLabel.font = .defaultFont(16)
            countLabel.textColor = .black
            countLabel.textAlignment = .center
        }

        for captionLabel in captionLabels {
            captionLabel.font = .defaultFont(10)
            captionLabel.textColor = .greyA
            captionLabel.textAlignment = .center
        }

        grayLine.backgroundColor = .greyE5
    }

    override func bindActions() {
        postsButton.addTarget(self, action: #selector(postsButtonTapped), for: .touchUpInside)
        followingButton.addTarget(self, action: #selector(followingButtonTapped), for: .touchUpInside)
        followersButton.addTarget(self, action: #selector(followersButtonTapped), for: .touchUpInside)
        lovesButton.addTarget(self, action: #selector(lovesButtonTapped), for: .touchUpInside)

        postsButton.addTarget(self, action: #selector(buttonDown(_:)), for: [.touchDown, .touchDragEnter])
        followingButton.addTarget(self, action: #selector(buttonDown(_:)), for: [.touchDown, .touchDragEnter])
        followersButton.addTarget(self, action: #selector(buttonDown(_:)), for: [.touchDown, .touchDragEnter])
        lovesButton.addTarget(self, action: #selector(buttonDown(_:)), for: [.touchDown, .touchDragEnter])

        postsButton.addTarget(self, action: #selector(buttonUp(_:)), for: [.touchUpInside, .touchCancel, .touchDragExit])
        followingButton.addTarget(self, action: #selector(buttonUp(_:)), for: [.touchUpInside, .touchCancel, .touchDragExit])
        followersButton.addTarget(self, action: #selector(buttonUp(_:)), for: [.touchUpInside, .touchCancel, .touchDragExit])
        lovesButton.addTarget(self, action: #selector(buttonUp(_:)), for: [.touchUpInside, .touchCancel, .touchDragExit])
    }

    override func setText() {
        postsCaptionLabel.text = InterfaceString.Profile.PostsCount
        followingCaptionLabel.text = InterfaceString.Profile.FollowingCount
        followersCaptionLabel.text = InterfaceString.Profile.FollowersCount
        lovesCaptionLabel.text = InterfaceString.Profile.LovesCount
    }

    override func arrange() {
        addSubview(grayLine)

        grayLine.snp.makeConstraints { make in
            make.height.equalTo(1)
            make.bottom.equalTo(self)
            make.leading.trailing.equalTo(self).inset(Size.grayInsets)
        }

        var prevCountLabel: UIView?
        let spaceBetween: CGFloat = (UIScreen.main.bounds.width - (Size.horizontalMargin * 2)) / CGFloat(allThreeViews.count - 1)
        for (index, (count: countLabel, caption: captionLabel, button: button)) in allThreeViews.enumerated() {
            addSubview(countLabel)
            addSubview(captionLabel)
            addSubview(button)

            countLabel.snp.makeConstraints { make in
                let x = (spaceBetween * CGFloat(index)) + Size.horizontalMargin
                if let prevCountLabel = prevCountLabel {
                    make.width.equalTo(prevCountLabel)
                }
                make.centerX.equalTo(self.snp.leading).offset(x)
                make.top.equalTo(self).offset(Size.countVerticalOffset)
            }

            captionLabel.snp.makeConstraints { make in
                make.centerX.equalTo(countLabel)
                make.top.equalTo(countLabel.snp.bottom).offset(Size.captionVerticalOffset)
            }

            button.snp.makeConstraints { make in
                make.leading.trailing.equalTo(countLabel)
                make.top.bottom.equalTo(self)
            }

            prevCountLabel = countLabel
        }
    }
}

extension ProfileHeaderStatsCell {

    override func prepareForReuse() {
        super.prepareForReuse()
        for countLabel in countLabels {
            countLabel.text = ""
        }
        grayLine.isVisible = true
    }

    @objc
    func postsButtonTapped() {
        let responder: PostsTappedResponder? = findResponder()
        responder?.onPostsTapped()
    }

    @objc
    func followingButtonTapped() {
        guard followingEnabled else { return }

        let responder: ProfileHeaderResponder? = findResponder()
        responder?.onFollowingTapped()
    }

    @objc
    func followersButtonTapped() {
        guard followersEnabled else { return }

        let responder: ProfileHeaderResponder? = findResponder()
        responder?.onFollowersTapped()
    }

    @objc
    func lovesButtonTapped() {
        let responder: ProfileHeaderResponder? = findResponder()
        responder?.onLovesTapped()
    }
}

extension ProfileHeaderStatsCell {
    @objc
    func buttonDown(_ touchedButton: UIButton) {
        for (_, captionLabel, button) in allThreeViews {
            guard button == touchedButton else { continue }
            captionLabel.textColor = .black
        }
    }

    @objc
    func buttonUp(_ touchedButton: UIButton) {
        for (_, captionLabel, _) in allThreeViews {
            captionLabel.textColor = .greyA
        }
    }
}
