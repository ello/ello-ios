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
            let bioHeight: CGFloat = 50
            let locationHeight: CGFloat = ProfileLocationView.Size.height
            let linksHeight: CGFloat = 100
            let namesHeight: CGFloat = 75
            let countHeight: CGFloat = ProfileTotalCountView.Size.height

            let expectations: [(String, bioHeight: CGFloat, locationHeight: CGFloat, linksHeight: CGFloat)] = [
                ("no bio", bioHeight: 0, locationHeight: locationHeight, linksHeight: linksHeight),
                ("no links", bioHeight: bioHeight, locationHeight: locationHeight, linksHeight: 0),
                ("no location", bioHeight: bioHeight, locationHeight: 0, linksHeight: linksHeight),
                ("no bio or links", bioHeight: 0, locationHeight: locationHeight, linksHeight: 0),
                ("no bio, no links, no location", bioHeight: 0, locationHeight: 0, linksHeight: 0),
                ("no bio or no location", bioHeight: 0, locationHeight: 0, linksHeight: linksHeight)

            ]

            for (desc, bio, location, links) in expectations {
                it("\(desc) profile header renders correctly") {
                    let user: User = stub([
                        "name" : "bob",
                        "username" : "bill",
                        "postsCount" : 20,
                        "followingCount" : 123,
                        "followersCount" : 444,
                        "lovesCount" : 89,
                        "formattedShortBio" : "This is a bio",
                        "location" : "Denver",
                        "externalLinksList" : [["url" : "http://google.com", "text" : "google"]]
                    ])
                    let cell: ProfileHeaderCell = ProfileHeaderCell()
                    let item: StreamCellItem = StreamCellItem(jsonable: user, type: .ProfileHeader)
                    item.calculatedCellHeights.profileAvatar = avatarHeight
                    item.calculatedCellHeights.profileNames = namesHeight
                    item.calculatedCellHeights.profileStats = statsHeight
                    item.calculatedCellHeights.profileTotalCount = countHeight
                    item.calculatedCellHeights.profileBio = bio
                    item.calculatedCellHeights.profileLinks = links
                    item.calculatedCellHeights.profileLocation = location

                    let totalHeight = avatarHeight + namesHeight + countHeight + statsHeight + bio + location + links

                    let size = CGSize(width: width, height: totalHeight)

                    ProfileHeaderCellPresenter.configure(cell, streamCellItem: item, streamKind: .CurrentUserStream, indexPath: NSIndexPath(forItem: 0, inSection: 0), currentUser: nil)

                    expectValidSnapshot(cell, named: "ProfileHeaderCell-\(desc)", device: .Custom(size))
                }
            }
        }
    }
}
