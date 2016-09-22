////
///  InterfaceString.swift
//

import Foundation


public struct InterfaceString {

    // Adding type information to the strings reduced the overall compile time considerably
    public struct Tab {
        public struct PopupTitle {
            static let Discover: String = NSLocalizedString("Discover", comment: "Discover pop up title")
            static let Notifications: String = NSLocalizedString("Notifications", comment: "Notifications pop up title")
            static let Stream: String = NSLocalizedString("Streams", comment: "Stream pop up title")
            static let Profile: String = NSLocalizedString("Your Profile", comment: "Profile pop up title")
            static let Omnibar: String = NSLocalizedString("Post (Omnibar)", comment: "Omnibar pop up title")
        }

        public struct PopupText {
            static let Discover: String = NSLocalizedString("Explore creators, curated categories & communities.", comment: "Discover pop up text")
            static let Notifications: String = NSLocalizedString("Keep it fresh with real-time alerts.", comment: "Notifications pop up text")
            static let Stream: String = NSLocalizedString("Two streams: Following & Starred.\nUse them however you like.", comment: "Stream pop up text")
            static let Profile: String = NSLocalizedString("Everything you create in one place.\nSettings too.", comment: "Profile pop up text")
            static let Omnibar: String = NSLocalizedString("Share text, links, images, GIFs and more.", comment: "Omnibar pop up text")
        }
    }

    public struct Followers {
        static let CurrentUserNoResultsTitle: String = NSLocalizedString("You don't have any followers yet!", comment: "Current user no followers results title")
        static let CurrentUserNoResultsBody: String = NSLocalizedString("Here's some tips on how to get new followers: use Discover to find people you're interested in, and to find or invite your contacts. When you see things you like you can comment, repost, mention people and love the posts that you most enjoy. ", comment: "Current user no followers results body.")
        static let NoResultsTitle: String = NSLocalizedString("This person doesn't have any followers yet! ", comment: "Non-current user followers no results title")
        static let NoResultsBody: String = NSLocalizedString("Be the first to follow them and give them some love! Following interesting people makes Ello way more fun.", comment: "Non-current user following no results body")
        static let Title: String = NSLocalizedString("Followers", comment: "Followers title")
    }

    public struct Following {
        static let Title: String = NSLocalizedString("Following", comment: "Following title")
        static let CurrentUserNoResultsTitle: String = NSLocalizedString("You aren't following anyone yet!", comment: "Current user no following results title")
        static let CurrentUserNoResultsBody: String = NSLocalizedString("Ello is way more rad when you're following lots of people.\n\nUse Discover to find people you're interested in, and to find or invite your contacts.\nYou can also use Search (upper right) to look for new and excellent people!", comment: "Current user No following results body.")
        static let NoResultsTitle: String = NSLocalizedString("This person isn't following anyone yet!", comment: "Non-current user followoing no results title")
        static let NoResultsBody: String = NSLocalizedString("Follow, mention them, comment, repost or love one of their posts and maybe they'll follow you back ;)", comment: "Non-current user following no results body")
    }

    public struct FollowingStream {
        static let Title: String = NSLocalizedString("Following", comment: "Following title")
        static let NoResultsTitle: String = NSLocalizedString("Welcome to Following!", comment: "No following results title")
        static let NoResultsBody: String = NSLocalizedString("Follow people and things that inspire you.", comment: "No following results body.")
    }

    public struct StarredStream {
        static let Title: String = NSLocalizedString("Starred", comment: "Starred title")
        static let NoResultsTitle: String = NSLocalizedString("Welcome to Starred!", comment: "No starred results title")
        static let NoResultsBody: String = NSLocalizedString("When you Star someone their posts appear here. Star people to create a second stream.", comment: "No following results body.")
    }

    public struct Notifications {
        static let Title: String = NSLocalizedString("Notifications", comment: "Notifications title")
        static let Reply: String = NSLocalizedString("Reply", comment: "Reply button title")
        static let NoResultsTitle: String = NSLocalizedString("Welcome to your Notifications Center!", comment: "No notification results title")
        static let NoResultsBody: String = NSLocalizedString("Whenever someone mentions you, follows you, accepts an invitation, comments, reposts or Loves one of your posts, you'll be notified here.", comment: "No notification results body.")
    }

