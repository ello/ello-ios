////
///  Fragments.swift
//

struct Fragments: Equatable {
    static let imageProps = Fragments("""
        fragment imageProps on Image {
          url
          metadata { height width type size }
        }
        """)

    static let tshirtProps = Fragments("""
        fragment tshirtProps on TshirtImageVersions {
          regular { ...imageProps }
          large { ...imageProps }
          original { ...imageProps }
        }
        """, needs: [imageProps])

    static let responsiveProps = Fragments("""
        fragment responsiveProps on ResponsiveImageVersions {
          mdpi { ...imageProps }
          hdpi { ...imageProps }
          xhdpi { ...imageProps }
          optimized { ...imageProps }
        }
        """, needs: [imageProps])

    static let authorProps = Fragments("""
        fragment authorProps on User {
          id
          username
          name
          currentUserState { relationshipPriority }
          settings {
            hasCommentingEnabled hasLovesEnabled hasRepostingEnabled hasSharingEnabled
            isCollaborateable isHireable
          }
          avatar {
            ...tshirtProps
          }
          coverImage {
            ...responsiveProps
          }
        }
        """, needs: [tshirtProps, responsiveProps])

    static let pageHeaderUserProps = Fragments("""
        fragment pageHeaderUserProps on User {
          id
          username
          name
          avatar {
            ...tshirtProps
          }
          coverImage {
            ...responsiveProps
          }
        }
        """, needs: [tshirtProps, responsiveProps])

    static let postStream = Fragments("""
        fragment contentProps on ContentBlocks {
          linkUrl
          kind
          data
          links { assets }
        }

        fragment assetProps on Asset {
          id
          attachment { ...responsiveProps }
        }

        fragment postContent on Post {
          content { ...contentProps }
        }

        fragment categoryProps on Category {
          id name slug order allowInOnboarding isCreatorType level
          tileImage { ...tshirtProps }
        }

        fragment postSummary on Post {
          id
          token
          createdAt
          summary { ...contentProps }
          author { ...authorProps }
          artistInviteSubmission { id artistInvite { id } }
          assets { ...assetProps }
          postStats { lovesCount commentsCount viewsCount repostsCount }
          currentUserState { watching loved reposted }
        }
        """, needs: [imageProps, tshirtProps, responsiveProps, authorProps])

    static let categoriesBody = """
        id
        name
        slug
        order
        allowInOnboarding
        isCreatorType
        level
        tileImage { ...tshirtProps }
        """
    static let pageHeaderBody = """
        id
        postToken
        category { id }
        kind
        header
        subheader
        image { ...responsiveProps }
        ctaLink { text url }
        user { ...pageHeaderUserProps }
        """
    static let postStreamBody = """
        next isLastPage
        posts {
            ...postSummary
            ...postContent
            repostContent { ...contentProps }
            categories { ...categoryProps }
            currentUserState { loved reposted watching }
            repostedSource {
                ...postSummary
            }
        }
        """

    let string: String
    let needs: [Fragments]

    var dependencies: [Fragments] {
        return [self] + needs + needs.flatMap { $0.dependencies }
    }

    init(_ string: String, needs: [Fragments] = []) {
        self.string = string
        self.needs = needs
    }

    static func flatten(_ fragments: [Fragments]) -> String {
        let dependencies: [Fragments] = fragments.flatMap { frag -> [Fragments] in return frag.dependencies }
        return dependencies.unique().map { $0.string }.joined(separator: "\n")
    }

    static func == (lhs: Fragments, rhs: Fragments) -> Bool {
        return lhs.string == rhs.string
    }
}
