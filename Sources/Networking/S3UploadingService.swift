////
///  S3UploadingService.swift
//

import PromiseKit


class S3UploadingService {
    var uploader: ElloS3?
    let endpoint: ElloAPI

    enum Error: Swift.Error {
        case badData
    }

    init(endpoint: ElloAPI = .amazonCredentials) {
        self.endpoint = endpoint
    }

    func upload(imageRegionData image: ImageRegionData) -> Promise<URL?> {
        if let data = image.data, let contentType = image.contentType {
            return upload(data, contentType: contentType)
        }
        else {
            return upload(image.image)
        }
    }

    func upload(_ image: UIImage) -> Promise<URL?> {
        let (promise, seal) = Promise<URL?>.pending()
        inBackground {
            if let data = image.jpegData(compressionQuality: Globals.imageQuality) {
                // Head back to the thread the original caller was on before heading into the service calls. I may be overthinking it.
                nextTick {
                    self.upload(data, contentType: "image/jpeg").done(seal.fulfill).catch(
                        seal.reject
                    )
                }
            }
            else {
                let error = NSError(
                    domain: ElloErrorDomain,
                    code: 500,
                    userInfo: [NSLocalizedFailureReasonErrorKey: InterfaceString.Error.JPEGCompress]
                )
                seal.reject(error)
            }
        }
        return promise
    }

    func upload(_ text: String, filename: String) -> Promise<URL?> {
        guard let data = text.data(using: .utf8) else {
            return Promise<URL?>(error: Error.badData)
        }

        return upload(data, contentType: "text/plain", filename: filename)
    }

    func upload(_ data: Data, contentType: String, filename overrideFilename: String? = nil)
        -> Promise<URL?>
    {
        return ElloProvider.shared.request(endpoint)
            .then { (jsonable, _) -> Promise<URL?> in
                guard let credentials = jsonable as? AmazonCredentials else {
                    throw NSError.uncastableModel()
                }

                let filename: String
                if let overrideFilename = overrideFilename {
                    filename = overrideFilename
                }
                else {
                    switch contentType {
                    case "image/gif":
                        filename = "\(UUID().uuidString).gif"
                    case "image/png":
                        filename = "\(UUID().uuidString).png"
                    case "text/plain":
                        filename = "\(UUID().uuidString).txt"
                    default:
                        filename = "\(UUID().uuidString).jpg"
                    }
                }

                return ElloS3(
                    credentials: credentials,
                    filename: filename,
                    data: data,
                    contentType: contentType
                )
                    .start()
                    .map { data -> URL? in
                        let endpoint: String = credentials.endpoint
                        let prefix: String = credentials.prefix
                        return URL(string: "\(endpoint)/\(prefix)/\(filename)")
                    }
            }
    }
}
