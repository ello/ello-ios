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
            let avatarHeight: CGFloat = ProfileHeaderAvatarCell.Size.calculateHeight(width: width)
            let statsHeight: CGFloat = ProfileHeaderStatsCell.Size.height
            let namesHeight: CGFloat = 75

            let defaultBioHeight: CGFloat = 50
            let defaultLocationHeight: CGFloat = ProfileHeaderLocationCell.Size.height
            let defaultLinksHeight: CGFloat = 100
            let defaultCountHeight: CGFloat = ProfileHeaderTotalCountAndBadgesCell.Size.height

            let expectations: [(String, bioHeight: CGFloat, locationHeight: CGFloat, linksHeight: CGFloat, hasTotal: Bool, hasBadges: Bool)] = [
                ("no bio", bioHeight: 0, locationHeight: defaultLocationHeight, linksHeight: defaultLinksHeight, hasTotal: true, hasBadges: true),
                ("no links", bioHeight: defaultBioHeight, locationHeight: defaultLocationHeight, linksHeight: 0, hasTotal: true, hasBadges: true),
                ("no location", bioHeight: defaultBioHeight, locationHeight: 0, linksHeight: defaultLinksHeight, hasTotal: true, hasBadges: true),
                ("no badges", bioHeight: defaultBioHeight, locationHeight: defaultLocationHeight, linksHeight: defaultLinksHeight, hasTotal: true, hasBadges: false),
                ("no total", bioHeight: defaultBioHeight, locationHeight: defaultLocationHeight, linksHeight: defaultLinksHeight, hasTotal: false, hasBadges: true),
                ("no bio, no links", bioHeight: 0, locationHeight: defaultLocationHeight, linksHeight: 0, hasTotal: true, hasBadges: true),
                ("no bio, no links, no location", bioHeight: 0, locationHeight: 0, linksHeight: 0, hasTotal: true, hasBadges: true),
                ("no bio, no links, no location, no badges", bioHeight: 0, locationHeight: 0, linksHeight: 0, hasTotal: true, hasBadges: false),
                ("no bio, no location", bioHeight: 0, locationHeight: 0, linksHeight: defaultLinksHeight, hasTotal: true, hasBadges: true)
            ]

            for (desc, bioHeight, locationHeight, linksHeight, hasTotal, hasBadges) in expectations {
                it("\(desc) profile header renders correctly") {
                    let user: User = stub([
                        "name": "bob",
                        "username": "bill",
                        "postsCount": 20,
                        "followingCount": 123,
                        "followersCount": 444,
                        "lovesCount": 89,
                        "formattedShortBio": "This is a bio",
                        "location": locationHeight > 0 ? "Denver": "",
                        "totalViewsCount": hasTotal ? 1 : 0,
                        "externalLinksList": linksHeight > 0 ? [["url": "http://google.com", "text": "google"]] : [],
                    ])
                    expect(user.hasProfileData) == true

                    if hasBadges {
                        user.badges = [Badge.lookup(slug: "featured")!, Badge.lookup(slug: "community")!, Badge.lookup(slug: "experimental")!]
                    }

                    let cell: ProfileHeaderCell = ProfileHeaderCell()
                    cell.bioView.backgroundColor = .blue

                    let item: StreamCellItem = StreamCellItem(jsonable: user, type: .profileHeader)
                    item.calculatedCellHeights.profileAvatar = avatarHeight
                    item.calculatedCellHeights.profileTotalCount = hasTotal ? defaultCountHeight : 0
                    item.calculatedCellHeights.profileBadges = hasBadges ? defaultCountHeight : 0
                    item.calculatedCellHeights.profileNames = namesHeight
                    item.calculatedCellHeights.profileStats = statsHeight
                    item.calculatedCellHeights.profileBio = bioHeight
                    item.calculatedCellHeights.profileLocation = locationHeight
                    item.calculatedCellHeights.profileLinks = linksHeight

                    let totalHeight = avatarHeight + namesHeight + statsHeight + bioHeight + locationHeight + linksHeight + (hasTotal || hasBadges ? defaultCountHeight : 0)
                    let size = CGSize(width: width, height: totalHeight)
                    cell.frame.size = size
                    // we need to force the cell to layout so that view bounds are calculated before configure is called
                    // (ProfileHeaderLinksCell needs bounds.width > 0)
                    prepareForSnapshot(cell, size: size)

                    ProfileHeaderCellPresenter.configure(cell,
                        streamCellItem: item,
                        streamKind: .userStream(userParam: ""),
                        indexPath: IndexPath(item: 0, section: 0),
                        currentUser: nil
                        )

                    expectValidSnapshot(cell, named: "ProfileHeaderCompactView-\(desc)")
                }
            }
        }
    }
}
