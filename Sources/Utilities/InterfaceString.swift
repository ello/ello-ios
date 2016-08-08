////
///  InterfaceString.swift
//

import Foundation


public struct InterfaceString {

    public struct Tab {
        public struct PopupTitle {
            static let Discover = NSLocalizedString("Discover", comment: "Discover pop up title")
            static let Notifications = NSLocalizedString("Notifications", comment: "Notifications pop up title")
            static let Stream = NSLocalizedString("Streams", comment: "Stream pop up title")
            static let Profile = NSLocalizedString("Your Profile", comment: "Profile pop up title")
            static let Omnibar = NSLocalizedString("Post (Omnibar)", comment: "Omnibar pop up title")
        }

        public struct PopupText {
            static let Discover = NSLocalizedString("Explore creators, curated categories & communities", comment: "Discover pop up text")
            static let Notifications = NSLocalizedString("Keep it fresh with real-time alerts.", comment: "Notifications pop up text")
            static let Stream = NSLocalizedString("Two streams: Following & Starred.\nUse them however you like.", comment: "Stream pop up text")
            static let Profile = NSLocalizedString("Everything you create in one place.\nSettings too.", comment: "Profile pop up text")
            static let Omnibar = NSLocalizedString("Share text, links, images, GIFs and more.", comment: "Omnibar pop up text")
        }
    }

    public struct Followers {
        static let CurrentUserNoResultsTitle = NSLocalizedString("You don't have any followers yet!", comment: "Current user no followers results title")
        static let CurrentUserNoResultsBody = NSLocalizedString("Here's some tips on how to get new followers: use Discover to find people you're interested in, and to find or invite your contacts. When you see things you like you can comment, repost, mention people and love the posts that you most enjoy. ", comment: "Current user no followers results body.")
        static let NoResultsTitle = NSLocalizedString("This person doesn't have any followers yet! ", comment: "Non-current user followers no results title")
        static let NoResultsBody = NSLocalizedString("Be the first to follow them and give them some love! Following interesting people makes Ello way more fun.", comment: "Non-current user following no results body")
        static let Title = NSLocalizedString("Followers", comment: "Followers title")
    }

    public struct Following {
        static let Title = NSLocalizedString("Following", comment: "Following title")
        static let CurrentUserNoResultsTitle = NSLocalizedString("You aren't following anyone yet!", comment: "Current user no following results title")
        static let CurrentUserNoResultsBody = NSLocalizedString("Ello is way more rad when you're following lots of people.\n\nUse Discover to find people you're interested in, and to find or invite your contacts.\nYou can also use Search (upper right) to look for new and excellent people!", comment: "Current user No following results body.")
        static let NoResultsTitle = NSLocalizedString("This person isn't following anyone yet!", comment: "Non-current user followoing no results title")
        static let NoResultsBody = NSLocalizedString("Follow, mention them, comment, repost or love one of their posts and maybe they'll follow you back ;)", comment: "Non-current user following no results body")
    }

    public struct FollowingStream {
        static let Title = NSLocalizedString("Following", comment: "Following title")
        static let NoResultsTitle = NSLocalizedString("Welcome to Following!", comment: "No following results title")
        static let NoResultsBody = NSLocalizedString("Follow people and things that inspire you.", comment: "No following results body.")
    }

    public struct StarredStream {
        static let Title = NSLocalizedString("Starred", comment: "Starred title")
        static let NoResultsTitle = NSLocalizedString("Welcome to Starred!", comment: "No starred results title")
        static let NoResultsBody = NSLocalizedString("When you Star someone their posts appear here. Star people to create a second stream.", comment: "No following results body.")
    }

