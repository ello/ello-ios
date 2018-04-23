////
///  CategoryService.swift
//

import PromiseKit


class CategoryService {

    func loadCategories() -> Promise<[Category]> {
        if let categories = Globals.cachedCategories {
            return .value(categories)
        }

        return ElloProvider.shared.request(.categories)
            .map { data, _ -> [Category] in
                guard let categories = data as? [Category] else {
                    throw NSError.uncastableModel()
                }
                Globals.cachedCategories = categories
                Preloader().preloadImages(categories)
                return categories
            }
    }

    func loadCreatorCategories() -> Promise<[Category]> {
        return loadCategories()
            .map { categories -> [Category] in
                return categories.filter { $0.isCreatorType }
            }
    }

    func loadCategory(_ categorySlug: String) -> Promise<Category> {
        if let category = Globals.cachedCategories?.find({ $0.slug == categorySlug }) {
            return .value(category)
        }

        return ElloProvider.shared.request(.category(slug: categorySlug))
            .map { data, _ -> Category in
                guard let category = data as? Category else {
                    throw NSError.uncastableModel()
                }
                Preloader().preloadImages([category])
                return category
            }
    }

}
