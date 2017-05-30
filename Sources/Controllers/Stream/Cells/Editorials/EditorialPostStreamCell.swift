////
///  EditorialPostStreamCell.swift
//

import SnapKit


class EditorialPostStreamCell: EditorialCell {
    fileprivate let nextButton = UIButton()
    fileprivate let prevButton = UIButton()
    fileprivate let scrollView = UIScrollView()
    fileprivate var postViews: [EditorialPostCell] = []
    fileprivate let titleLabel = StyledLabel(style: .giantWhite)
    fileprivate let bg = UIView()

    override func style() {
        super.style()

        bg.backgroundColor = .black
        titleLabel.numberOfLines = 0
        scrollView.isPagingEnabled = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.alwaysBounceVertical = false
        scrollView.scrollsToTop = false
        nextButton.setImage(.arrow, imageStyle: .white, for: .normal, degree: 90)
        prevButton.setImage(.arrow, imageStyle: .white, for: .normal, degree: -90)
        editorialContentView.isHidden = true
    }

    override func bindActions() {
        super.bindActions()
        nextButton.addTarget(self, action: #selector(nextTapped), for: .touchUpInside)
        prevButton.addTarget(self, action: #selector(prevTapped), for: .touchUpInside)
    }

    override func updateConfig() {
        super.updateConfig()
        titleLabel.text = config.title

        let postStreamConfigs: [EditorialCell.Config] = config.postStream?.postConfigs ?? []
        updatePostViews(configs: postStreamConfigs)
        nextButton.isHidden = postStreamConfigs.count == 0
        prevButton.isHidden = postStreamConfigs.count == 0
    }

    override func arrange() {
        super.arrange()

        contentView.addSubview(bg)
        contentView.addSubview(scrollView)
        contentView.addSubview(nextButton)
        contentView.addSubview(prevButton)
        contentView.addSubview(titleLabel)

        bg.snp.makeConstraints { make in
            make.edges.equalTo(contentView).inset(Size.bgMargins)
        }
        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(contentView)
        }
        nextButton.snp.makeConstraints { make in
            make.top.trailing.equalTo(contentView).inset(Size.arrowMargin)
        }
        prevButton.snp.makeConstraints { make in
            make.top.equalTo(contentView).inset(Size.arrowMargin)
            make.trailing.equalTo(nextButton.snp.leading).offset(-Size.arrowMargin)
        }

        titleLabel.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(contentView).inset(Size.defaultMargin)
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        for view in postViews {
            view.snp.updateConstraints { make in
                make.size.equalTo(frame.size)
            }
        }
    }
}

extension EditorialPostStreamCell {
    @objc
    func nextTapped() {
        movePage(delta: 1)
    }

    @objc
    func prevTapped() {
        movePage(delta: -1)
    }

    private func movePage(delta: CGFloat) {
        let numPages = scrollView.contentSize.width / scrollView.frame.width
        let page: CGFloat = floor(map(
            scrollView.contentOffset.x,
            fromInterval: (0, scrollView.contentSize.width),
            toInterval: (0, numPages)
            ))
        let destPage: CGFloat = min(numPages - 1, max(0, page + delta))
        let destX = scrollView.frame.width * destPage
        scrollView.setContentOffset(CGPoint(x: destX, y: scrollView.contentOffset.y), animated: true)
    }
}

extension EditorialPostStreamCell {
    func updatePostViews(configs: [EditorialCell.Config]) {
        for view in postViews {
            view.removeFromSuperview()
        }

        postViews = configs.map { config in
            let cell = EditorialPostCell()
            cell.config = config
            return cell
        }

        postViews.eachPair { prevView, view, isLast in
            scrollView.addSubview(view)
            view.snp.makeConstraints { make in
                make.top.bottom.equalTo(scrollView)
                make.size.equalTo(frame.size)

                if let prevView = prevView {
                    make.leading.equalTo(prevView.snp.trailing)
                }
                else {
                    make.leading.equalTo(scrollView)
                }

                if isLast {
                    make.trailing.equalTo(scrollView)
                }
            }

            view.contentView.snp.makeConstraints { make in
                make.edges.equalTo(view)
            }
        }
    }
}
