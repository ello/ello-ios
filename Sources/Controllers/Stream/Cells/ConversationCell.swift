////
///  ConversationCell.swift
//

import SnapKit

public class ConversationCell: UICollectionViewCell {
    static let reuseIdentifier = "ConversationCell"

    struct Size {
        static let sideMargins: CGFloat = 15
        static let lineHeight: CGFloat = 1
    }

    var title: String {
        set { label.text = newValue }
        get { return label.text ?? "" }
    }

    private let label = ElloLabel()
    override public init(frame: CGRect) {
        super.init(frame: frame)

        arrange()
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func arrange() {
        contentView.addSubview(label)

        label.snp_makeConstraints { make in
            make.centerY.equalTo(contentView)
            make.left.equalTo(contentView).offset(Size.sideMargins)
        }
    }
}
