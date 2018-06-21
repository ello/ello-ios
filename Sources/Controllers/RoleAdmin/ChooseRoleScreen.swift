////
///  ChooseRoleScreen.swift
//

class ChooseRoleScreen: NavBarScreen, ChooseRoleScreenProtocol {
    weak var delegate: ChooseRoleScreenDelegate?

    struct Size {
        static let defaultMargins = 10
        static let buttonHeight = 40
    }

    private let selectedRole: CategoryUser.Role?
    private let contentView = Container()
    private let categoryButton = UIButton()
    private let categoryLabel = StyledLabel(style: .white)
    private let moderatorButton = StyledButton(style: .roundedGrayOutline)
    private let curatorButton = StyledButton(style: .roundedGrayOutline)
    private let featuredButton = StyledButton(style: .roundedGrayOutline)
    private let verifyFeaturedButton = StyledButton(style: .roundedGrayOutline)

    init(selectedRole: CategoryUser.Role?) {
        self.selectedRole = selectedRole
        super.init(frame: .zero)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    required init(frame: CGRect) {
        fatalError("init(frame:) has not been implemented")
    }

    var categoryName: String = "" {
        didSet { categoryLabel.text = categoryName }
    }

    var categoryImageURL: URL? {
        didSet { categoryButton.pin_setImage(from: categoryImageURL) }
    }

    var canModerate: Bool = false {
        didSet { updateRoleButtons() }
    }

    override func style() {
        categoryLabel.textAlignment = .center
        categoryButton.setTitleColor(.white, for: .normal)
        categoryButton.imageView?.contentMode = .scaleAspectFill
        categoryButton.layer.masksToBounds = true
        categoryButton.layer.cornerRadius = 5
        categoryButton.layer.borderWidth = 1
        categoryButton.layer.borderColor = UIColor.greyA.cgColor
        categoryButton.isUserInteractionEnabled = false

        if let selectedRole = selectedRole {
            switch selectedRole {
            case .moderator: moderatorButton.style = .roundedBlack
            case .curator: curatorButton.style = .roundedBlack
            case .featured: featuredButton.style = .roundedBlack
            case .unspecified: break
            }
        }
    }

    override func setText() {
        navigationBar.title = InterfaceString.Category.RoleAdmin
        moderatorButton.title = InterfaceString.Category.Moderator
        curatorButton.title = InterfaceString.Category.Curator
        featuredButton.title = InterfaceString.Category.FeaturedUser
        verifyFeaturedButton.title = InterfaceString.Category.FeaturedUser
    }

    override func bindActions() {
        moderatorButton.addTarget(self, action: #selector(moderatorButtonTapped), for: .touchUpInside)
        curatorButton.addTarget(self, action: #selector(curatorButtonTapped), for: .touchUpInside)
        featuredButton.addTarget(self, action: #selector(featuredButtonTapped), for: .touchUpInside)
        verifyFeaturedButton.addTarget(self, action: #selector(featuredButtonTapped), for: .touchUpInside)
    }

    override func arrange() {
        arrange(contentView: nil)

        addSubview(contentView)

        contentView.snp.makeConstraints { make in
            make.top.equalTo(navigationBar.snp.bottom)
            make.leading.trailing.bottom.equalTo(self)
        }

        [categoryButton, moderatorButton, curatorButton, featuredButton].eachPair { prevView, button in
            contentView.addSubview(button)

            button.snp.makeConstraints { make in
                make.leading.trailing.equalTo(contentView).inset(Size.defaultMargins)
                make.height.equalTo(Size.buttonHeight)

                if let prevView = prevView {
                    make.top.equalTo(prevView.snp.bottom).offset(Size.defaultMargins)
                }
                else {
                    make.top.equalTo(contentView).offset(Size.defaultMargins)
                }
            }
        }

        categoryButton.addSubview(categoryLabel)

        categoryLabel.snp.makeConstraints { make in
            make.edges.equalTo(categoryButton)
        }

        contentView.addSubview(verifyFeaturedButton)
        verifyFeaturedButton.snp.makeConstraints { make in
            make.edges.equalTo(moderatorButton)
        }
    }

    private func updateRoleButtons() {
        if canModerate {
            moderatorButton.isVisible = true
            curatorButton.isVisible = true
            featuredButton.isVisible = true
            verifyFeaturedButton.isVisible = false
        }
        else {
            moderatorButton.isVisible = false
            curatorButton.isVisible = false
            featuredButton.isVisible = false
            verifyFeaturedButton.isVisible = true
        }
    }
}

extension ChooseRoleScreen {
    @objc
    func moderatorButtonTapped() {
        delegate?.moderatorChosen()
    }

    @objc
    func curatorButtonTapped() {
        delegate?.curatorChosen()
    }

    @objc
    func featuredButtonTapped() {
        delegate?.featuredChosen()
    }
}
