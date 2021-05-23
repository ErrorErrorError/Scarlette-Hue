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

    private let endPoint: String
    private let scheduler: ConcurrentDispatchQueueScheduler

    init(_ endPoint: String) {
        self.endPoint = endPoint
        self.scheduler = ConcurrentDispatchQueueScheduler(qos: DispatchQoS(qosClass: DispatchQoS.QoSClass.background, relativePriority: 1))
    }

    func getItem(_ device: Device, _ path: String) -> Observable<T> {
        return getItem(device.ip, device.port, path)
    }

    func getItem(_ ip: String, _ port: Int, _ path: String) -> Observable<T> {
        let absolutePath = String(format: "\(endPoint)", ip, port) + "/\(path)"
        return RxAlamofire
            .data(.get, absolutePath)
            .observe(on: scheduler)
            .map({ data -> T in
                return try JSONDecoder().decode(T.self, from: data)
            })
    }

    func postItem(_ device: Device, _ path: String, _ data: Data) -> Observable<T> {
        return postItem(device.ip, device.port, path, data)
    }

    func postItem(_ ip: String, _ port: Int, _ path: String, _ data: Data) -> Observable<T> {
        let absolutePath = String(format: "\(endPoint)", ip, port) + "/\(path)"
        var request = try! URLRequest(url: absolutePath, method: .post)
        request.httpBody = data
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        return RxAlamofire
            .requestData(request)
            .observe(on: scheduler)
            .map({ response -> T in
                return try JSONDecoder().decode(T.self, from: response.1)
            })
    }

    func postItem(_ device: Device, _ path: String, _ data: Data) -> Observable<Bool> {
        return postItem(device.ip, device.port, path, data)
    }

    func postItem(_ ip: String, _ port: Int, _ path: String, _ data: Data) -> Observable<Bool> {
        let absolutePath = String(format: "\(endPoint)", ip, port) + "/\(path)"
        if var request = try? URLRequest(url: absolutePath, method: .post) {
            request.httpBody = data
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            return RxAlamofire
                .requestJSON(request)
                .observe(on: scheduler)
                .map { (response, data) in
                    (200..<300).contains(response.statusCode)
                }
        }
        return Observable.just(false)
    }
}