    public struct Discover {
        static let Title: String = NSLocalizedString("Discover", comment: "Discover title")
        static let Categories: String = NSLocalizedString("Categories", comment: "some Categories title")
        static let AllCategories: String = NSLocalizedString("All", comment: "All Categories title")
        static let Featured: String = NSLocalizedString("Featured", comment: "Discover tab titled Featured")
        static let Trending: String = NSLocalizedString("Trending", comment: "Discover tab titled Trending")
        static let Recent: String = NSLocalizedString("Recent", comment: "Discover tab titled Recent")
    }

    public struct Search {
        static let Title: String = NSLocalizedString("Search", comment: "Search title")
        static let Prompt: String = NSLocalizedString("Search Ello", comment: "search ello prompt")
        static let Posts: String = NSLocalizedString("Posts", comment: "Posts search toggle")
        static let People: String = NSLocalizedString("People", comment: "People search toggle")
        static let FindFriendsPrompt: String = NSLocalizedString("Help grow the Ello community.\nShare the experience.", comment: "Search zero state button title")
        static let NoMatches: String = NSLocalizedString("We couldn't find any matches.", comment: "No search results found title")
        static let TryAgain: String = NSLocalizedString("Try another search?", comment: "No search results found body")
    }

    public struct Drawer {
        static let Store: String = NSLocalizedString("Store", comment: "Store")
        static let Invite: String = NSLocalizedString("Invite", comment: "Invite")
        static let Help: String = NSLocalizedString("Help", comment: "Help")
        static let Resources: String = NSLocalizedString("Resources", comment: "Resources")
        static let About: String = NSLocalizedString("About", comment: "About")
        static let Logout: String = NSLocalizedString("Logout", comment: "Logout")
        static let Version: String = {
            let marketingVersion: String
            let buildVersion: String
            if AppSetup.sharedState.isSimulator {
                marketingVersion = "SPECS"
                buildVersion = "specs"
            }
            else {
                marketingVersion = (NSBundle.mainBundle().infoDictionary?["CFBundleShortVersionString"] as? String) ?? "???"
                buildVersion = (NSBundle.mainBundle().infoDictionary?["CFBundleVersion"] as? String) ?? "???"
             }
            return NSLocalizedString("Ello v\(marketingVersion) b\(buildVersion)", comment: "version number")
        }()
    }

    public struct Settings {
        static let EditProfile: String = NSLocalizedString("Edit Profile", comment: "Edit Profile Title")
        static let Name: String = NSLocalizedString("Name", comment: "name setting")
        static let Links: String = NSLocalizedString("Links", comment: "links setting")
        static let AvatarUploaded: String = NSLocalizedString("You’ve updated your Avatar.\n\nIt may take a few minutes for your new avatar/header to appear on Ello, so please be patient. It’ll be live soon!", comment: "Avatar updated copy")
        static let CoverImageUploaded: String = NSLocalizedString("You’ve updated your Header.\n\nIt may take a few minutes for your new avatar/header to appear on Ello, so please be patient. It’ll be live soon!", comment: "Cover Image updated copy")
        static let BlockedTitle: String = NSLocalizedString("Blocked", comment: "blocked settings item")
        static let MutedTitle: String = NSLocalizedString("Muted", comment: "muted settings item")
        static let DeleteAccountTitle: String = NSLocalizedString("Account Deletion", comment: "account deletion settings button")
        static let DeleteAccount: String = NSLocalizedString("Delete Account", comment: "account deletion label")
        static let DeleteAccountExplanation: String = NSLocalizedString("By deleting your account you remove your personal information from Ello. Your account cannot be restored.", comment: "By deleting your account you remove your personal information from Ello. Your account cannot be restored.")
        static let DeleteAccountConfirm: String = NSLocalizedString("Delete Account?", comment: "delete account question")
        static let AccountIsBeingDeleted: String = NSLocalizedString("Your account is in the process of being deleted.", comment: "Your account is in the process of being deleted.")
        static let RedirectedCountdownTemplate: String = NSLocalizedString("You will be redirected in %d...", comment: "You will be redirected in ...")
    }

