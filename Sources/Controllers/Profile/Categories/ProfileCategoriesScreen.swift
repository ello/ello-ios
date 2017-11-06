////
///  ProfileCategoriesScreen.swift
//

import SnapKit


class ProfileCategoriesScreen: Screen, ProfileCategoriesProtocol {

    struct Size {
        static let textInset: CGFloat = 15
        static let learnMoreSpacing: CGFloat = 20
    }

    weak var delegate: ProfileCategoriesDelegate?
    let categories: [Category]

    private let textView = ElloTextView()
    private let learnMoreButton = StyledButton(style: .grayUnderlined)

    init(categories: [Category]) {
        self.categories = categories
        super.init(frame: .zero)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    required init(frame: CGRect) {
        fatalError("use init(categories:)")
    }

    override func style() {
        backgroundColor = .clear
        textView.backgroundColor = .clear
        textView.isEditable = false
        textView.allowsEditingTextAttributes = false
        textView.isSelectable = false
        textView.textColor = .white
    }

    override func bindActions() {
        textView.textViewDelegate = self
        let gesture = UITapGestureRecognizer(target: self, action: #selector(dismiss))
        addGestureRecognizer(gesture)
        learnMoreButton.addTarget(self, action: #selector(learnMoreTapped), for: .touchUpInside)
    }

    override func setText() {
        textView.attributedText = NSAttributedString(featuredIn: categories)
        textView.sizeToFit()

        learnMoreButton.setTitle(InterfaceString.Badges.LearnMore, for: .normal)
    }

    override func arrange() {
        addSubview(textView)
        addSubview(learnMoreButton)

        textView.snp.makeConstraints { make in
            make.leading.trailing.equalTo(self).inset(Size.textInset)
            make.centerY.equalTo(self)
        }

        learnMoreButton.snp.makeConstraints { make in
            make.centerX.equalTo(self)
            make.top.equalTo(textView.snp.bottom).offset(Size.learnMoreSpacing)
        }
    }

    @objc
    func dismiss() {
        delegate?.dismiss()
    }

    @objc
    func learnMoreTapped() {
        delegate?.learnMoreTapped()
    }
}

extension ProfileCategoriesScreen: ElloTextViewDelegate {

    func textViewTapped(_ link: String, object: ElloAttributedObject) {
        switch object {
        case let .attributedCategory(category):
            delegate?.categoryTapped(category)
        default: break
        }
    }

    func textViewTappedDefault() {
        // no-op
    }
}
