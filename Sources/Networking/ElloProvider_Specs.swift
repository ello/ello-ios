////
///  ElloProvider_Specs.swift
//

import Moya

public struct RecordedResponse {
    let endpoint: ElloAPI
    let responseClosure: (target: ElloAPI) -> EndpointSampleResponse

    public init(endpoint: ElloAPI, responseClosure: (target: ElloAPI) -> EndpointSampleResponse) {
        self.endpoint = endpoint
        self.responseClosure = responseClosure
    }

    public init(endpoint: ElloAPI, response: EndpointSampleResponse) {
        self.endpoint = endpoint
        self.responseClosure = { _ in return response }
    }

}


public struct ElloProvider_Specs {
    public static var errorStatusCode: ErrorStatusCode = .Status404

    static func errorEndpointsClosure(target: ElloAPI) -> Endpoint<ElloAPI> {
        let sampleResponseClosure = { () -> EndpointSampleResponse in
            return .NetworkResponse(ElloProvider_Specs.errorStatusCode.rawValue, ElloProvider_Specs.errorStatusCode.defaultData)
        }

        let method = target.method
        let parameters = target.parameters
        let endpoint = Endpoint<ElloAPI>(URL: url(target), sampleResponseClosure: sampleResponseClosure, method: method, parameters: parameters)
        return endpoint.endpointByAddingHTTPHeaderFields(target.headers())
    }

    static func recordedEndpointsClosure(recordings: [RecordedResponse]) -> (target: ElloAPI) -> Endpoint<ElloAPI> {
        var playback = recordings
        return { (target: ElloAPI) -> Endpoint<ElloAPI> in
            var responseClosure: ((target: ElloAPI) -> EndpointSampleResponse)? = nil
            for (index, recording) in playback.enumerate() {
                if recording.endpoint.description == target.description {
                    responseClosure = recording.responseClosure
                    playback.removeAtIndex(index)
                    break
                }
            }

            let sampleResponseClosure: () -> EndpointSampleResponse
            if let responseClosure = responseClosure {
                sampleResponseClosure = {
                    return responseClosure(target: target)
                }
            }
            else {
                sampleResponseClosure = {
                    return EndpointSampleResponse.NetworkResponse(200, target.sampleData)
                }
            }

            let method = target.method
            let parameters = target.parameters
            let endpoint = Endpoint<ElloAPI>(URL: url(target), sampleResponseClosure: sampleResponseClosure, method: method, parameters: parameters)
            return endpoint.endpointByAddingHTTPHeaderFields(target.headers())
        }
    }

}


extension ElloProvider {

    public static func StubbingProvider() -> MoyaProvider<ElloAPI> {
        return MoyaProvider<ElloAPI>(endpointClosure: ElloProvider.endpointClosure, stubClosure: MoyaProvider.ImmediatelyStub)
    }

    public static func DelayedStubbingProvider() -> MoyaProvider<ElloAPI> {
        return MoyaProvider<ElloAPI>(endpointClosure: ElloProvider.endpointClosure, stubClosure: MoyaProvider.DelayedStub(1))
    }

    public static func ErrorStubbingProvider() -> MoyaProvider<ElloAPI> {
        return MoyaProvider<ElloAPI>(endpointClosure: ElloProvider_Specs.errorEndpointsClosure, stubClosure: MoyaProvider.ImmediatelyStub)
    }

    public static func RecordedStubbingProvider(recordings: [RecordedResponse]) -> MoyaProvider<ElloAPI> {
        return MoyaProvider<ElloAPI>(endpointClosure: ElloProvider_Specs.recordedEndpointsClosure(recordings), stubClosure: MoyaProvider.ImmediatelyStub)
    }

}
