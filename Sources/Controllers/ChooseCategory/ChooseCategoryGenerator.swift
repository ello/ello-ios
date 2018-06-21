////
///  ChooseCategoryGenerator.swift
//

class ChooseCategoryGenerator: StreamGenerator {
    typealias Usage = ChooseCategoryViewController.Usage

    var currentUser: User?
    var category: Category?
    var usage: Usage
    var streamKind: StreamKind = .chooseCategory
    let searchString = SearchString(text: "")
    weak var destination: StreamDestination?

    init(currentUser: User, category: Category?, usage: Usage, destination: StreamDestination?) {
        self.currentUser = currentUser
        self.category = category
        self.usage = usage
        self.destination = destination
    }

    func load(reload: Bool) {
        if reload {
        }
        else {
            setPlaceHolders()
        }

        loadAllCategories()
    }
}

extension ChooseCategoryGenerator {
    private func setPlaceHolders() {
        destination?.setPlaceholders(items: [
            StreamCellItem(type: .placeholder, placeholderType: .streamItems)
        ])
    }

    private func loadAllCategories() {
        if let cachedCategories: [Category] = TemporaryCache.load(.categories) {
            processCategories(cachedCategories)
            return
        }

        API().allCategories()
            .execute()
            .done { allCategories in
                guard let currentUser = self.currentUser else { return }

                // put all subscribed categories first, then unsubscribed, preserving order
                let sortedCategories = allCategories.enumerated().map { index, category in
                    return currentUser.subscribedTo(categoryId: category.id) ? (index, category) : (allCategories.count + index, category)
                }.sorted { infoA, infoB in
                    return infoA.0 < infoB.0
                }.map { $0.1 }

                TemporaryCache.save(.categories, sortedCategories)
                self.processCategories(sortedCategories)
            }
            .ignoreErrors()
    }

    private func processCategories(_ categories: [Category]) {
        let items = [StreamCellItem(jsonable: self.searchString, type: .search(placeholder: InterfaceString.Community.Search))] + categories.map { category in
            let isSelected = self.category?.id == category.id
            let isSubscribed: Bool
            switch usage {
            case .omnibar: isSubscribed = currentUser?.subscribedTo(categoryId: category.id) == true
            case .roleAdmin: isSubscribed = false
            }

            return StreamCellItem(jsonable: category, type: .categoryChooseCard(isSubscribed: isSubscribed, isSelected: isSelected))
        }

        destination?.replacePlaceholder(type: .streamItems, items: items)
    }
}
