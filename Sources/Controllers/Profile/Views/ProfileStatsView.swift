////
///  ProfileStatsView.swift
//

class ProfileStatsView: ProfileBaseView {
    struct Size {
        static let height: CGFloat = 60
        static let horizontalMargin: CGFloat = 47
        static let horizontalInset: CGFloat = -3
        static let verticalMargin: CGFloat = 1
        static let countVerticalOffset: CGFloat = 15
        static let captionVerticalOffset: CGFloat = 3
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

    fileprivate let postsCountLabel = UILabel()
    fileprivate let followingCountLabel = UILabel()
    fileprivate let followersCountLabel = UILabel()
    fileprivate let lovesCountLabel = UILabel()
    fileprivate var countLabels: [UILabel] {
        return [postsCountLabel, followingCountLabel, followersCountLabel, lovesCountLabel]
    }

    fileprivate let postsCaptionLabel = UILabel()
    fileprivate let followingCaptionLabel = UILabel()
    fileprivate let followersCaptionLabel = UILabel()
    fileprivate let lovesCaptionLabel = UILabel()
    fileprivate var captionLabels: [UILabel] {
        return [postsCaptionLabel, followingCaptionLabel, followersCaptionLabel, lovesCaptionLabel]
    }

    fileprivate let postsButton = UIButton()
    fileprivate let followingButton = UIButton()
    fileprivate let followersButton = UIButton()
    fileprivate let lovesButton = UIButton()

    fileprivate var allThreeViews: [(count: UILabel, caption: UILabel, button: UIButton)] { return [
        (postsCountLabel,     postsCaptionLabel,     postsButton),
        (followingCountLabel, followingCaptionLabel, followingButton),
        (followersCountLabel, followersCaptionLabel, followersButton),
        (lovesCountLabel,     lovesCaptionLabel,     lovesButton),
    ]}

    fileprivate let grayLine = UIView()
    var grayLineVisible: Bool {
        get { return !grayLine.isHidden }
        set { grayLine.isHidden = !newValue }
    }
}

extension ProfileStatsView {

    override func style() {
        backgroundColor = .white

        for countLabel in countLabels {
            countLabel.font = .defaultFont(16)
            countLabel.textColor = .black
            countLabel.textAlignment = .center
        }

        for captionLabel in captionLabels {
            captionLabel.font = .defaultFont(10)
            captionLabel.textColor = .greyA()
            captionLabel.textAlignment = .center
        }

        grayLine.backgroundColor = .greyE5()
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
            make.leading.trailing.equalTo(self).inset(ProfileBaseView.Size.grayInset)
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

    func prepareForReuse() {
        for countLabel in countLabels {
            countLabel.text = ""
        }
        grayLine.isHidden = false
    }
}

extension ProfileStatsView {

    func postsButtonTapped() {
        let responder = target(forAction: #selector(PostsTappedResponder.onPostsTapped), withSender: self) as? PostsTappedResponder
        responder?.onPostsTapped()
    }

    func followingButtonTapped() {
        guard let cell: UICollectionViewCell = self.findParentView() else { return }

        let responder = target(forAction: #selector(ProfileHeaderResponder.onFollowingTapped(_:)), withSender: self) as? ProfileHeaderResponder
        responder?.onFollowingTapped(cell)
    }

    func followersButtonTapped() {
        guard let cell: UICollectionViewCell = self.findParentView() else { return }

        let responder = target(forAction: #selector(ProfileHeaderResponder.onFollowersTapped(_:)), withSender: self) as? ProfileHeaderResponder
        responder?.onFollowersTapped(cell)
    }

    func lovesButtonTapped() {
        guard let cell: UICollectionViewCell = self.findParentView() else { return }

        let responder = target(forAction: #selector(ProfileHeaderResponder.onLovesTapped(_:)), withSender: self) as? ProfileHeaderResponder
        responder?.onLovesTapped(cell)
    }
}

extension ProfileStatsView {
    func buttonDown(_ touchedButton: UIButton) {
        for (_, captionLabel, button) in allThreeViews {
            guard button == touchedButton else { continue }
            captionLabel.textColor = .black
        }
    }

    func buttonUp(_ touchedButton: UIButton) {
        for (_, captionLabel, _) in allThreeViews {
            captionLabel.textColor = .greyA()
        }
    }
}

extension ProfileStatsView: ProfileViewProtocol {}
