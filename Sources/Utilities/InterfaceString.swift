////
///  InterfaceString.swift
//

struct InterfaceString {

    // Adding type information to the strings reduced the overall compile time considerably
    struct Tab {
        struct PopupTitle {
            static let Discover: String = NSLocalizedString("Discover", comment: "Discover pop up title")
            static let Notifications: String = NSLocalizedString("Notifications", comment: "Notifications pop up title")
            static let Following: String = NSLocalizedString("Following", comment: "Stream pop up title")
            static let Profile: String = NSLocalizedString("Your Profile", comment: "Profile pop up title")
            static let Omnibar: String = NSLocalizedString("Post", comment: "Omnibar pop up title")
        }

        struct PopupText {
            static let Discover: String = NSLocalizedString("What's next in art, design, fashion, web culture & more.", comment: "Discover pop up text")
            static let Notifications: String = NSLocalizedString("Stay hyped with real-time alerts.", comment: "Notifications pop up text")
            static let Following: String = NSLocalizedString("Follow the people, work & ideas that you think are most rad.", comment: "Stream pop up text")
            static let Profile: String = NSLocalizedString("Your deets & posts in one place. All your settings too.", comment: "Profile pop up text")
            static let Omnibar: String = NSLocalizedString("Publish images, GIFs, text, links and more.", comment: "Omnibar pop up text")
        }
    }

    struct Followers {
        static let Title: String = NSLocalizedString("Followers", comment: "Followers title")
    }

    struct Following {
        static let Title: String = NSLocalizedString("Following", comment: "Following title")
        static let NewPosts: String = NSLocalizedString("New Posts", comment: "New posts title")
    }

    struct Editorials {
        static let Title: String = NSLocalizedString("Editorials", comment: "")
        static let NavbarTitle: String = NSLocalizedString("Editorial", comment: "")
        static let Join: String = NSLocalizedString("Join The Creators Network.", comment: "")
        static let JoinCaption: String = NSLocalizedString("Be part of what’s next in art, design, fasion, web, culture & more.", comment: "")
        static let SubmitJoin: String = NSLocalizedString("Create Account", comment: "")
        static let Invite: String = NSLocalizedString("Invite some cool people.", comment: "")
        static let InviteCaption: String = NSLocalizedString("Help Ello grow.", comment: "")
        static let InviteInstructions: String = NSLocalizedString("Invite as many people as you want, just separate their email addresses with commas.", comment: "")
        static let InvitePlaceholder: String = NSLocalizedString("Enter email addresses", comment: "")
        static let InviteSent: String = NSLocalizedString("✅ Invitations sent.", comment: "")
        static let SubmitInvite: String = NSLocalizedString("Invite", comment: "")
        static let EmailPlaceholder: String = NSLocalizedString("Email", comment: "")
        static let UsernamePlaceholder: String = NSLocalizedString("Username", comment: "")
        static let PasswordPlaceholder: String = NSLocalizedString("Password", comment: "")
    }

    struct ArtistInvites {
        static let Title: String = NSLocalizedString("Invites", comment: "")
        static let Submissions: String = NSLocalizedString("Submissions", comment: "")
        static let Selections: String = NSLocalizedString("Selections", comment: "")
        static let PostSubmissionHeader: String = NSLocalizedString("Invite Submission", comment: "")
        static let SubmissionsError: String = NSLocalizedString("Error while loading submissions", comment: "")
        static let SeeSubmissions: String = NSLocalizedString("↓ See Submissions", comment: "")
        static let Submit: String = NSLocalizedString("SUBMIT", comment: "")
        static let PreviewStatus: String = NSLocalizedString("Preview", comment: "")
        static let UpcomingStatus: String = NSLocalizedString("Coming Soon", comment: "")
        static let OpenStatus: String = NSLocalizedString("Open For Submissions", comment: "")
        static let SelectingStatus: String = NSLocalizedString("Selections In Progress", comment: "")
        static let ClosedStatus: String = NSLocalizedString("Invite Closed", comment: "")
        static let SubmissionJoinPrompt: String = NSLocalizedString("To submit to an Invite you first need to create an Ello account.", comment: "")
        static let SubmissionSuccessTitle: String = NSLocalizedString("Submission received!", comment: "")
        static let SubmissionSuccessDescription: String = NSLocalizedString("Our team of curators will review your submission and you’ll recieve a notification when it is accepted.", comment: "")

        static let AdminTitle: String = NSLocalizedString("Submissions", comment: "")
        static let AdminEmpty: String = NSLocalizedString("No submissions", comment: "")

