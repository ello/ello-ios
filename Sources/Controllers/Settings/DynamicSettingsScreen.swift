////
///  DynamicSettingsScreen.swift
//

class DynamicSettingsScreen: NavBarScreen, DynamicSettingsScreenProtocol {
    struct Size {
        static let estimatedRowHeight: CGFloat = 50
    }

    weak var delegate: DynamicSettingsScreenDelegate?
    var title: String? {
        get { return navigationBar.title }
        set { navigationBar.title = newValue }
    }
    var contentInset: UIEdgeInsets = .zero { didSet { updateInsets() }}

    private let settings: [DynamicSetting]
    private let tableView = UITableView()

    init(settings: [DynamicSetting]) {
        self.settings = settings
        super.init(frame: UIScreen.main.bounds)
    }

    required init(frame: CGRect) {
        fatalError("init(frame:) has not been implemented")
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func reload() {
        tableView.reloadData()
    }

    override func style() {
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        }

        tableView.backgroundColor = .white
        navigationBar.leftItems = [.back]
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = Size.estimatedRowHeight
        tableView.register(DynamicSettingCell.self, forCellReuseIdentifier: DynamicSettingCell.reuseIdentifier)
    }

    override func bindActions() {
        tableView.dataSource = self
        tableView.delegate = self
    }

    override func arrange() {
        arrange(contentView: tableView)

        tableView.snp.makeConstraints { make in
            make.edges.equalTo(self)
        }

        contentInset.top = ElloNavigationBar.Size.height
        contentInset.bottom = ElloTabBar.Size.height
    }

    private func updateInsets() {
        tableView.contentInset = contentInset
        tableView.scrollIndicatorInsets = contentInset
    }
}

extension DynamicSettingsScreen: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settings.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: DynamicSettingCell.reuseIdentifier, for: indexPath) as! DynamicSettingCell
        guard let currentUser = delegate?.currentUser else { return cell }

        DynamicSettingCellPresenter.configure(cell,
            setting: settings[indexPath.row],
            currentUser: currentUser)

        return cell
    }
}

extension DynamicSettingsScreen: UITableViewDelegate {
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return false
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
