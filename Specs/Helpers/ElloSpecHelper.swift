////
///  ElloSpecHelpers.swift
//

@testable
import Ello
import Quick
import OHHTTPStubs
import Nimble_Snapshots

// Add in custom configuration
class ElloConfiguration: QuickConfiguration {
    override class func configure(config: Configuration) {
        config.beforeSuite {
            setNimbleTolerance(0.001)
            ElloLinkedStore.databaseName = "ello_test.sqlite"
        }
        config.beforeEach {
            let keychain = FakeKeychain()
            keychain.username = "email"
            keychain.password = "password"
            keychain.authToken = "abcde"
            keychain.authTokenExpires = NSDate().dateByAddingTimeInterval(3600)
            keychain.authTokenType = "grant"
            keychain.refreshAuthToken = "abcde"
            keychain.isPasswordBased = true
            AuthToken.sharedKeychain = keychain

            ElloProvider.shared.authState = .Authenticated
            ElloProvider.shared.queue = nil
            ElloProvider.sharedProvider = ElloProvider.StubbingProvider()

            ElloLinkedStore.sharedInstance.writeConnection.readWriteWithBlock { transaction in
                transaction.removeAllObjectsInAllCollections()
            }
        }
        config.afterEach {
            ElloProvider_Specs.errorStatusCode = .Status404
            let window = UIWindow()
            window.rootViewController = UIViewController()
            window.makeKeyAndVisible()
        }
        config.afterSuite {
            AuthToken.sharedKeychain = ElloKeychain()
            ElloLinkedStore.sharedInstance.writeConnection.readWriteWithBlock { transaction in
                transaction.removeAllObjectsInAllCollections()
            }
            ElloProvider.sharedProvider = ElloProvider.DefaultProvider()
        }
    }
}

func specImage(named name: String) -> UIImage? {
    return UIImage(named: name, inBundle: NSBundle(forClass: ElloConfiguration.self), compatibleWithTraitCollection: nil)!
}

func stubbedJSONData(file: String, _ propertyName: String) -> ([String:AnyObject]) {
    let loadedData:NSData = stubbedData(file)
    let json: AnyObject = try! NSJSONSerialization.JSONObjectWithData(loadedData, options: [])

    var castJSON = json as! [String: AnyObject]
    let parsedProperty = castJSON[propertyName] as! [String:AnyObject]
    if let linkedJSON = castJSON["linked"] as? [String:[[String:AnyObject]]] {
        ElloLinkedStore.sharedInstance.parseLinked(linkedJSON, completion: {})
    }

    return parsedProperty
}

func stubbedJSONDataArray(file: String, _ propertyName: String) -> [[String:AnyObject]] {
    let loadedData:NSData = stubbedData(file)
    let json: AnyObject = try! NSJSONSerialization.JSONObjectWithData(loadedData, options: [])

    var castJSON:[String:AnyObject] = json as! [String: AnyObject]
    let parsedProperty = castJSON[propertyName] as! [[String:AnyObject]]
    if let linkedJSON = castJSON["linked"] as? [String:[[String:AnyObject]]] {
        ElloLinkedStore.sharedInstance.parseLinked(linkedJSON, completion: {})
    }

    return parsedProperty
}

func supressRequestsTo(domain: String) {
    OHHTTPStubs.stubRequestsPassingTest({$0.URL!.host == domain}) { _ in
        return OHHTTPStubsResponse(data: NSData(),
            statusCode: 200, headers: ["Content-Type":"image/gif"])
    }
}
