////
///  StubbedManager.swift
//

@testable import Ello


class StubbedManager: Ello.RequestManager {
    static var current: StubbedManager!

    typealias RequestStub = (URLRequest) -> Data
    typealias Stub = (URLRequest, RequestSender) -> Data?
    var stubs: [Stub] = []

    init() {
        StubbedManager.current = self
    }

    func addStub(endpointName: String, stub stubFile: String? = nil) {
        addStub { request, sender in
            guard sender.endpointDescription == endpointName else { return nil }
            return stubbedData(stubFile ?? endpointName)
        }
    }

    func addStub(_ stub: @escaping Stub) {
        stubs.append(stub)
    }

    func request(_ request: URLRequest, sender: RequestSender, _ handler: @escaping RequestHandler)
        -> RequestTask
    {
        var newStubs: [Stub] = []
        var matchingData: Data?
        for stub in stubs {
            if matchingData == nil, let data = stub(request, sender) {
                matchingData = data
            }
            else {
                newStubs.append(stub)
            }

        }
        stubs = newStubs

        return StubbedTask(request: request, data: matchingData ?? Data(), handler: handler)
    }
}

struct StubbedTask: Ello.RequestTask {
    let request: URLRequest
    let data: Data
    let handler: RequestHandler

    func resume() {
        let httpResponse = HTTPURLResponse(
            url: request.url!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )

        let response = StubbedResponse(
            request: request,
            response: httpResponse,
            data: data,
            error: nil
        )
        self.handler(response)
    }
}

struct StubbedResponse: Ello.Response {
    let request: URLRequest?
    let response: HTTPURLResponse?
    let data: Data?
    let error: Error?
}
