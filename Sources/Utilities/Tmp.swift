////
///  Tmp.swift
//

public struct Tmp {
    public static let uniqDir = Tmp.uniqueName()

    public static func fileExists(fileName: String) -> Bool {
        if let fileURL = self.fileURL(fileName),
            filePath = fileURL.path
        {
            return NSFileManager.defaultManager().fileExistsAtPath(filePath)
        }
        else {
            return false
        }
    }

    public static func directoryURL() -> NSURL? {
        if let pathURL = NSURL(string: NSTemporaryDirectory()),
            directoryName = pathURL.URLByAppendingPathComponent(Tmp.uniqDir)?.absoluteString
        {
            return NSURL.fileURLWithPath(directoryName, isDirectory: true)
        }
        return nil
    }

    public static func fileURL(fileName: String) -> NSURL? {
        if let directoryURL = directoryURL() {
            return directoryURL.URLByAppendingPathComponent(fileName)
        }
        return nil
    }

    static func uniqueName() -> String {
        return NSProcessInfo.processInfo().globallyUniqueString
    }

    public static func write(toDataable: ToNSData, to fileName: String) -> NSURL? {
        if let data = toDataable.toNSData() {
            if let directoryURL = self.directoryURL() {
                do {
                    try NSFileManager.defaultManager().createDirectoryAtURL(directoryURL, withIntermediateDirectories: true, attributes: nil)

                    if let fileURL = self.fileURL(fileName) {
                        data.writeToURL(fileURL, atomically: true)
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

    public static func read(fileName: String) -> NSData? {
        if fileExists(fileName) {
            if let fileURL = fileURL(fileName) {
                return NSData(contentsOfURL: fileURL)
            }
        }
        return nil
    }

    public static func read(fileName: String) -> String? {
        if let data: NSData = read(fileName) {
            return NSString(data: data, encoding: NSUTF8StringEncoding) as? String
        }
        return nil
    }

    public static func read(fileName: String) -> UIImage? {
        if let data: NSData = read(fileName) {
            return UIImage(data: data)
        }
        return nil
    }

    public static func remove(fileName: String) -> Bool {
        let fileURL = self.fileURL(fileName)
        if let filePath = fileURL?.path {
            if NSFileManager.defaultManager().fileExistsAtPath(filePath) {
                do {
                    try NSFileManager.defaultManager().removeItemAtPath(filePath)
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
