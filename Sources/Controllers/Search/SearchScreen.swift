////
///  SearchScreen.swift
//

import SnapKit


class SearchScreen: StreamableScreen, SearchScreenProtocol {
    struct Size {
        static let margins: CGFloat = 15
        static let backButtonMargin: CGFloat = 10
        static let buttonMargin: CGFloat = 5
        static let buttonWidth: CGFloat = 40
        static let bottomMargin: CGFloat = 10
        static let searchButtonsHeight: CGFloat = 30
        static let searchControlsHeight: CGFloat = searchButtonsHeight + bottomMargin
        static let searchControlsTallHeight: CGFloat = searchControlsHeight + 44
        static let cornerRadius: CGFloat = 5
        static let findFriendsInsets = UIEdgeInsets(all: 20)
        static let findFriendsLabelLeft: CGFloat = 25
        static let findFriendsButtonHeight: CGFloat = 44
    }

    weak var delegate: SearchScreenDelegate?

    var topInsetView: UIView { return searchControlsContainer }

    var showsFindFriends: Bool = true {
        didSet { showHideFindFriends() }
    }

    var isGridView = false {
        didSet {
            gridListButton.setImage(isGridView ? .listView : .gridView, imageStyle: .normal, for: .normal)
        }
    }

    var showBackButton: Bool = false {
        didSet { updateBackButton() }
    }

    // for specs
    let searchField = SearchNavBarField()

    private let searchControlsContainer = UIView()
    private let debounced: ThrottledBlock = debounce(0.8)
    private let backButton = UIButton()
    private let persistentBackButton = PersistentBackButton()
    private let toggleButtonsLeadingGuide = UILayoutGuide()
    private let postsToggleButton = SearchToggleButton()
    private let peopleToggleButton = SearchToggleButton()
    private let findFriendsContainer = UIView()
    private var findFriendsPinToKeyboard: Constraint!
    private var findFriendsPinToBottom: Constraint!
    private let findFriendsButton = StyledButton(style: .green)
    private let findFriendsLabel = StyledLabel(style: .black)
    private var bottomInset: CGFloat = 0
    private let gridListButton = UIButton()
    private var searchControlsContainerTop: Constraint!
    private var searchControlsContainerHeight: Constraint!
    private var gridListVisibleConstraint: Constraint!
    private var gridListHiddenConstraint: Constraint!
    private var showBackButtonConstraint: Constraint!
    private var hideBackButtonConstraint: Constraint!

    override func setText() {
        postsToggleButton.setTitle(InterfaceString.Search.Posts, for: .normal)
        peopleToggleButton.setTitle(InterfaceString.Search.People, for: .normal)
        findFriendsButton.setTitle(InterfaceString.Friends.FindAndInvite, for: .normal)
        findFriendsLabel.text = InterfaceString.Search.FindFriendsPrompt
    }

