////
///  DrawerViewController.swift
//

class DrawerViewController: StreamableViewController {
    @IBOutlet weak var tableView: UITableView!
    weak var navigationBar: ElloNavigationBar!
    var isLoggingOut = false

    override var backGestureEdges: UIRectEdge { return .right }

    let dataSource = DrawerViewDataSource()

    required init() {
        super.init(nibName: "DrawerViewController", bundle: .none)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // Using a StreamableViewController to gain access to the InviteResponder
    // Not a great longterm setup.
    override func setupStreamController() {
        // noop
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        addLeftButtons()
        setupTableView()
        setupNavigationBar()
        registerCells()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        postNotification(StatusBarNotifications.statusBarShouldHide, value: false)
    }
}

// MARK: UITableViewDelegate
extension DrawerViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let item = dataSource.itemForIndexPath(indexPath) else { return }

        if let tracking = item.tracking {
            Tracker.shared.tappedDrawer(tracking)
        }

        switch item.type {
        case let .external(link):
            postNotification(ExternalWebNotification, value: link)
        case .invite:
            let responder: InviteResponder? = findResponder()
            responder?.onInviteFriends()
        case .logout:
            isLoggingOut = true
            nextTick {
                self.dismiss(animated: true, completion: { _ in
                     postNotification(AuthenticationNotifications.userLoggedOut, value: ())
                })
            }
        default: break
        }
    }
}

// MARK: View Helpers
private extension DrawerViewController {
    func setupTableView() {
        tableView.backgroundColor = .grey6()
        tableView.delegate = self
        tableView.dataSource = dataSource
    }

    func setupNavigationBar() {
        navigationBar.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: ElloNavigationBar.Size.height)
        navigationBar.items = [elloNavigationItem]
        navigationBar.tintColor = .greyA()

        let color = UIColor.grey6()
        navigationBar.backgroundColor = color
        navigationBar.shadowImage = nil
        navigationBar.barTintColor = color
    }

    func addLeftButtons() {
        let logoView = UIImageView(image: InterfaceImage.elloLogo.normalImage)
        logoView.frame = CGRect(x: 15, y: 30, width: 24, height: 24)
        navigationBar.addSubview(logoView)
    }

    func registerCells() {
        tableView.register(DrawerCell.nib(), forCellReuseIdentifier: DrawerCell.reuseIdentifier)
    }
}
