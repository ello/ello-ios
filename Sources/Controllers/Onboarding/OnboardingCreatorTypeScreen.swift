////
///  OnboardingCreatorTypeScreen.swift
//

import SnapKit


class OnboardingCreatorTypeScreen: StreamableScreen {
    struct Size {
        static let margins: CGFloat = 15
        static let hugeTop: CGFloat = 180
        static let bigTop: CGFloat = 90
        static let smallTop: CGFloat = 30
        static let normalTop: CGFloat = 15
        static let containerOffset: CGFloat = 30
        static let buttonOffset: CGFloat = 22
        static let buttonHeight: CGFloat = 50
    }

    enum CreatorType {
        case none
        case fan
        case artist([Int])

        var isFan: Bool {
            switch self {
            case .fan: return true
            default: return false
            }
        }
        var isArtist: Bool {
            switch self {
            case .artist: return true
            default: return false
            }
        }
    }

    weak var delegate: OnboardingCreatorTypeDelegate?
    var creatorCategories: [String] = [] {
        didSet {
            updateCreatorCategories()
        }
    }
    var showIntroText: Bool = false {
        didSet {
            updateCreatorTypeLabels()
        }
    }

    var topInset: CGFloat = 0 {
        didSet {
            scrollView.contentInset.top = topInset
            scrollView.scrollIndicatorInsets.top = topInset
        }
    }
    var bottomInset: CGFloat = 0 {
        didSet {
            scrollView.contentInset.bottom = bottomInset
            scrollView.scrollIndicatorInsets.bottom = bottomInset
        }
    }

    private let headerLabel = StyledLabel(style: .black)
    private let scrollView = UIScrollView()
    private let scrollableWidth = UIView()
    private let creatorTypeContainer = Container()
    private let hereAsLabel = StyledLabel(style: .gray)
    private let artistButton = StyledButton(style: .roundedGrayOutline)
    private let fanButton = StyledButton(style: .roundedGrayOutline)
    private var scrollViewWidth: Constraint!
    private var scrollViewFanBottom: Constraint!
    private var scrollViewArtistBottom: Constraint!
    private var creatorTypeContainerTop: Constraint!
    private var creatorTypeContainerIntroTop: Constraint!
    private let creatorLabel = StyledLabel(style: .gray)
    private let creatorButtonsContainer = Container()
    private var creatorButtons: [UIView] = []

    override func style() {
        super.style()
        headerLabel.isMultiline = true
        creatorButtonsContainer.alpha = 0
    }