        static let AdminUnapprovedStream: String = NSLocalizedString("Pending review", comment: "")
        static let AdminApprovedStream: String = NSLocalizedString("Accepted submissions", comment: "")
        static let AdminSelectedStream: String = NSLocalizedString("Selected submissions", comment: "")
        static let AdminDeclinedStream: String = NSLocalizedString("Declined submissions", comment: "")
        static let AdminUnapprovedTab: String = NSLocalizedString("To Review", comment: "")
        static let AdminApprovedTab: String = NSLocalizedString("Accepted", comment: "")
        static let AdminSelectedTab: String = NSLocalizedString("Selected", comment: "")
        static let AdminDeclinedTab: String = NSLocalizedString("Declined", comment: "")

        static let AdminUnapproveAction: String = NSLocalizedString("Accepted", comment: "")
        static let AdminUnselectAction: String = NSLocalizedString("Selected", comment: "")
        static let AdminApproveAction: String = NSLocalizedString("Accept", comment: "")
        static let AdminSelectAction: String = NSLocalizedString("Select", comment: "")
        static let AdminDeclineAction: String = NSLocalizedString("Decline", comment: "")

        static let Selecting: String = NSLocalizedString("Hold Tight", comment: "")
        static func Opens(_ dateStr: String) -> String {
            return String.localizedStringWithFormat("Opens %@", dateStr)
        }
        static func Ends(_ dateStr: String) -> String {
            return String.localizedStringWithFormat("Ends %@", dateStr)
        }
        static func Ended(_ dateStr: String) -> String {
            return String.localizedStringWithFormat("Ended %@", dateStr)
        }
        static func DaysRemaining(_ days: Int) -> String {
            return String.localizedStringWithFormat("%lu Days Remaining", days)
        }
        static func Countdown(_ totalSeconds: Int) -> String {
            var remainingSeconds = totalSeconds
            let seconds = totalSeconds % 60
            remainingSeconds -= seconds

            let minutes: Int = remainingSeconds / 60 % 60
            remainingSeconds -= minutes * 60

            let hours: Int = remainingSeconds / 3600 % 60
            return String.localizedStringWithFormat("%02d:%02d:%02d Remaining", hours, minutes, seconds)
        }
    }

    struct Notifications {
        static let Title: String = NSLocalizedString("Notifications", comment: "Notifications title")
        static let Reply: String = NSLocalizedString("Reply", comment: "Reply button title")
    }

    struct Discover {
        static let Title: String = NSLocalizedString("Discover", comment: "")
        static let Categories: String = NSLocalizedString("Categories", comment: "")
        static let AllCategories: String = NSLocalizedString("All", comment: "All Categories title")
        static let Subscriptions: String = NSLocalizedString("Subscriptions", comment: "")
        static let Subscribed: String = NSLocalizedString("Subscribed", comment: "Subscribed Categories title")
        static let Subscribe: String = NSLocalizedString("Subscribe", comment: "Subscribe Categories title")

        static let ZeroState: String = NSLocalizedString("Choose communities to subscribe to here.", comment: "")
        static let ZeroState1: String = NSLocalizedString("Choose communities to subscribe to ", comment: "")
        static let ZeroState2: String = NSLocalizedString("here", comment: "")
        static let ZeroState3: String = NSLocalizedString(".", comment: "")

        static let Featured: String = NSLocalizedString("Featured", comment: "")
        static let Trending: String = NSLocalizedString("Trending", comment: "")
        static let Recent: String = NSLocalizedString("Recent", comment: "")
        static let Shop: String = NSLocalizedString("Shop", comment: "")
    }

    struct Search {
        static let Prompt: String = NSLocalizedString("Search Ello", comment: "search ello prompt")
        static let Posts: String = NSLocalizedString("Posts", comment: "Posts search toggle")
        static let People: String = NSLocalizedString("People", comment: "People search toggle")
        static let FindFriendsPrompt: String = NSLocalizedString("Help grow the Ello community.", comment: "Search zero state button title")
        static let NoMatches: String = NSLocalizedString("We couldn't find any matches.", comment: "No search results found title")
        static let TryAgain: String = NSLocalizedString("Try another search?", comment: "No search results found body")
    }

