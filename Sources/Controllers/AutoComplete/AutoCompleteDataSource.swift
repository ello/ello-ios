////
///  AutoCompleteDataSource.swift
//

struct AutoCompleteItem {
    let result: AutoCompleteResult
    let type: AutoCompleteType
    let match: AutoCompleteMatch

    init(result: AutoCompleteResult, type: AutoCompleteType, match: AutoCompleteMatch) {
        self.result = result
        self.type = type
        self.match = match
    }
}

class AutoCompleteDataSource: NSObject {
    var items: [AutoCompleteItem] = []

    func itemForIndexPath(_ indexPath: IndexPath) -> AutoCompleteItem? {
        return items.safeValue(indexPath.row)
    }
}

extension AutoCompleteDataSource: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let cell = tableView.dequeueReusableCell(
                withIdentifier: AutoCompleteCell.reuseIdentifier,
                for: indexPath
            ) as? AutoCompleteCell,
            let item = items.safeValue(indexPath.row)
        else { return UITableViewCell() }

        AutoCompleteCellPresenter.configure(cell, item: item)
        return cell
    }
}
