////
///  S3UploadingService.swift
//

import Moya
import Foundation
import UIKit

class S3UploadingService {
    typealias S3UploadSuccessCompletion = (URL?) -> Void

    var uploader: ElloS3?

    func upload(imageRegionData image: ImageRegionData, success: @escaping S3UploadSuccessCompletion, failure: @escaping ElloFailureCompletion) {
        if let data = image.data, let contentType = image.contentType {
            upload(data as Data, contentType: contentType, success: success, failure: failure)
        }
        else {
            upload(image.image, success: success, failure: failure)
        }
    }

    func upload(_ image: UIImage, success: @escaping S3UploadSuccessCompletion, failure: @escaping ElloFailureCompletion) {
        inBackground {
            if let data = UIImageJPEGRepresentation(image, 0.8) {
                // Head back to the thread the original caller was on before heading into the service calls. I may be overthinking it.
                nextTick {
                    self.upload(data, contentType: "image/jpeg", success: success, failure: failure)
                }
            }
            else {
                let error = NSError(domain: ElloErrorDomain, code: 500, userInfo: [NSLocalizedFailureReasonErrorKey: InterfaceString.Error.JPEGCompress])
                failure(error, nil)
            }
        }
    }

    func upload(_ data: Data, contentType: String, success: @escaping S3UploadSuccessCompletion, failure: @escaping ElloFailureCompletion) {
        let filename: String
        switch contentType {
        case "image/gif":
            filename = "\(UUID().uuidString).gif"
        case "image/png":
            filename = "\(UUID().uuidString).png"
        default:
            filename = "\(UUID().uuidString).jpg"
        }

        ElloProvider.shared.elloRequest(ElloAPI.amazonCredentials,
            success: { credentialsData, responseConfig in
                if let credentials = credentialsData as? AmazonCredentials {
                    self.uploader = ElloS3(credentials: credentials, filename: filename, data: data, contentType: contentType)
                        .onSuccess({ (data: Data) in
                            let endpoint: String = credentials.endpoint
                            let prefix: String = credentials.prefix
                            success(URL(string: "\(endpoint)/\(prefix)/\(filename)"))
                        })
                        .onFailure({ (error: Swift.Error) in
                            failure(error as NSError, nil) // FIXME - is this the correct usage of Error?
                        })
                        .start()
                }
                else {
                    ElloProvider.unCastableJSONAble(failure)
                }
            },
            failure: failure
        )
    }
}
