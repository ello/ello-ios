////
///  ShareCryptoStringExtensions.swift
//

extension String {

    // no need to include common crypto in
    // an app extension so we return an
    // unmodified string in ShareExtension
    var saltedSHA1String: String? {
        return self
    }

    var SHA1String: String? {
        return self
    }
}
