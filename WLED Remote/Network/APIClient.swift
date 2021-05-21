//
//  RestApiManager.swift
//  WLED Remote
//
//  Created by Erik Bautista on 5/17/21.
//

import Foundation


public class APIClient {

    public static let shared = APIClient()

    private let stateRepository: StateService
    private let infoRepository: InfoService

    private init() {
        stateRepository = StateService()
        infoRepository = InfoService()
    }

    public func fetchState(device: Device,
                           success successCallback: @escaping (State) -> Void,
                           failure  failureCallback: @escaping (Error?) -> Void) {
        stateRepository.fetch(with: device.ip, port: Int(device.port)) { state, error in
            if let state = state {
                successCallback(state)
            } else {
                failureCallback(error)
            }
        }
    }

    public func fetchInfo(device: Device,
                          success successCallback: @escaping (Info) -> Void,
                          failure  failureCallback: @escaping (Error?) -> Void) {
       infoRepository.fetch(with: device.ip, port: Int(device.port)) { info, error in
           if let info = info {
               successCallback(info)
           } else {
               failureCallback(error)
           }
       }
    }

    public func updateState(device: Device,
                            state: State,
                            success successCallback: @escaping () -> Void,
                            failure  failureCallback: @escaping (Error?) -> Void) {
        stateRepository.update(ip: device.ip,
                               port: Int(device.port),
                               state: state,
                               success: successCallback,
                               failed: failureCallback)

    }
}
