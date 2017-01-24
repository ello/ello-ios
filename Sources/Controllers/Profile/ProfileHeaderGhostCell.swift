////
///  ProfileHeaderGhostCell.swift
//

class ProfileHeaderGhostCell: UICollectionViewCell {
    static let reuseIdentifier = "ProfileHeaderGhostCell"

    struct Size {
        static let height: CGFloat = 460
        static let sideMargin: CGFloat = 15
        static let whiteTopMargin: CGFloat = 212
        static let avatarTopMargin: CGFloat = 90
        static let avatarSize: CGFloat = 180
        static let ghostNameHeight: CGFloat = 20
        static let ghostHeight: CGFloat = 10
        static let nameTopMargin: CGFloat = 20
        static let nameWidth: CGFloat = 135
        static let nameBottomMargin: CGFloat = 15
        static let totalCountTopMargin: CGFloat = 24
        static let totalCountLeftWidth: CGFloat = 30
        static let totalCountInnerMargin: CGFloat = 13
        static let totalCountRightWidth: CGFloat = 60
        static let totalCountBottomMargin: CGFloat = 24
        static let statsTopMargin: CGFloat = 15
        static let statsInnerMargin: CGFloat = 7
        static let statsTopWidth: CGFloat = 30
        static let statsBottomWidth: CGFloat = 60
        static let statsBottomMargin: CGFloat = 28
    }

    fileprivate let whiteBackground = UIView()
    fileprivate let avatar = UIView()
    fileprivate let name = UIView()
    fileprivate let nameGrayLine = UIView()
    fileprivate let totalCountContainer = UIView()
    fileprivate let totalCountLeft = UIView()
    fileprivate let totalCountRight = UIView()
    fileprivate let totalCountGrayLine = UIView()
    fileprivate let statsContainer = UIView()
    fileprivate let stat1Container = UIView()
    fileprivate let stat1Top = UIView()
    fileprivate let stat1Bottom = UIView()
    fileprivate let stat2Container = UIView()
    fileprivate let stat2Top = UIView()
    fileprivate let stat2Bottom = UIView()
    fileprivate let stat3Container = UIView()
    fileprivate let stat3Top = UIView()
    fileprivate let stat3Bottom = UIView()
    fileprivate let stat4Container = UIView()
    fileprivate let stat4Top = UIView()
    fileprivate let stat4Bottom = UIView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        style()
        arrange()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    fileprivate func style() {
        whiteBackground.backgroundColor = .white
        let ghostsViews = [avatar, name, totalCountLeft, totalCountRight, stat1Top, stat1Bottom, stat2Top, stat2Bottom, stat3Top, stat3Bottom, stat4Top, stat4Bottom]
        for view in ghostsViews {
            view.backgroundColor = .greyF2()
        }
        avatar.layer.cornerRadius = Size.avatarSize / 2

        let lines = [nameGrayLine, totalCountGrayLine]
        for view in lines {
            view.backgroundColor = .greyF2()
        }
    }

