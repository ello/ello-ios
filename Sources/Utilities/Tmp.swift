////
///  Tmp.swift
//

struct Tmp {
    static let uniqDir = Tmp.uniqueName()

    static func fileExists(_ fileName: String) -> Bool {
        if let fileURL = self.fileURL(fileName) {
            let filePath = fileURL.path
            return FileManager.default.fileExists(atPath: filePath)
        }
        else {
            return false
        }
    }

    static func directoryURL() -> URL? {
        if let pathURL = URL(string: NSTemporaryDirectory()) {
            let directoryName = pathURL.appendingPathComponent(Tmp.uniqDir).absoluteString
            return URL(fileURLWithPath: directoryName, isDirectory: true)
        }
        return nil
    }

    static func fileURL(_ fileName: String) -> URL? {
        if let directoryURL = directoryURL() {
            return directoryURL.appendingPathComponent(fileName)
        }
        return nil
    }

    static func uniqueName() -> String {
        return ProcessInfo.processInfo.globallyUniqueString
    }

    static func write(_ toDataable: ToData, to fileName: String) -> URL? {
        if let data = toDataable.toData() {
            if let directoryURL = self.directoryURL() {
                do {
                    try FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true, attributes: nil)

                    if let fileURL = self.fileURL(fileName) {
                        try? data.write(to: fileURL, options: [.atomic])
                        return fileURL
                    }
                }
                catch {
                    return nil
                }
            }
        }
        return nil
    }

    static func read(_ fileName: String) -> Data? {
        if fileExists(fileName) {
            if let fileURL = fileURL(fileName) {
                return (try? Data(contentsOf: fileURL))
            }
        }
        return nil
    }

    static func read(_ fileName: String) -> String? {
        if let data: Data = read(fileName) {
            return NSString(data: data, encoding: String.Encoding.utf8.rawValue) as? String
        }
        return nil
    }

    static func read(_ fileName: String) -> UIImage? {
        if let data: Data = read(fileName) {
            return UIImage(data: data)
        }
        return nil
    }

    static func remove(_ fileName: String) -> Bool {
        let fileURL = self.fileURL(fileName)
        if let filePath = fileURL?.path {
            if FileManager.default.fileExists(atPath: filePath) {
                do {
                    try FileManager.default.removeItem(atPath: filePath)
                    return true
                }
                catch {
                    return false
                }
            }
        }
        return false
    }
}
