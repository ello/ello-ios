////
///  StreamSeeMoreCommentsCell.swift
//

class StreamSeeMoreCommentsCell: CollectionViewCell {
    static let reuseIdentifier = "StreamSeeMoreCommentsCell"

    @IBOutlet weak var buttonContainer: UIView!
    @IBOutlet weak var seeMoreButton: UIButton!

    override func style() {
        buttonContainer.backgroundColor = .greyA
        seeMoreButton.setTitleColor(.greyA, for: .normal)
        seeMoreButton.backgroundColor = .white
        seeMoreButton.titleLabel?.font = .defaultFont()
    }

}
