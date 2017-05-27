////
///  CategoryService.swift
//

import PINRemoteImage
import PromiseKit

typealias CategoriesCompletion = (_ categories: [Category]) -> Void

class CategoryService {

    func loadCategories() -> Promise<[Category]> {
        return ElloProvider.shared.request(.categories)
            .then { data, _ -> [Category] in
                guard let categories = data as? [Category] else {
                    throw NSError.uncastableJSONAble()
                }
                Preloader().preloadImages(categories)
                return categories
            }
    }

    func loadCategory(_ categorySlug: String) -> Promise<Category> {
        return ElloProvider.shared.request(.category(slug: categorySlug))
            .then { data, _ -> Category in
                guard let category = data as? Category else {
                    throw NSError.uncastableJSONAble()
                }
                Preloader().preloadImages([category])
                return category
            }
    }

}
