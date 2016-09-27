////
///  CategoryCardCell.swift
//

import SnapKit

public class CategoryCardCell: UICollectionViewCell {
    static let reuseIdentifier = "CategoryCardCell"
    static let selectableReuseIdentifier = "SelectableCategoryCardCell"

    struct Size {
        static let colorFillTopOffset: CGFloat = 2
        static let selectedImageOffset: CGFloat = 5
    }

    override public var selectable: Bool {
        didSet { self.selected = selected }
    }
    override public var selected: Bool {
        didSet {
            if selectable {
                colorFillView.alpha = selected ? 0.8 : 0.4
                label.font = selected ? UIFont.defaultBoldFont() : UIFont.defaultFont()
                selectedImageView.hidden = !selected
            }
            else {
                colorFillView.alpha = 0
                label.font = UIFont.defaultFont()
                selectedImageView.hidden = true
            }
        }
    }
    var title: String {
        set { label.text = newValue }
        get { return label.text ?? "" }
    }
    var imageURL: NSURL? {
        didSet {
            imageView.pin_setImageFromURL(imageURL)
        }
    }

    private let label = ElloSizeableLabel()
    private let colorFillView = UIView()
    private let imageView = UIImageView()
    private let selectedImageView = UIImageView()

    override public init(frame: CGRect) {
        super.init(frame: frame)

        style()
        arrange()
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func prepareForReuse() {
        super.prepareForReuse()
        label.text = ""
        imageView.image = nil
        selected = false
    }

    private func style() {
        label.font = UIFont.defaultFont()
        label.textColor = .whiteColor()
        imageView.contentMode = .ScaleAspectFill
        imageView.clipsToBounds = true
        colorFillView.backgroundColor = .blackColor()
        colorFillView.alpha = 0.4
        selectedImageView.hidden = true
        selectedImageView.image = InterfaceImage.SmallCheck.normalImage
    }

    private func arrange() {
        contentView.addSubview(imageView)
        contentView.addSubview(colorFillView)
        contentView.addSubview(label)
        contentView.addSubview(selectedImageView)

        colorFillView.snp_makeConstraints { make in
            make.top.equalTo(contentView)
            make.bottom.equalTo(contentView).offset(-Size.colorFillTopOffset)
            make.leading.equalTo(contentView)
            make.trailing.equalTo(contentView)
        }
        imageView.snp_makeConstraints { make in
            make.edges.equalTo(colorFillView)
        }
        label.snp_makeConstraints { make in
            make.centerX.centerY.equalTo(colorFillView)
        }
        selectedImageView.snp_makeConstraints { make in
            make.trailing.equalTo(label.snp_leading).offset(-Size.selectedImageOffset)
            make.centerY.equalTo(colorFillView)
        }
    }
}
