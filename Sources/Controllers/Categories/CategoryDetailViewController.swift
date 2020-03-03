////
///  CategoryDetailViewController.swift
//

class CategoryDetailViewController: BaseElloViewController {
    private var generator: CategoryDetailGenerator!
    private let category: Category
    private let pageHeader: PageHeader

    private var _mockScreen: CategoryDetailScreenProtocol?
    var screen: CategoryDetailScreenProtocol {
        set(screen) { _mockScreen = screen }
        get { return fetchScreen(_mockScreen) }
    }

    var headerView: UIView { return screen.headerView }

    init(category: Category, pageHeader: PageHeader) {
        self.category = category
        self.pageHeader = pageHeader
        super.init(nibName: nil, bundle: nil)
        self.generator = CategoryDetailGenerator(destination: self)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        let screen = CategoryDetailScreen()

        let isSubscribed: Bool
        if let currentUser = currentUser, let categoryId = pageHeader.categoryId {
            isSubscribed = currentUser.subscribedTo(categoryId: categoryId)
        }
        else {
            isSubscribed = false
        }

        let config = CategoryDetailScreen.Config(
            category: category,
            pageHeader: pageHeader,
            isSubscribed: isSubscribed
        )
        screen.config = config
        screen.delegate = self
        screen.updateUsers(moderators: [], curators: [])

        self.view = screen
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        generator.loadAdmins(slug: category.slug)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        postNotification(StatusBarNotifications.statusBarVisibility, value: false)
    }
}

extension CategoryDetailViewController: CategoryDetailDelegate {
    func closeController() {
        dismiss(animated: true, completion: nil)
    }

    func adminsLoaded(moderators: [User], curators: [User]) {
        screen.updateUsers(moderators: moderators, curators: curators)
    }
}