    public struct Profile {
        static let Title: String = NSLocalizedString("Profile", comment: "Profile Title")
        static let Mention: String = NSLocalizedString("@ Mention", comment: "Mention button title")
        static let Hire: String = NSLocalizedString("Hire", comment: "Hire button title")
        static let Invite: String = NSLocalizedString("Invite", comment: "Invite button title")
        static let EditProfile: String = NSLocalizedString("Edit Profile", comment: "Edit Profile button title")
        static let PostsCount: String = NSLocalizedString("Posts", comment: "Posts count header")
        static let FollowingCount: String = NSLocalizedString("Following", comment: "Following count header")
        static let LovesCount: String = NSLocalizedString("Loves", comment: "Loves count header")
        static let FollowersCount: String = NSLocalizedString("Followers", comment: "Followers count header")
        static let CurrentUserNoResultsTitle: String = NSLocalizedString("Welcome to your Profile", comment: "")
        static let CurrentUserNoResultsBody: String = NSLocalizedString("Everything you post lives here!\n\nThis is the place to find everyone you’re following and everyone that’s following you. You’ll find your Loves here too!", comment: "")
        static let NoResultsTitle: String = NSLocalizedString("This person hasn't posted yet.", comment: "")
        static let NoResultsBody: String = NSLocalizedString("Follow or mention them to help them get started!", comment: "")
    }

    public struct Post {
        static let DefaultTitle: String = NSLocalizedString("Post Detail", comment: "Default post title")
        static let LovedByList: String = NSLocalizedString("Loved by", comment: "Loved by list title")
        static let RepostedByList: String = NSLocalizedString("Reposted by", comment: "Reposted by list title")

        static let Edit: String = NSLocalizedString("Edit", comment: "Edit Post Button Title")
        static let Delete: String = NSLocalizedString("Delete", comment: "Delete Post Button Title")
        static let DeletePostConfirm: String = NSLocalizedString("Delete Post?", comment: "Delete Post confirmation")
        static let DeleteCommentConfirm: String = NSLocalizedString("Delete Comment?", comment: "Delete Comment confirmation")
        static let RepostConfirm: String = NSLocalizedString("Repost?", comment: "Repost confirmation")
        static let RepostSuccess: String = NSLocalizedString("Success!", comment: "Successful repost alert")
        static let RepostError: String = NSLocalizedString("Could not create repost", comment: "Could not create repost message")
        static let CannotEditPost: String = NSLocalizedString("Looks like this post was created on the web!\n\nThe videos and embedded content it contains are not YET editable on our iOS app.  We’ll add this feature soon!", comment: "Uneditable post error message")
        static let CannotEditComment: String = NSLocalizedString("Looks like this comment was created on the web!\n\nThe videos and embedded content it contains are not YET editable on our iOS app.  We’ll add this feature soon!", comment: "Uneditable comment error message")
    }

    public struct Omnibar {
        static let SayEllo: String = NSLocalizedString("Say Ello...", comment: "Say Ello prompt")
        static let AddMoreText: String = NSLocalizedString("Add more text...", comment: "Add more text prompt")
        static let EnterURL: String = NSLocalizedString("Enter the URL", comment: "Enter the URL")
        static let CreatePostTitle: String = NSLocalizedString("Post", comment: "Create a post")
        static let CreatePostButton: String = NSLocalizedString("Post", comment: "Post")
        static let EditPostTitle: String = NSLocalizedString("Edit this post", comment: "Edit this post")
        static let EditPostButton: String = NSLocalizedString("Edit Post", comment: "Edit Post")
        static let EditCommentTitle: String = NSLocalizedString("Edit this comment", comment: "Edit this comment")
        static let EditCommentButton: String = NSLocalizedString("Edit Comment", comment: "Edit Comment")
        static let CreateCommentTitle: String = NSLocalizedString("Leave a comment", comment: "Leave a comment")
        static let CreateCommentButton: String = NSLocalizedString("Comment", comment: "Comment")
        static let TooLongError: String = NSLocalizedString("Your text is too long.\n\nThe character limit is 5,000.", comment: "Post too long (maximum characters is 5000) error message")
        static let CreatedPost: String = NSLocalizedString("Post successfully created!", comment: "Post successfully created!")
        static let SellYourWorkTitle: String = NSLocalizedString("Sell your work", comment: "Sell your work title")
        static let ProductLinkPlaceholder: String = NSLocalizedString("Product detail URL", comment: "Product detail URL prompt")
    }

