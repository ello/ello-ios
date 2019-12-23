////
///  SettingsGenerator.swift
//

class SettingsGenerator {
    var currentUser: User
    weak var delegate: SettingsGeneratorDelegate?
    init(currentUser: User) {
        self.currentUser = currentUser
    }

    func load(reload: Bool) {
        loadCurrentUser()
        loadSettings()
        loadCategories()
    }

    func loadCurrentUser() {
        ProfileService().loadCurrentUser()
            .done { user in
                self.delegate?.currentUserReloaded(user)
            }
            .ignoreErrors()
    }

    func loadSettings() {
        SettingsService().dynamicSettings(currentUser: currentUser)
            .done { settingsCategories in
                self.delegate?.dynamicSettingsLoaded(settingsCategories)
            }
            .ignoreErrors()
    }

    func loadCategories() {
        CategoryService().loadCreatorCategories()
            .done { categories in
                self.delegate?.categoriesLoaded(categories)
            }
            .ignoreErrors()
    }
}
