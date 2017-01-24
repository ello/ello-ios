////
///  ElloSegmentedControl.swift
//

class ElloSegmentedControl: UISegmentedControl {
    enum ElloSegmentedControlStyle {
        case compact
        case normal

        var fontSize: CGFloat {
            switch self {
            case .compact: return 11
            case .normal: return 14
            }
        }

        var height: CGFloat {
            switch self {
            case .compact: return 19
            case .normal: return 30
            }
        }
    }

    var style: ElloSegmentedControlStyle = .normal { didSet { updateStyle() }}

    override func awakeFromNib() {
        super.awakeFromNib()
        layer.borderWidth = 1
        tintColor = .black
        updateStyle()
    }

    fileprivate func updateStyle() {
        let fontSize = style.fontSize
        let normalTitleTextAttributes = [
            NSForegroundColorAttributeName: UIColor.black,
            NSFontAttributeName: UIFont.defaultFont(fontSize)
        ]
        let selectedTitleTextAttributes = [
            NSForegroundColorAttributeName: UIColor.white,
            NSFontAttributeName: UIFont.defaultFont(fontSize)
        ]
        setTitleTextAttributes(normalTitleTextAttributes, for: .normal)
        setTitleTextAttributes(selectedTitleTextAttributes, for: .selected)
        setBackgroundImage(UIImage.imageWithColor(UIColor.white), for: .normal, barMetrics: .default)
        setBackgroundImage(UIImage.imageWithColor(UIColor.black), for: .selected, barMetrics: .default)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        frame.size.height = style.height
    }

    override var intrinsicContentSize: CGSize {
        return CGSize(width: super.intrinsicContentSize.width, height: style.height)
    }

}