    public struct Hire {
        static let Send: String = NSLocalizedString("Send", comment: "Send Button title")
    }

    public struct Loves {
        static let CurrentUserNoResultsTitle: String = NSLocalizedString("You haven't Loved any posts yet!", comment: "Current user no loves results title")
        static let CurrentUserNoResultsBody: String = NSLocalizedString("You can use Ello Loves as a way to bookmark the things you care about most. Go Love someone's post, and it will be added to this stream.", comment: "Current user no loves results body.")
        static let NoResultsTitle: String = NSLocalizedString("This person hasn’t Loved any posts yet!", comment: "Non-current user no loves results title")
        static let NoResultsBody: String = NSLocalizedString("Ello Loves are a way to bookmark the things you care about most. When they love something the posts will appear here.", comment: "Non-current user no loves results body.")
        static let Title: String = NSLocalizedString("Loves", comment: "love stream")
    }

    public struct Relationship {
        static let Follow: String = NSLocalizedString("Follow", comment: "Follow relationship")
        static let Following: String = NSLocalizedString("Following", comment: "Following relationship")
        static let Starred: String = NSLocalizedString("Starred", comment: "Starred relationship")
        static let Muted: String = NSLocalizedString("Muted", comment: "Muted relationship")
        static let Blocked: String = NSLocalizedString("Blocked", comment: "Blocked relationship")

        static let MuteButton: String = NSLocalizedString("Mute", comment: "Mute button title")
        static let BlockButton: String = NSLocalizedString("Block", comment: "Block button title")
        static let FlagButton: String = NSLocalizedString("Flag", comment: "Flag button title")
        static let BlockedNoResultsTitle: String = NSLocalizedString("You haven't blocked any users", comment: "Current user no blocked results title")
        static let BlockedNoResultsBody = ""
        static let MutedNoResultsTitle: String = NSLocalizedString("You haven't muted any users", comment: "Current user no muted results title")
        static let MutedNoResultsBody = ""

        static let UnmuteAlertTemplate: String = NSLocalizedString("Would you like to \nunmute or block %@?", comment: "alert prompt before unmuting or blocking")
        static let BlockAlertTemplate: String = NSLocalizedString("Would you like to \nmute or unblock %@?", comment: "alert prompt before muting or unblocking")
        static let MuteAlertTemplate: String = NSLocalizedString("Would you like to \nmute or block %@?", comment: "alert prompt before muting or blocking")
        static let MuteWarningTemplate: String = NSLocalizedString("%@ will not be able to comment on your posts. If %@ mentions you, you will not be notified.", comment: "muting explanation")
        static let BlockWarningTemplate: String = NSLocalizedString("%@ will not be able to follow you or view your profile, posts or find you in search.", comment: "muting explanation")
        static let FlagWarningTemplate: String = NSLocalizedString("%@ will be investigated by our staff.", comment: "flagging explanation")
    }

    public struct PushNotifications {
        static let PermissionPrompt: String = NSLocalizedString("Ello would like to send you push notifications.\n\nWe will let you know when you have new notifications. You can makes changes in your settings.\n", comment: "Turn on Push Notifications prompt")
        static let PermissionYes: String = NSLocalizedString("Yes please", comment: "Allow")
        static let PermissionNo: String = NSLocalizedString("No thanks", comment: "Disallow")
    }

    public struct Friends {
        static let ImportPermissionPrompt: String = NSLocalizedString("Import your contacts to invite cool people to Ello.\n\nEllo does not sell user data, and never contacts anyone without your permission.", comment: "Use address book permission prompt")
        static let ImportAllow: String = NSLocalizedString("Import my contacts", comment: "Import my contacts action")
        static let ImportNotNow: String = NSLocalizedString("Not now", comment: "Not now action")

        static let ImportErrorTemplate: String = NSLocalizedString("We were unable to access your address book\n%@", comment: "Unable to access address book and error message")
        static let AccessDenied: String = NSLocalizedString("Access to your contacts has been denied.  If you want to search for friends, you will need to grant access from Settings.", comment: "Access to contacts denied by user")
        static let AccessRestricted: String = NSLocalizedString("Access to your contacts has been denied by the system.", comment: "Access to contacts denied by system")

