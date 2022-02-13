//
//  Network.swift
//  WLED Remote
//
//  Created by Erik Bautista on 5/21/21.
//

import Foundation
import Alamofire
import RxAlamofire
import RxSwift

final class Network<T: Decodable> {
    private let scheduler: ConcurrentDispatchQueueScheduler

    init(_ endPoint: String) {
        self.scheduler = ConcurrentDispatchQueueScheduler(qos: DispatchQoS(qosClass: .background, relativePriority: 1))
    }

    func getItems(_ endPoint: String, _ path: String) -> Observable<[T]> {
        let absolutePath = "\(endPoint)/\(path)"
        return RxAlamofire
            .data(.get, absolutePath)
            .observe(on: scheduler)
            .map({ data -> [T] in
                return try JSONDecoder().decode([T].self, from: data)
            })
    }

    func getItem(_ endPoint: String, _ path: String) -> Observable<T> {
        let absolutePath = "\(endPoint)/\(path)"
        return RxAlamofire
            .data(.get, absolutePath)
            .observe(on: scheduler)
            .map({ data -> T in
                return try JSONDecoder().decode(T.self, from: data)
            })
    }

    func postItem(_ endPoint: String, _ path: String, _ data: Data) -> Observable<T> {
        let absolutePath = "\(endPoint)/\(path)"
        if var request = try? URLRequest(url: absolutePath, method: .post) {
            request.httpBody = data
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            return RxAlamofire
                .request(request)
                .responseData()
                .observe(on: scheduler)
                .map({ response -> T in
                    return try JSONDecoder().decode(T.self, from: response.1)
                })
        } else {
            return Observable.error(URLError.unsupportedURL as! Error)
        }
    }
}
