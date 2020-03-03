////
///  StreamLoadMoreCommentsCell.swift
//

import SnapKit


class StreamLoadMoreCommentsCell: CollectionViewCell {
    static let reuseIdentifier = "StreamLoadMoreCommentsCell"

    struct Size {
        static let height: CGFloat = 60
        static let margins: CGFloat = 15
    }

    private let button = StyledButton(style: .roundedGray)

    override func setText() {
        button.title = InterfaceString.Post.LoadMoreComments
    }

    override func bindActions() {
        button.isUserInteractionEnabled = false  // let StreamViewController handle taps
    }

    override func arrange() {
        contentView.addSubview(button)

        button.snp.makeConstraints { make in
            make.edges.equalTo(contentView).inset(Size.margins)
        }
    }

}
