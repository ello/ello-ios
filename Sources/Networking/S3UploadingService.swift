////
///  S3UploadingService.swift
//

import PromiseKit


class S3UploadingService {
    typealias S3UploadSuccessCompletion = (URL?) -> Void

    var uploader: ElloS3?

    func upload(imageRegionData image: ImageRegionData) -> Promise<URL?> {
        if let data = image.data, let contentType = image.contentType {
            return upload(data as Data, contentType: contentType)
        }
        else {
            return upload(image.image)
        }
    }

    func upload(_ image: UIImage) -> Promise<URL?> {
        let (promise, fulfill, reject) = Promise<URL?>.pending()
        inBackground {
            if let data = UIImageJPEGRepresentation(image, AppSetup.sharedState.imageQuality) {
                // Head back to the thread the original caller was on before heading into the service calls. I may be overthinking it.
                nextTick {
                    self.upload(data, contentType: "image/jpeg").then(execute: fulfill).catch(execute: reject)
                }
            }
            else {
                let error = NSError(domain: ElloErrorDomain, code: 500, userInfo: [NSLocalizedFailureReasonErrorKey: InterfaceString.Error.JPEGCompress])
                reject(error)
            }
        }
        return promise
    }

    func upload(_ data: Data, contentType: String) -> Promise<URL?> {
        let filename: String
        switch contentType {
        case "image/gif":
            filename = "\(UUID().uuidString).gif"
        case "image/png":
            filename = "\(UUID().uuidString).png"
        default:
            filename = "\(UUID().uuidString).jpg"
        }

        return ElloProvider.shared.request(ElloAPI.amazonCredentials)
            .then { response -> Promise<URL?> in
                guard let credentials = response.0 as? AmazonCredentials else {
                    throw NSError.uncastableJSONAble()
                }

                return ElloS3(credentials: credentials, filename: filename, data: data, contentType: contentType)
                    .start()
                    .then { data -> URL? in
                        let endpoint: String = credentials.endpoint
                        let prefix: String = credentials.prefix
                        return URL(string: "\(endpoint)/\(prefix)/\(filename)")
                    }
            }
    }
}
