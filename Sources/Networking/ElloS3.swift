////
///  ElloS3.swift
//
// creds = AmazonCredentials(...)
// data = NSData()
// uploader = ElloS3(credentials: credentials, data: data)
//   .start()
//   .then { response -> Void in }
//   .catch { error in }

import PromiseKit


class ElloS3 {
    let filename: String
    let data: Data
    let contentType: String
    let credentials: AmazonCredentials
    let (promise, resolve, reject) = Promise<Data>.pending()

    init(credentials: AmazonCredentials, filename: String, data: Data, contentType: String) {
        self.filename = filename
        self.data = data
        self.contentType = contentType
        self.credentials = credentials
    }

    // this is just the uploading code, the initialization and handler code is
    // mostly the same
    func start() -> Promise<Data> {
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
                    self.reject(error)
                }
                else if let statusCode = httpResponse?.statusCode,
                    statusCode >= 200 && statusCode < 300
                {
                    if let data = data {
                        self.resolve(data)
                    }
                    else {
                        self.reject(NSError(domain: ElloErrorDomain, code: 0, userInfo: [NSLocalizedFailureReasonErrorKey: "failure"]))
                    }
                }
                else {
                    self.reject(NSError(domain: ElloErrorDomain, code: 0, userInfo: [NSLocalizedFailureReasonErrorKey: "failure"]))
                }
            }
        })
        task.resume()

        return promise
    }

}
