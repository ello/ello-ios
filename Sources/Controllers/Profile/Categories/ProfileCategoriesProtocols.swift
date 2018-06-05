////
///  ProfileCategoriesProtocols.swift
//

protocol ProfileCategoriesDelegate: class {
    func learnMoreTapped()
    func profileCategoryTapped(_ category: Category)
    func dismiss()
}

protocol ProfileCategoriesProtocol: class {
}
