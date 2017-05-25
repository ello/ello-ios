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

    override func style() {
        super.style()

        titleLabel.numberOfLines = 0
        scrollView.isPagingEnabled = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.alwaysBounceVertical = false
        scrollView.scrollsToTop = false
        nextButton.setImage(.arrow, imageStyle: .white, for: .normal, degree: 90)
        prevButton.setImage(.arrow, imageStyle: .white, for: .normal, degree: -90)
    }

    override func bindActions() {
        super.bindActions()
    }

    override func updateConfig() {
        super.updateConfig()
        titleLabel.text = config.title
        updatePostViews(configs: config.postConfigs)
        nextButton.isHidden = config.postConfigs.count == 0
        prevButton.isHidden = config.postConfigs.count == 0
    }

    override func arrange() {
        super.arrange()

        contentView.addSubview(scrollView)
        contentView.addSubview(nextButton)
        contentView.addSubview(prevButton)
        contentView.addSubview(titleLabel)

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

    func updatePostViews(configs: [EditorialCell.Config]) {
        for view in postViews {
            view.removeFromSuperview()
        }

        postViews = configs.map { config in
            let cell = EditorialPostCell()
            cell.config = config
            return cell
        }
        titleLabel.text = "count: \(postViews.count)"

        postViews.eachPair { prevView, view in
            scrollView.addSubview(view)

            view.snp.makeConstraints { make in
                make.top.bottom.equalTo(scrollView)
                if let prevView = prevView {
                    make.leading.equalTo(prevView.snp.trailing)
                }
                else {
                    make.leading.equalTo(scrollView)
                }

                make.size.equalTo(frame.size)
            }

            view.contentView.snp.makeConstraints { make in
                make.edges.equalTo(view)
            }
        }

        if let lastView = postViews.last {
            lastView.snp.makeConstraints { make in
                make.trailing.equalTo(scrollView)
            }
        }
    }
}
