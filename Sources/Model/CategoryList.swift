////
///  CategoryList.swift
//

import SwiftyJSON

let CategoryListVersion = 1

class CategoryList: JSONAble {
    let categories: [Category]

    init(categories: [Category]) {
        self.categories = categories.sorted { (catA, catB) in
            if catA.level.order != catB.level.order {
                return catA.level.order < catB.level.order
            }
            return catA.order < catB.order
        }
        super.init(version: CategoryListVersion)
    }

    required init(coder: NSCoder) {
        let decoder = Coder(coder)
        categories = decoder.decodeKey("categories")
        super.init(coder: coder)
    }

    override func encode(with coder: NSCoder) {
        let encoder = Coder(coder)
        encoder.encodeObject(categories, forKey: "categories")
        super.encode(with: coder)
    }

    override class func fromJSON(_ data: [String: AnyObject]) -> JSONAble {
        let json = JSON(data)
        let categories: [Category]
        if let jsonCategories = json["categories"].array {
            let unsorted: [(order: Int, category: Category)] = jsonCategories.flatMap { json in
                if let val = json.object as? [String: AnyObject],
                    let category = Category.fromJSON(val) as? Category
                {
                    return (order: json["order"].intValue, category: category)
                }
                return nil
            }

            categories = unsorted.sorted { entryA, entryB in
                return entryA.order < entryB.order
            }.map { $0.category }
        }
        else {
            categories = []
        }
        return CategoryList(categories: categories)
    }

}

extension CategoryList {
    class func metaCategories() -> CategoryList {
        return CategoryList(categories: [
            Category.featured,
            Category.trending,
            Category.recent,
        ])
    }
}