    struct Drawer {
        static let Invite: String = NSLocalizedString("Invite", comment: "")
        static let Giveaways: String = NSLocalizedString("Giveaways", comment: "")
        static let Twitter: String = NSLocalizedString("Twitter", comment: "")
        static let Instagram: String = NSLocalizedString("Instagram", comment: "")
        static let Facebook: String = NSLocalizedString("Facebook", comment: "")
        static let Pinterest: String = NSLocalizedString("Pinterest", comment: "")
        static let Tumblr: String = NSLocalizedString("Tumblr", comment: "")
        static let Medium: String = NSLocalizedString("Medium", comment: "")
        static let Magazine: String = NSLocalizedString("Magazine", comment: "")
        static let Store: String = NSLocalizedString("Store", comment: "")
        static let Help: String = NSLocalizedString("Help", comment: "")
        static let Resources: String = NSLocalizedString("Resources", comment: "")
        static let About: String = NSLocalizedString("About", comment: "")
        static let Logout: String = NSLocalizedString("Logout", comment: "")
        static let Version: String = {
            let marketingVersion: String
            let buildVersion: String
            if Globals.isTesting {
                marketingVersion = "SPECS"
                buildVersion = "specs"
            }
            else {
                marketingVersion = (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String) ?? "???"
                buildVersion = (Bundle.main.infoDictionary?["CFBundleVersion"] as? String) ?? "???"
             }
            return NSLocalizedString("Ello v\(marketingVersion) b\(buildVersion)", comment: "version number")
        }()
    }

    struct Community {
        static let Choose: String = NSLocalizedString("Choose Category", comment: "")
        static let Search: String = NSLocalizedString("Search Categories", comment: "")
    }

    struct Category {
        static let Moderator: String = NSLocalizedString("Moderator", comment: "")
        static let Moderators: String = NSLocalizedString("Moderators", comment: "")
        static let Curator: String = NSLocalizedString("Curator", comment: "")
        static let Curators: String = NSLocalizedString("Curators", comment: "")
        static let FeaturedUser: String = NSLocalizedString("Featured User", comment: "")
        static let NoRoles: String = NSLocalizedString("No existing roles", comment: "")
        static let SponsoredBy: String = NSLocalizedString("Sponsored by", comment: "")
        static let PostedBy: String = NSLocalizedString("Posted by", comment: "")
        static let HeaderBy: String = NSLocalizedString("Header by", comment: "")
        static let RoleAdmin: String = NSLocalizedString("Community Roles", comment: "")
    }

    struct Settings {
        static let EditProfile: String = NSLocalizedString("Edit Profile", comment: "")
        static let EditCredentials: String = NSLocalizedString("Edit Credentials", comment: "")
        static let CredentialsSettings: String = NSLocalizedString("To change your username, email, or password, please verify your current password", comment: "")
        static let TapToEdit: String = NSLocalizedString("(tap to edit)", comment: "")
        static let AbortChanges: String = NSLocalizedString("Discard changes?", comment: "")
        static let Logout: String = NSLocalizedString("Logout", comment: "")
        static let Profile: String = NSLocalizedString("Profile", comment: "")
        static let ProfileDescription: String = NSLocalizedString("Your name, username, bio and links appear on your public profile. Your email address remains private.", comment: "Profile Privacy Description")
        static let CommunityInfo: String = NSLocalizedString("Community Info", comment: "")
        static let Username: String = NSLocalizedString("Username", comment: "")
        static let Email: String = NSLocalizedString("Email", comment: "")
        static let OldPassword: String = NSLocalizedString("Current Password", comment: "")
        static let OldPasswordRequired: String = NSLocalizedString("You must enter your current password to change your username, email, or password.", comment: "")
        static let Password: String = NSLocalizedString("Password", comment: "")
        static let Name: String = NSLocalizedString("Name", comment: "")
        static let Bio: String = NSLocalizedString("Bio", comment: "")
        static let Links: String = NSLocalizedString("Links", comment: "")
        static let Location: String = NSLocalizedString("Location", comment: "")
        static let AvatarUploaded: String = NSLocalizedString("You’ve updated your Avatar.\n\nIt may take a few minutes for your new avatar to appear on Ello, so please be patient. It’ll be live soon!", comment: "Avatar updated copy")
        static let CoverImageUploaded: String = NSLocalizedString("You’ve updated your Header.\n\nIt may take a few minutes for your new header to appear on Ello, so please be patient. It’ll be live soon!", comment: "Cover Image updated copy")
        static let CreatorType: String = NSLocalizedString("Creator Type", comment: "")
        static let BlockedTitle: String = NSLocalizedString("Blocked", comment: "")
        static let MutedTitle: String = NSLocalizedString("Muted", comment: "")
        static let DeleteAccountTitle: String = NSLocalizedString("Account Deletion", comment: "")
        static let DeleteAccount: String = NSLocalizedString("Delete Account", comment: "")
        static let DeleteAccountExplanation: String = NSLocalizedString("By deleting your account you remove your personal information from Ello. Your account cannot be restored.", comment: "")
        static let DeleteAccountConfirm: String = NSLocalizedString("Delete Account?", comment: "delete account question")
        static let AccountIsBeingDeleted: String = NSLocalizedString("Your account is in the process of being deleted.", comment: "")
        static func RedirectedCountdown(_ count: Int) -> String {
            return String.localizedStringWithFormat("You will be redirected in %lu...", count)
        }
    }

