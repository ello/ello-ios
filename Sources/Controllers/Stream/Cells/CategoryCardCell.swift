////
///  CategoryCardCell.swift
//

import SnapKit


class CategoryCardCell: CollectionViewCell {
    static let reuseIdentifier = "CategoryCardCell"
    static let selectableReuseIdentifier = "SelectableCategoryCardCell"

    struct Size {
        static let aspect: CGFloat = 1.5
        static let subscribeButtonHeight: CGFloat = 30
        static func calculateHeight(columnCount: Int, subscribing: Bool) -> CGFloat {
            var windowWidth = Globals.windowSize.width
            if subscribing {
                windowWidth -= StreamKind.manageCategories.layoutInsets.sides
            }

            let horizontalColumnSpacing: CGFloat = subscribing ? 10 : 2
            let width = (windowWidth - horizontalColumnSpacing * (CGFloat(columnCount) - 1)) / CGFloat(columnCount)
            var height = ceil(width / aspect)
            if subscribing {
                height += subscribeButtonHeight + cardMargins
            }
            return height
        }
        static let smallMargin: CGFloat = 2
        static let subscribedCheckboxOffset: CGFloat = 4
        static let selectedImageOffset: CGFloat = 5
        static let cardMargins: CGFloat = 10
        static let textMargins: CGFloat = 30
        static let cornerRadius: CGFloat = 5
    }

    enum Usage {
        case subscribing
        case onboarding
        case choosing
    }

    var title: String {
        set { label.text = newValue }
        get { return label.text ?? "" }
    }
    var imageURL: URL? {
        didSet {
            imageView.pin_setImage(from: imageURL)
        }
    }
    var usage: Usage = .subscribing { didSet { updateStyle() } }
    override var isSelected: Bool { didSet { updateStyle() } }
    var isSubscribed: Bool = false { didSet { updateStyle() } }

    private let insetContentView = UIView()
    private let label = StyledLabel()
    private let subscribedCheckbox = UIImageView()
    private let subscribeButton = StyledButton(style: .subscribed)
    private let mainContentView = UIView()
    private let imageView = UIImageView()
    private let selectedImageView = UIImageView()
    private var insetConstraint: Constraint!
    private var subscribeContentConstraint: Constraint!
    private var onboardingContentConstraint: Constraint!

    override func style() {
        insetContentView.clipsToBounds = true
        label.isMultiline = true
        label.textAlignment = .center
        subscribedCheckbox.isHidden = true
        subscribedCheckbox.setInterfaceImage(.circleCheckLarge, style: .green)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        mainContentView.backgroundColor = .black
        mainContentView.alpha = 0.4
        selectedImageView.isHidden = true
        selectedImageView.interfaceImage = .smallCheck
    }

    override func bindActions() {
        subscribeButton.addTarget(self, action: #selector(subscribeButtonTapped), for: .touchUpInside)
    }

    override func arrange() {
        contentView.addSubview(insetContentView)

        insetContentView.snp.makeConstraints { make in
            make.leading.trailing.top.equalTo(contentView)
            insetConstraint = make.bottom.equalTo(contentView).constraint
        }

        insetContentView.addSubview(imageView)
        insetContentView.addSubview(mainContentView)
        insetContentView.addSubview(subscribeButton)
        insetContentView.addSubview(label)
        insetContentView.addSubview(subscribedCheckbox)
        insetContentView.addSubview(selectedImageView)

        imageView.snp.makeConstraints { make in
            make.edges.equalTo(insetContentView)
        }
        mainContentView.snp.makeConstraints { make in
            make.leading.trailing.top.equalTo(insetContentView)
            subscribeContentConstraint = make.bottom.equalTo(subscribeButton.snp.top).constraint
            onboardingContentConstraint = make.bottom.equalTo(insetContentView).constraint
        }
        subscribeContentConstraint.deactivate()

        subscribeButton.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalTo(insetContentView)
            make.height.equalTo(Size.subscribeButtonHeight)
        }
        label.snp.makeConstraints { make in
            make.centerX.centerY.equalTo(mainContentView)
            make.leading.greaterThanOrEqualTo(mainContentView).inset(Size.textMargins)
            make.trailing.lessThanOrEqualTo(mainContentView).inset(Size.textMargins)
        }
        subscribedCheckbox.snp.makeConstraints { make in
            make.trailing.equalTo(label.snp.leading).offset(-Size.subscribedCheckboxOffset)
            make.centerY.equalTo(label)
        }
        selectedImageView.snp.makeConstraints { make in
            make.trailing.equalTo(label.snp.leading).offset(-Size.selectedImageOffset)
            make.centerY.equalTo(label)
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        label.text = ""
        imageView.image = nil
        isSelected = false
    }

    private func updateStyle() {
        subscribeContentConstraint.set(isActivated: usage == .subscribing)
        onboardingContentConstraint.set(isActivated: usage != .subscribing)

        if usage == .subscribing {
            insetContentView.layer.cornerRadius = Size.cornerRadius
            subscribedCheckbox.isVisible = isSelected
            subscribeButton.isSelected = isSelected
            subscribeButton.isVisible = true
            subscribeButton.title = isSelected ? InterfaceString.Discover.Subscribed : InterfaceString.Discover.Subscribe
            selectedImageView.isHidden = true
            insetConstraint.update(inset: Size.cardMargins)
            mainContentView.alpha = isSelected ? 0.7 : 0.5
            label.style = .white
        }
        else if usage == .choosing {
            insetContentView.layer.cornerRadius = Size.cornerRadius
            subscribedCheckbox.isVisible = isSelected
            subscribeButton.isSelected = true
            subscribeButton.isVisible = isSubscribed
            subscribeButton.title = InterfaceString.Discover.Subscribed
            selectedImageView.isHidden = true
            insetConstraint.update(inset: Size.cardMargins)
            mainContentView.alpha = isSelected ? 0.7 : 0.5
            label.style = .white
        }
        else {
            insetContentView.layer.cornerRadius = 0
            subscribedCheckbox.isHidden = true
            subscribeButton.isHidden = true
            selectedImageView.isVisible = isSelected
            insetConstraint.update(inset: Size.smallMargin)
            mainContentView.alpha = isSelected ? 0.8 : 0.4
            label.style = isSelected ? .boldWhite : .white
        }
    }

    @objc
    private func subscribeButtonTapped() {
        let responder: SubscribedCategoryResponder? = findResponder()
        responder?.categorySubscribeTapped(cell: self)
    }
}