    public struct Notifications {
        static let Title = NSLocalizedString("Notifications", comment: "Notifications title")
        static let Reply = NSLocalizedString("Reply", comment: "Reply button title")
        static let NoResultsTitle = NSLocalizedString("Welcome to your Notifications Center!", comment: "No notification results title")
        static let NoResultsBody = NSLocalizedString("Whenever someone mentions you, follows you, accepts an invitation, comments, reposts or Loves one of your posts, you'll be notified here.", comment: "No notification results body.")
    }

    public struct Discover {
        static let Title = NSLocalizedString("Discover", comment: "Discover title")
        static let MoreCategories = NSLocalizedString("Categories", comment: "All Categories title")
        static let AllCategories = NSLocalizedString("All", comment: "All Categories title")
        static let Featured = NSLocalizedString("Featured", comment: "Discover tab titled Featured")
        static let Trending = NSLocalizedString("Trending", comment: "Discover tab titled Trending")
        static let Recent = NSLocalizedString("Recent", comment: "Discover tab titled Recent")
    }

    public struct Conversations {
        static let Title = NSLocalizedString("Conversations", comment: "Conversations title")
    }

    public struct CreateConversation {
        static let Title = NSLocalizedString("New Message", comment: "Create Conversation title")
    }

    public struct Search {
        static let Title = NSLocalizedString("Search", comment: "Search title")
        static let Prompt = NSLocalizedString("Search Ello", comment: "search ello prompt")
        static let Posts = NSLocalizedString("Posts", comment: "Posts search toggle")
        static let People = NSLocalizedString("People", comment: "People search toggle")
        static let FindFriendsPrompt = NSLocalizedString("Help grow the Ello community.\nShare the experience.", comment: "Search zero state button title")
        static let NoMatches = NSLocalizedString("We couldn't find any matches.", comment: "No search results found title")
        static let TryAgain = NSLocalizedString("Try another search?", comment: "No search results found body")
    }

    public struct Drawer {
        static let Store = NSLocalizedString("Store", comment: "Store")
        static let Invite = NSLocalizedString("Invite", comment: "Invite")
        static let Help = NSLocalizedString("Help", comment: "Help")
        static let Resources = NSLocalizedString("Resources", comment: "Resources")
        static let About = NSLocalizedString("About", comment: "About")
        static let Logout = NSLocalizedString("Logout", comment: "Logout")
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
        static let EditProfile = NSLocalizedString("Edit Profile", comment: "Edit Profile Title")
        static let Name = NSLocalizedString("Name", comment: "name setting")
        static let Links = NSLocalizedString("Links", comment: "links setting")
        static let AvatarUploaded = NSLocalizedString("You’ve updated your Avatar.\n\nIt may take a few minutes for your new avatar/header to appear on Ello, so please be patient. It’ll be live soon!", comment: "Avatar updated copy")
        static let CoverImageUploaded = NSLocalizedString("You’ve updated your Header.\n\nIt may take a few minutes for your new avatar/header to appear on Ello, so please be patient. It’ll be live soon!", comment: "Cover Image updated copy")
        static let BlockedTitle = NSLocalizedString("Blocked", comment: "blocked settings item")
        static let MutedTitle = NSLocalizedString("Muted", comment: "muted settings item")
        static let DeleteAccountTitle = NSLocalizedString("Account Deletion", comment: "account deletion settings button")
        static let DeleteAccount = NSLocalizedString("Delete Account", comment: "account deletion label")
        static let DeleteAccountExplanation = NSLocalizedString("By deleting your account you remove your personal information from Ello. Your account cannot be restored.", comment: "By deleting your account you remove your personal information from Ello. Your account cannot be restored.")
        static let DeleteAccountConfirm = NSLocalizedString("Delete Account?", comment: "delete account question")
        static let AccountIsBeingDeleted = NSLocalizedString("Your account is in the process of being deleted.", comment: "Your account is in the process of being deleted.")
        static let RedirectedCountdownTemplate = NSLocalizedString("You will be redirected in %d...", comment: "You will be redirected in ...")
    }

