////
///  ElloSpecHelpers.swift
//

@testable import Ello
import Quick
import Nimble_Snapshots

// Add in custom configuration
class ElloConfiguration: QuickConfiguration {
    override class func configure(_ config: Configuration) {
        config.beforeSuite {
            setNimbleTolerance(0.001)
            ElloLinkedStore.databaseName = "ello_test.sqlite"
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

            ElloLinkedStore.sharedInstance.writeConnection.readWrite { transaction in
                transaction.removeAllObjectsInAllCollections()
            }
        }
        config.afterEach {
            ElloProvider_Specs.errorStatusCode = .status404
            let window = UIWindow()
            window.rootViewController = UIViewController()
            window.makeKeyAndVisible()
        }
        config.afterSuite {
            AuthToken.sharedKeychain = ElloKeychain()
            ElloLinkedStore.sharedInstance.writeConnection.readWrite { transaction in
                transaction.removeAllObjectsInAllCollections()
            }
            ElloProvider.sharedProvider = ElloProvider.DefaultProvider()
        }
    }
}

func specImage(named name: String) -> UIImage? {
    return UIImage(named: name, in: Bundle(for: ElloConfiguration.self), compatibleWith: nil)!
}

func stubbedJSONData(_ file: String, _ propertyName: String) -> ([String: AnyObject]) {
    let loadedData: Data = stubbedData(file)
    let json: AnyObject = try! JSONSerialization.jsonObject(with: loadedData, options: []) as AnyObject

    var castJSON = json as! [String: AnyObject]
    let parsedProperty = castJSON[propertyName] as! [String:AnyObject]
    if let linkedJSON = castJSON["linked"] as? [String:[[String:AnyObject]]] {
        ElloLinkedStore.sharedInstance.parseLinked(linkedJSON, completion: {})
    }

    return parsedProperty
}

func stubbedJSONDataArray(_ file: String, _ propertyName: String) -> [[String: AnyObject]] {
    let loadedData: Data = stubbedData(file)
    let json: AnyObject = try! JSONSerialization.jsonObject(with: loadedData, options: []) as AnyObject

    var castJSON:[String:AnyObject] = json as! [String: AnyObject]
    let parsedProperty = castJSON[propertyName] as! [[String:AnyObject]]
    if let linkedJSON = castJSON["linked"] as? [String:[[String:AnyObject]]] {
        ElloLinkedStore.sharedInstance.parseLinked(linkedJSON, completion: {})
    }

    return parsedProperty
}
