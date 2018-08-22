////
///  FollowingScreen.swift
//

class FollowingScreen: HomeSubviewScreen, FollowingScreenProtocol {
    weak var delegate: FollowingScreenDelegate?

    private let newPostsButton = NewPostsButton()

    var newPostsButtonVisible: Bool {
        get { return newPostsButton.alpha > 0 }
        set {
            if newValue { showNewPostsButton() }
            else { hideNewPostsButton() }
        }
    }

    override func bindActions() {
        newPostsButton.addTarget(self, action: #selector(loadNewPosts), for: .touchUpInside)
    }

    override func style() {
        super.style()
        navigationBar.sizeClass = .large
    }

    override func arrange() {
        super.arrange()

        addSubview(newPostsButton)

        newPostsButton.snp.makeConstraints { make in
            make.centerX.equalTo(self)
            make.top.equalTo(self).offset(NewPostsButton.Size.top)
        }
        newPostsButton.alpha = 0

        arrangeHomeScreenNavBar(type: .following, navigationBar: navigationBar)
    }

    func showNewPostsButton() {
        elloAnimate {
            self.newPostsButton.alpha = 1
        }
    }

    func hideNewPostsButton() {
        elloAnimate {
            self.newPostsButton.alpha = 0
        }
    }
}

extension FollowingScreen {
    @objc
    func loadNewPosts() {
        delegate?.loadNewPosts()
    }
}

extension FollowingScreen: HomeScreenNavBar {
    @objc
    func homeScreenScrollToTop() {
        delegate?.scrollToTop()
    }
}
