////
///  SearchStreamCell.swift
//

class SearchStreamCell: UICollectionViewCell {
    static let reuseIdentifier = "SearchStreamCell"
    struct Size {
        static let insets: CGFloat = 10
    }

    fileprivate var debounced = debounce(0.8)
    fileprivate let searchField = SearchTextField()

    var placeholder: String? {
        get { return searchField.placeholder }
        set { searchField.placeholder = newValue }
    }
    var search: String? {
        get { return searchField.text }
        set { searchField.text = newValue }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.white

        style()
        arrange()

        searchField.delegate = self
        searchField.addTarget(self, action: #selector(searchFieldDidChange), for: .editingChanged)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    fileprivate func style() {
    }

    fileprivate func arrange() {
        contentView.addSubview(searchField)

        searchField.snp.makeConstraints { make in
            make.top.bottom.equalTo(contentView)
            make.leading.trailing.equalTo(contentView).inset(Size.insets)
        }
    }
}

extension SearchStreamCell: DismissableCell {
    func didEndDisplay() {
        _ = searchField.resignFirstResponder()
    }
    func willDisplay() {
        // no op
    }
}

extension SearchStreamCell: UITextFieldDelegate {

    @objc
    func searchFieldDidChange() {
        let text = searchField.text ?? ""
        if text.characters.count == 0 {
            clearSearch()
        }
        else {
            debounced { [weak self] in
                self?.performSearch()
            }
        }
    }

    @objc
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.setNeedsLayout()
        textField.layoutIfNeeded()
    }

    @objc
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        _ = textField.resignFirstResponder()
        return true
    }

    fileprivate func performSearch() {
        guard
            let text = searchField.text,
            text.characters.count > 0
        else { return }

        let responder: SearchStreamResponder? = findResponder()
        responder?.searchFieldChanged(text: text)
    }

    fileprivate func clearSearch() {
        let responder: SearchStreamResponder? = findResponder()
        responder?.searchFieldChanged(text: "")
        debounced {}
    }
}
