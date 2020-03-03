////
///  DrawerViewController.swift
//

protocol DrawerResponder: class {
    func showDrawerViewController()
}

class DrawerViewController: BaseElloViewController {
    struct Size {
        static let height = calculateHeight()
        static let headerHeight: CGFloat = 50
        static let logoSize: CGFloat = 30

        static private func calculateHeight() -> CGFloat {
            return Size.headerHeight + StatusBar.Size.height
        }
    }

    let tableView = UITableView()
    let headerView = UIView()

    var isLoggingOut = false

    override var backGestureEdges: UIRectEdge { return .right }

    let dataSource = DrawerViewDataSource()

    required init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        arrange()
        setupNavigationBar()
        setupTableView()
        registerCells()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        postNotification(StatusBarNotifications.statusBarVisibility, value: true)
    }
}

extension DrawerViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let item = dataSource.itemForIndexPath(indexPath) else { return 0 }
        return item.height
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let item = dataSource.itemForIndexPath(indexPath) else { return }
        nextTick { self.didSelectItem(item) }
    }

    private func didSelectItem(_ item: DrawerItem) {
        if let tracking = item.tracking {
            Tracker.shared.tappedDrawer(tracking)
        }

        switch item.type {
        case let .external(link):
            postNotification(ExternalWebNotification, value: link)
        case .twitter:
            let link = "https://twitter.com/ellohype"
            postNotification(ExternalWebNotification, value: link)
        case .instagram:
            let link = "https://www.instagram.com/ellohype"
            postNotification(ExternalWebNotification, value: link)
        case .facebook:
            let link = "https://www.facebook.com/ellohype"
            postNotification(ExternalWebNotification, value: link)
        case .pinterest:
            let link = "https://www.pinterest.com/ellohype"
            postNotification(ExternalWebNotification, value: link)
        case .tumblr:
            let link = "http://ellohype.tumblr.com/"
            postNotification(ExternalWebNotification, value: link)
        case .medium:
            let link = "https://medium.com/@ElloHype"
            postNotification(ExternalWebNotification, value: link)
        case .invite:
            let responder: InviteResponder? = findResponder()
            responder?.onInviteFriends()
        case .giveaways:
            let appViewController = self.appViewController
            dismiss(animated: true) {
                nextTick {
                    appViewController?.showProfileScreen(
                        userParam: "elloartgiveaways",
                        isSlug: true
                    )
                }
            }
        case .logout:
            isLoggingOut = true
            dismiss(animated: true) {
                nextTick {
                    postNotification(AuthenticationNotifications.userLoggedOut, value: ())
                }
            }
        case .debugger:
            let appViewController = self.appViewController
            dismiss(animated: true) {
                nextTick {
                    appViewController?.showDebugController()
                }
            }
        default: break
        }
    }
}

private extension DrawerViewController {
    func arrange() {
        view.addSubview(tableView)
        view.addSubview(headerView)

        headerView.snp.makeConstraints { make in
            make.leading.trailing.top.equalTo(self.view)
            make.height.equalTo(Size.height)
        }

        tableView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalTo(self.view)
            make.top.equalTo(headerView.snp.bottom)
        }
    }

    func setupTableView() {
        tableView.backgroundColor = .grey6
        tableView.delegate = self
        tableView.dataSource = dataSource
        tableView.separatorStyle = .none
        tableView.rowHeight = DrawerCell.Size.height
    }

    func setupNavigationBar() {
        headerView.backgroundColor = .grey6

        let logoView = UIImageView(image: InterfaceImage.elloLogo.normalImage)
        let logoY: CGFloat = Globals.statusBarHeight + 10
        logoView.frame = CGRect(x: 15, y: logoY, width: Size.logoSize, height: Size.logoSize)
        headerView.addSubview(logoView)
    }

    func registerCells() {
        tableView.register(DrawerCell.self, forCellReuseIdentifier: DrawerCell.reuseIdentifier)
    }
}
