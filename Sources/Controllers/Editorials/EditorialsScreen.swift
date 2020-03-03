////
///  EditorialsScreen.swift
//

class EditorialsScreen: HomeSubviewScreen, EditorialsScreenProtocol {
    weak var delegate: EditorialsScreenDelegate?
    private var usage: EditorialsViewController.Usage

    init(usage: EditorialsViewController.Usage) {
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
        navigationBar.sizeClass = .large
    }

    override func arrange() {
        super.arrange()

        arrangeHomeScreenNavBar(type: .editorials(loggedIn: usage == .loggedIn), navigationBar: navigationBar)
    }
}

extension EditorialsScreen: HomeScreenNavBar {

    @objc
    func homeScreenScrollToTop() {
        delegate?.scrollToTop()
    }

}
