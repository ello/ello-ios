////
///  CategoryDetailGenerator.swift
//

class CategoryDetailGenerator {
    weak var destination: CategoryDetailDelegate?

    init(destination: CategoryDetailDelegate) {
        self.destination = destination
    }

    func loadAdmins(slug: String) {
        API().categoryAdmins(categorySlug: slug)
            .execute()
            .done { (moderators, curators) in
                self.destination?.adminsLoaded(moderators: moderators, curators: curators)
            }
            .catch { _ in
            }
    }
}