    public struct Profile {
        static let Title = NSLocalizedString("Profile", comment: "Profile Title")
        static let Mention = NSLocalizedString("@ Mention", comment: "Mention button title")
        static let EditProfile = NSLocalizedString("Edit Profile", comment: "Edit Profile button title")
        static let PostsCount = NSLocalizedString("Posts", comment: "Posts count header")
        static let FollowingCount = NSLocalizedString("Following", comment: "Following count header")
        static let LovesCount = NSLocalizedString("Loves", comment: "Loves count header")
        static let FollowersCount = NSLocalizedString("Followers", comment: "Followers count header")
        static let CurrentUserNoResultsTitle = NSLocalizedString("Welcome to your Profile", comment: "")
        static let CurrentUserNoResultsBody = NSLocalizedString("Everything you post lives here!\n\nThis is the place to find everyone you’re following and everyone that’s following you. You’ll find your Loves here too!", comment: "")
        static let NoResultsTitle = NSLocalizedString("Ello is more fun with friends!", comment: "")
        static let NoResultsBody = NSLocalizedString("This person hasn't posted yet.\n\nFollow or mention them to help them get started!", comment: "")
    }

    public struct Post {
        static let DefaultTitle = NSLocalizedString("Post Detail", comment: "Default post title")
        static let LovedByList = NSLocalizedString("Loved by", comment: "Loved by list title")
        static let RepostedByList = NSLocalizedString("Reposted by", comment: "Reposted by list title")

        static let Edit = NSLocalizedString("Edit", comment: "Edit Post Button Title")
        static let Delete = NSLocalizedString("Delete", comment: "Delete Post Button Title")
        static let DeletePostConfirm = NSLocalizedString("Delete Post?", comment: "Delete Post confirmation")
        static let DeleteCommentConfirm = NSLocalizedString("Delete Comment?", comment: "Delete Comment confirmation")
        static let RepostConfirm = NSLocalizedString("Repost?", comment: "Repost confirmation")
        static let RepostSuccess = NSLocalizedString("Success!", comment: "Successful repost alert")
        static let RepostError = NSLocalizedString("Could not create repost", comment: "Could not create repost message")
        static let CannotEditPost = NSLocalizedString("Looks like this post was created on the web!\n\nThe videos and embedded content it contains are not YET editable on our iOS app.  We’ll add this feature soon!", comment: "Uneditable post error message")
        static let CannotEditComment = NSLocalizedString("Looks like this comment was created on the web!\n\nThe videos and embedded content it contains are not YET editable on our iOS app.  We’ll add this feature soon!", comment: "Uneditable comment error message")
    }

    public struct Omnibar {
        static let EnterURL = NSLocalizedString("Enter the URL", comment: "Enter the URL")
        static let CreatePostTitle = NSLocalizedString("Post", comment: "Create a post")
        static let CreatePostButton = NSLocalizedString("Post", comment: "Post")
        static let EditPostTitle = NSLocalizedString("Edit this post", comment: "Edit this post")
        static let EditPostButton = NSLocalizedString("Edit Post", comment: "Edit Post")
        static let EditCommentTitle = NSLocalizedString("Edit this comment", comment: "Edit this comment")
        static let EditCommentButton = NSLocalizedString("Edit Comment", comment: "Edit Comment")
        static let CreateCommentTitle = NSLocalizedString("Leave a comment", comment: "Leave a comment")
        static let CreateCommentButton = NSLocalizedString("Comment", comment: "Comment")
        static let TooLongError = NSLocalizedString("Your text is too long.\n\nThe character limit is 5,000.", comment: "Post too long (maximum characters is 5000) error message")
        static let CreatedPost = NSLocalizedString("Post successfully created!", comment: "Post successfully created!")
    }

