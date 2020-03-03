////
///  DrawerViewDataSource.swift
//

struct DrawerItem: Equatable {
    let title: String
    let type: DrawerItemType
    let tracking: String?

    init(title: String = "", type: DrawerItemType, tracking: String? = nil) {
        self.title = title
        self.type = type
        self.tracking = tracking
    }

    var height: CGFloat {
        switch type {
        case .spacer: return DrawerCell.Size.spacerHeight
        default: return DrawerCell.Size.height
        }
    }

    var logo: UIImage? {
        switch type {
        case .twitter: return UIImage(named: "drawer-twitter")
        case .instagram: return UIImage(named: "drawer-instagram")
        case .facebook: return UIImage(named: "drawer-facebook")
        case .pinterest: return UIImage(named: "drawer-pinterest")
        case .tumblr: return UIImage(named: "drawer-tumblr")
        case .medium: return InterfaceImage.logoMedium.normalImage
        default: return nil
        }
    }

    static func == (lhs: DrawerItem, rhs: DrawerItem) -> Bool {
        return lhs.title == rhs.title
    }
}

enum DrawerItemType {
    case external(String)
    case invite
    case giveaways
    case twitter
    case instagram
    case facebook
    case pinterest
    case tumblr
    case medium
    case logout
    case version
    case debugger
    case spacer
}

class DrawerViewDataSource: NSObject {
    lazy var items: [DrawerItem] = self.drawerItems()

    // moved into a separate function to save compile time
    private func drawerItems() -> [DrawerItem] {
        var items: [DrawerItem] = [
            DrawerItem(title: InterfaceString.Drawer.Invite, type: .invite, tracking: "invite"),
            DrawerItem(
                title: InterfaceString.Drawer.Giveaways,
                type: .giveaways,
                tracking: "giveaways"
            ),
            DrawerItem(
                title: InterfaceString.Drawer.Store,
                type: .external("http://store.ello.co/"),
                tracking: "store"
            ),
            DrawerItem(
                title: InterfaceString.Drawer.Help,
                type: .external("https://ello.co/wtf/"),
                tracking: "help"
            ),
            DrawerItem(title: InterfaceString.Drawer.Logout, type: .logout, tracking: "logout"),
            DrawerItem(type: .spacer),

            DrawerItem(title: InterfaceString.Drawer.Twitter, type: .twitter, tracking: "twitter"),
            DrawerItem(
                title: InterfaceString.Drawer.Instagram,
                type: .instagram,
                tracking: "instagram"
            ),
            DrawerItem(
                title: InterfaceString.Drawer.Facebook,
                type: .facebook,
                tracking: "facebook"
            ),
            DrawerItem(
                title: InterfaceString.Drawer.Pinterest,
                type: .pinterest,
                tracking: "pinterest"
            ),
            DrawerItem(title: InterfaceString.Drawer.Tumblr, type: .tumblr, tracking: "tumblr"),
            DrawerItem(title: InterfaceString.Drawer.Medium, type: .medium, tracking: "medium"),
        ]
        if AuthToken().isStaff {
            items.append(DrawerItem(title: "Show Debugger", type: .debugger))
        }
        items.append(DrawerItem(title: InterfaceString.Drawer.Version, type: .version))
        return items
    }

    func itemForIndexPath(_ indexPath: IndexPath) -> DrawerItem? {
        return items.safeValue(indexPath.row)
    }
}

extension DrawerViewDataSource: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: DrawerCell.reuseIdentifier,
            for: indexPath
        ) as! DrawerCell
        guard let item = items.safeValue(indexPath.row) else { return cell }

        DrawerCellPresenter.configure(cell, item: item, isLast: item == items.last)
        return cell
    }
}
