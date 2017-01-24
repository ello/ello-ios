////
///  ElloProvider_Specs.swift
//

import Moya


struct ElloProvider_Specs {
    static var errorStatusCode: ErrorStatusCode = .status404

    static func errorEndpointsClosure(_ target: ElloAPI) -> Endpoint<ElloAPI> {
        let sampleResponseClosure = { () -> EndpointSampleResponse in
            return .networkResponse(ElloProvider_Specs.errorStatusCode.rawValue, ElloProvider_Specs.errorStatusCode.defaultData)
        }

        let method = target.method
        let parameters = target.parameters
        let endpoint = Endpoint<ElloAPI>(url: url(target), sampleResponseClosure: sampleResponseClosure, method: method, parameters: parameters)
        return endpoint.adding(newHTTPHeaderFields: target.headers())
    }

    static func recordedEndpointsClosure(_ recordings: [RecordedResponse]) -> (_ target: ElloAPI) -> Endpoint<ElloAPI> {
        var playback = recordings
        return { (target: ElloAPI) -> Endpoint<ElloAPI> in
            var responseClosure: ((_ target: ElloAPI) -> EndpointSampleResponse)? = nil
            for (index, recording) in playback.enumerated() {
                if recording.endpoint.description == target.description {
                    responseClosure = recording.responseClosure
                    playback.remove(at: index)
                    break
                }
            }

            let sampleResponseClosure: () -> EndpointSampleResponse
            if let responseClosure = responseClosure {
                sampleResponseClosure = {
                    return responseClosure(target)
                }
            }
            else {
                sampleResponseClosure = {
                    return EndpointSampleResponse.networkResponse(200, target.sampleData)
                }
            }

            let method = target.method
            let parameters = target.parameters
            let endpoint = Endpoint<ElloAPI>(url: url(target), sampleResponseClosure: sampleResponseClosure, method: method, parameters: parameters)
            return endpoint.adding(newHTTPHeaderFields: target.headers())
        }
    }

}


extension ElloProvider {

    static func StubbingProvider() -> MoyaProvider<ElloAPI> {
        return MoyaProvider<ElloAPI>(endpointClosure: ElloProvider.endpointClosure, stubClosure: MoyaProvider.immediatelyStub)
    }

    static func DelayedStubbingProvider() -> MoyaProvider<ElloAPI> {
        return MoyaProvider<ElloAPI>(endpointClosure: ElloProvider.endpointClosure, stubClosure: MoyaProvider.delayedStub(1))
    }

    static func ErrorStubbingProvider() -> MoyaProvider<ElloAPI> {
        return MoyaProvider<ElloAPI>(endpointClosure: ElloProvider_Specs.errorEndpointsClosure, stubClosure: MoyaProvider.immediatelyStub)
    }

    static func RecordedStubbingProvider(_ recordings: [RecordedResponse]) -> MoyaProvider<ElloAPI> {
        return MoyaProvider<ElloAPI>(endpointClosure: ElloProvider_Specs.recordedEndpointsClosure(recordings), stubClosure: MoyaProvider.immediatelyStub)
    }

}
