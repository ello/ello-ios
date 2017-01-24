////
///  ProfileHeaderCompactViewSpec
//

@testable import Ello
import Quick
import Nimble


class ProfileHeaderCompactViewSpec: QuickSpec {

    override func spec() {
        describe("ProfileHeaderCompactView") {
            let width: CGFloat = 375
            let avatarHeight: CGFloat = ProfileAvatarSizeCalculator.calculateHeight(maxWidth: width)
            let statsHeight: CGFloat = ProfileStatsView.Size.height
            let namesHeight: CGFloat = 75

            let defauntBioHeight: CGFloat = 50
            let defaultLocationHeight: CGFloat = ProfileLocationView.Size.height
            let defaultLinksHeight: CGFloat = 100
            let defaultCountHeight: CGFloat = ProfileTotalCountView.Size.height

            let expectations: [(String, bioHeight: CGFloat, locationHeight: CGFloat, linksHeight: CGFloat, countHeight: CGFloat)] = [
                ("no bio", bioHeight: 0, locationHeight: defaultLocationHeight, linksHeight: defaultLinksHeight, countHeight: defaultCountHeight),
                ("no links", bioHeight: defauntBioHeight, locationHeight: defaultLocationHeight, linksHeight: 0, countHeight: defaultCountHeight),
                ("no location", bioHeight: defauntBioHeight, locationHeight: 0, linksHeight: defaultLinksHeight, countHeight: defaultCountHeight),
                ("no total count", bioHeight: defauntBioHeight, locationHeight: 0, linksHeight: defaultLinksHeight, countHeight: 0),
                ("no bio or links", bioHeight: 0, locationHeight: defaultLocationHeight, linksHeight: 0, countHeight: defaultCountHeight),
                ("no bio, no links, no location", bioHeight: 0, locationHeight: 0, linksHeight: 0, countHeight: defaultCountHeight),
                ("no bio, no links, no location, no total count", bioHeight: 0, locationHeight: 0, linksHeight: 0, countHeight: 0),
                ("no bio or no location", bioHeight: 0, locationHeight: 0, linksHeight: defaultLinksHeight, countHeight: defaultCountHeight)
            ]

            for (desc, bioHeight, locationHeight, linksHeight, countHeight) in expectations {
                it("\(desc) profile header renders correctly") {
                    let totalViewsCount: AnyObject
                    if countHeight == 0 {
                        totalViewsCount = "" as AnyObject // stubs will turn this into nil
                    }
                    else {
                        totalViewsCount = 1 as AnyObject
                    }

                    let user: User = stub([
                        "name" : "bob",
                        "username" : "bill",
                        "postsCount" : 20,
                        "followingCount" : 123,
                        "followersCount" : 444,
                        "lovesCount" : 89,
                        "formattedShortBio" : "This is a bio",
                        "location" : "Denver",
                        "totalViewsCount" : totalViewsCount,
                        "categories": [Ello.Category.stub([:])],
                        "externalLinksList" : [["url" : "http://google.com", "text" : "google"]]
                    ])

                    let cell: ProfileHeaderCell = ProfileHeaderCell()
                    let item: StreamCellItem = StreamCellItem(jsonable: user, type: .profileHeader)
                    item.calculatedCellHeights.profileAvatar = avatarHeight
                    item.calculatedCellHeights.profileNames = namesHeight
                    item.calculatedCellHeights.profileStats = statsHeight
                    item.calculatedCellHeights.profileBio = bioHeight
                    item.calculatedCellHeights.profileLocation = locationHeight
                    item.calculatedCellHeights.profileLinks = linksHeight
                    item.calculatedCellHeights.profileTotalCount = countHeight

                    let totalHeight = avatarHeight + namesHeight + statsHeight + bioHeight + locationHeight + linksHeight + countHeight
                    let size = CGSize(width: width, height: totalHeight)

                    ProfileHeaderCellPresenter.configure(cell,
                        streamCellItem: item,
                        streamKind: .currentUserStream,
                        indexPath: IndexPath(item: 0, section: 0),
                        currentUser: nil
                        )

                    expectValidSnapshot(cell, named: "ProfileHeaderCompactView-\(desc)", device: .custom(size))
                }
            }
        }
    }
}