    override func bindActions() {
        super.bindActions()
        artistButton.addTarget(self, action: #selector(toggleCreatorType(sender:)), for: .touchUpInside)
        fanButton.addTarget(self, action: #selector(toggleCreatorType(sender:)), for: .touchUpInside)
    }

    override func setText() {
        super.setText()
        headerLabel.text = InterfaceString.Onboard.CreatorTypeHeader
        hereAsLabel.text = InterfaceString.Onboard.HereAs
        artistButton.title = InterfaceString.Onboard.Artist
        fanButton.title = InterfaceString.Onboard.Fan
        creatorLabel.text = InterfaceString.Onboard.Interests
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        scrollViewWidth?.update(offset: frame.width)
    }

    override func arrange() {
        super.arrange()

        addSubview(scrollView)
        addSubview(navigationBar)

        scrollView.addSubview(headerLabel)
        scrollView.addSubview(creatorTypeContainer)
        scrollView.addSubview(scrollableWidth)
        scrollView.addSubview(creatorButtonsContainer)

        creatorTypeContainer.addSubview(hereAsLabel)
        creatorTypeContainer.addSubview(artistButton)
        creatorTypeContainer.addSubview(fanButton)
        creatorButtonsContainer.addSubview(creatorLabel)

        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(self)
        }

        scrollableWidth.snp.makeConstraints { make in
            scrollViewWidth = make.width.equalTo(frame.width).constraint
            make.leading.trailing.equalTo(scrollView)
        }

        headerLabel.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(scrollView).inset(Size.margins)
        }

        creatorTypeContainer.snp.makeConstraints { make in
            creatorTypeContainerTop = make.top.equalTo(scrollView).offset(Size.hugeTop).constraint
            creatorTypeContainerIntroTop = make.top.equalTo(headerLabel.snp.bottom).offset(Size.bigTop).constraint
            make.leading.trailing.equalTo(scrollView).inset(Size.margins)
        }

        hereAsLabel.snp.makeConstraints { make in
            make.top.leading.equalTo(creatorTypeContainer)
        }

        artistButton.snp.makeConstraints { make in
            make.leading.equalTo(creatorTypeContainer)
            make.width.equalTo(fanButton)
            make.top.equalTo(hereAsLabel.snp.bottom).offset(Size.buttonOffset)
            make.bottom.equalTo(creatorTypeContainer)
            make.height.equalTo(Size.buttonHeight)
        }

        fanButton.snp.makeConstraints { make in
            make.trailing.equalTo(creatorTypeContainer)
            make.leading.equalTo(artistButton.snp.trailing).offset(Size.margins)
            make.top.equalTo(hereAsLabel.snp.bottom).offset(Size.buttonOffset)
            make.bottom.equalTo(creatorTypeContainer)
            make.height.equalTo(Size.buttonHeight)
            scrollViewFanBottom = make.bottom.equalTo(scrollView).inset(Size.margins).constraint
        }

        creatorButtonsContainer.snp.makeConstraints { make in
            make.top.equalTo(creatorTypeContainer.snp.bottom).offset(Size.containerOffset)
            make.leading.trailing.equalTo(creatorTypeContainer)
            scrollViewArtistBottom = make.bottom.equalTo(scrollView).offset(-Size.margins).constraint
        }

        creatorLabel.snp.makeConstraints { make in
            make.top.leading.equalTo(creatorButtonsContainer)
        }

        scrollViewArtistBottom.deactivate()
        scrollViewFanBottom.activate()

        addCreatorCategoriesSpinner()
        updateCreatorTypeLabels()
    }

    private func addCreatorCategoriesSpinner() {
        let spinner = UIActivityIndicatorView(style: .gray)
        spinner.startAnimating()
        creatorButtonsContainer.addSubview(spinner)
        spinner.snp.makeConstraints { make in
            make.top.equalTo(creatorLabel.snp.bottom).offset(Size.buttonOffset)
            make.centerX.bottom.equalTo(creatorButtonsContainer)
        }
        creatorButtons = [spinner]
    }

    private func updateCreatorTypeLabels() {
        creatorTypeContainerIntroTop.set(isActivated: showIntroText)
        creatorTypeContainerTop.set(isActivated: !showIntroText)
        headerLabel.isVisible = showIntroText
    }

