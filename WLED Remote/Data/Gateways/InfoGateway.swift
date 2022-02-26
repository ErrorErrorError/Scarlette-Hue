//
//  InfoGateway.swift
//  WLED Hue
//
//  Created by Erik Bautista on 2/16/22.
//

import Foundation
import RxSwift
import WLEDClient



//protocol InfoGatewayType {
//    func getInfo(for device: Device) -> Observable<Info>
//    func validate(ip: String, port: Int) -> Observable<Info>
//}
//
//struct InfoGateway: InfoGatewayType {
//    func validate(ip: String, port: Int) -> Observable<Info> {
//        let apiEndpoint = "http://%@:%d"
//        let infoApi = InfoAPI(network: .init(apiEndpoint))
//
//        return infoApi.validateNetwork(ip: ip, port: port)
//    }
//    
//    func getInfo(for device: Device) -> Observable<Info> {
//        let apiEndpoint = "http://%@:%d"
//        let infoApi = InfoAPI(network: .init(apiEndpoint))
//
//        return infoApi.fetchInfo(for: device)
//    }
//}