    override func bindActions() {
        searchField.addTarget(self, action: #selector(searchFieldDidChange), for: .editingChanged)
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        postsToggleButton.addTarget(self, action: #selector(onPostsTapped), for: .touchUpInside)
        peopleToggleButton.addTarget(self, action: #selector(onPeopleTapped), for: .touchUpInside)
        findFriendsButton.addTarget(self, action: #selector(findFriendsTapped), for: .touchUpInside)
        gridListButton.addTarget(self, action: #selector(gridListToggled), for: .touchUpInside)
        persistentBackButton.addTarget(navigationBar, action: #selector(ElloNavigationBar.backButtonTapped), for: .touchUpInside)
        searchField.delegate = self
    }

    override func style() {
        backButton.setImages(.backChevron)

        searchControlsContainer.backgroundColor = .white
        persistentBackButton.alpha = 0

        findFriendsContainer.backgroundColor = .greyF2
        findFriendsContainer.isHidden = !showsFindFriends
        findFriendsContainer.layer.cornerRadius = Size.cornerRadius
        findFriendsContainer.clipsToBounds = true

        postsToggleButton.isSelected = true
        peopleToggleButton.isSelected = false
    }

    override func arrange() {
        super.arrange()

        navigationBar.addSubview(backButton)
        navigationBar.addSubview(searchField)
        navigationBar.addSubview(gridListButton)

        addSubview(searchControlsContainer)
        searchControlsContainer.addLayoutGuide(toggleButtonsLeadingGuide)
        searchControlsContainer.addSubview(persistentBackButton)
        searchControlsContainer.addSubview(postsToggleButton)
        searchControlsContainer.addSubview(peopleToggleButton)

        addSubview(findFriendsContainer)
        findFriendsContainer.addSubview(findFriendsLabel)
        findFriendsContainer.addSubview(findFriendsButton)

        backButton.snp.makeConstraints { make in
            make.leading.bottom.equalTo(navigationBar)
            make.top.equalTo(navigationBar).offset(BlackBar.Size.height)
            make.width.equalTo(Size.buttonWidth)
        }

        searchField.snp.makeConstraints { make in
            var insets = SearchNavBarField.Size.searchInsets
            insets.right = Size.margins
            make.leading.equalTo(backButton.snp.trailing)
            make.bottom.top.equalTo(navigationBar).inset(insets)
            gridListVisibleConstraint = make.trailing.equalTo(gridListButton.snp.leading).offset(-Size.buttonMargin).constraint
            gridListHiddenConstraint = make.trailing.equalTo(navigationBar).offset(-insets.right).constraint
        }
        gridListHiddenConstraint.deactivate()

        gridListButton.snp.makeConstraints { make in
            make.top.equalTo(navigationBar).offset(BlackBar.Size.height)
            make.bottom.equalTo(navigationBar)
            make.trailing.equalTo(navigationBar).offset(-Size.buttonMargin)
            make.width.equalTo(Size.buttonWidth)
        }

        searchControlsContainer.snp.makeConstraints { make in
            searchControlsContainerTop = make.top.equalTo(self).offset(ElloNavigationBar.Size.height).constraint
            make.leading.trailing.equalTo(self)
            searchControlsContainerHeight = make.height.equalTo(Size.searchControlsHeight).constraint
        }

        toggleButtonsLeadingGuide.snp.makeConstraints { make in
            showBackButtonConstraint = make.leading.trailing.equalTo(persistentBackButton.snp.trailing).offset(Size.backButtonMargin).constraint
            hideBackButtonConstraint = make.leading.trailing.equalTo(searchControlsContainer.snp.leading).offset(Size.margins).constraint
        }
        showBackButtonConstraint.deactivate()

        persistentBackButton.setContentHuggingPriority(UILayoutPriority.required, for: .horizontal)
        persistentBackButton.snp.makeConstraints { make in
            make.leading.equalTo(searchControlsContainer).offset(Size.backButtonMargin)
            make.bottom.equalTo(searchControlsContainer).offset(-Size.bottomMargin)
            make.height.equalTo(Size.searchButtonsHeight)
        }

        postsToggleButton.snp.makeConstraints { make in
            make.leading.equalTo(toggleButtonsLeadingGuide)
            make.bottom.equalTo(searchControlsContainer).offset(-Size.bottomMargin)
            make.height.equalTo(Size.searchButtonsHeight)
        }

        peopleToggleButton.snp.makeConstraints { make in
            make.trailing.equalTo(searchControlsContainer).offset(-Size.margins)
            make.leading.equalTo(postsToggleButton.snp.trailing)
            make.width.equalTo(postsToggleButton)
            make.bottom.equalTo(searchControlsContainer).offset(-Size.bottomMargin)
            make.height.equalTo(Size.searchButtonsHeight)
        }

        findFriendsContainer.snp.makeConstraints { make in
            make.leading.trailing.equalTo(self).inset(Size.margins)
            findFriendsPinToKeyboard = make.bottom.equalTo(keyboardAnchor.snp.top).offset(-Size.margins).constraint
            findFriendsPinToBottom = make.bottom.equalTo(self).inset(ElloTabBar.Size.height).constraint
        }
        findFriendsPinToKeyboard.deactivate()

        findFriendsLabel.snp.makeConstraints { make in
            make.leading.equalTo(findFriendsContainer).offset(Size.findFriendsLabelLeft)
            make.top.trailing.equalTo(findFriendsContainer).inset(Size.findFriendsInsets)
        }

        findFriendsButton.snp.makeConstraints { make in
            make.top.equalTo(findFriendsLabel.snp.bottom).offset(Size.findFriendsInsets.top)
            make.bottom.leading.trailing.equalTo(findFriendsContainer).inset(Size.findFriendsInsets)
            make.height.equalTo(Size.findFriendsButtonHeight)
        }
    }

    override func keyboardWillChange(_ keyboard: Keyboard, animated: Bool) {
        if keyboard.isActive {
            findFriendsPinToKeyboard.activate()
            findFriendsPinToBottom.deactivate()
        }
        else {
            findFriendsPinToKeyboard.deactivate()
            findFriendsPinToBottom.activate()
        }

        super.keyboardWillChange(keyboard, animated: animated)
    }

    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        searchField.becomeFirstResponder()
    }

}

extension SearchScreen {

    func showNavBars() {
        elloAnimate {
            self.searchControlsContainerTop.update(offset: ElloNavigationBar.Size.height)
            if Globals.isIphoneX {
                self.updateSearchControlsHeight(Size.searchControlsHeight)
            }
            self.showBackButton = false
            self.layoutIfNeeded()
        }
    }

    func hideNavBars() {
        elloAnimate {
            self.searchControlsContainerTop.update(offset: 0)
            if Globals.isIphoneX {
                self.updateSearchControlsHeight(Size.searchControlsTallHeight)
            }
            self.showBackButton = true
            self.layoutIfNeeded()
        }
    }

    private func updateSearchControlsHeight(_ newHeight: CGFloat) {
        let delta = searchControlsContainer.frame.height - newHeight
        postsToggleButton.frame.origin.y -= delta
        peopleToggleButton.frame.origin.y -= delta
        searchControlsContainerHeight.update(offset: newHeight)
    }

    func updateInsets(bottom: CGFloat) {
        bottomInset = bottom
        setNeedsLayout()
    }

    func searchFor(_ text: String) {
        searchField.text = text
        performSearch()
    }

}

extension SearchScreen {

    private func clearSearch() {
        delegate?.searchFieldCleared()
        debounced {}
    }

    private func performSearch() {
        guard
            let text = searchField.text,
            !text.isEmpty
        else { return }

        showHideFindFriends()
        delegate?.searchFieldChanged(text, isPostSearch: postsToggleButton.isSelected)
    }

// MARK: actions

    @objc
    func onPostsTapped() {
        postsToggleButton.isSelected = true
        peopleToggleButton.isSelected = false
        var searchFieldText = searchField.text ?? ""
        if searchFieldText == "@" {
            searchFieldText = ""
        }
        searchField.text = searchFieldText
        animateGridListButton(visible: true)

        delegate?.toggleChanged(searchFieldText, isPostSearch: postsToggleButton.isSelected)
    }

    @objc
    func onPeopleTapped() {
        peopleToggleButton.isSelected = true
        postsToggleButton.isSelected = false
        var searchFieldText = searchField.text ?? ""
        if searchFieldText == "" {
            searchFieldText = "@"
        }
        searchField.text = searchFieldText
        animateGridListButton(visible: false)

        delegate?.toggleChanged(searchFieldText, isPostSearch: postsToggleButton.isSelected)
    }

    private func animateGridListButton(visible: Bool) {
        if visible {
            self.gridListVisibleConstraint.activate()
            self.gridListHiddenConstraint.deactivate()
        }
        else {
            self.gridListVisibleConstraint.deactivate()
            self.gridListHiddenConstraint.activate()
        }

        elloAnimate {
            self.gridListButton.alpha = visible ? 1 : 0

            let trailing: CGFloat
            if visible {
                trailing = self.gridListButton.frame.minX - Size.buttonMargin
            }
            else {
                var insets = SearchNavBarField.Size.searchInsets
                insets.right = Size.margins
                trailing = self.navigationBar.frame.maxX - insets.right
            }
            self.searchField.frame.size.width = trailing - self.searchField.frame.minX
        }
    }

    @objc
    func backButtonTapped() {
        delegate?.searchCanceled()
    }

    @objc
    func findFriendsTapped() {
        delegate?.findFriendsTapped()
    }

    @objc
    func gridListToggled() {
        delegate?.gridListToggled(sender: gridListButton)
    }

    @objc
    func searchFieldDidChange() {
        delegate?.searchShouldReset()
        let text = searchField.text ?? ""
        if text.isEmpty {
            clearSearch()
            showHideFindFriends()
        }
        else {
            debounced { [weak self] in
                self?.performSearch()
            }
        }
    }

}

extension SearchScreen: UITextFieldDelegate {

    @objc
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        clearSearch()
        showHideFindFriends()
        return true
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        _ = textField.resignFirstResponder()
        return true
    }

}

extension SearchScreen {

    private func showHideFindFriends() {
        if showsFindFriends && searchField.text.isEmpty {
            findFriendsContainer.isHidden = false
        }
        else {
            findFriendsContainer.isHidden = true
        }
    }

}

extension SearchScreen: ArrangeNavBackButton {
    func arrangeNavBackButton(_ button: UIButton) {
    }

    private func updateBackButton() {
        if showBackButton {
            persistentBackButton.alpha = 1
            showBackButtonConstraint.activate()
            hideBackButtonConstraint.deactivate()
        }
        else {
            persistentBackButton.alpha = 0
            showBackButtonConstraint.deactivate()
            hideBackButtonConstraint.activate()
        }
        searchControlsContainer.layoutIfNeeded()
    }
}
