////
///  AutoCompleteViewController.swift
//


protocol AutoCompleteDelegate: NSObjectProtocol {
    func autoComplete(_ controller: AutoCompleteViewController, itemSelected item: AutoCompleteItem)
}

class AutoCompleteViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    let dataSource = AutoCompleteDataSource()
    let service = AutoCompleteService()
    weak var delegate: AutoCompleteDelegate?

    required init() {
        super.init(nibName: "AutoCompleteViewController", bundle: .none)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: View Lifecycle
extension AutoCompleteViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = dataSource
        registerCells()
        style()
    }
}


// MARK: Public
extension AutoCompleteViewController {

    func load(_ match: AutoCompleteMatch, loaded: @escaping (_ count: Int) -> Void) {
        switch match.type {
        case .emoji:
            let results: [AutoCompleteResult] = service.loadEmojiResults(match.text)
            self.dataSource.items = results.map { AutoCompleteItem(result: $0, type: match.type, match: match) }
            self.tableView.reloadData()
            loaded(self.dataSource.items.count)
        case .username:
            service.loadUsernameResults(match.text,
                success: { (results, _) in
                    self.dataSource.items = results.map { AutoCompleteItem(result: $0, type: match.type, match: match) }
                    self.tableView.reloadData()
                    loaded(self.dataSource.items.count)
                }, failure: showAutoCompleteLoadFailure)
        case .location:
            service.loadLocationResults(match.text,
                success: { (results, _) in
                    self.dataSource.items = results.map { AutoCompleteItem(result: $0, type: match.type, match: match) }
                    self.tableView.reloadData()
                    loaded(self.dataSource.items.count)
                }, failure: showAutoCompleteLoadFailure)
        }
    }

    func showAutoCompleteLoadFailure(_ error: NSError, statusCode: Int?) {
        let message = InterfaceString.GenericError
        let alertController = AlertViewController(message: message)
        let action = AlertAction(title: InterfaceString.OK, style: .dark, handler: nil)
        alertController.addAction(action)
        logPresentingAlert("AutoCompleteViewController")
        present(alertController, animated: true) {
            _ = self.navigationController?.popViewController(animated: true)
        }
    }
}

// MARK: UITableViewDelegate
extension AutoCompleteViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let item = dataSource.itemForIndexPath(indexPath) {
            delegate?.autoComplete(self, itemSelected: item)
        }
    }
}


// MARK: Private
private extension AutoCompleteViewController {
    func registerCells() {
        tableView.register(AutoCompleteCell.nib(), forCellReuseIdentifier: AutoCompleteCell.reuseIdentifier)
    }

    func style() {
        tableView.backgroundColor = UIColor.black
    }
}
