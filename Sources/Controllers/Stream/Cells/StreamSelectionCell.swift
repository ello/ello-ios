////
///  StreamSelectionCell.swift
//

import SnapKit

class StreamSelectionCell: CollectionViewCell {
    static let reuseIdentifier = "StreamSelectionCell"

    struct Size {
        static let height: CGFloat = 45
        static let spacing: CGFloat = 1
    }

    var selectedFilter: CategoryFilter = .featured {
        didSet {
            switch selectedFilter {
            case .featured: tabBar?.select(tab: featuredTab)
            case .trending: tabBar?.select(tab: trendingTab)
            case .recent: tabBar?.select(tab: recentTab)
            case .shop: tabBar?.select(tab: shopTab)
            }
        }
    }
    var filters: [CategoryFilter] = [.featured, .trending, .recent, .shop] {
        didSet { updateTabs() }
    }

    private var tabBar: NestedTabBarView?
    private var featuredTab: NestedTabBarView.Tab!
    private var trendingTab: NestedTabBarView.Tab!
    private var recentTab: NestedTabBarView.Tab!
    private var shopTab: NestedTabBarView.Tab!

    override func style() {
        backgroundColor = .white
        updateTabs()
    }

    private func updateTabs() {
        if let tabBar = self.tabBar {
            tabBar.removeFromSuperview()
        }

        let tabBar = NestedTabBarView()
        let tabs: [NestedTabBarView.Tab] = filters.map { filter in
            let tab = tabBar.createTab(title: filter.name)
            switch filter {
            case .featured:
                tab.addTarget(self, action: #selector(featuredTapped))
                featuredTab = tab
            case .trending:
                tab.addTarget(self, action: #selector(trendingTapped))
                trendingTab = tab
            case .recent:
                tab.addTarget(self, action: #selector(recentTapped))
                recentTab = tab
            case .shop:
                tab.addTarget(self, action: #selector(shopTapped))
                shopTab = tab
            }
            return tab
        }
        for tab in tabs {
            tabBar.addTab(tab)
        }

        if let tab = tabs.first {
            tabBar.select(tab: tab)
        }
        contentView.addSubview(tabBar)

        tabBar.snp.makeConstraints { make in
            make.edges.equalTo(contentView)
        }

        self.tabBar = tabBar
    }

    @objc
    func featuredTapped() {
        tabBar?.select(tab: featuredTab)
        let responder: StreamSelectionCellResponder? = findResponder()
        responder?.streamTapped(CategoryFilter.featured.slug)
    }

    @objc
    func trendingTapped() {
        tabBar?.select(tab: trendingTab)
        let responder: StreamSelectionCellResponder? = findResponder()
        responder?.streamTapped(CategoryFilter.trending.slug)
    }

    @objc
    func recentTapped() {
        tabBar?.select(tab: recentTab)
        let responder: StreamSelectionCellResponder? = findResponder()
        responder?.streamTapped(CategoryFilter.recent.slug)
    }

    @objc
    func shopTapped() {
        tabBar?.select(tab: shopTab)
        let responder: StreamSelectionCellResponder? = findResponder()
        responder?.streamTapped(CategoryFilter.shop.slug)
    }

}
