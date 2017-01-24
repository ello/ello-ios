////
///  CategoryCardCell.swift
//

import SnapKit

class CategoryCardCell: UICollectionViewCell {
    static let reuseIdentifier = "CategoryCardCell"
    static let selectableReuseIdentifier = "SelectableCategoryCardCell"

    struct Size {
        static let colorFillTopOffset: CGFloat = 2
        static let selectedImageOffset: CGFloat = 5
    }

    var selectable: Bool = false {
        didSet { updateSelected() }
    }
    override var isSelected: Bool {
        didSet { updateSelected() }
    }
    var title: String {
        set { label.text = newValue }
        get { return label.text ?? "" }
    }
    var imageURL: URL? {
        didSet {
            imageView.pin_setImage(from: imageURL)
        }
    }

    fileprivate let label = StyledLabel()
    fileprivate let colorFillView = UIView()
    fileprivate let imageView = UIImageView()
    fileprivate let selectedImageView = UIImageView()

    override init(frame: CGRect) {
        super.init(frame: frame)

        style()
        arrange()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    fileprivate func updateSelected() {
        if selectable {
            colorFillView.alpha = isSelected ? 0.8 : 0.4
            label.style = isSelected ? .BoldWhite : .White
            selectedImageView.isHidden = !isSelected
        }
        else {
            colorFillView.alpha = 0.4
            label.style = .White
            selectedImageView.isHidden = true
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        label.text = ""
        imageView.image = nil
        isSelected = false
    }

    fileprivate func style() {
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        colorFillView.backgroundColor = .black
        colorFillView.alpha = 0.4
        selectedImageView.isHidden = true
        selectedImageView.image = InterfaceImage.smallCheck.normalImage
    }

    fileprivate func arrange() {
        contentView.addSubview(imageView)
        contentView.addSubview(colorFillView)
        contentView.addSubview(label)
        contentView.addSubview(selectedImageView)

        colorFillView.snp.makeConstraints { make in
            make.top.equalTo(contentView)
            make.bottom.equalTo(contentView).offset(-Size.colorFillTopOffset)
            make.leading.equalTo(contentView)
            make.trailing.equalTo(contentView)
        }
        imageView.snp.makeConstraints { make in
            make.edges.equalTo(colorFillView)
        }
        label.snp.makeConstraints { make in
            make.centerX.centerY.equalTo(colorFillView)
        }
        selectedImageView.snp.makeConstraints { make in
            make.trailing.equalTo(label.snp.leading).offset(-Size.selectedImageOffset)
            make.centerY.equalTo(colorFillView)
        }
    }
}