        static let FindAndInvite: String = NSLocalizedString("Find & invite your contacts", comment: "Find & invite")
        static let SearchPrompt: String = NSLocalizedString("Name or email", comment: "Find friends prompt")

        static let Resend: String = NSLocalizedString("Re-send", comment: "invite friends cell re-send")
        static let Invite: String = NSLocalizedString("Invite", comment: "invite friends cell invite")
    }

    public struct NSFW {
        static let Show: String = NSLocalizedString("Tap to View.", comment: "Tap to View.")
        static let Hide: String = NSLocalizedString("Tap to Hide.", comment: "Tap to Hide.")
    }

    public struct ImagePicker {
        static let ChooseSource: String = NSLocalizedString("Choose a photo source", comment: "choose photo source (camera or library)")
        static let Camera: String = NSLocalizedString("Camera", comment: "camera button")
        static let Library: String = NSLocalizedString("Library", comment: "library button")
        static let NoSourceAvailable: String = NSLocalizedString("Sorry, but your device doesn’t have a photo library!", comment: "device doesn't support photo library")
        static let TakePhoto: String = NSLocalizedString("Take Photo Or Video", comment: "Camera button")
        static let PhotoLibrary: String = NSLocalizedString("Photo Library", comment: "Library button")
        static let AddImagesTemplate: String = NSLocalizedString("Add %lu Image(s)", comment: "Add Images")
        static let ChooseImage: String = NSLocalizedString("Choose Image", comment: "Choose Image")
    }

    public struct WebBrowser {
        static let TermsAndConditions: String = NSLocalizedString("Terms and Conditions", comment: "terms and conditions title")
    }

    public struct Startup {
        static let SignUp: String = NSLocalizedString("Sign Up", comment: "sign up button")
        static let Login: String = NSLocalizedString("Login", comment: "login button")
    }

    public struct Login {
        static let Continue: String = NSLocalizedString("Continue", comment: "continue button")
        static let LoadUserError: String = NSLocalizedString("Unable to load user.", comment: "Unable to load user message")
        static let ForgotPassword: String = NSLocalizedString("Forgot Password", comment: "forgot password title")
        static let UsernamePlaceholder: String = NSLocalizedString("Username or Email", comment: "username or email field")
        static let PasswordPlaceholder: String = NSLocalizedString("Password", comment: "password field")
    }

    public struct Join {
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

    public struct Validator {
        static let EmailRequired: String = NSLocalizedString("Email is required.", comment: "email is required message")
        static let UsernameRequired: String = NSLocalizedString("Username is required.", comment: "username is required message")
        static let PasswordRequired: String = NSLocalizedString("Password is required.", comment: "password is required message")

        static let SignInInvalid: String = NSLocalizedString("Invalid email or username", comment: "Invalid email or username message")
        static let CredentialsInvalid: String = NSLocalizedString("Invalid credentials", comment: "Invalid credentials message")
        static let EmailInvalid: String = NSLocalizedString("That email is invalid.\nPlease try again.", comment: "invalid email message")
        static let UsernameInvalid: String = NSLocalizedString("That username is invalid.\nPlease try again.", comment: "invalid username message")
        static let PasswordInvalid: String = NSLocalizedString("Password must be at least 8\ncharacters long.", comment: "password length error message")
    }

    public struct Rate {
        static let Title: String = NSLocalizedString("Love Ello?", comment: "rate app prompt title")
        static let Continue: String = NSLocalizedString("Rate us: ⭐️⭐️⭐️⭐️⭐️", comment: "rate app button title")
        static let Cancel: String = NSLocalizedString("No Thanks", comment: "do not rate app button title")
    }

    public struct Onboard {
        static let PickCategoriesPrimary: String = NSLocalizedString("Pick what you’re into.", comment: "pick what you're into")
        static let PickCategoriesSecondary: String = NSLocalizedString("Slow down & check out some cool ass shit.", comment: "slow down & check out some cool ass shit")
        static let CreateProfilePrimary: String = NSLocalizedString("Grow your creative influence.", comment: "grow your creative influence")
        static let CreateProfileSecondary: String = NSLocalizedString("Completed profiles get way more views.", comment: "completed profiles get way more views")

        static let InviteFriendsPrimary: String = NSLocalizedString("Invite some cool people.", comment: "invite some cool people")
        static let InviteFriendsSecondary: String = NSLocalizedString("Make Ello better.", comment: "make ello better")

