////
///  ProfileHeaderCellSizeCalculator.swift
//

import FutureKit


public class ProfileHeaderCellSizeCalculator: NSObject {
    static let ratio: CGFloat = 320 / 211

    private var maxWidth: CGFloat = 0.0
    private typealias CellJob = (cellItems: [StreamCellItem], width: CGFloat, columnCount: Int, completion: ElloEmptyCompletion)
    private var cellJobs: [CellJob] = []
    private var cellItems: [StreamCellItem] = []
    private var completion: ElloEmptyCompletion = {}

    let statsSizeCalculator = ProfileStatsSizeCalculator()
    let avatarSizeCalculator = ProfileAvatarSizeCalculator()
    let bioSizeCalculator = ProfileBioSizeCalculator()
    let locationSizeCalculator = ProfileLocationSizeCalculator()
    let linksSizeCalculator = ProfileLinksSizeCalculator()
    let namesSizeCalculator = ProfileNamesSizeCalculator()
    let totalCountSizeCalculator = ProfileTotalCountSizeCalculator()

// MARK: Public

    public func processCells(cellItems: [StreamCellItem], withWidth width: CGFloat, columnCount: Int, completion: ElloEmptyCompletion) {
        let job: CellJob = (cellItems: cellItems, width: width, columnCount: columnCount, completion: completion)
        cellJobs.append(job)
        if cellJobs.count == 1 {
            processJob(job)
        }
    }

    static func calculateHeightFromCellHeights(calculatedCellHeights: CalculatedCellHeights) -> CGFloat? {
        guard let
            profileAvatar = calculatedCellHeights.profileAvatar,
            profileNames = calculatedCellHeights.profileNames,
            profileTotalCount = calculatedCellHeights.profileTotalCount,
            profileStats = calculatedCellHeights.profileStats,
            profileBio = calculatedCellHeights.profileBio,
            profileLocation = calculatedCellHeights.profileLocation,
            profileLinks = calculatedCellHeights.profileLinks
        else { return nil }

        return profileAvatar + profileNames + profileTotalCount + profileStats + profileBio + profileLocation + profileLinks
    }

}

private extension ProfileHeaderCellSizeCalculator {

    func processJob(job: CellJob) {

        self.completion = {
            if self.cellJobs.count > 0 {
                self.cellJobs.removeAtIndex(0)
            }
            job.completion()
            if let nextJob = self.cellJobs.safeValue(0) {
                self.processJob(nextJob)
            }
        }
        self.cellItems = job.cellItems
        self.maxWidth = job.width
        loadNext()
    }

    func loadNext() {

        if let item = cellItems.safeValue(0) {
            if item.jsonable is User {
                calculateAggregateHeights(item)
            }
            else {
                assignCellHeight(0)
            }
        }
        else {
            completion()
        }
    }

    func assignCellHeight(height: CGFloat) {

        if let cellItem = cellItems.safeValue(0) {
            self.cellItems.removeAtIndex(0)
            cellItem.calculatedCellHeights.webContent = height
            cellItem.calculatedCellHeights.oneColumn = height
            cellItem.calculatedCellHeights.multiColumn = height
        }
        loadNext()
    }

    func calculateAggregateHeights(item: StreamCellItem) {
        let futures: [(CalculatedCellHeights.Prop, Future<CGFloat>)] = [
            (.ProfileAvatar, avatarSizeCalculator.calculate(item, maxWidth: maxWidth)),
            (.ProfileNames, namesSizeCalculator.calculate(item, maxWidth: maxWidth)),
            (.ProfileTotalCount, totalCountSizeCalculator.calculate(item)),
            (.ProfileStats, statsSizeCalculator.calculate(item)),
            (.ProfileBio, bioSizeCalculator.calculate(item, maxWidth: maxWidth)),
            (.ProfileLocation, locationSizeCalculator.calculate(item, maxWidth: maxWidth)),
            (.ProfileLinks, linksSizeCalculator.calculate(item, maxWidth: maxWidth)),
        ]

        let done = after(futures.count) {
            let totalHeight = ProfileHeaderCellSizeCalculator.calculateHeightFromCellHeights(item.calculatedCellHeights)!
            self.assignCellHeight(totalHeight)
        }

        for (calcType, future) in futures {
            future
                .onSuccess { height in
                    item.calculatedCellHeights.assign(calcType, height: height)
                    done()
                }
                .onFailorCancel { _ in done() }
        }
    }
}
