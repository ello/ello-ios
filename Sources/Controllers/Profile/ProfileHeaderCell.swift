////
///  ProfileHeaderCell.swift
//

@objc
protocol EditProfileResponder {
    func onEditProfile()
}

@objc
protocol PostsTappedResponder {
    func onPostsTapped()
}

@objc
protocol ProfileHeaderResponder {
    func onCategoryBadgeTapped(_ cell: UICollectionViewCell)
    func onLovesTapped(_ cell: UICollectionViewCell)
    func onFollowersTapped(_ cell: UICollectionViewCell)
    func onFollowingTapped(_ cell: UICollectionViewCell)
}

class ProfileHeaderCell: UICollectionViewCell {

    static let reuseIdentifier = "ProfileHeaderCell"

    let headerView = ProfileHeaderCompactView()
    var calculatedCellHeights: CalculatedCellHeights? {
        didSet {
            headerView.calculatedCellHeights = calculatedCellHeights
        }
    }

    var avatarView: ProfileAvatarView { get { return headerView.avatarView } }
    var namesView: ProfileNamesView { get { return headerView.namesView } }
    var totalCountView: ProfileTotalCountView { get { return headerView.totalCountView } }
    var statsView: ProfileStatsView { get { return headerView.statsView } }
    var bioView: ProfileBioView { get { return headerView.bioView } }
    var locationView: ProfileLocationView { get { return headerView.locationView } }
    var linksView: ProfileLinksView { get { return headerView.linksView } }

    weak var webLinkDelegate: WebLinkDelegate? {
        set {
            bioView.webLinkDelegate = newValue
            linksView.webLinkDelegate = newValue
        }
        get { return bioView.webLinkDelegate }
    }

    weak var userDelegate: UserDelegate?

    var user: User?
    var currentUser: User?

    var onHeightMismatch: OnCalculatedCellHeightsMismatch?

    // this little hack prevents constraints from breaking on initial load
    override var bounds: CGRect {
        didSet {
          contentView.frame = bounds
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        style()
        bindActions()
        arrange()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    fileprivate func style() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear
    }

    fileprivate func bindActions() {
        avatarView.onHeightMismatch = { avatarHeight in
            guard var calculatedCellHeights = self.calculatedCellHeights else { return }
            calculatedCellHeights.profileAvatar = avatarHeight
            self.recalculateHeight(calculatedCellHeights)
        }

        totalCountView.onHeightMismatch = { totalCountHeight in
            guard var calculatedCellHeights = self.calculatedCellHeights else { return }
            calculatedCellHeights.profileTotalCount = totalCountHeight
            self.recalculateHeight(calculatedCellHeights)
        }

        bioView.onHeightMismatch = { bioHeight in
            guard var calculatedCellHeights = self.calculatedCellHeights else { return }
            calculatedCellHeights.profileBio = bioHeight
            self.recalculateHeight(calculatedCellHeights)
        }

        linksView.onHeightMismatch = { linkHeight in
            guard var calculatedCellHeights = self.calculatedCellHeights else { return }
            calculatedCellHeights.profileLinks = linkHeight
            self.recalculateHeight(calculatedCellHeights)
        }

        locationView.onHeightMismatch = { linkHeight in
            guard var calculatedCellHeights = self.calculatedCellHeights else { return }
            calculatedCellHeights.profileLocation = linkHeight
            self.recalculateHeight(calculatedCellHeights)
        }
    }

    fileprivate func arrange() {
        contentView.addSubview(headerView)

        headerView.snp.makeConstraints { make in
            make.edges.equalTo(self.contentView)
        }
    }

    override func prepareForReuse() {
        onHeightMismatch = nil

        avatarView.prepareForReuse()
        statsView.prepareForReuse()
        totalCountView.prepareForReuse()
        namesView.prepareForReuse()
        bioView.prepareForReuse()
        locationView.prepareForReuse()
        linksView.prepareForReuse()
    }

    fileprivate func recalculateHeight(_ _calculatedCellHeights: CalculatedCellHeights) {
        var calculatedCellHeights = _calculatedCellHeights
        calculatedCellHeights.oneColumn = ProfileHeaderCellSizeCalculator.calculateHeightFromCellHeights(calculatedCellHeights)
        self.calculatedCellHeights = calculatedCellHeights
        onHeightMismatch?(calculatedCellHeights)
    }
}
