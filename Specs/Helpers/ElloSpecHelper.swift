////
///  ElloSpecHelpers.swift
//

@testable import Ello
import Quick
import Nimble_Snapshots
import PromiseKit


// Add in custom configuration
class ElloConfiguration: QuickConfiguration {
    override class func configure(_ config: Configuration) {
        config.beforeSuite {
            // make sure the promise `then` blocks are run synchronously
            DispatchQueue.default = zalgo
            if ( DispatchQueue.default != zalgo ) {
                fatalError(
                    "Aww dang, somehow PromiseKit's `DispatchQueue.default` was " +
                    "accessed before `zalgo` could be assigned. Add a break point to " +
                    "PromiseKit/CorePromise/GlobalState.m, inside dispatch_queue_t PMKDefaultDispatchQueue() " +
                    "to find out where this is being set"
                    )
            }

            ElloLinkedStore.databaseName = "ello_test.sqlite"
            BadgesService.badges = [
                "featured": Badge(slug: "featured", name: "Featured", link: "Learn More", url: nil, imageURL: nil),
                "community": Badge(slug: "community", name: "Community", link: "Learn More", url: nil, imageURL: nil),
                "experimental": Badge(slug: "experimental", name: "Experimental", link: "Learn More", url: nil, imageURL: nil),
                "staff": Badge(slug: "staff", name: "Staff", link: "Meet our team", url: nil, imageURL: nil),
                "spam": Badge(slug: "spam", name: "Spam", link: "Learn More", url: nil, imageURL: nil),
                "nsfw": Badge(slug: "nsfw", name: "Nsfw", link: "Learn More", url: nil, imageURL: nil),
            ]
        }
        config.beforeEach {
            let keychain = FakeKeychain()
            keychain.username = "email"
            keychain.password = "password"
            keychain.authToken = "abcde"
            keychain.authTokenExpires = Date().addingTimeInterval(3600)
            keychain.authTokenType = "grant"
            keychain.refreshAuthToken = "abcde"
            keychain.isPasswordBased = true
            AuthToken.sharedKeychain = keychain

            ElloProvider.shared.authState = .authenticated
            ElloProvider.shared.queue = nil
            ElloProvider.sharedProvider = ElloProvider.StubbingProvider()
        }
        config.afterEach {
            ElloProvider_Specs.errorStatusCode = .status404
            let window = UIWindow()
            window.rootViewController = UIViewController()
            window.makeKeyAndVisible()

            ElloLinkedStore.sharedInstance.writeConnection.readWrite { transaction in
                transaction.removeAllObjectsInAllCollections()
            }
        }
        config.afterSuite {
            AuthToken.sharedKeychain = ElloKeychain()
            ElloProvider.sharedProvider = ElloProvider.DefaultProvider()
        }
    }
}

func specImage(named name: String) -> UIImage? {
    return UIImage(named: name, in: Bundle(for: ElloConfiguration.self), compatibleWith: nil)!
}

func stubbedJSONData(_ file: String, _ propertyName: String) -> ([String: Any]) {
    let loadedData: Data = stubbedData(file)
    let json: Any = try! JSONSerialization.jsonObject(with: loadedData, options: [])

    var castJSON = json as! [String: Any]
    let parsedProperty = castJSON[propertyName] as! [String:Any]
    if let linkedJSON = castJSON["linked"] as? [String:[[String:Any]]] {
        ElloLinkedStore.sharedInstance.parseLinked(linkedJSON, completion: {})
    }

    return parsedProperty
}

func stubbedJSONDataArray(_ file: String, _ propertyName: String) -> [[String: Any]] {
    let loadedData: Data = stubbedData(file)
    let json: Any = try! JSONSerialization.jsonObject(with: loadedData, options: [])

    var castJSON:[String:Any] = json as! [String: Any]
    let parsedProperty = castJSON[propertyName] as! [[String:Any]]
    if let linkedJSON = castJSON["linked"] as? [String:[[String:Any]]] {
        ElloLinkedStore.sharedInstance.parseLinked(linkedJSON, completion: {})
    }

    return parsedProperty
}