    public struct Loves {
        static let CurrentUserNoResultsTitle = NSLocalizedString("You haven't Loved any posts yet!", comment: "Current user no loves results title")
        static let CurrentUserNoResultsBody = NSLocalizedString("You can use Ello Loves as a way to bookmark the things you care about most. Go Love someone's post, and it will be added to this stream.", comment: "Current user no loves results body.")
        static let NoResultsTitle = NSLocalizedString("This person hasn’t Loved any posts yet!", comment: "Non-current user no loves results title")
        static let NoResultsBody = NSLocalizedString("Ello Loves are a way to bookmark the things you care about most. When they love something the posts will appear here.", comment: "Non-current user no loves results body.")
        static let Title = NSLocalizedString("Loves", comment: "love stream")
    }

    public struct Relationship {
        static let Follow = NSLocalizedString("Follow", comment: "Follow relationship")
        static let Following = NSLocalizedString("Following", comment: "Following relationship")
        static let Starred = NSLocalizedString("Starred", comment: "Starred relationship")
        static let Muted = NSLocalizedString("Muted", comment: "Muted relationship")
        static let Blocked = NSLocalizedString("Blocked", comment: "Blocked relationship")

        static let MuteButton = NSLocalizedString("Mute", comment: "Mute button title")
        static let BlockButton = NSLocalizedString("Block", comment: "Block button title")
        static let FlagButton = NSLocalizedString("Flag", comment: "Flag button title")
        static let BlockedNoResultsTitle = NSLocalizedString("You haven't blocked any users", comment: "Current user no blocked results title")
        static let BlockedNoResultsBody = ""
        static let MutedNoResultsTitle = NSLocalizedString("You haven't muted any users", comment: "Current user no muted results title")
        static let MutedNoResultsBody = ""

        static let UnmuteAlertTemplate = NSLocalizedString("Would you like to \nunmute or block %@?", comment: "alert prompt before unmuting or blocking")
        static let BlockAlertTemplate = NSLocalizedString("Would you like to \nmute or unblock %@?", comment: "alert prompt before muting or unblocking")
        static let MuteAlertTemplate = NSLocalizedString("Would you like to \nmute or block %@?", comment: "alert prompt before muting or blocking")
        static let MuteWarningTemplate = NSLocalizedString("%@ will not be able to comment on your posts. If %@ mentions you, you will not be notified.", comment: "muting explanation")
        static let BlockWarningTemplate = NSLocalizedString("%@ will not be able to follow you or view your profile, posts or find you in search.", comment: "muting explanation")
        static let FlagWarningTemplate = NSLocalizedString("%@ will be investigated by our staff.", comment: "flagging explanation")
    }

    public struct PushNotifications {
        static let PermissionPrompt = NSLocalizedString("Ello would like to send you push notifications.\n\nWe will let you know when you have new notifications. You can makes changes in your settings.\n", comment: "Turn on Push Notifications prompt")
        static let PermissionYes = NSLocalizedString("Yes please", comment: "Allow")
        static let PermissionNo = NSLocalizedString("No thanks", comment: "Disallow")
    }

    public struct Friends {
        static let ImportPermissionPrompt = NSLocalizedString("Find your friends on Ello using your contacts.\n\nEllo does not sell user data, and never contacts anyone without your permission.", comment: "Use address book permission prompt")
        static let ImportAllow = NSLocalizedString("Find my friends", comment: "Find my friends action")
        static let ImportNotNow = NSLocalizedString("Not now", comment: "Not now action")
        static let ImportErrorTemplate = NSLocalizedString("We were unable to access your address book\n%@", comment: "Unable to access address book and error message")
        static let AccessDenied = NSLocalizedString("Access to your contacts has been denied.  If you want to search for friends, you will need to grant access from Settings.", comment: "Access to contacts denied by user")
        static let AccessRestricted = NSLocalizedString("Access to your contacts has been denied by the system.", comment: "Access to contacts denied by system")

        static let FindAndInvite = NSLocalizedString("Find & invite your contacts", comment: "Find & invite")
        static let SearchPrompt = NSLocalizedString("Name or email", comment: "Find friends prompt")