    fileprivate func arrange() {
        addSubview(whiteBackground)

        addSubview(avatar)
        addSubview(name)

        addSubview(nameGrayLine)

        addSubview(totalCountContainer)
        totalCountContainer.addSubview(totalCountLeft)
        totalCountContainer.addSubview(totalCountRight)

        addSubview(totalCountGrayLine)

        addSubview(statsContainer)
        statsContainer.addSubview(stat1Container)
        stat1Container.addSubview(stat1Top)
        stat1Container.addSubview(stat1Bottom)

        statsContainer.addSubview(stat2Container)
        stat2Container.addSubview(stat2Top)
        stat2Container.addSubview(stat2Bottom)

        statsContainer.addSubview(stat3Container)
        stat3Container.addSubview(stat3Top)
        stat3Container.addSubview(stat3Bottom)

        statsContainer.addSubview(stat4Container)
        stat4Container.addSubview(stat4Top)
        stat4Container.addSubview(stat4Bottom)

        whiteBackground.snp.makeConstraints { make in
            make.top.equalTo(self).offset(Size.whiteTopMargin)
            make.leading.trailing.bottom.equalTo(self)
        }
        avatar.snp.makeConstraints { make in
            make.centerX.equalTo(self)
            make.top.equalTo(self).offset(Size.avatarTopMargin)
            make.width.height.equalTo(Size.avatarSize)
        }
        name.snp.makeConstraints { make in
            make.centerX.equalTo(self)
            make.top.equalTo(avatar.snp.bottom).offset(Size.nameTopMargin)
            make.width.equalTo(Size.nameWidth)
            make.height.equalTo(Size.ghostNameHeight)
        }
        nameGrayLine.snp.makeConstraints { make in
            make.leading.trailing.equalTo(self).inset(Size.sideMargin)
            make.top.equalTo(name.snp.bottom).offset(Size.nameBottomMargin)
            make.height.equalTo(1)
        }
        totalCountContainer.snp.makeConstraints { make in
            make.centerX.equalTo(self)
            make.top.equalTo(nameGrayLine.snp.bottom).offset(Size.totalCountTopMargin)
            make.leading.equalTo(totalCountLeft)
            make.trailing.equalTo(totalCountRight)
            make.height.equalTo(Size.ghostHeight)
        }
        totalCountLeft.snp.makeConstraints { make in
            make.width.equalTo(Size.totalCountLeftWidth)
            make.top.bottom.equalTo(totalCountContainer)
        }
        totalCountRight.snp.makeConstraints { make in
            make.width.equalTo(Size.totalCountRightWidth)
            make.leading.equalTo(totalCountLeft.snp.trailing).offset(Size.totalCountInnerMargin)
            make.top.bottom.equalTo(totalCountContainer)
        }
        totalCountGrayLine.snp.makeConstraints { make in
            make.leading.trailing.equalTo(self).inset(Size.sideMargin)
            make.top.equalTo(totalCountContainer.snp.bottom).offset(Size.totalCountBottomMargin)
            make.height.equalTo(1)
        }
        statsContainer.snp.makeConstraints { make in
            make.leading.equalTo(self).offset(Size.sideMargin)
            make.trailing.equalTo(self)
            make.bottom.equalTo(self).offset(-Size.statsBottomMargin)
            make.top.equalTo(totalCountGrayLine.snp.bottom).offset(Size.statsTopMargin)
        }
        stat1Container.snp.makeConstraints { make in
            make.top.bottom.leading.equalTo(statsContainer)
            make.width.equalTo(statsContainer).dividedBy(4)
        }
        stat1Top.snp.makeConstraints { make in
            make.top.leading.equalTo(stat1Container)
            make.width.equalTo(Size.statsTopWidth)
            make.height.equalTo(Size.ghostHeight)
        }
        stat1Bottom.snp.makeConstraints { make in
            make.top.equalTo(stat1Top.snp.bottom).offset(Size.statsInnerMargin)
            make.leading.equalTo(stat1Container)
            make.width.equalTo(Size.statsBottomWidth)
            make.height.equalTo(Size.ghostHeight)
        }
        stat2Container.snp.makeConstraints { make in
            make.top.bottom.width.equalTo(stat1Container)
            make.leading.equalTo(stat1Container.snp.trailing)
        }
        stat2Top.snp.makeConstraints { make in
            make.top.leading.equalTo(stat2Container)
            make.width.equalTo(Size.statsTopWidth)
            make.height.equalTo(Size.ghostHeight)
        }
        stat2Bottom.snp.makeConstraints { make in
            make.top.equalTo(stat2Top.snp.bottom).offset(Size.statsInnerMargin)
            make.leading.equalTo(stat2Container)
            make.width.equalTo(Size.statsBottomWidth)
            make.height.equalTo(Size.ghostHeight)
        }
        stat3Container.snp.makeConstraints { make in
            make.leading.equalTo(stat2Container.snp.trailing)
            make.top.bottom.width.equalTo(stat1Container)
        }
        stat3Top.snp.makeConstraints { make in
            make.top.leading.equalTo(stat3Container)
            make.width.equalTo(Size.statsTopWidth)
            make.height.equalTo(Size.ghostHeight)
        }
        stat3Bottom.snp.makeConstraints { make in
            make.top.equalTo(stat3Top.snp.bottom).offset(Size.statsInnerMargin)
            make.leading.equalTo(stat3Container)
            make.width.equalTo(Size.statsBottomWidth)
            make.height.equalTo(Size.ghostHeight)
        }
        stat4Container.snp.makeConstraints { make in
            make.trailing.equalTo(statsContainer)
            make.leading.equalTo(stat3Container.snp.trailing)
            make.top.bottom.width.equalTo(stat1Container)
        }
        stat4Top.snp.makeConstraints { make in
            make.top.leading.equalTo(stat4Container)
            make.width.equalTo(Size.statsTopWidth)
            make.height.equalTo(Size.ghostHeight)
        }
        stat4Bottom.snp.makeConstraints { make in
            make.top.equalTo(stat4Top.snp.bottom).offset(Size.statsInnerMargin)
            make.leading.equalTo(stat4Container)
            make.width.equalTo(Size.statsBottomWidth)
            make.height.equalTo(Size.ghostHeight)
        }
    }
}
