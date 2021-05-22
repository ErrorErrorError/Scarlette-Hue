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
        let absolutePath = String(format: "\(endPoint)", device.ip, device.port) + "/\(path)"
        return RxAlamofire
            .data(.get, absolutePath)
            .observe(on: scheduler)
            .map({ data -> T in
                return try JSONDecoder().decode(T.self, from: data)
            })
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
}