    struct Profile {
        static let Title: String = NSLocalizedString("Profile", comment: "Profile Title")
        static let Mention: String = NSLocalizedString("@ Mention", comment: "Mention button title")
        static let Collaborate: String = NSLocalizedString("Collab", comment: "Collaborate button title")
        static let Hire: String = NSLocalizedString("Hire", comment: "Hire button title")
        static let Invite: String = NSLocalizedString("Invite", comment: "Invite button title")
        static let EditProfile: String = NSLocalizedString("Edit Profile", comment: "Edit Profile button title")
        static let PostsCount: String = NSLocalizedString("Posts", comment: "Posts count header")
        static let FollowingCount: String = NSLocalizedString("Following", comment: "Following count header")
        static let FollowersCount: String = NSLocalizedString("Followers", comment: "Followers count header")
        static let LovesCount: String = NSLocalizedString("Loves", comment: "Loves count header")
        static let CurrentUserNoResultsTitle: String = NSLocalizedString("Welcome to your Profile", comment: "")
        static let CurrentUserNoResultsBody: String = NSLocalizedString("Everything you post lives here!\n\nThis is the place to find everyone you’re following and everyone that’s following you. You’ll find your Loves here too!", comment: "")
        static let NoResultsTitle: String = NSLocalizedString("This person hasn't posted yet.", comment: "")
        static let NoResultsBody: String = NSLocalizedString("Follow or mention them to help them get started!", comment: "")
        static let FeaturedIn: String = NSLocalizedString("Featured in", comment: "Featurd in label")
        static let TotalViews: String = NSLocalizedString("Views", comment: "Total views label")
        static let Badges: String = NSLocalizedString("Badges", comment: "")
    }

    struct Badges {
        static let Featured = NSLocalizedString("Featured", comment: "")
        static let Community = NSLocalizedString("Community Profile", comment: "")
        static let Experimental = NSLocalizedString("Experimental Group", comment: "")
        static let Staff = NSLocalizedString("Ello Staff Member", comment: "")
        static let StaffLink = NSLocalizedString("Meet the Staff", comment: "")
        static let Spam = NSLocalizedString("Spam, Eggs, and Spam", comment: "")
        static let Nsfw = NSLocalizedString("NSFW", comment: "")
        static let LearnMore: String = NSLocalizedString("Learn More", comment: "")
    }

    struct Post {
        static let DefaultTitle: String = NSLocalizedString("Post Detail", comment: "Default post title")
        static let LovedByList: String = NSLocalizedString("Loved by", comment: "Loved by list title")
        static let RepostedByList: String = NSLocalizedString("Reposted by", comment: "Reposted by list title")
        static let RelatedPosts: String = NSLocalizedString("Related Posts", comment: "Related posts title")
        static let LoadMoreComments: String = NSLocalizedString("Load More", comment: "Load More Comments title")

        static let Feature: String = NSLocalizedString("Feature", comment: "")
        static let Featured: String = NSLocalizedString("Featured", comment: "")

        static let FeaturedBy: String = NSLocalizedString("Featured by", comment: "")
        static let AddedTo: String = NSLocalizedString("Added to", comment: "")
        static let PostedInto: String = NSLocalizedString("Posted into", comment: "")

