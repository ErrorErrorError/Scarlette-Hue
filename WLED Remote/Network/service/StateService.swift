//
//  StateRepository.swift
//  WLED Remote
//
//  Created by Erik Bautista on 5/16/21.
//

import Foundation
import Alamofire


final class StateService {

    private var apiUrl = "http://%@:%d"

    func fetch(with ip: String, port: Int, completion: @escaping (State?, Error?) -> ()) {
        let deviceUrl = String(format: apiUrl + "/json/state", ip, port)
        AF.request(deviceUrl)
            .validate()
            .responseDecodable(of: State.self) { response in
                if let state = response.value {
                    completion(state, nil)
                } else {
                    completion(nil, response.error)
                }
            }
    }

    func update(ip: String, port: Int, state: State, success: @escaping () -> (), failed: @escaping (Error?) -> ()) {
        let deviceUrl = String(format: apiUrl + "/json/si", ip, port)
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601

        AF.request(deviceUrl, method: .post, parameters: state, encoder: JSONParameterEncoder())
            .validate()
            .response { response in
                if let error = response.error {
                    failed(error)
                } else {
                    success()
                }
            }
    }
}
