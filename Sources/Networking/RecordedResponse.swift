////
///  RecordedResponse.swift
//

import Moya


struct RecordedResponse {
    let endpoint: ElloAPI
    let responseClosure: (_ target: ElloAPI) -> EndpointSampleResponse

    init(endpoint: ElloAPI, responseClosure: @escaping (_ target: ElloAPI) -> EndpointSampleResponse) {
        self.endpoint = endpoint
        self.responseClosure = responseClosure
    }

    init(endpoint: ElloAPI, response: EndpointSampleResponse) {
        self.endpoint = endpoint
        self.responseClosure = { _ in return response }
    }

}