        static let CreateComment: String = NSLocalizedString("Comment...", comment: "Create Comment Button Prompt")
        static let DeletePostConfirm: String = NSLocalizedString("Delete Post?", comment: "Delete Post confirmation")
        static let DeleteCommentConfirm: String = NSLocalizedString("Delete Comment?", comment: "Delete Comment confirmation")
        static let RepostConfirm: String = NSLocalizedString("Repost?", comment: "Repost confirmation")
        static let RepostSuccess: String = NSLocalizedString("Success!", comment: "Successful repost alert")
        static let RepostError: String = NSLocalizedString("Could not create repost", comment: "Could not create repost message")
        static let CannotEditPost: String = NSLocalizedString("Looks like this post was created on the web!\n\nThe videos and embedded content it contains are not YET editable on our iOS app.  We’ll add this feature soon!", comment: "Uneditable post error message")
        static let CannotEditComment: String = NSLocalizedString("Looks like this comment was created on the web!\n\nThe videos and embedded content it contains are not YET editable on our iOS app.  We’ll add this feature soon!", comment: "Uneditable comment error message")
    }

    struct Omnibar {
        static let SayEllo: String = NSLocalizedString("Say Ello...", comment: "Say Ello prompt")
        static let AddMoreText: String = NSLocalizedString("Add more text...", comment: "Add more text prompt")
        static let EnterURL: String = NSLocalizedString("Enter the URL", comment: "")
        static let CreatePostTitle: String = NSLocalizedString("Post", comment: "Create a post")
        static func CreateArtistInviteSubmission(title: String) -> String {
            return String.localizedStringWithFormat("Submit to %@", title)
        }
        static let CreatePostButton: String = NSLocalizedString("Post", comment: "")
        static let ChooseCommunity: String = NSLocalizedString("Choose Category", comment: "")
        static let EditPostTitle: String = NSLocalizedString("Edit this post", comment: "")
        static let EditPostButton: String = NSLocalizedString("Edit Post", comment: "")
        static let EditCommentTitle: String = NSLocalizedString("Edit this comment", comment: "")
        static let EditCommentButton: String = NSLocalizedString("Edit Comment", comment: "")
        static let CreateCommentTitle: String = NSLocalizedString("Leave a comment", comment: "")
        static let CreateCommentButton: String = NSLocalizedString("Comment", comment: "")
        static let CannotComment: String = NSLocalizedString("This user has disabled comments.", comment: "")
        static let TooLongError: String = NSLocalizedString("Your text is too long.\n\nThe character limit is 5,000.", comment: "Post too long (maximum characters is 5000) error message")
        static func LoadingImageError(url: URL) -> String {
            return String.localizedStringWithFormat("There was a problem loading the image\n%@", url.absoluteString)
        }
        static let UpdatingPost: String = NSLocalizedString("Updating your post…", comment: "")
        static let UpdatingComment: String = NSLocalizedString("Updating your comment…", comment: "")
        static let CreatingPost: String = NSLocalizedString("Creating your post…", comment: "")
        static let CreatingComment: String = NSLocalizedString("Creating your comment…", comment: "")
        static let CreatedPost: String = NSLocalizedString("Post successfully created!", comment: "")
        static let CreatedComment: String = NSLocalizedString("Comment successfully created!", comment: "")
        static let SellYourWorkTitle: String = NSLocalizedString("Sell your work", comment: "Sell your work title")
        static let ProductLinkPlaceholder: String = NSLocalizedString("Product detail URL", comment: "Product detail URL prompt")
    }

    struct Hire {
        static func HireTitle(atName: String) -> String {
            return String.localizedStringWithFormat("Hire %@", atName)
        }
        static func CollaborateTitle(atName: String) -> String {
            return String.localizedStringWithFormat("Collaborate with %@", atName)
        }
    }

    struct Loves {
        static let Title: String = NSLocalizedString("Loves", comment: "love stream")
    }

    struct Relationship {
        static let Follow: String = NSLocalizedString("Follow", comment: "Follow relationship")
        static let Following: String = NSLocalizedString("Following", comment: "Following relationship")
        static let Muted: String = NSLocalizedString("Muted", comment: "Muted relationship")
        static let Blocked: String = NSLocalizedString("Blocked", comment: "Blocked relationship")

        static let MuteButton: String = NSLocalizedString("Mute", comment: "Mute button title")
        static let UnmuteButton: String = NSLocalizedString("Unmute", comment: "Unmute button title")
        static let BlockButton: String = NSLocalizedString("Block", comment: "Block button title")
        static let UnblockButton: String = NSLocalizedString("Unblock", comment: "Unblock button title")
        static let FlagButton: String = NSLocalizedString("Flag", comment: "Flag button title")

