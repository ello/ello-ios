////
///  CategoryDetailScreen.swift
//

import SnapKit


class CategoryDetailScreen: Screen {
    struct Size {
        static let defaultMargin: CGFloat = 10
        static let closeButtonMargin: CGFloat = calculateButtonMargin()
        static let lineMargin: CGFloat = 10
        static let closeSize: CGFloat = 30
        static let textSideMargin: CGFloat = 15
        static let sectionSpacing: CGFloat = 35
        static let lineHeight: CGFloat = 1

        static func calculateButtonMargin() -> CGFloat {
            return Globals.isIphoneX ? 20 : 10
        }
    }

    struct Config {
        let title: String
        let description: String
        let imageURL: URL?
        let user: User?
        let isSubscribed: Bool

        init(title: String = "", description: String = "", imageURL: URL? = nil, user: User? = nil, isSubscribed: Bool = false) {
            self.title = title
            self.description = description
            self.imageURL = imageURL
            self.user = user
            self.isSubscribed = isSubscribed
        }
    }

    weak var delegate: CategoryDetailDelegate?
    var headerView: UIView { return categoryHeaderView }

    private let closeButton = UIButton()
    private let scrollView = UIScrollView()
    private var scrollViewWidthConstraint: Constraint!
    private let categoryHeaderView = CategoryDetailHeaderView()
    private let aboutLabel = StyledLabel(style: .bold)

    private let moderatorsContainer = Container()
    private let moderatorsLabel = StyledLabel(style: .largeBoldGray)
    private var moderatorViews: [UIView] = []
    private var moderatorsContainerCollapsed: Constraint!

    private let curatorsContainer = Container()
    private let curatorsLabel = StyledLabel(style: .largeBoldGray)
    private var curatorViews: [UIView] = []
    private var curatorsContainerSpacing: Constraint!
    private var curatorsContainerCollapsed: Constraint!

    var config: Config = Config() {
        didSet {
            updateConfig()
            categoryHeaderView.config = CategoryDetailHeaderView.Config(
                title: config.title,
                imageURL: config.imageURL,
                user: config.user,
                isSubscribed: config.isSubscribed
                )
        }
    }

    override func updateConstraints() {
        super.updateConstraints()
        scrollViewWidthConstraint.update(offset: frame.size.width)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        scrollViewWidthConstraint.update(offset: frame.size.width)
    }

    override func setText() {
        moderatorsLabel.text = InterfaceString.Category.Moderators
        curatorsLabel.text = InterfaceString.Category.Curators
    }

    override func style() {
        if #available(iOS 11.0, *) {
            scrollView.contentInsetAdjustmentBehavior = .never
        }
        backgroundColor = .white

        closeButton.setImage(.x, imageStyle: .white, for: .normal)
        closeButton.layer.masksToBounds = true
        closeButton.layer.cornerRadius = Size.closeSize / 2
        closeButton.backgroundColor = .dimmedBlackBackground