        static let Resend = NSLocalizedString("Re-send", comment: "invite friends cell re-send")
        static let Invite = NSLocalizedString("Invite", comment: "invite friends cell invite")
    }

    public struct NSFW {
        static let Show = NSLocalizedString("Tap to View.", comment: "Tap to View.")
        static let Hide = NSLocalizedString("Tap to Hide.", comment: "Tap to Hide.")
    }

    public struct ImagePicker {
        static let ChooseSource = NSLocalizedString("Choose a photo source", comment: "choose photo source (camera or library)")
        static let Camera = NSLocalizedString("Camera", comment: "camera button")
        static let Library = NSLocalizedString("Library", comment: "library button")
        static let NoSourceAvailable = NSLocalizedString("Sorry, but your device doesn’t have a photo library!", comment: "device doesn't support photo library")
        static let TakePhoto = NSLocalizedString("Take Photo Or Video", comment: "Camera button")
        static let PhotoLibrary = NSLocalizedString("Photo Library", comment: "Library button")
        static let AddImagesTemplate = NSLocalizedString("Add %lu Image(s)", comment: "Add Images")
    }

    public struct WebBrowser {
        static let TermsAndConditions = NSLocalizedString("Terms and Conditions", comment: "terms and conditions title")
    }

    public struct SignIn {
        static let EmailInvalid = NSLocalizedString("Invalid email or username", comment: "Invalid email or username message")
        static let PasswordInvalid = NSLocalizedString("Invalid password", comment: "Invalid password message")
        static let CredentialsInvalid = NSLocalizedString("Invalid credentials", comment: "Invalid credentials message")
        static let LoadUserError = NSLocalizedString("Unable to load user.", comment: "Unable to load user message")
        static let ForgotPassword = NSLocalizedString("Forgot Password", comment: "forgot password title")
    }

    public struct Join {
        static let SignInAfterJoinError = NSLocalizedString("Your account has been created, but there was an error logging in, please try again", comment: "After successfully joining, there was an error signing in")
        static let Email = NSLocalizedString("Email", comment: "email key")
        static let EmailRequired = NSLocalizedString("Email is required.", comment: "email is required message")
        static let EmailInvalid = NSLocalizedString("That email is invalid.\nPlease try again.", comment: "invalid email message")
        static let Username = NSLocalizedString("Username", comment: "username key")
        static let UsernameRequired = NSLocalizedString("Username is required.", comment: "username is required message")
        static let UsernameUnavailable = NSLocalizedString("Username already exists.\nPlease try a new one.", comment: "username exists error message")
        static let UsernameSuggestionTemplate = NSLocalizedString("Here are some available usernames -\n%@", comment: "username suggestions showmes")
        static let Password = NSLocalizedString("Password", comment: "password key")
        static let PasswordInvalid = NSLocalizedString("Password must be at least 8\ncharacters long.", comment: "password length error message")
    }

    public struct Rate {
        static let Title = NSLocalizedString("Love Ello?", comment: "rate app prompt title")
        static let Continue = NSLocalizedString("Rate us: ⭐️⭐️⭐️⭐️⭐️", comment: "rate app button title")
        static let Cancel = NSLocalizedString("No Thanks", comment: "do not rate app button title")
    }

    public struct Onboard {
        static let PickAnotherImage = NSLocalizedString("Pick Another", comment: "Pick another button")
        static let UploadFailed = NSLocalizedString("Oh no! Something went wrong.\n\nTry that again maybe?", comment: "image upload failed during onboarding message")
        static let RelationshipFailed = NSLocalizedString("Oh no! Something went wrong.\n\nTry that again maybe?", comment: "relationship status update failed during onboarding message")

