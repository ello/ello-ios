////
///  StreamLoadingCell.swift
//

class StreamLoadingCell: UICollectionViewCell {
    static let reuseIdentifier = "StreamLoadingCell"

    lazy var elloLogo: ElloLogoView = {
        let logo = ElloLogoView()
        logo.bounds = CGRect(x: 0, y: 0, width: 30, height: 30)
        return logo
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.sharedInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.sharedInit()
    }

    func start() {
        elloLogo.animateLogo()
    }

    func stop() {
        elloLogo.stopAnimatingLogo()
    }

    fileprivate func sharedInit() {
        backgroundColor = .white
        addSubview(elloLogo)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        elloLogo.center = CGPoint(x: self.bounds.size.width / 2.0, y: self.bounds.size.height / 2.0)
    }
}
