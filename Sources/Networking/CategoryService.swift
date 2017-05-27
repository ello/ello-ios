////
///  CategoryService.swift
//

import PINRemoteImage
import PromiseKit

typealias CategoriesCompletion = (_ categories: [Category]) -> Void

class CategoryService {

    func loadCategories() -> Promise<[Category]> {
        return Promise { fulfill, reject in
            ElloProvider.shared.elloRequest(.categories, success: { (data, responseConfig) in
                if let categories = data as? [Category] {
                    Preloader().preloadImages(categories)
                    fulfill(categories)
                }
                else {
                    reject(NSError.uncastableJSONAble())
                }
            }, failure: { (error, _) in
                reject(error)
            })
        }
    }

    func loadCategory(_ categorySlug: String) -> Promise<Category> {
        return Promise { fulfill, reject in
            ElloProvider.shared.elloRequest(
                ElloAPI.category(slug: categorySlug),
                success: { (data, responseConfig) in
                    if let category = data as? Category {
                        Preloader().preloadImages([category])
                        fulfill(category)
                    }
                    else {
                        reject(NSError.uncastableJSONAble())
                    }
                }, failure: { (error, statusCode) in
                    reject(error)
                })
        }
    }
}