        public struct Community {
            static let Title = NSLocalizedString("Creative communities.", comment: "Community Selection Header text")
            static let Description = NSLocalizedString("Follow the communities that interest you.", comment: "Community Selection Body text")
        }
        public struct AwesomePeople {
            static let Title = NSLocalizedString("Talented creators.", comment: "Creators Selection Header text")
            static let Description = NSLocalizedString("Follow some of Ello’s top creators.", comment: "Creators Selection Body text")
        }
        public struct FindYourFriends {
            static let Title = NSLocalizedString("Connect with your contacts.", comment: "Find Friends Header text")
            static let Description = NSLocalizedString("See who’s on Ello.", comment: "Find Friends Body text")
            static let NoResultsTitle = NSLocalizedString("Find your friends!", comment: "Import friends no results title")
            static let NoResultsBody = NSLocalizedString("Thanks. We didn’t find any of your friends.\n\nWhen your friends join Ello you’ll be able to find and invite them on the Discover and Search screen.", comment: "Import friends no results body.")
        }
        public struct Avatar {
            static let Button = NSLocalizedString("Select your profile avatar", comment: "Choose avatar button")
        }
        public struct CoverImage {
            static let Button = NSLocalizedString("Select your header image", comment: "Choose header image button")
            static let Title = NSLocalizedString("Create your profile.", comment: "Header Image Selection text")
            static let Description = NSLocalizedString("Make it rad.", comment: "Header Image Selection text")
        }
        public struct Profile {
            static let Name = NSLocalizedString("Name (optional)", comment: "Name (optional) placeholder text")
            static let Bio = NSLocalizedString("Bio (optional)", comment: "Bio (optional) placeholder text")
            static let Links = NSLocalizedString("Links (optional)", comment: "Links (optional) placeholder text")
            static let LinksFailed = NSLocalizedString("Something is wrong with those links.\n\nThey need to start with ‘http://’ or ‘https://’", comment: "Updating Links failed during onboarding message")
        }
    }

    public struct Share {
        static let FailedToPost = NSLocalizedString("Uh oh, failed to post to Ello.", comment: "Failed to post to Ello")
        static let PleaseLogin = NSLocalizedString("Please login to the Ello app first to use this feature.", comment: "Not logged in message.")
    }

    public struct App {
        static let OpenInSafari = NSLocalizedString("Open in Safari", comment: "Open in Safari")
        static let LoggedOut = NSLocalizedString("You have been automatically logged out", comment: "Automatically logged out message")
        static let LoginAndView = NSLocalizedString("Login and view", comment: "Login and view prompt")
        static let OldVersion = NSLocalizedString("The version of the app you’re using is too old, and is no longer compatible with our API.\n\nPlease update the app to the latest version, using the “Updates” tab in the App Store.", comment: "App out of date message")
        static let LoggedOutError = NSLocalizedString("You must be logged in", comment: "You must be logged in")
    }

    static let GenericError = NSLocalizedString("Something went wrong. Thank you for your patience with Ello Beta!", comment: "Generic error message")
    static let UnknownError = NSLocalizedString("Unknown error", comment: "Unknown error message")

    static let Yes = NSLocalizedString("Yes", comment: "Yes")
    static let No = NSLocalizedString("No", comment: "No")
    static let Cancel = NSLocalizedString("Cancel", comment: "Cancel")
    static let Retry = NSLocalizedString("Retry", comment: "Retry")
    static let AreYouSure = NSLocalizedString("Are You Sure?", comment: "are you sure question")
    static let OK = NSLocalizedString("OK", comment: "OK")
    static let ThatIsOK = NSLocalizedString("It’s OK, I understand!", comment: "It’s OK, I understand!")
    static let Delete = NSLocalizedString("Delete", comment: "Delete")
    static let Next = NSLocalizedString("Next", comment: "Next button")
    static let Done = NSLocalizedString("Done", comment: "Done button title")
    static let Skip = NSLocalizedString("Skip", comment: "Skip action")
    static let SeeAll = NSLocalizedString("See All", comment: "See All title")
}
