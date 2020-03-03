////
///  NestedTabBarView.swift
//

class NestedTabBarView: View {
    struct Size {
        static let height: CGFloat = 60
        static let tabSpacing: CGFloat = 1
        static let margins = UIEdgeInsets(top: 5, left: 15, bottom: 15, right: 15)
        static let buttonHeight: CGFloat = 40
    }

    class Tab {
        fileprivate let button = StyledButton(style: .clearGray)
        fileprivate let line = Line()

        static func == (lhs: Tab, rhs: Tab) -> Bool {
            return lhs.button == rhs.button
        }

        init(title: String? = nil) {
            button.addSubview(line)
            button.title = title
        }

        var title: String? {
            get { return button.title(for: .normal) }
            set { button.title = newValue }
        }

        func addTarget(_ target: Any?, action: Selector) {
            button.addTarget(target, action: action, for: .touchUpInside)
        }
    }

    var tabs: [Tab] = []
    var isArranged = false

    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIView.noIntrinsicMetric, height: Size.height)
    }

    func createTab(title: String? = nil) -> Tab {
        return Tab(title: title)
    }

    func addTab(_ tab: Tab) {
        guard !isArranged else {
            fatalError("cannot add tabs after tabbar has been added to a view")
        }

        addSubview(tab.button)
        tabs.append(tab)
    }

    override func style() {
        backgroundColor = .background
    }

    func select(tab selectedTab: Tab) {
        for tab in tabs {
            if tab == selectedTab {
                tab.button.style = .clearDynamic
                tab.line.backgroundColor = .text
                tab.button.isUserInteractionEnabled = false
            }
            else {
                tab.button.style = .clearGrayDynamic
                tab.line.backgroundColor = .greyA
                tab.button.isUserInteractionEnabled = true
            }
        }
    }

    func select(button: UIButton) {
        for tab in tabs {
            guard tab.button == button else { continue }
            select(tab: tab)
            break
        }
    }

    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        if superview != nil {
            rearrange()
        }
    }

    private func rearrange() {
        guard !isArranged else { return }

        tabs.eachPair { prevTab, tab, isLast in
            tab.button.snp.makeConstraints { make in
                make.top.equalTo(self).inset(Size.margins)
                make.height.equalTo(Size.buttonHeight)

                if let prevTab = prevTab {
                    make.leading.equalTo(prevTab.button.snp.trailing).offset(Size.tabSpacing)
                    make.width.equalTo(prevTab.button)
                }
                else {
                    make.leading.equalTo(self).inset(Size.margins)
                }

                if isLast {
                    make.trailing.equalTo(self).inset(Size.margins)
                }
            }

            tab.line.snp.makeConstraints { make in
                make.leading.trailing.bottom.equalTo(tab.button)
            }
        }

        isArranged = true
    }
}
