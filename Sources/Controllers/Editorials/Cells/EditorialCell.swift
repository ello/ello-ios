////
///  EditorialCell.swift
//

class EditorialCell: CollectionViewCell {
    struct Size {
        static func calculateHeight(windowSize: CGSize) -> CGFloat {
            let aspect = EditorialCellContent.Size.aspect
            let maxHeight: CGFloat = windowSize.height - 256
            let height = min(ceil(windowSize.width / aspect), maxHeight)
            return height + EditorialCellContent.Size.bgMargins.bottom
        }
    }

    var editorialContentView: EditorialCellContent?
    var editorialKind: Editorial.Kind? {
        willSet {
            guard editorialContentView == nil || editorialKind == newValue
            else { fatalError("cell reuse will not work now!") }
        }
        didSet {
            guard let editorialKind = editorialKind else { return }
            let classType = editorialKind.classType
            let view = classType.init(frame: .default)
            view.editorialCell = self

            editorialContentView = view
            contentView.addSubview(view)
            view.snp.makeConstraints { make in
                make.edges.equalTo(contentView)
            }
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        editorialContentView?.prepareForReuse()
    }
}