        static func UnmuteAlert(atName: String) -> String {
            return String.localizedStringWithFormat("Would you like to \nunmute or block %@?", atName)
        }
        static func UnblockAlert(atName: String) -> String {
            return String.localizedStringWithFormat("Would you like to \nmute or unblock %@?", atName)
        }
        static func MuteAlert(atName: String) -> String {
            return String.localizedStringWithFormat("Would you like to \nmute or block %@?", atName)
        }
        static func MuteWarning(atName: String) -> String {
            return String.localizedStringWithFormat("%@ will not be able to comment on your posts. If %@ mentions you, you will not be notified.", atName, atName)
        }
        static func BlockWarning(atName: String) -> String {
            return String.localizedStringWithFormat("%@ will not be able to follow you or view your profile, posts or find you in search.", atName)
        }
        static func FlagWarning(atName: String) -> String {
            return String.localizedStringWithFormat("%@ will be investigated by our staff.", atName)
        }
    }

    struct PushNotifications {
        static let PermissionPrompt: String = NSLocalizedString("Ello would like to send you push notifications.\n\nWe will let you know when you have new notifications. You can make changes in your settings.\n", comment: "Turn on Push Notifications prompt")
        static let PermissionYes: String = NSLocalizedString("Yes please", comment: "Allow")
        static let PermissionNo: String = NSLocalizedString("No thanks", comment: "Disallow")

        static let CommentReply: String = NSLocalizedString("Reply", comment: "")
        static let MessageUser: String = NSLocalizedString("Mention", comment: "")
        static let PostComment: String = NSLocalizedString("Comment", comment: "")
        static let LovePost: String = NSLocalizedString("Love", comment: "")
        static let FollowUser: String = NSLocalizedString("Follow", comment: "")
        static let View: String = NSLocalizedString("View", comment: "")
    }

    struct Friends {
        static let ImportPermissionTitle: String = NSLocalizedString("Invite some cool people", comment: "")
        static let ImportPermissionSubtitle: String = NSLocalizedString("Help Ello grow.", comment: "")
        static let ImportPermissionPrompt: String = NSLocalizedString("Ello does not sell user data, and will never contact anyone without your permission.", comment: "")
        static let ImportSMS: String = NSLocalizedString("Send Invite", comment: "")
        static let SMSMessage: String = NSLocalizedString("Check out Ello, the Creators Network. https://itunes.apple.com/us/app/ello/id953614327", comment: "")
        static let ImportAllow: String = NSLocalizedString("Import my contacts", comment: "")
        static let ImportNotNow: String = NSLocalizedString("Not now", comment: "")

        static func ImportError(_ message: String) -> String {
            return String.localizedStringWithFormat("We were unable to access your address book\n%@", message)
        }
        static let AccessDenied: String = NSLocalizedString("Access to your contacts has been denied.  If you want to search for friends, you will need to grant access from Settings.", comment: "Access to contacts denied by user")
        static let AccessRestricted: String = NSLocalizedString("Access to your contacts has been denied by the system.", comment: "Access to contacts denied by system")

        static let FindAndInvite: String = NSLocalizedString("Find & invite your contacts", comment: "Find & invite")

        static let Resend: String = NSLocalizedString("Re-send", comment: "invite friends cell re-send")
        static let Invite: String = NSLocalizedString("Invite", comment: "invite friends cell invite")
    }

    struct NSFW {
        static let Show: String = NSLocalizedString("Tap to View.", comment: "")
        static let Hide: String = NSLocalizedString("Tap to Hide.", comment: "")
    }

    struct ImagePicker {
        static let ChooseSource: String = NSLocalizedString("Choose a photo source", comment: "choose photo source (camera or library)")
        static let Camera: String = NSLocalizedString("Camera", comment: "camera button")
        static let Library: String = NSLocalizedString("Library", comment: "library button")
        static let NoSourceAvailable: String = NSLocalizedString("Sorry, but your device doesn’t have a photo library!", comment: "device doesn't support photo library")
        static let TakePhoto: String = NSLocalizedString("Take Photo", comment: "Camera button")
        static let PhotoLibrary: String = NSLocalizedString("Photo Library", comment: "Library button")
        static func AddImages(_ count: Int) -> String {
            return String.localizedStringWithFormat("Add %lu Image(s)", count)
        }
        static let ChooseImage: String = NSLocalizedString("Choose Image", comment: "")
    }

    struct WebBrowser {
        static let TermsAndConditions: String = NSLocalizedString("Terms and Conditions", comment: "terms and conditions title")
    }

