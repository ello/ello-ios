////
///  SettingsGenerator.swift
//

class SettingsGenerator {
    var currentUser: User
    weak var delegate: SettingsGeneratorDelegate?
    init(currentUser: User) {
        self.currentUser = currentUser
    }

    func loadSettings() {
        SettingsService().dynamicSettings(currentUser: currentUser)
            .then { [weak self] settingsCategories -> Void in
                self?.delegate?.dynamicSettingsLoaded(settingsCategories)
            }
            .ignoreErrors()
    }

    func loadCategories() {
        CategoryService().loadCreatorCategories()
            .then { [weak self] categories -> Void in
                self?.delegate?.categoriesLoaded(categories)
            }
            .ignoreErrors()
    }
}