    private func updateCreatorCategories() {
        for view in creatorButtons {
            view.removeFromSuperview()
        }

        creatorButtons = []
        var pairs: [[UIView]] = []
        var row: [UIView] = []
        var firstView: UIView?
        var prevRow: UIView?
        var prevView: UIView?
        for category in creatorCategories {
            let categoryView = StyledButton(style: .roundedGrayOutline)
            categoryView.addTarget(self, action: #selector(toggleCreatorCategory(sender:)), for: .touchUpInside)
            creatorButtons.append(categoryView)
            categoryView.title = category
            categoryView.titleLineBreakMode = .byTruncatingTail
            creatorButtonsContainer.addSubview(categoryView)

            categoryView.snp.makeConstraints { make in
                if let prevRow = prevRow {
                    make.top.equalTo(prevRow.snp.bottom).offset(Size.margins)
                }
                else {
                    make.top.equalTo(creatorLabel.snp.bottom).offset(Size.buttonOffset)
                }

                switch row.count {
                case 0:
                    make.leading.equalTo(creatorButtonsContainer)
                case 1:
                    if let prevView = prevView {
                        make.leading.equalTo(prevView.snp.trailing).offset(Size.margins)
                    }
                    make.trailing.equalTo(creatorButtonsContainer)
                default:
                    break
                }

                if let firstView = firstView {
                    make.width.equalTo(firstView)
                }

                if category == creatorCategories.last {
                    make.bottom.equalTo(creatorButtonsContainer)
                }
                make.height.equalTo(Size.buttonHeight)

                if creatorCategories.count == 1 {
                    let width = (UIScreen.main.bounds.width - 3 * Size.margins) / 2
                    make.width.equalTo(width)
                }
            }
            row.append(categoryView)

            if row.count == 2 || category == creatorCategories.last {
                prevRow = categoryView
                pairs.append(row)
                row = []
            }

            firstView = firstView ?? categoryView
            prevView = categoryView
        }
    }

    @objc
    func toggleCreatorCategory(sender: UIButton) {
        sender.isSelected = !sender.isSelected

        var paths: [Int] = []
        for (index, view) in creatorButtons.enumerated() {
            guard let button = view as? UIButton, button.isSelected else { continue }
            paths.append(index)
        }
        delegate?.creatorTypeChanged(type: .artist(paths))
    }

    @objc
    func toggleCreatorType(sender: UIButton) {
        let isSelected = !sender.isSelected
        let type: CreatorType
        if isSelected {
            if sender == fanButton {
                type = .fan
            }
            else {
                type = .artist([])
            }
        }
        else {
            type = .none
        }

        delegate?.creatorTypeChanged(type: type)
        updateButtons(type: type)
    }

    func updateButtons(type: CreatorType, animated: Bool = true) {
        fanButton.isSelected = type.isFan
        artistButton.isSelected = type.isArtist

        scrollViewArtistBottom.set(isActivated: type.isArtist)
        scrollViewFanBottom.set(isActivated: !type.isArtist)

        let creatorTypeMargin: CGFloat
        let creatorTypeIntroMargin: CGFloat
        let creatorButtonsAlpha: CGFloat
        if artistButton.isSelected {
            creatorTypeMargin = Size.normalTop
            creatorTypeIntroMargin = Size.smallTop
            creatorButtonsAlpha = 1
        }
        else {
            creatorTypeMargin = Size.hugeTop
            creatorTypeIntroMargin = Size.bigTop
            creatorButtonsAlpha = 0
        }
        creatorTypeContainerTop.update(offset: creatorTypeMargin)
        creatorTypeContainerIntroTop.update(offset: creatorTypeIntroMargin)

        let completion: Block = {
            self.unselectAllCategories()
        }
        let creatorTypeY: CGFloat
        if showIntroText {
            creatorTypeY = headerLabel.frame.maxY + creatorTypeIntroMargin
        }
        else {
            creatorTypeY = creatorTypeMargin
        }
        elloAnimate(animated: animated) {
            self.creatorTypeContainer.frame.origin.y = creatorTypeY
            self.creatorButtonsContainer.frame.origin.y = creatorTypeY + self.creatorTypeContainer.frame.height + Size.containerOffset
            self.creatorButtonsContainer.alpha = creatorButtonsAlpha
        }.done(completion)
    }

    func unselectAllCategories() {
        creatorButtons.compactMap({ (button: UIView) -> UIButton? in return button as? UIButton }).forEach { button in
            button.isSelected = false
        }
    }
}

extension OnboardingCreatorTypeScreen: OnboardingCreatorTypeScreenProtocol {

    func updateCreatorType(type: Profile.CreatorType) {
        switch type {
        case .none:
            updateButtons(type: .none, animated: false)
            unselectAllCategories()
        case .fan:
            updateButtons(type: .fan, animated: false)
            unselectAllCategories()
        case let .artist(categories):
            updateButtons(type: .artist([]), animated: false)
            creatorButtons.compactMap({ (button: UIView) -> UIButton? in return button as? UIButton }).forEach { button in
                button.isSelected = categories.any({ button.title(for: .normal) == $0.name })
            }
        }
    }

}
