////
///  CryptoStringExtensions.swift
//

import Foundation
import Keys


extension String {

    var saltedSHA1String: String? {
        let sodiumChloride: String = ElloKeys().sodiumChloride()
        return (sodiumChloride + self).SHA1String
    }

    var SHA1String: String? {
        if let data = self.data(using: String.Encoding.utf8, allowLossyConversion: false) {

            var digest = [UInt8](repeating: 0, count: Int(CC_SHA1_DIGEST_LENGTH))
            CC_SHA1((data as NSData).bytes, CC_LONG(data.count), &digest)
            let output = NSMutableString(capacity: Int(CC_SHA512_DIGEST_LENGTH))
            for byte in digest {
                output.appendFormat("%02x", byte)
            }

            return output as String
        }
        return .none
    }

}
