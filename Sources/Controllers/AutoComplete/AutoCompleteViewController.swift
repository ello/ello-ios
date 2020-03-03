////
///  AutoCompleteViewController.swift
//


protocol AutoCompleteDelegate: class {
    func autoComplete(_ controller: AutoCompleteViewController, itemSelected item: AutoCompleteItem)
}

class AutoCompleteViewController: UIViewController {
    let tableView = UITableView()
    let dataSource = AutoCompleteDataSource()
    let service = AutoCompleteService()
    weak var delegate: AutoCompleteDelegate?

    required init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension AutoCompleteViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalTo(view)
        }

        tableView.rowHeight = AutoCompleteCell.Size.height
        tableView.delegate = self
        tableView.dataSource = dataSource
        tableView.separatorStyle = .none
        registerCells()
        style()
    }
}

extension AutoCompleteViewController {

    func load(_ match: AutoCompleteMatch, loaded: @escaping (_ count: Int) -> Void) {
        switch match.type {
        case .emoji:
            let results = service.loadEmojiResults(match.text)
            self.dataSource.items = results.map {
                AutoCompleteItem(result: $0, type: match.type, match: match)
            }
            self.tableView.reloadData()
            loaded(self.dataSource.items.count)
        case .username:
            service.loadUsernameResults(match.text)
                .done { results in
                    self.dataSource.items = results.map {
                        AutoCompleteItem(result: $0, type: match.type, match: match)
                    }
                    self.tableView.reloadData()
                    loaded(self.dataSource.items.count)
                }
                .catch { _ in
                    self.showAutoCompleteLoadFailure()
                }
        case .location:
            service.loadLocationResults(match.text)
                .done { results in
                    self.dataSource.items = results.map {
                        AutoCompleteItem(result: $0, type: match.type, match: match)
                    }
                    self.tableView.reloadData()
                    loaded(self.dataSource.items.count)
                }
                .catch { _ in
                    self.showAutoCompleteLoadFailure()
                }
        }
    }

    func showAutoCompleteLoadFailure() {
        let message = InterfaceString.GenericError
        let alertController = AlertViewController(confirmation: message) { _ in
            _ = self.navigationController?.popViewController(animated: true)
        }
        present(alertController, animated: true)
    }
}

extension AutoCompleteViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let item = dataSource.itemForIndexPath(indexPath) else { return }
        nextTick {
            self.delegate?.autoComplete(self, itemSelected: item)
        }
    }
}


private extension AutoCompleteViewController {
    func registerCells() {
        tableView.register(
            AutoCompleteCell.self,
            forCellReuseIdentifier: AutoCompleteCell.reuseIdentifier
        )
    }

    func style() {
        tableView.backgroundColor = UIColor.black
    }
}
