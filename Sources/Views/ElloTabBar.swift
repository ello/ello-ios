////
///  ElloTabBar.swift
//

class ElloTabBar: UIView {
    struct Size {
        static let height: CGFloat = calculateHeight()
        static let itemHeight: CGFloat = 44
        static let topOffset: CGFloat = calculateTopOffset()

        static private func calculateHeight() -> CGFloat {
            if Globals.isIphoneX {
                return 66
            }
            return 44
        }

        static private func calculateTopOffset() -> CGFloat {
            if Globals.isIphoneX {
                return 5
            }
            return 0
        }
    }

    weak var delegate: ElloTabBarDelegate?

    var selectedTab: ElloTab? {
        didSet {
            for button in tabbarButtons {
                button.isSelected = false
            }

            guard let selectedTab = selectedTab,
                let index = tabs.firstIndex(of: selectedTab)
            else { return }
            tabbarButtons[index].isSelected = true
        }
    }
    var tabs: [ElloTab] = [] {
        didSet { arrangeTabs() }
    }

    var buttonFrames: [CGRect] { return tabbarButtons.map { $0.frame } }
    private var tabbarButtons: [UIButton] = []

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        privateInit()
    }

    convenience init() {
        self.init(frame: .zero)
        privateInit()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        privateInit()
    }

    private func privateInit() {
        self.backgroundColor = .background
        self.isOpaque = true
        self.tintColor = .text
        self.clipsToBounds = true
    }

    func resetImages(profile: UIImage?) {
        for (index, tab) in tabs.enumerated() {
            let button = tabbarButtons[index]
            if let (image, selectedImage) = tab.customImages(profile: profile) {
                button.setImage(image, for: .normal)
                button.setImage(selectedImage, for: .selected)
                button.setImage(selectedImage, for: .highlighted)
            }
            else {
                button.setImages(tab.interfaceImage, style: .dynamic)
            }
        }
    }

    private func arrangeTabs() {
        for button in tabbarButtons {
            button.removeFromSuperview()
        }

        tabbarButtons = tabs.map { tab in
            let button = UIButton()
            button.addTarget(self, action: #selector(tappedTabbarButton(_:)), for: .touchUpInside)
            return button
        }

        resetImages(profile: nil)

        tabbarButtons.eachPair { prevButton, button, isLast in
            addSubview(button)
            button.snp.makeConstraints { make in
                make.top.equalTo(self).offset(Size.topOffset)
                make.height.equalTo(Size.itemHeight)

                if let prevButton = prevButton {
                    make.width.equalTo(prevButton)
                    make.leading.equalTo(prevButton.snp.trailing)
                }
                else {
                    make.leading.equalTo(self)
                }

                if isLast {
                    make.trailing.equalTo(self)
                }
            }
        }
    }

    @objc
    func tappedTabbarButton(_ sender: UIButton) {
        guard
            let delegate = delegate,
            let index = tabbarButtons.firstIndex(of: sender)
        else { return }

        let tab = tabs[index]
        selectedTab = tab
        delegate.tabBar(self, didSelect: tab)
    }

    func addRedDotFor(tab: ElloTab) -> UIView {
         let redDot = UIView()
         redDot.backgroundColor = .red
         redDot.isHidden = true
         addSubview(redDot)

         positionRedDot(redDot, forTab: tab)
         return redDot
     }

     private func positionRedDot(_ redDot: UIView, forTab tab: ElloTab) {
        layoutIfNeeded()

        let radius: CGFloat = 3
        let diameter = radius * 2
        let tab = tabs[tab.rawValue]
        let button = tabbarButtons[tab.rawValue]

        redDot.layer.masksToBounds = true
        redDot.layer.cornerRadius = radius
        redDot.snp.makeConstraints { make in
            make.leading.equalTo(button.snp.centerX).offset(tab.redDotMargins.x)
            make.top.equalTo(self).offset(tab.redDotMargins.y)
            make.width.height.equalTo(diameter)
        }
    }

}

protocol ElloTabBarDelegate: class {
    func tabBar(_ tabBar: ElloTabBar, didSelect item: ElloTab)
}
