////
///  NotificationAttributedTitle.swift
//

struct NotificationAttributedTitle {

    static private func attrs(_ addlAttrs: [NSAttributedString.Key: Any] = [:])
        -> [NSAttributedString.Key: Any]
    {
        let attrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.defaultFont(),
            .foregroundColor: UIColor.greyA,
        ]
        return attrs + addlAttrs
    }

    static private func styleText(_ text: String) -> NSAttributedString {
        return NSAttributedString(string: text, attributes: attrs())
    }

    static private func styleUser(_ user: User?) -> NSAttributedString {
        if let user = user {
            return NSAttributedString(
                string: user.atName,
                attributes: attrs([
                    ElloAttributedText.Link: "user",
                    ElloAttributedText.Object: user,
                    .underlineStyle: NSUnderlineStyle.single.rawValue,
                ])
            )
        }
        else {
            return styleText("Someone")
        }
    }

    static private func stylePost(_ text: String, _ post: Post) -> NSAttributedString {
        let attrs = self.attrs([
            ElloAttributedText.Link: "post",
            ElloAttributedText.Object: post,
            .underlineStyle: NSUnderlineStyle.single.rawValue,
        ])
        return NSAttributedString(string: text, attributes: attrs)
    }

    static private func styleComment(_ text: String, _ comment: ElloComment) -> NSAttributedString {
        let attrs = self.attrs([
            ElloAttributedText.Link: "comment",
            ElloAttributedText.Object: comment,
            .underlineStyle: NSUnderlineStyle.single.rawValue,
        ])
        return NSAttributedString(string: text, attributes: attrs)
    }

    static private func styleArtistInvite(_ artistInvite: ArtistInvite) -> NSAttributedString {
        let attrs = self.attrs([
            ElloAttributedText.Link: "artistInvite",
            ElloAttributedText.Object: artistInvite,
            .underlineStyle: NSUnderlineStyle.single.rawValue,
        ])
        return NSAttributedString(string: artistInvite.title, attributes: attrs)
    }

    static private func styleCategory(_ category: Category) -> NSAttributedString {
        let attrs = self.attrs([
            ElloAttributedText.Link: "category",
            ElloAttributedText.Object: category,
            .underlineStyle: NSUnderlineStyle.single.rawValue,
        ])
        return NSAttributedString(string: category.name, attributes: attrs)
    }

    static private func styleCategory(partial: CategoryPartial) -> NSAttributedString {
        let attrs = self.attrs([
            ElloAttributedText.Link: "categoryPartial",
            ElloAttributedText.Object: partial,
            .underlineStyle: NSUnderlineStyle.single.rawValue,
        ])
        return NSAttributedString(string: partial.name, attributes: attrs)
    }

    static func from(notification: Notification) -> NSAttributedString {
        let kind = notification.activity.kind
        let author = notification.author
        let subject = notification.subject

        switch kind {
        case .repostNotification:
            if let post = subject as? Post {
                return styleUser(author).appending(styleText(" reposted your "))
                    .appending(stylePost("post", post))
                    .appending(styleText("."))
            }
            else {
                return styleUser(author).appending(styleText(" reposted your post."))
            }
        case .newFollowedUserPost:
            return styleText("You started following ").appending(styleUser(author))
                .appending(styleText("."))
        case .newFollowerPost:
            return styleUser(author).appending(styleText(" started following you."))
        case .postMentionNotification:
            if let post = subject as? Post {
                return styleUser(author).appending(styleText(" mentioned you in a "))
                    .appending(stylePost("post", post))
                    .appending(styleText("."))
            }
            else {
                return styleUser(author)
                    .appending(styleText(" mentioned you in a post."))
            }
        case .commentNotification:
            if let comment = subject as? ElloComment {
                return styleUser(author)
                    .appending(styleText(" commented on your "))
                    .appending(styleComment("post", comment))
                    .appending(styleText("."))
            }
            else {
                return styleUser(author)
                    .appending(styleText(" commented on a post."))
            }
        case .commentMentionNotification:
            if let comment = subject as? ElloComment {
                return styleUser(author)
                    .appending(styleText(" mentioned you in a "))
                    .appending(styleComment("comment", comment))
                    .appending(styleText("."))
            }
            else {
                return styleUser(author)
                    .appending(styleText(" mentioned you in a comment."))
            }
        case .commentOnOriginalPostNotification:
            if let comment = subject as? ElloComment,
                let repost = comment.loadedFromPost,
                let repostAuthor = repost.author,
                let source = repost.repostSource
            {
                return styleUser(author)
                    .appending(styleText(" commented on "))
                    .appending(styleUser(repostAuthor))
                    .appending(styleText("’s "))
                    .appending(stylePost("repost", repost))
                    .appending(styleText(" of your "))
                    .appending(stylePost("post", source))
                    .appending(styleText("."))
            }
            else {
                return styleUser(author)
                    .appending(styleText(" commented on your post"))
            }
        case .commentOnRepostNotification:
            if let comment = subject as? ElloComment {
                return styleUser(author)
                    .appending(styleText(" commented on your "))
                    .appending(styleComment("repost", comment))
                    .appending(styleText("."))
            }
            else {
                return styleUser(author)
                    .appending(styleText(" commented on your repost"))
            }
        case .invitationAcceptedPost:
            return styleUser(author)
                .appending(styleText(" accepted your invitation."))
        case .loveNotification:
            if let love = subject as? Love,
                let post = love.post
            {
                return styleUser(author)
                    .appending(styleText(" loved your "))
                    .appending(stylePost("post", post))
                    .appending(styleText("."))
            }
            else {
                return styleUser(author).appending(styleText(" loved your post."))
            }
        case .loveOnRepostNotification:
            if let love = subject as? Love,
                let post = love.post
            {
                return styleUser(author)
                    .appending(styleText(" loved your "))
                    .appending(stylePost("repost", post))
                    .appending(styleText("."))
            }
            else {
                return styleUser(author).appending(styleText(" loved your repost."))
            }
        case .loveOnOriginalPostNotification:
            if let love = subject as? Love,
                let repost = love.post,
                let repostAuthor = repost.author,
                let source = repost.repostSource
            {
                return styleUser(author)
                    .appending(styleText(" loved "))
                    .appending(styleUser(repostAuthor))
                    .appending(styleText("’s "))
                    .appending(stylePost("repost", repost))
                    .appending(styleText(" of your "))
                    .appending(stylePost("post", source))
                    .appending(styleText("."))
            }
            else {
                return styleUser(author).appending(styleText(" loved a repost of your post."))
            }
        case .watchNotification:
            if let watch = subject as? Watch,
                let post = watch.post
            {
                return styleUser(author)
                    .appending(styleText(" is watching your "))
                    .appending(stylePost("post", post))
                    .appending(styleText("."))
            }
            else {
                return styleUser(author).appending(styleText(" is watching your post."))
            }
        case .watchCommentNotification:
            if let comment = subject as? ElloComment,
                let post = comment.parentPost
            {
                return styleUser(author)
                    .appending(styleText(" commented on a "))
                    .appending(stylePost("post", post))
                    .appending(styleText(" you’re watching."))
            }
            else {
                return styleUser(author).appending(
                    styleText(" commented on a post you’re watching.")
                )
            }
        case .watchOnRepostNotification:
            if let watch = subject as? Watch,
                let post = watch.post
            {
                return styleUser(author)
                    .appending(styleText(" is watching your "))
                    .appending(stylePost("repost", post))
                    .appending(styleText("."))
            }
            else {
                return styleUser(author).appending(styleText(" is watching your repost."))
            }
        case .watchOnOriginalPostNotification:
            if let watch = subject as? Watch,
                let repost = watch.post,
                let repostAuthor = repost.author,
                let source = repost.repostSource
            {
                return styleUser(author)
                    .appending(styleText(" is watching "))
                    .appending(styleUser(repostAuthor))
                    .appending(styleText("’s "))
                    .appending(stylePost("repost", repost))
                    .appending(styleText(" of your "))
                    .appending(stylePost("post", source))
                    .appending(styleText("."))
            }
            else {
                return styleUser(author).appending(styleText(" is watching a repost of your post."))
            }
        case .approvedArtistInviteSubmission:
            if let submission = subject as? ArtistInviteSubmission,
                let artistInvite = submission.artistInvite
            {
                return styleText("Your submission to ")
                    .appending(styleArtistInvite(artistInvite))
                    .appending(styleText(" has been accepted!"))
            }
            else {
                return styleText("Your submission has been accepted!")
            }
        case .approvedArtistInviteSubmissionNotificationForFollowers:
            if let submission = subject as? ArtistInviteSubmission,
                let artistInvite = submission.artistInvite,
                let author = submission.post?.author
            {
                return styleUser(author)
                    .appending(styleText("’s submission to "))
                    .appending(styleArtistInvite(artistInvite))
                    .appending(styleText(" has been accepted!"))
            }
            else {
                return styleText("A followers submission has been accepted!")
            }
        case .categoryPostFeatured:
            if let submission = subject as? CategoryPost,
                let featuredBy = submission.featuredBy,
                let categoryText = submission.category.map(({ styleCategory($0) }))
                    ?? submission.categoryPartial.map({ styleCategory(partial: $0) }),
                let post = submission.post
            {
                return styleUser(featuredBy)
                    .appending(styleText(" featured your "))
                    .appending(stylePost("post", post))
                    .appending(styleText(" in "))
                    .appending(categoryText)
                    .appending(styleText("."))
            }
            else {
                return styleText("Someone featured your post.")
            }
        case .categoryRepostFeatured:
            if let submission = subject as? CategoryPost,
                let featuredBy = submission.featuredBy,
                let categoryText = submission.category.map(({ styleCategory($0) }))
                    ?? submission.categoryPartial.map({ styleCategory(partial: $0) }),
                let post = submission.post
            {
                return styleUser(featuredBy)
                    .appending(styleText(" featured your "))
                    .appending(stylePost("repost", post))
                    .appending(styleText(" in "))
                    .appending(categoryText)
                    .appending(styleText("."))
            }
            else {
                return styleText("Someone featured your repost.")
            }
        case .categoryPostViaRepostFeatured:
            if let submission = subject as? CategoryPost,
                let featuredBy = submission.featuredBy,
                let categoryText = submission.category.map(({ styleCategory($0) }))
                    ?? submission.categoryPartial.map({ styleCategory(partial: $0) }),
                let repost = submission.post,
                let source = repost.repostSource
            {
                return styleUser(featuredBy)
                    .appending(styleText(" featured a "))
                    .appending(stylePost("repost", repost))
                    .appending(styleText(" of your "))
                    .appending(stylePost("post", source))
                    .appending(styleText(" in "))
                    .appending(categoryText)
                    .appending(styleText("."))
            }
            else {
                return styleText("Someone featured a repost of your post.")
            }
        case .userAddedAsFeatured:
            if let submission = subject as? CategoryUser,
                let featuredBy = submission.featuredBy,
                let category = submission.category
            {
                return styleUser(featuredBy)
                    .appending(styleText(" has featured you in "))
                    .appending(styleCategory(category))
                    .appending(styleText("."))
            }
            else {
                return styleText("Someone has featured you in a category.")
            }
        case .userAddedAsCurator:
            if let submission = subject as? CategoryUser,
                let curatorBy = submission.curatorBy,
                let category = submission.category
            {
                return styleUser(curatorBy)
                    .appending(styleText(" has invited you to help curate "))
                    .appending(styleCategory(category))
                    .appending(styleText("."))
            }
            else {
                return styleText("Someone has invited you to help curate a category.")
            }
        case .userAddedAsModerator:
            if let submission = subject as? CategoryUser,
                let moderatorBy = submission.moderatorBy,
                let category = submission.category
            {
                return styleUser(moderatorBy)
                    .appending(styleText(" has invited you to help moderate "))
                    .appending(styleCategory(category))
                    .appending(styleText("."))
            }
            else {
                return styleText("Someone has invited you to help moderate a category.")
            }
        case .welcomeNotification:
            return styleText("Welcome to Ello!")
        default:
            return NSAttributedString(string: "")
        }
    }
}
