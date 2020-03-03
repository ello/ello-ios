////
///  RoleAdminScreen.swift
//

import SnapKit


class RoleAdminScreen: NavBarScreen, RoleAdminScreenProtocol {
    weak var delegate: RoleAdminScreenDelegate?

    struct Size {
        static let addButtonSpacing: CGFloat = 20
        static let buttonSpacing: CGFloat = 10
        static let buttonHeight: CGFloat = 40
        static let defaultMargins: CGFloat = 15
        static let bottomButtonMargin: CGFloat = 10
        static let innerButtonMargin: CGFloat = 10
        static let labelCenterAdjustment: CGFloat = 4
    }

    struct RoleInfo {
        let categoryName: String
        let imageURL: URL?
        let role: CategoryUser.Role
        let currentUserCanEdit: Bool
        let currentUserCanDelete: Bool
    }

    private let scrollView = UIScrollView()
    private let addButton = StyledButton(style: .roundedGrayOutline)
    private let rolesSeparator = Line(color: .greyF2)
    private let rolesContainer = Container()

    override func style() {
        if #available(iOS 11.0, *) {
            scrollView.contentInsetAdjustmentBehavior = .never
        }

        var insets = scrollView.contentInset
        insets.top = ElloNavigationBar.Size.height
        insets.bottom = ElloTabBar.Size.height
        scrollView.contentInset = insets
        scrollView.scrollIndicatorInsets = insets
    }

    override func bindActions() {
        addButton.addTarget(self, action: #selector(addButtonTapped(_:)), for: .touchUpInside)
    }

    override func setText() {
        navigationBar.title = InterfaceString.Category.RoleAdmin
        addButton.title = InterfaceString.Add
    }

    override func arrange() {
        arrange(contentView: scrollView)

        scrollView.addSubview(addButton)
        scrollView.addSubview(rolesSeparator)
        scrollView.addSubview(rolesContainer)

        let scrollWidthAnchor = UIView()
        scrollView.addSubview(scrollWidthAnchor)
        scrollWidthAnchor.snp.makeConstraints { make in
            make.leading.trailing.equalTo(scrollView)
            make.width.equalTo(self).priority(Priority.required)
        }

        addButton.snp.makeConstraints { make in
            make.leading.trailing.equalTo(scrollView).inset(Size.defaultMargins)
            make.height.equalTo(Size.buttonHeight)
            make.top.equalTo(scrollView)
        }

        rolesSeparator.snp.makeConstraints { make in
            make.leading.trailing.equalTo(scrollView)
            make.top.equalTo(addButton.snp.bottom).offset(Size.addButtonSpacing)
        }

        rolesContainer.snp.makeConstraints { make in
            make.leading.trailing.equalTo(scrollView)
            make.top.equalTo(rolesSeparator.snp.bottom).offset(Size.addButtonSpacing)
            make.bottom.equalTo(scrollView)
        }
    }

    func updateRoles(_ roles: [RoleInfo]) {
        for view in rolesContainer.subviews {
            view.removeFromSuperview()
        }

        if roles.count == 0 {
            let label = StyledLabel(style: .gray)
            label.text = InterfaceString.Category.NoRoles
            rolesContainer.addSubview(label)
            label.snp.makeConstraints { make in
                make.centerX.equalTo(rolesContainer)
                make.top.bottom.equalTo(rolesContainer).inset(Size.defaultMargins)
            }
        }
        else {
            let roleViews: [UIView] = roles.map { roleInfo in
                let editButton = UIButton()
                let editImage = UIImageView()
                let removeButton = UIButton()
                let label = UILabel()

                editImage.image = InterfaceImage.pencil.whiteImage
                removeButton.setImages(.xBox, style: .white)
                label.attributedText = NSAttributedString(
                    label: roleInfo.role.title + " in ",
                    style: .white
                ) + NSAttributedString(label: roleInfo.categoryName, style: .whiteUnderlined)

                if let imageURL = roleInfo.imageURL {
                    editButton.pin_setImage(from: imageURL)
                }
                else {
                    editButton.backgroundColor = .greyA
                }
                editButton.adjustsImageWhenDisabled = false
                editButton.imageView?.contentMode = .scaleAspectFill
                editButton.layer.masksToBounds = true
                editButton.layer.cornerRadius = 5

                editImage.isVisible = roleInfo.currentUserCanEdit
                editButton.isEnabled = roleInfo.currentUserCanEdit
                removeButton.isEnabled = roleInfo.currentUserCanDelete

                let view = Container()
                view.addSubview(editButton)
                view.addSubview(editImage)
                view.addSubview(removeButton)
                view.addSubview(label)

                editButton.snp.makeConstraints { make in
                    make.top.equalTo(view)
                    make.leading.trailing.equalTo(view).inset(Size.defaultMargins)
                    make.bottom.equalTo(view).inset(Size.bottomButtonMargin)
                    make.height.equalTo(Size.buttonHeight)
                }

                let editButtonOverlay = UIView()
                editButtonOverlay.backgroundColor = .dimmedBlackBackground
                editButton.addSubview(editButtonOverlay)
                editButtonOverlay.snp.makeConstraints { make in
                    make.edges.equalTo(editButton)
                }

                removeButton.snp.makeConstraints { make in
                    make.centerY.equalTo(editButton)
                    make.trailing.equalTo(editButton).offset(-Size.innerButtonMargin)
                }

                editImage.snp.makeConstraints { make in
                    make.centerY.equalTo(editButton)
                    make.trailing.equalTo(removeButton.snp.leading).offset(-Size.innerButtonMargin)
                }

                label.snp.makeConstraints { make in
                    make.centerY.equalTo(editButton).offset(Size.labelCenterAdjustment)
                    make.leading.equalTo(editButton).offset(Size.innerButtonMargin)
                }

                editButton.addTarget(
                    self,
                    action: #selector(editButtonTapped(_:)),
                    for: .touchUpInside
                )
                removeButton.addTarget(
                    self,
                    action: #selector(removeButtonTapped(_:)),
                    for: .touchUpInside
                )

                return view
            }

            roleViews.eachPair { prevView, view, isLast in
                rolesContainer.addSubview(view)

                view.snp.makeConstraints { make in
                    make.leading.trailing.equalTo(rolesContainer)
                    if let prevView = prevView {
                        make.top.equalTo(prevView.snp.bottom)
                    }
                    else {
                        make.top.equalTo(rolesContainer)
                    }

                    if isLast {
                        make.bottom.equalTo(rolesContainer)
                    }
                }
            }
        }
    }

    @objc
    private func addButtonTapped(_ button: UIButton) {
        delegate?.addRoleTapped()
    }

    @objc
    private func editButtonTapped(_ button: UIButton) {
        guard
            let container:Container = button.findParentView(),
            let index = rolesContainer.subviews.firstIndex(of: container)
        else { return }

        delegate?.editRoleTapped(index: index)
    }

    @objc
    private func removeButtonTapped(_ button: UIButton) {
        guard
            let container:Container = button.findParentView(),
            let index = rolesContainer.subviews.firstIndex(of: container)
        else { return }

        delegate?.removeRoleTapped(index: index)
    }
}
