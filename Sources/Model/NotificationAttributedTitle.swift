////
///  NotificationAttributedTitle.swift
//

import Foundation
import UIKit

struct NotificationAttributedTitle {

    static fileprivate func attrs(_ addlAttrs: [String : AnyObject] = [:]) -> [String : AnyObject] {
        let attrs: [String: AnyObject] = [
            NSFontAttributeName: UIFont.defaultFont(),
            NSForegroundColorAttributeName: UIColor.greyA(),
        ]
        return attrs + addlAttrs
    }

    static fileprivate func styleText(_ text: String) -> NSAttributedString {
        return NSAttributedString(string: text, attributes: attrs())
    }

    static fileprivate func styleUser(_ user: User?) -> NSAttributedString {
        if let user = user {
            return NSAttributedString(string: user.atName, attributes: attrs([
                ElloAttributedText.Link: "user" as AnyObject,
                ElloAttributedText.Object: user,
                NSUnderlineStyleAttributeName: NSUnderlineStyle.styleSingle.rawValue as AnyObject,
            ]))
        }
        else {
            return styleText("Someone")
        }
    }

    static fileprivate func stylePost(_ text: String, _ post: Post) -> NSAttributedString {
        let attrs = self.attrs([
            ElloAttributedText.Link: "post" as AnyObject,
            ElloAttributedText.Object: post,
            NSUnderlineStyleAttributeName: NSUnderlineStyle.styleSingle.rawValue as AnyObject,
        ])
        return NSAttributedString(string: text, attributes: attrs)
    }

    static fileprivate func styleComment(_ text: String, _ comment: ElloComment) -> NSAttributedString {
        let attrs = self.attrs([
            ElloAttributedText.Link: "comment" as AnyObject,
            ElloAttributedText.Object: comment,
            NSUnderlineStyleAttributeName: NSUnderlineStyle.styleSingle.rawValue as AnyObject,
        ])
        return NSAttributedString(string: text, attributes: attrs)
    }

    static func attributedTitle(_ kind: Activity.Kind, author: User?, subject: JSONAble?) -> NSAttributedString {
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
                    return styleUser(author).appending(styleText(" commented on a post you’re watching."))
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
            case .welcomeNotification:
                return styleText("Welcome to Ello!")
            default:
                return NSAttributedString(string: "")
        }
    }
}
