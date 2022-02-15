//
//  Network+Device.swift
//  WLED Hue
//
//  Created by Erik Bautista on 1/9/22.
//

import RxSwift
import Foundation

extension Network {
    func getItem(_ device: Device, _ path: String) -> Observable<T> {
        let endpoint = "http://\(device.ip):\(device.port)"
        return getItem(endpoint, path)
    }

    func postItem(_ device: Device, _ path: String, _ data: Data) -> Observable<T> {
        let endpoint = "http://\(device.ip):\(device.port)"
        return postItem(endpoint, path, data)
    }
}
