////
///  StreamLoadingCell.swift
//

class StreamLoadingCell: CollectionViewCell {
    static let reuseIdentifier = "StreamLoadingCell"
    struct Size {
        static let topMargin: CGFloat = 50
        static let bottomMargin: CGFloat = 15
        static var height: CGFloat {
            return GradientLoadingView.Size.size.height + topMargin + bottomMargin
        }
    }

    let elloLogo = GradientLoadingView()

    override func arrange() {
        contentView.addSubview(elloLogo)

        elloLogo.snp.makeConstraints { make in
            make.top.equalTo(contentView).offset(Size.topMargin)
            make.centerX.equalTo(contentView)
        }
    }

    override func style() {
        backgroundColor = .white
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        stopAnimating()
    }
}

protocol LoadingCell {
    func startAnimating()
    func stopAnimating()
}

extension StreamLoadingCell: LoadingCell {
    func startAnimating() {
        elloLogo.startAnimating()
    }

    func stopAnimating() {
        elloLogo.stopAnimating()
    }
}