    struct Startup {
        static let SignUp: String = NSLocalizedString("Sign Up", comment: "sign up button")
        static let Login: String = NSLocalizedString("Login", comment: "login button")
        static let Join: String = NSLocalizedString("Join The Creators Network.", comment: "")
        static let Reset: String = NSLocalizedString("Reset", comment: "Reset button label")
        static let ForgotPasswordEnter: String = NSLocalizedString("Enter your email", comment: "Enter your email label")
        static let ForgotPasswordEnterSuccess: String = NSLocalizedString("If your email address exists in our database, you will receive a password recovery link at your email address in a few minutes.", comment: "Enter your email success description")
        static let ForgotPasswordReset: String = NSLocalizedString("Reset your password.", comment: "Reset your password label")
        static let ForgotPasswordResetError: String = NSLocalizedString("The password reset token you used is no longer valid. This may be because you requested more than one token, or that too much time has elapsed.", comment: "Reset your password long error reason.")
        static let Tagline: String = NSLocalizedString("Be part of what’s next in art, design, fashion, web culture & more.", comment: "Be part of what's next tag line label")
    }

    struct Login {
        static let Continue: String = NSLocalizedString("Continue", comment: "continue button")
        static let LoadUserError: String = NSLocalizedString("Unable to load user.", comment: "Unable to load user message")
        static let ForgotPassword: String = NSLocalizedString("Forgot Password", comment: "forgot password title")
        static let UsernamePlaceholder: String = NSLocalizedString("Username or Email", comment: "username or email field")
        static let PasswordPlaceholder: String = NSLocalizedString("Password", comment: "password field")
    }

    struct Join {
        static let Discover: String = NSLocalizedString("Discover Ello", comment: "discover ello button")
        static let LoginAfterJoinError: String = NSLocalizedString("Your account has been created, but there was an error logging in, please try again", comment: "After successfully joining, there was an error signing in")
        static let Email: String = NSLocalizedString("Email", comment: "email key")
        static let EmailPlaceholder: String = NSLocalizedString("Enter email", comment: "sign up email field")
        static let Username: String = NSLocalizedString("Username", comment: "username key")
        static let UsernamePlaceholder: String = NSLocalizedString("Create username", comment: "sign up username field")
        static let PasswordPlaceholder: String = NSLocalizedString("Set password", comment: "sign up password field")

        static let UsernameUnavailable: String = NSLocalizedString("Username already exists.\nPlease try a new one.", comment: "username exists error message")
        static let UsernameSuggestionPrefix: String = NSLocalizedString("Here are some available usernames -\n", comment: "username suggestions showmes")
        static let Password: String = NSLocalizedString("Password", comment: "password key")
    }

    struct Validator {
        static let EmailRequired: String = NSLocalizedString("Email is required.", comment: "email is required message")
        static let UsernameRequired: String = NSLocalizedString("Username is required.", comment: "username is required message")
        static let PasswordRequired: String = NSLocalizedString("Password is required.", comment: "password is required message")

        static let SignInInvalid: String = NSLocalizedString("Invalid email or username", comment: "Invalid email or username message")
        static let CredentialsInvalid: String = NSLocalizedString("Invalid credentials", comment: "Invalid credentials message")
        static let EmailInvalid: String = NSLocalizedString("That email is invalid.\nPlease try again.", comment: "invalid email message")
        static let UsernameInvalid: String = NSLocalizedString("That username is invalid.\nPlease try again.", comment: "invalid username message")
        static let PasswordInvalid: String = NSLocalizedString("Password must be at least 8\ncharacters long.", comment: "password length error message")
    }

    struct Onboard {
        static let PickCategoriesPrimary: String = NSLocalizedString("Pick what you’re into.", comment: "")
        static let PickCategoriesSecondary: String = NSLocalizedString("Slow down & check out some cool ass shit.", comment: "")
        static let CreateProfilePrimary: String = NSLocalizedString("Grow your creative influence.", comment: "")
        static let CreateProfileSecondary: String = NSLocalizedString("Completed profiles get way more views.", comment: "")

        static let InviteFriendsPrimary: String = NSLocalizedString("Invite some cool people.", comment: "")
        static let InviteFriendsSecondary: String = NSLocalizedString("Make Ello better.", comment: "")

