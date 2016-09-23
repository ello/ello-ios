////
///  NotificationAttributedTitle.swift
//

import Foundation
import UIKit

public struct NotificationAttributedTitle {

    static private func attrs(addlAttrs: [String : AnyObject] = [:]) -> [String : AnyObject] {
        let attrs: [String: AnyObject] = [
            NSFontAttributeName: UIFont.defaultFont(),
            NSForegroundColorAttributeName: UIColor.greyA(),
        ]
        return attrs + addlAttrs
    }

    static private func styleText(text: String) -> NSAttributedString {
        return NSAttributedString(string: text, attributes: attrs())
    }

    static private func styleUser(user: User?) -> NSAttributedString {
        if let user = user {
            return NSAttributedString(string: user.atName, attributes: attrs([
                ElloAttributedText.Link: "user",
                ElloAttributedText.Object: user,
                NSUnderlineStyleAttributeName: NSUnderlineStyle.StyleSingle.rawValue,
            ]))
        }
        else {
            return styleText("Someone")
        }
    }

    static private func stylePost(text: String, _ post: Post) -> NSAttributedString {
        let attrs = self.attrs([
            ElloAttributedText.Link: "post",
            ElloAttributedText.Object: post,
            NSUnderlineStyleAttributeName: NSUnderlineStyle.StyleSingle.rawValue,
        ])
        return NSAttributedString(string: text, attributes: attrs)
    }

    static private func styleComment(text: String, _ comment: ElloComment) -> NSAttributedString {
        let attrs = self.attrs([
            ElloAttributedText.Link: "comment",
            ElloAttributedText.Object: comment,
            NSUnderlineStyleAttributeName: NSUnderlineStyle.StyleSingle.rawValue,
        ])
        return NSAttributedString(string: text, attributes: attrs)
    }

    static func attributedTitle(kind: Activity.Kind, author: User?, subject: JSONAble?) -> NSAttributedString {
        switch kind {
            case .RepostNotification:
                if let post = subject as? Post {
                    return styleUser(author)
                        .append(styleText(" reposted your "))
                        .append(stylePost("post", post))
                        .append(styleText("."))
                }
                else {
                    return styleUser(author)
                        .append(styleText(" reposted your post."))
                }
            case .NewFollowedUserPost:
                return styleText("You started following ")
                    .append(styleUser(author))
                    .append(styleText("."))
            case .NewFollowerPost:
                return styleUser(author)
                    .append(styleText(" started following you."))
            case .PostMentionNotification:
                if let post = subject as? Post {
                    return styleUser(author)
                        .append(styleText(" mentioned you in a "))
                        .append(stylePost("post", post))
                        .append(styleText("."))
                }
                else {
                    return styleUser(author)
                        .append(styleText(" mentioned you in a post."))
                }
            case .CommentNotification:
                if let comment = subject as? ElloComment {
                    return styleUser(author)
                        .append(styleText(" commented on your "))
                        .append(styleComment("post", comment))
                        .append(styleText("."))
                }
                else {
                    return styleUser(author)
                        .append(styleText(" commented on a post."))
                }
            case .CommentMentionNotification:
                if let comment = subject as? ElloComment {
                    return styleUser(author)
                        .append(styleText(" mentioned you in a "))
                        .append(styleComment("comment", comment))
                        .append(styleText("."))
                }
                else {
                    return styleUser(author)
                        .append(styleText(" mentioned you in a comment."))
                }
            case .CommentOnOriginalPostNotification:
                if let comment = subject as? ElloComment,
                    repost = comment.loadedFromPost,
                    repostAuthor = repost.author,
                    source = repost.repostSource
                {
                    return styleUser(author)
                        .append(styleText(" commented on "))
                        .append(styleUser(repostAuthor))
                        .append(styleText("’s "))
                        .append(stylePost("repost", repost))
                        .append(styleText(" of your "))
                        .append(stylePost("post", source))
                        .append(styleText("."))
                }
                else {
                    return styleUser(author)
                        .append(styleText(" commented on your post"))
                }
            case .CommentOnRepostNotification:
                if let comment = subject as? ElloComment {
                    return styleUser(author)
                        .append(styleText(" commented on your "))
                        .append(styleComment("repost", comment))
                        .append(styleText("."))
                }
                else {
                    return styleUser(author)
                        .append(styleText(" commented on your repost"))
                }
            case .InvitationAcceptedPost:
                return styleUser(author)
                    .append(styleText(" accepted your invitation."))
            case .LoveNotification:
                if let love = subject as? Love,
                    post = love.post
                {
                    return styleUser(author)
                        .append(styleText(" loved your "))
                        .append(stylePost("post", post))
                        .append(styleText("."))
                }
                else {
                    return styleUser(author).append(styleText(" loved your post."))
                }
            case .LoveOnRepostNotification:
                if let love = subject as? Love,
                    post = love.post
                {
                    return styleUser(author)
                        .append(styleText(" loved your "))
                        .append(stylePost("repost", post))
                        .append(styleText("."))
                }
                else {
                    return styleUser(author).append(styleText(" loved your repost."))
                }
            case .LoveOnOriginalPostNotification:
                if let love = subject as? Love,
                    repost = love.post,
                    repostAuthor = repost.author,
                    source = repost.repostSource
                {
                    return styleUser(author)
                        .append(styleText(" loved "))
                        .append(styleUser(repostAuthor))
                        .append(styleText("’s "))
                        .append(stylePost("repost", repost))
                        .append(styleText(" of your "))
                        .append(stylePost("post", source))
                        .append(styleText("."))
                }
                else {
                    return styleUser(author).append(styleText(" loved a repost of your post."))
                }
            case .WatchNotification:
                if let love = subject as? Watch,
                    post = love.post
                {
                    return styleUser(author)
                        .append(styleText(" watched your "))
                        .append(stylePost("post", post))
                        .append(styleText("."))
                }
                else {
                    return styleUser(author).append(styleText(" watched your post."))
                }
            case .WatchOnRepostNotification:
                if let love = subject as? Watch,
                    post = love.post
                {
                    return styleUser(author)
                        .append(styleText(" watched your "))
                        .append(stylePost("repost", post))
                        .append(styleText("."))
                }
                else {
                    return styleUser(author).append(styleText(" watched your repost."))
                }
            case .WatchOnOriginalPostNotification:
                if let love = subject as? Watch,
                    repost = love.post,
                    repostAuthor = repost.author,
                    source = repost.repostSource
                {
                    return styleUser(author)
                        .append(styleText(" watched "))
                        .append(styleUser(repostAuthor))
                        .append(styleText("’s "))
                        .append(stylePost("repost", repost))
                        .append(styleText(" of your "))
                        .append(stylePost("post", source))
                        .append(styleText("."))
                }
                else {
                    return styleUser(author).append(styleText(" watched a repost of your post."))
                }
            case .WelcomeNotification:
                return styleText("Welcome to Ello!")
            default:
                return NSAttributedString(string: "")
        }
    }
}
