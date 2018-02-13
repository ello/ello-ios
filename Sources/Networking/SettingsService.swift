////
///  SettingsService.swift
//

import PromiseKit


class SettingsService {
    func dynamicSettings(currentUser: User) -> Promise<[DynamicSettingCategory]> {
        return ElloProvider.shared.request(.profileToggles)
            .then { jsonables, _ -> [DynamicSettingCategory] in
                guard let categories = jsonables as? [DynamicSettingCategory]
                else {
                    throw NSError.uncastableJSONAble()
                }

                return categories.filter { category in
                    category.settings = category.settings.filter { setting in
                        return currentUser.hasProperty(key: setting.key)
                    }
                    return category.settings.count > 0
                }
            }
    }
}
