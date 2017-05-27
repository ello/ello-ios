////
///  ProfileStatsSizeCalculator.swift
//

import PromiseKit


struct ProfileStatsSizeCalculator {

    func calculate(_ item: StreamCellItem) -> Promise<CGFloat> {
        return Promise { fulfill, _ in
            fulfill(ProfileStatsView.Size.height)
        }
    }
}
