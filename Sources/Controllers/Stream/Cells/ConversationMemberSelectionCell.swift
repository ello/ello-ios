////
///  ConversationMemberSelectionCell.swift
//

import SnapKit

public class ConversationMemberSelectionCell: UICollectionViewCell {
    static let reuseIdentifier = "ConversationMemberSelectionCell"

    struct Size {
        static let topMargin: CGFloat = 20
        static let sideMargins: CGFloat = 15
        static let lineHeight: CGFloat = 1
        static let textPadding: CGFloat = 8
        static let messageButtonWidth: CGFloat = 30
        static let messageButtonHeight: CGFloat = 30
    }

    private var user: User?
    weak var conversationDelegate: ConversationDelegate?
    private let avatarButton = AvatarButton()
    private let usernameLabel = UILabel()
    private let nameLabel = UILabel()
    private let messageButton = MemberElloButton()

    var bottomBorder = CALayer()

    override public init(frame: CGRect) {
        super.init(frame: frame)

        style()
        bindActions()
        arrange()
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setUser(user: User?) {
        self.user = user
        avatarButton.setUser(user)
        usernameLabel.text = user?.atName ?? ""
        nameLabel.text = user?.name ?? ""
    }

    private func arrange() {
        contentView.addSubview(usernameLabel)
        contentView.addSubview(nameLabel)
        contentView.addSubview(avatarButton)
        contentView.addSubview(messageButton)

        avatarButton.snp_makeConstraints { make in
            make.left.equalTo(contentView).offset(Size.sideMargins)
            make.top.equalTo(contentView).offset(Size.topMargin)
            make.bottom.equalTo(contentView).offset(-Size.topMargin)
            make.width.equalTo(avatarButton.snp_height)
        }

        usernameLabel.snp_makeConstraints { make in
            make.top.equalTo(avatarButton)
            make.left.equalTo(avatarButton.snp_right).offset(Size.textPadding)
        }

        nameLabel.snp_makeConstraints { make in
            make.top.equalTo(usernameLabel.snp_bottom).offset(Size.textPadding)
            make.left.equalTo(usernameLabel.snp_left)
        }

        messageButton.snp_makeConstraints { make in
            make.centerY.equalTo(contentView)
            make.right.equalTo(contentView).offset(-Size.sideMargins)
            make.width.equalTo(Size.messageButtonWidth)
            make.height.equalTo(Size.messageButtonHeight)
        }
    }

    private func style() {
        usernameLabel.font = UIFont.defaultBoldFont(18)
        usernameLabel.textColor = UIColor.blackColor()
        usernameLabel.lineBreakMode = NSLineBreakMode.ByTruncatingTail

        nameLabel.font = UIFont.defaultFont()
        nameLabel.textColor = UIColor.greyA()
        nameLabel.lineBreakMode = NSLineBreakMode.ByTruncatingTail

        messageButton.setTitle("✓", forState: .Normal)
        messageButton.selected = false

        // bottom border
        bottomBorder.backgroundColor = UIColor.greyF1().CGColor
        self.layer.addSublayer(bottomBorder)
    }

    private func bindActions() {
        messageButton.addTarget(self, action: #selector(messageButtonTapped), forControlEvents: .TouchUpInside)
    }

    @objc
    func messageButtonTapped(button: UIButton) {
        button.selected = !button.selected
        guard let user = self.user else { return }
        conversationDelegate?.userSelected(user)
    }
}

public class MemberElloButton: ElloButton {

    required public init(frame: CGRect) {
        super.init(frame: frame)
    }

    required public init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override public func updateStyle() {

        updateOutline()
    }

    override public func sharedSetup() {
        self.titleLabel?.font = UIFont.defaultFont()
        self.titleLabel?.numberOfLines = 1
        self.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        self.setTitleColor(UIColor.grayColor(), forState: .Highlighted)
        self.setTitleColor(UIColor.blackColor(), forState: .Selected)
        self.setTitleColor(UIColor.greyA(), forState: .Disabled)
        self.backgroundColor = .whiteColor()
    }

    func updateOutline() {
        self.layer.borderColor = UIColor.grayColor().CGColor
        self.layer.borderWidth = 1
    }
}
