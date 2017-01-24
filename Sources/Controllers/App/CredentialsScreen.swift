////
///  CredentialsScreen.swift
//

import SnapKit


class CredentialsScreen: EmptyScreen {
    struct Size {
        static let backTopInset: CGFloat = 10
        static let titleTop: CGFloat = 110
        static let inset: CGFloat = 10
    }

    let scrollView = UIScrollView()
    var scrollViewWidthConstraint: Constraint!
    let backButton = UIButton()
    let titleLabel = StyledLabel(style: .LargeWhite)
    let gradientLayer = StartupGradientLayer()

    override func updateConstraints() {
        super.updateConstraints()
        scrollViewWidthConstraint.update(offset: frame.size.width)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let maxDimension = max(layer.frame.size.width, layer.frame.size.height)
        let size = CGSize(width: maxDimension, height: maxDimension)
        gradientLayer.frame.size = size
        gradientLayer.position = layer.bounds.center
    }

    override func bindActions() {
        backButton.addTarget(self, action: #selector(backAction), for: .touchUpInside)
    }

    override func style() {
        super.style()
        backButton.setImages(.angleBracket, degree: 180, white: true)
        backButton.contentMode = .center
    }

    override func arrange() {
        layer.masksToBounds = true
        layer.addSublayer(gradientLayer)

        super.arrange()

        addSubview(scrollView)
        scrollView.addSubview(titleLabel)
        scrollView.addSubview(backButton)

        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(scrollView).offset(Size.titleTop)
            make.leading.equalTo(scrollView).offset(Size.inset)
        }

        backButton.snp.makeConstraints { make in
            make.top.equalTo(scrollView).offset(Size.backTopInset)
            make.leading.equalTo(scrollView)
            make.size.equalTo(CGSize.minButton)
        }
    }

    func backAction() {
    }
}