        aboutLabel.isMultiline = true
    }

    override func bindActions() {
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
    }

    override func arrange() {
        addSubview(scrollView)
        addSubview(closeButton)

        scrollView.addSubview(categoryHeaderView)
        scrollView.addSubview(aboutLabel)

        let moderatorsLine = generateSectionLine()
        scrollView.addSubview(moderatorsContainer)
        moderatorsContainer.addSubview(moderatorsLabel)
        moderatorsContainer.addSubview(moderatorsLine)

        let curatorsLine = generateSectionLine()
        scrollView.addSubview(curatorsContainer)
        curatorsContainer.addSubview(curatorsLabel)
        curatorsContainer.addSubview(curatorsLine)

        closeButton.snp.makeConstraints { make in
            make.top.trailing.equalTo(self).inset(Size.closeButtonMargin)
            make.size.equalTo(Size.closeSize)
        }

        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(self)
        }

        let scrollWidthGuide = UILayoutGuide()
        scrollView.addLayoutGuide(scrollWidthGuide)
        scrollWidthGuide.snp.makeConstraints { make in
            make.leading.trailing.equalTo(scrollView)
            scrollViewWidthConstraint = make.width.equalTo(frame.size.width).priority(Priority.required).constraint
        }

        categoryHeaderView.snp.makeConstraints { make in
            make.top.equalTo(scrollView)
            make.leading.trailing.equalTo(scrollWidthGuide)
            make.height.equalTo(CategoryDetailHeaderView.Size.height)
        }

        aboutLabel.snp.makeConstraints { make in
            make.leading.trailing.equalTo(scrollWidthGuide).inset(Size.textSideMargin)
            make.top.equalTo(categoryHeaderView.snp.bottom).offset(Size.textSideMargin)
        }

        moderatorsContainer.snp.makeConstraints { make in
            make.top.equalTo(aboutLabel.snp.bottom).offset(Size.sectionSpacing)
            make.leading.trailing.equalTo(scrollWidthGuide).inset(Size.textSideMargin)
            moderatorsContainerCollapsed = make.height.equalTo(0).priority(Priority.required).constraint
        }
        moderatorsContainerCollapsed.deactivate()

        moderatorsLabel.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(moderatorsContainer)
        }

        moderatorsLine.snp.makeConstraints { make in
            make.leading.trailing.equalTo(moderatorsContainer)
            make.top.equalTo(moderatorsLabel.snp.bottom).offset(Size.defaultMargin)
        }

        curatorsContainer.snp.makeConstraints { make in
            curatorsContainerSpacing = make.top.equalTo(moderatorsContainer.snp.bottom).offset(Size.sectionSpacing).constraint
            make.leading.trailing.equalTo(scrollWidthGuide).inset(Size.textSideMargin)
            curatorsContainerCollapsed = make.height.equalTo(0).priority(Priority.required).constraint

            make.bottom.equalTo(scrollView).inset(Size.defaultMargin)
        }
        curatorsContainerCollapsed.deactivate()

        curatorsLabel.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(curatorsContainer)
        }
        curatorsLine.snp.makeConstraints { make in
            make.leading.trailing.equalTo(curatorsContainer)
            make.top.equalTo(curatorsLabel.snp.bottom).offset(Size.lineMargin)
        }
    }

    private func generateSectionLine() -> UIView {
        let view = UIView()
        view.backgroundColor = .greyA
        view.snp.makeConstraints { make in
            make.height.equalTo(Size.lineHeight)
        }
        return view
    }

    private func updateConfig() {
        aboutLabel.text = config.description
    }

    func updateUsers(moderators: [User], curators: [User]) {
        curatorsContainerSpacing.update(offset: moderators.isEmpty ? 0 : Size.sectionSpacing)

        moderatorViews = updateUserContainer(container: moderatorsContainer, label: moderatorsLabel,
            collapsedConstraint: moderatorsContainerCollapsed,
            users: moderators, prevViews: moderatorViews
            )
        curatorViews = updateUserContainer(container: curatorsContainer, label: curatorsLabel,
            collapsedConstraint: curatorsContainerCollapsed,
            users: curators, prevViews: curatorViews
            )
    }

    private func updateUserContainer(container: UIView, label: UIView, collapsedConstraint: Constraint, users: [User], prevViews: [UIView]) -> [UIView] {
        collapsedConstraint.set(isActivated: users.count == 0)
        container.isVisible = users.count > 0

        prevViews.forEach { $0.removeFromSuperview() }
        let newViews = users.map { ModeratorView(user: $0) }
        newViews.eachPair { prev, view, isLast in
            container.addSubview(view)

            view.snp.makeConstraints { make in
                make.leading.trailing.equalTo(container)

                if let prev = prev {
                    make.top.equalTo(prev.snp.bottom)
                }
                else {
                    make.top.equalTo(label.snp.bottom).offset(Size.lineMargin)
                }

                if isLast {
                    make.bottom.equalTo(container)
                }
            }
        }

        return newViews
    }
}

extension CategoryDetailScreen: CategoryDetailScreenProtocol {
    @objc
    func closeButtonTapped() {
        delegate?.closeController()
    }
}

extension CategoryDetailScreen.Config {

    init(category: Category, pageHeader: PageHeader, isSubscribed: Bool) {
        title = category.name
        description = category.categoryDescription ?? ""
        imageURL = pageHeader.tileURL
        self.user = pageHeader.user
        self.isSubscribed = isSubscribed
    }
}
