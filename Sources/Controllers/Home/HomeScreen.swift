////
///  HomeScreen.swift
//

class HomeScreen: StreamableScreen, HomeScreenProtocol {
    weak var delegate: HomeScreenDelegate?
    let controllerContainer: UIView = Container()

    override func arrange() {
        super.arrange()

        addSubview(controllerContainer)

        controllerContainer.snp.makeConstraints { make in
            make.edges.equalTo(self)
        }
    }
}


@objc
protocol HomeScreenNavBar: class {
    @objc func homeScreenScrollToTop()
    @objc optional func homeScreenEditorialsTapped()
    @objc optional func homeScreenArtistInvitesTapped()
    @objc optional func homeScreenFollowingTapped()
    @objc optional func homeScreenDiscoverTapped()
}

struct HomeScreenNavBarSize {
    static let typeOffset: CGFloat = 18.625
    static let tabBarOffset: CGFloat = 4.5
}

private typealias Size = HomeScreenNavBarSize

enum HomeScreenType {
    case editorials(loggedIn: Bool)
    case artistInvites(loggedIn: Bool)
    case following
    case discover
}

extension HomeScreenNavBar {

    func arrangeHomeScreenNavBar(type: HomeScreenType, navigationBar: UIView) {
        let logoButton = UIButton()
        logoButton.setImage(.elloType, imageStyle: .normal, for: .normal)
        logoButton.addTarget(self, action: #selector(homeScreenScrollToTop), for: .touchUpInside)

        let tabBar = NestedTabBarView()
        let editorialsTab = tabBar.createTab(title: InterfaceString.Editorials.NavbarTitle)
        let otherTab = tabBar.createTab()
        let middleTab = tabBar.createTab(title: InterfaceString.ArtistInvites.Title)

        editorialsTab.addTarget(self, action: #selector(homeScreenEditorialsTapped))
        middleTab.addTarget(self, action: #selector(homeScreenArtistInvitesTapped))

        tabBar.addTab(editorialsTab)
        tabBar.addTab(middleTab)
        tabBar.addTab(otherTab)

        switch type {
        case let .editorials(loggedIn):
            tabBar.select(tab: editorialsTab)

            if loggedIn {
                otherTab.title = InterfaceString.Following.Title
                otherTab.addTarget(self, action: #selector(homeScreenFollowingTapped))
            }
            else {
                otherTab.title = InterfaceString.Discover.Title
                otherTab.addTarget(self, action: #selector(homeScreenDiscoverTapped))
            }
        case .following:
            tabBar.select(tab: otherTab)
            otherTab.title = InterfaceString.Following.Title
        case let .artistInvites(loggedIn):
            tabBar.select(tab: middleTab)

            if loggedIn {
                otherTab.title = InterfaceString.Following.Title
                otherTab.addTarget(self, action: #selector(homeScreenFollowingTapped))
            }
            else {
                otherTab.title = InterfaceString.Discover.Title
                otherTab.addTarget(self, action: #selector(homeScreenDiscoverTapped))
            }
        case .discover:
            tabBar.select(tab: otherTab)
            otherTab.title = InterfaceString.Discover.Title
        }

        navigationBar.addSubview(logoButton)
        navigationBar.addSubview(tabBar)

        logoButton.snp.makeConstraints { make in
            make.centerX.equalTo(navigationBar)
            make.top.equalTo(navigationBar).offset(StatusBar.Size.height + HomeScreenNavBarSize.typeOffset)
        }

        tabBar.snp.makeConstraints { make in
            make.leading.trailing.equalTo(navigationBar)
            make.top.equalTo(logoButton.snp.bottom).offset(HomeScreenNavBarSize.tabBarOffset)
        }
    }
}
