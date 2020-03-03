////
///  ArtistInvitesScreen.swift
//

class ArtistInvitesScreen: HomeSubviewScreen {
    weak var delegate: ArtistInvitesScreenDelegate?
    private var usage: ArtistInvitesViewController.Usage

    init(usage: ArtistInvitesViewController.Usage) {
        self.usage = usage
        super.init(frame: .zero)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    required init(frame: CGRect) {
        self.usage = .loggedOut
        super.init(frame: frame)
    }

    override func style() {
        styleHomeScreenNavBar(navigationBar: navigationBar)
        navigationBar.sizeClass = .large
    }

    override func arrange() {
        super.arrange()
        arrangeHomeScreenNavBar(
            type: .artistInvites(loggedIn: usage == .loggedIn),
            navigationBar: navigationBar
        )
    }
}

extension ArtistInvitesScreen: HomeScreenNavBar {

    @objc
    func homeScreenScrollToTop() {
        delegate?.scrollToTop()
    }

}
