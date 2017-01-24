////
///  ToData.swift
//

protocol ToData {
    func toData() -> Data?
}


extension Data : ToData {
    func toData() -> Data? {
        return self
    }
}


extension String : ToData {
    func toData() -> Data? {
        return self.data(using: String.Encoding.utf8)
    }
}


extension UIImage : ToData {
    func toData() -> Data? {
        return UIImagePNGRepresentation(self)
    }
}
