////
///  ProfileBadgesSizeCalculator.swift
//

import PromiseKit


struct ProfileBadgesSizeCalculator {

    func calculate(_ item: StreamCellItem) -> Promise<CGFloat> {
        return Promise { fulfill, reject in
            guard
                let user = item.jsonable as? User,
                user.badges.count > 0
            else {
                fulfill(0)
                return
            }

            fulfill(ProfileBadgesView.Size.height)
        }
    }
}
