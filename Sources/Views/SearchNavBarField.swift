////
///  SearchNavBarField.swift
//

class SearchNavBarField: UITextField {
    struct Size {
        static let cornerRadius: CGFloat = 5
        static let leftViewCorrection = CGPoint(x: 10, y: 0.5)
        static let textCorrection = CGPoint(x: 4.5, y: 2)
        static let largeNavSearchInsets = calculateLargeInsets()
        static let searchInsets = calculateInsets()

        static private func calculateInsets() -> UIEdgeInsets {
            var insets = UIEdgeInsets(top: 7, left: 7, bottom: 7, right: 7)
            insets.top += BlackBar.Size.height
            return insets
        }

        static private func calculateLargeInsets() -> UIEdgeInsets {
            var insets = calculateInsets()
            insets.left += 8
            return insets
        }
    }

    override required init(frame: CGRect) {
        super.init(frame: frame)
        sharedInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        sharedInit()
    }

    private func sharedInit() {
        font = .defaultFont()
        backgroundColor = .greyE5
        clipsToBounds = true
        layer.cornerRadius = Size.cornerRadius
        clearButtonMode = .whileEditing
        textColor = .black
        autocapitalizationType = .none
        autocorrectionType = .no
        spellCheckingType = .no
        enablesReturnKeyAutomatically = true
        returnKeyType = .search
        keyboardAppearance = .dark
        keyboardType = .default

        attributedPlaceholder = NSAttributedString(
            string: InterfaceString.Search.Prompt,
            attributes: [
                .foregroundColor: UIColor.greyA
            ])

        leftViewMode = .always
        leftView = UIImageView(image: InterfaceImage.searchField.normalImage)
    }

    override func leftViewRect(forBounds bounds: CGRect) -> CGRect {
        var rect = super.leftViewRect(forBounds: bounds)
        rect.origin.x += Size.leftViewCorrection.x
        rect.origin.y += Size.leftViewCorrection.y
        return rect
    }

    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return rectForBounds(bounds)
    }

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return rectForBounds(bounds)
    }

    private func rectForBounds(_ bounds: CGRect) -> CGRect {
        var rect = super.editingRect(forBounds: bounds)
        rect = rect.shrink(right: Size.textCorrection.x)
        rect = rect.shrink(down: Size.textCorrection.y)
        return rect
    }
}