        static let CreatorTypeHeader: String = NSLocalizedString("We’re doing a quick survey to find out a little more about the artistic composition of the Ello community.  You can always update your selection(s) in settings.  Thank you!", comment: "")
        static let HereAs: String = NSLocalizedString("I am here as:", comment: "")
        static let Interests: String = NSLocalizedString("I make:", comment: "")
        static let Artist: String = NSLocalizedString("An Artist", comment: "")
        static let Fan: String = NSLocalizedString("A Fan", comment: "")
        static let CreateAccount: String = NSLocalizedString("Create Account", comment: "")
        static let CreateProfile: String = NSLocalizedString("Create Your Profile", comment: "")
        static let InvitePeople: String = NSLocalizedString("Invite Cool People", comment: "")
        static let ImDone: String = NSLocalizedString("I’m done", comment: "")
        static func Pick(_ count: Int) -> String {
            return String.localizedStringWithFormat("Pick %lu", count)
        }
        static let UploadCoverButton: String = NSLocalizedString("Upload Header", comment: "")
        static let UploadCoverImagePrompt: String = NSLocalizedString("2560 x 1440\nAnimated Gifs work, too", comment: "")
        static let UploadAvatarButton: String = NSLocalizedString("Upload Avatar", comment: "")
        static let UploadAvatarPrompt: String = NSLocalizedString("360 x 360\nAnimated Gifs work, too", comment: "")
        static let NamePlaceholder: String = NSLocalizedString("Name", comment: "")
        static let BioPlaceholder: String = NSLocalizedString("Bio", comment: "")
        static let LinksPlaceholder: String = NSLocalizedString("Links", comment: "")

        static let Search: String = NSLocalizedString("Name or email", comment: "")

        static let UploadFailed: String = NSLocalizedString("Oh no! Something went wrong.\n\nTry that again maybe?", comment: "image upload failed during onboarding message")
        static let RelationshipFailed: String = NSLocalizedString("Oh no! Something went wrong.\n\nTry that again maybe?", comment: "relationship status update failed during onboarding message")
    }

    struct Share {
        static let FailedToPost: String = NSLocalizedString("Uh oh, failed to post to Ello.", comment: "Failed to post to Ello")
        static let PleaseLogin: String = NSLocalizedString("Please login to the Ello app first to use this feature.", comment: "Not logged in message.")
    }

    struct App {
        static let OpenInSafari: String = NSLocalizedString("Open in Safari", comment: "")
        static let LoggedOut: String = NSLocalizedString("You have been automatically logged out", comment: "Automatically logged out message")
        static let LoginAndView: String = NSLocalizedString("Login and view", comment: "Login and view prompt")
        static let OldVersion: String = NSLocalizedString("The version of the app you’re using is too old, and is no longer compatible with our API.\n\nPlease update the app to the latest version, using the “Updates” tab in the App Store.", comment: "App out of date message")
        static let LoggedOutError: String = NSLocalizedString("You must be logged in", comment: "")
    }

    struct Error {
        static let JPEGCompress: String = NSLocalizedString("Could not compress image as JPEG", comment: "")
    }

    static let GenericError: String = NSLocalizedString("Something went wrong. Thank you for your patience with Ello!", comment: "Generic error message")
    static let UnknownError: String = NSLocalizedString("Unknown error", comment: "Unknown error message")

    static let EmptyStreamText: String = NSLocalizedString("Nothing To See Here", comment: "")
    static let Ello: String = NSLocalizedString("Ello", comment: "")
    static let OK: String = NSLocalizedString("OK", comment: "")
    static let Yes: String = NSLocalizedString("Yes", comment: "")
    static let No: String = NSLocalizedString("No", comment: "")
    static let Nevermind: String = NSLocalizedString("Nevermind", comment: "")
    static let Cancel: String = NSLocalizedString("Cancel", comment: "")
    static let Submit: String = NSLocalizedString("Submit", comment: "")
    static let Retry: String = NSLocalizedString("Retry", comment: "")
    static let AreYouSure: String = NSLocalizedString("Are You Sure?", comment: "")
    static let ThatIsOK: String = NSLocalizedString("It’s OK, I understand!", comment: "")
    static let Delete: String = NSLocalizedString("Delete", comment: "")
    static let Remove: String = NSLocalizedString("Remove", comment: "")
    static let Next: String = NSLocalizedString("Next", comment: "")
    static let Done: String = NSLocalizedString("Done", comment: "")
    static let Skip: String = NSLocalizedString("Skip", comment: "")
    static let SeeAll: String = NSLocalizedString("See All", comment: "")
    static let Send: String = NSLocalizedString("Send", comment: "")
    static let Save: String = NSLocalizedString("Save", comment: "")
    static let Edit: String = NSLocalizedString("Edit", comment: "")
    static let Info: String = NSLocalizedString("Info", comment: "")
    static let Add: String = NSLocalizedString("Add", comment: "")
}
