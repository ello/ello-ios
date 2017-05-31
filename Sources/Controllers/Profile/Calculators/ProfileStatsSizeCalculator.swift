////
///  ProfileStatsSizeCalculator.swift
//

import PromiseKit


struct ProfileStatsSizeCalculator {

    func calculate(_ item: StreamCellItem) -> Promise<CGFloat> {
        let (promise, fulfill, _) = Promise<CGFloat>.pending()
        fulfill(ProfileStatsView.Size.height)
        return promise
    }
}
