//
//  ElloS3
//  Ello
//
//  Created by Colin Gray on 3/3/2015.
//  Copyright (c) 2015 Ello. All rights reserved.
//
// creds = AmazonCredentials(...)
// data = NSData()
// uploader = ElloS3(credentials: credentials, data: data)
//   .onSuccess() { (response : NSData) in }
//   .onFailure() { (error : NSError) in }
//   // NOT yet supported:
//   //.onProgress() { (progress : Float) in }
//   .start()

import Foundation


class ElloS3 {
    let filename: String
    let data: Data
    let contentType: String
    let credentials: AmazonCredentials

    typealias SuccessHandler = (Data) -> Void
    typealias FailureHandler = (Error) -> Void
    typealias ProgressHandler = (Float) -> Void

    fileprivate var successHandler: SuccessHandler?
    fileprivate var failureHandler: FailureHandler?
    fileprivate var progressHandler: ProgressHandler?

    init(credentials: AmazonCredentials, filename: String, data: Data, contentType: String) {
        self.filename = filename
        self.data = data
        self.contentType = contentType
        self.credentials = credentials
    }

    func onSuccess(_ handler: @escaping SuccessHandler) -> Self {
        self.successHandler = handler
        return self
    }

    func onFailure(_ handler: @escaping FailureHandler) -> Self {
        self.failureHandler = handler
        return self
    }

    func onProgress(_ handler: @escaping ProgressHandler) -> Self {
        self.progressHandler = handler
        return self
    }

    // this is just the uploading code, the initialization and handler code is
    // mostly the same
    func start() -> Self {
        let key = "\(credentials.prefix)/\(filename)"
        let url = URL(string: credentials.endpoint)!

        let builder = MultipartRequestBuilder(url: url, capacity: data.count)
        builder.addParam("key", value: key)
        builder.addParam("AWSAccessKeyId", value: credentials.accessKey)
        builder.addParam("acl", value: "public-read")
        builder.addParam("success_action_status", value: "201")
        builder.addParam("policy", value: credentials.policy)
        builder.addParam("signature", value: credentials.signature)
        builder.addParam("Content-Type", value: self.contentType)
        // builder.addParam("Content-MD5", value: md5(data))
        builder.addFile("file", filename: filename, data: data, contentType: contentType)
        let request = builder.buildRequest()

        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) in
            nextTick {
                let httpResponse = response as? HTTPURLResponse
                if let error = error {
                    self.failureHandler?(error)
                }
                else if let statusCode = httpResponse?.statusCode,
                    statusCode >= 200 && statusCode < 300
                {
                    if let data = data {
                        self.successHandler?(data)
                    }
                    else {
                        self.failureHandler?(NSError(domain: ElloErrorDomain, code: 0, userInfo: [NSLocalizedFailureReasonErrorKey: "failure"]))
                    }
                }
                else {
                    self.failureHandler?(NSError(domain: ElloErrorDomain, code: 0, userInfo: [NSLocalizedFailureReasonErrorKey: "failure"]))
                }
            }
        })
        task.resume()

        return self
    }

}
