////
///  StubbedManager.swift
//

@testable import Ello

class StubbedManager: Ello.RequestManager {
    static var current: StubbedManager!

    typealias Stub = (URLRequest, Any) -> Data?
    var stubs: [Stub] = []

    init() {
        StubbedManager.current = self
    }

    func addStub(_ stub: @escaping Stub) {
        stubs.append(stub)
    }

    func request(_ request: URLRequest, sender: Any, _ handler: @escaping RequestHandler) -> RequestTask {
        var newStubs: [Stub] = []
        var matchingData: Data?
        for stub in stubs {
            if matchingData == nil, let task = stub(request, sender) {
                matchingData = task
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
            headerFields: nil)

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