        static let CreateProfile: String = NSLocalizedString("Create Your Profile", comment: "create your profile button")
        static let InvitePeople: String = NSLocalizedString("Invite Cool People", comment: "invite cool people button")
        static let ImDone: String = NSLocalizedString("I’m done", comment: "I'm done button")
        static let PickTemplate: String = NSLocalizedString("Pick %d", comment: "Pick ... prompt")

        static let UploadCoverButton: String = NSLocalizedString("Upload Header", comment: "Upload Header button")
        static let UploadCoverImagePrompt: String = NSLocalizedString("2560 x 1440\nAnimated Gifs work, too", comment: "Cover Image size and animated Gifs work, too")
        static let UploadAvatarButton: String = NSLocalizedString("Upload Avatar", comment: "Upload Avatar button")
        static let UploadAvatarPrompt: String = NSLocalizedString("360 x 360\nAnimated Gifs work, too", comment: "Avatar size and animated Gifs work, too")
        static let NamePlaceholder: String = NSLocalizedString("Name", comment: "Name field")
        static let BioPlaceholder: String = NSLocalizedString("Bio", comment: "Bio field")
        static let LinksPlaceholder: String = NSLocalizedString("Links", comment: "Links field")

        static let Search: String = NSLocalizedString("Name or email", comment: "Name or email search field")

        static let UploadFailed: String = NSLocalizedString("Oh no! Something went wrong.\n\nTry that again maybe?", comment: "image upload failed during onboarding message")
        static let RelationshipFailed: String = NSLocalizedString("Oh no! Something went wrong.\n\nTry that again maybe?", comment: "relationship status update failed during onboarding message")
    }

    public struct Share {
        static let FailedToPost: String = NSLocalizedString("Uh oh, failed to post to Ello.", comment: "Failed to post to Ello")
        static let PleaseLogin: String = NSLocalizedString("Please login to the Ello app first to use this feature.", comment: "Not logged in message.")
    }

    public struct App {
        static let OpenInSafari: String = NSLocalizedString("Open in Safari", comment: "Open in Safari")
        static let LoggedOut: String = NSLocalizedString("You have been automatically logged out", comment: "Automatically logged out message")
        static let LoginAndView: String = NSLocalizedString("Login and view", comment: "Login and view prompt")
        static let OldVersion: String = NSLocalizedString("The version of the app you’re using is too old, and is no longer compatible with our API.\n\nPlease update the app to the latest version, using the “Updates” tab in the App Store.", comment: "App out of date message")
        static let LoggedOutError: String = NSLocalizedString("You must be logged in", comment: "You must be logged in")
    }

    public struct Error {
        static let JPEGCompress: String = NSLocalizedString("Could not compress image as JPEG", comment: "Could not compress image as JPEG")
    }

    static let GenericError: String = NSLocalizedString("Something went wrong. Thank you for your patience with Ello Beta!", comment: "Generic error message")
    static let UnknownError: String = NSLocalizedString("Unknown error", comment: "Unknown error message")

    static let Ello: String = NSLocalizedString("Ello", comment: "Ello")
    static let OK: String = NSLocalizedString("OK", comment: "OK")
    static let Yes: String = NSLocalizedString("Yes", comment: "Yes")
    static let No: String = NSLocalizedString("No", comment: "No")
    static let Cancel: String = NSLocalizedString("Cancel", comment: "Cancel")
    static let Submit: String = NSLocalizedString("Submit", comment: "Submit")
    static let Retry: String = NSLocalizedString("Retry", comment: "Retry")
    static let AreYouSure: String = NSLocalizedString("Are You Sure?", comment: "are you sure question")
    static let ThatIsOK: String = NSLocalizedString("It’s OK, I understand!", comment: "It’s OK, I understand!")
    static let Delete: String = NSLocalizedString("Delete", comment: "Delete")
    static let Remove: String = NSLocalizedString("Remove", comment: "Remove")
    static let Next: String = NSLocalizedString("Next", comment: "Next button")
    static let Done: String = NSLocalizedString("Done", comment: "Done button title")
    static let Skip: String = NSLocalizedString("Skip", comment: "Skip action")
    static let SeeAll: String = NSLocalizedString("See All", comment: "See All title")
}
