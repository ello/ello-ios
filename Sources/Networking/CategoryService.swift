////
///  CategoryService.swift
//

import PINRemoteImage
import FutureKit

typealias CategoriesCompletion = (_ categories: [Category]) -> Void

class CategoryService {

    func loadCategories() -> Future<[Category]> {
        let promise = Promise<[Category]>()
        ElloProvider.shared.elloRequest(.categories, success: { (data, responseConfig) in
            if let categories = data as? [Category] {
                Preloader().preloadImages(categories)
                promise.completeWithSuccess(categories)
            }
            else {
                promise.completeWithFail(NSError.uncastableJSONAble())
            }
        }, failure: { (error, _) in
            promise.completeWithFail(error)
        })
        return promise.future
    }

    func loadCategory(_ categorySlug: String) -> Future<Category> {
        let promise = Promise<Category>()
        ElloProvider.shared.elloRequest(
            ElloAPI.category(slug: categorySlug),
            success: { (data, responseConfig) in
                if let category = data as? Category {
                    Preloader().preloadImages([category])
                    promise.completeWithSuccess(category)
                }
                else {
                    promise.completeWithFail(NSError.uncastableJSONAble())
                }
            }, failure: { (error, statusCode) in
                promise.completeWithFail(error)
            })
        return promise.future
    }
}
