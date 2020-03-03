////
///  Tmp.swift
//

struct Tmp {
    static let uniqDir = Tmp.uniqueName()

    static func clear() {
        try? FileManager.default.removeItem(atPath: NSTemporaryDirectory())
    }

    static func fileExists(_ fileName: String) -> Bool {
        guard let fileURL = self.fileURL(fileName) else { return false }
        return FileManager.default.fileExists(atPath: fileURL.path)
    }

    static func directoryURL() -> URL? {
        guard let pathURL = URL(string: NSTemporaryDirectory()) else { return nil }
        let directoryName = pathURL.appendingPathComponent(Tmp.uniqDir).absoluteString
        return URL(fileURLWithPath: directoryName, isDirectory: true)
    }

    static func fileURL(_ fileName: String) -> URL? {
        guard let directoryURL = directoryURL() else { return nil }
        return directoryURL.appendingPathComponent(fileName)
    }

    static func uniqueName() -> String {
        return ProcessInfo.processInfo.globallyUniqueString
    }

    static func write(_ toDataable: ToData, to fileName: String) -> URL? {
        guard
            let data = toDataable.toData(),
            let directoryURL = self.directoryURL()
        else { return nil }

        do {
            try FileManager.default.createDirectory(
                at: directoryURL,
                withIntermediateDirectories: true,
                attributes: nil
            )

            if let fileURL = self.fileURL(fileName) {
                try? data.write(to: fileURL, options: [.atomic])
                return fileURL
            }
            return nil
        }
        catch {
            return nil
        }
    }

    static func read(_ fileName: String) -> Data? {
        guard
            fileExists(fileName),
            let fileURL = fileURL(fileName)
        else { return nil }
        return (try? Data(contentsOf: fileURL))
    }

    static func read(_ fileName: String) -> String? {
        guard
            let data:Data = read(fileName),
            let string = String(data: data, encoding: .utf8)
        else { return nil }
        return string
    }

    static func read(_ fileName: String) -> UIImage? {
        if let data:Data = read(fileName) {
            return UIImage(data: data)
        }
        return nil
    }

    static func remove(_ fileName: String) -> Bool {
        guard
            let filePath = fileURL(fileName)?.path,
            FileManager.default.fileExists(atPath: filePath)
        else { return false }

        do {
            try FileManager.default.removeItem(atPath: filePath)
            return true
        }
        catch {
            return false
        }
    }
}

extension Tmp {
    static func sizeDiagnostics() -> (String, Int) {
        let paths = [
            ElloLinkedStore.databaseFolder(),
            FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.path,
            FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first?
                .path,
            FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first?.path,
            URL(string: NSTemporaryDirectory())?.path,
        ].compactMap { path -> Path? in path.map { Path($0) } }

        var text = ""
        var totalSize = 0
        for path in paths {
            guard let (desc, size) = sizeOf(path) else { continue }
            totalSize += size
            if !text.isEmpty {
                text += "------------------------------\n"
            }
            text += "---- \(path.abbreviate()) ----\n"
            text += "\(desc)\n"
        }

        text += "---- TOTAL ----\n"
        text += "\(totalSize.numberToHuman())\n"

        return (text, totalSize)
    }

    private static func sizeOf(_ path: Path, prefix: String? = nil, isLast: Bool = true) -> (
        String, Int
    )? {
        guard
            let fileDictionary = try? FileManager.default.attributesOfItem(atPath: path.path),
            var size = fileDictionary[.size] as? Int
        else { return nil }

        if let children = try? path.children() {
            let myPrefix = (prefix.map { $0 + (isLast ? "`--/" : "+--/") }) ?? ""
            let childPrefix = (prefix.map { $0 + (isLast ? "   " : "|  ") } ?? "")
            var childrenDesc = ""
            for child in children {
                guard
                    let (childDesc, childSize) = sizeOf(
                        child,
                        prefix: childPrefix,
                        isLast: child == children.last
                    )
                else { continue }
                childrenDesc += childDesc
                size += childSize
            }
            return (
                "\(myPrefix)\(path.lastComponent) \(size.numberToHuman())\n" + childrenDesc, size
            )
        }
        else {
            return ("", size)
        }
    }


}
