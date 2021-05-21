//
//  InfoRepository.swift
//  WLED Remote
//
//  Created by Erik Bautista on 5/16/21.
//

import Foundation
import Alamofire


final class InfoService {
    private var url = "http://%@:%d/json/state"

    func fetch(with ip: String, port: Int, completion: @escaping (Info?, Error?) -> ()) {
        let deviceUrl = String(format: url, ip, port)
        AF.request(deviceUrl)
            .validate()
            .responseDecodable(of: Info.self) { response in
                if let state = response.value {
                    completion(state, nil)
                } else {
                    completion(nil, response.error)
                }
            }
    }
}
