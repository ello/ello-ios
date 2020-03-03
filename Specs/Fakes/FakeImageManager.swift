////
///  FakeImageManager.swift
//

import PINRemoteImage

class FakeImageManager: PINRemoteImageManager {

    var downloads = [URL]()

    func reset() {
        downloads = [URL]()
    }

    override func prefetchImage(with url: URL, options: PINRemoteImageManagerDownloadOptions = [])
        -> UUID?
    {
        downloads.append(url)
        return nil
    }

}
