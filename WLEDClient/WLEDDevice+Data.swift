//
//  WLEDDevice+Data.swift
//  WLEDClient
//
//  Created by Erik Bautista on 2/18/22.
//

import Foundation
import RxSwift

internal protocol WLEDGetRequest {
    var path: WLEDDevice.WLEDPath { get }
}

internal protocol WLEDPostRequest {
    var path: WLEDDevice.WLEDPath { get }
    var data: Data { get }
}

// MARK: - Store

extension WLEDDevice {
    private struct GetStoreRequest: WLEDGetRequest {
        let path: WLEDDevice.WLEDPath = .store
    }

    public func getStore() -> Single<Store> {
        get(requestType: GetStoreRequest())
    }
}

// MARK: - State

extension WLEDDevice {
    private struct GetStateRequest: WLEDGetRequest {
        let path: WLEDDevice.WLEDPath = .state
    }

    private struct PostStateRequest: WLEDPostRequest {
        var path: WLEDDevice.WLEDPath = .state
        var data: Data
    }

    public func getState() -> Single<State> {
        get(requestType: GetStateRequest())
    }

    public func updateState(state: State) -> Single<Void> {
        if let store = try? self.storeCache.value() {
            let newState = state
            var updatedState = store.state
            updatedState.copy(with: newState)
            let updatedStore = store.with {
                $0.state = updatedState
            }
            self.storeCache.onNext(updatedStore)
        }

        if let data = try? state.jsonData() {
            return post(requestType: PostStateRequest(data: data))
        } else {
            return .error(WLEDConnectionError.failedToPost)
        }
    }
}

extension WLEDDevice {

    // MARK: - Segment

    private struct PostSegmentRequest: WLEDPostRequest {
        let path: WLEDDevice.WLEDPath = .state
        var data: Data
    }

    public func updateSegment(segment: Segment) -> Single<Void> {
        if let store = try? self.storeCache.value() {
            let updatedSegments = store.state.segments?.with { segments in
                if let index = segments.firstIndex(where: { $0.id == segment.id }) {
                    let updatedSegment = segments[index].with {
                        $0.copy(with: segment)
                    }

                    segments[index] = updatedSegment
                }
            }

            let updatedState = store.state.with {
                $0.segments = updatedSegments
            }

            let updatedStore = store.with {
                $0.state = updatedState
            }

            storeCache.onNext(updatedStore)
        }

        return postSegment(segment: segment)
    }

    public func addSegment(segment: Segment) -> Single<Void> {
        if let store = try? self.storeCache.value() {
            let updatedSegments = store.state.segments?.with {
                $0.append(segment)
                $0.sort(by: { $0.id < $1.id })
            }

            let updatedState = store.state.with {
                $0.segments = updatedSegments
            }

            let updatedStore = store.with {
                $0.state = updatedState
            }

            storeCache.onNext(updatedStore)
        }

        return postSegment(segment: segment)
    }

    public func removeSegment(segment: Segment) -> Single<Void> {
        if let store = try? self.storeCache.value() {
            let updatedSegments = store.state.segments?.with {
                $0.removeAll(where: { $0.id == segment.id })
            }

            let updatedState = store.state.with {
                $0.segments = updatedSegments
            }

            let updatedStore = store.with {
                $0.state = updatedState
            }

            storeCache.onNext(updatedStore)
        }

        return postSegment(segment: Segment(id: segment.id, stop: 0))
    }

    private func postSegment(segment: Segment) -> Single<Void> {
        if let data = try? SegmentRequest(seg: segment).jsonData() {
            return post(requestType: PostSegmentRequest(data: data))
        } else {
            return .error(WLEDConnectionError.failedToPost)
        }
    }
}

// MARK: - Info

extension WLEDDevice {
    private struct GetInfoRequest: WLEDGetRequest {
        let path: WLEDDevice.WLEDPath = .info
    }

    public func getInfo() -> Single<Info> {
        get(requestType: GetInfoRequest())
    }
}

// MARK: - Effects

extension WLEDDevice {
    private struct GetEffectsRequest: WLEDGetRequest {
        let path: WLEDDevice.WLEDPath = .effects
    }

    public func getEffects() -> Single<[String]> {
        get(requestType: GetEffectsRequest())
    }
}

// MARK: - Palettes

extension WLEDDevice {
    private struct GetPalettesRequest: WLEDGetRequest {
        let path: WLEDDevice.WLEDPath = .palettes
    }

    public func getPalettes() -> Single<[String]> {
        get(requestType: GetPalettesRequest())
    }
}
