////
///  ArtistInviteAdminScreen.swift
//

class ArtistInviteAdminScreen: StreamableScreen, ArtistInviteAdminScreenProtocol {
    weak var delegate: ArtistInviteAdminScreenDelegate?

    private var tabBar = NestedTabBarView()
    private var unapprovedTab: NestedTabBarView.Tab!
    private var approvedTab: NestedTabBarView.Tab!
    private var selectedTab: NestedTabBarView.Tab!
    private var declinedTab: NestedTabBarView.Tab!

    var selectedSubmissionsStatus: ArtistInviteSubmission.Status = .approved {
        didSet {
            switch selectedSubmissionsStatus {
            case .approved: tabBar.select(tab: approvedTab)
            case .selected: tabBar.select(tab: selectedTab)
            case .unapproved: tabBar.select(tab: unapprovedTab)
            case .declined: tabBar.select(tab: declinedTab)
            case .unspecified: break
            }
        }
    }

    override func style() {
        navigationBar.sizeClass = .large
    }

    override func arrange() {
        super.arrange()

        let titleLabel = StyledLabel(style: .header)
        titleLabel.text = InterfaceString.ArtistInvites.AdminTitle

        navigationBar.addSubview(titleLabel)

        titleLabel.snp.makeConstraints { make in
            make.centerX.equalTo(navigationBar)
            make.top.equalTo(navigationBar).offset(StatusBar.Size.height + HomeScreenNavBarSize.typeOffset)
        }

        unapprovedTab = tabBar.createTab(title: InterfaceString.ArtistInvites.AdminUnapprovedTab)
        unapprovedTab.addTarget(self, action: #selector(tappedUnapprovedSubmissions))
        approvedTab = tabBar.createTab(title: InterfaceString.ArtistInvites.AdminApprovedTab)
        approvedTab.addTarget(self, action: #selector(tappedApprovedSubmissions))
        selectedTab = tabBar.createTab(title: InterfaceString.ArtistInvites.AdminSelectedTab)
        selectedTab.addTarget(self, action: #selector(tappedSelectedSubmissions))
        declinedTab = tabBar.createTab(title: InterfaceString.ArtistInvites.AdminDeclinedTab)
        declinedTab.addTarget(self, action: #selector(tappedDeclinedSubmissions))

        tabBar.addTab(unapprovedTab)
        tabBar.addTab(approvedTab)
        tabBar.addTab(selectedTab)
        tabBar.addTab(declinedTab)
        tabBar.select(tab: approvedTab)

        navigationBar.sizeClass = .large
        navigationBar.addSubview(tabBar)
        tabBar.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalTo(navigationBar)
        }
    }

}

extension ArtistInviteAdminScreen {

    @objc
    func tappedUnapprovedSubmissions() {
        delegate?.tappedUnapprovedSubmissions()
    }

    @objc
    func tappedApprovedSubmissions() {
        delegate?.tappedApprovedSubmissions()
    }

    @objc
    func tappedSelectedSubmissions() {
        delegate?.tappedSelectedSubmissions()
    }

    @objc
    func tappedDeclinedSubmissions() {
        delegate?.tappedDeclinedSubmissions()
    }
}
