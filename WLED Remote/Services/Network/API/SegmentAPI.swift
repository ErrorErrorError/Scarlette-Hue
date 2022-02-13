//
//  SegmentAPI.swift
//  WLED Hue
//
//  Created by Erik Bautista on 1/14/22.
//

import Foundation
import RxSwift

public final class SegmentAPI {
    private let network: Network<Segment>

    init(network: Network<Segment>) {
        self.network = network
    }

    public func addSegment(device: Device, segment: Segment) -> Observable<Void> {
        return network.postItem(device, "json/state", (try? SegmentRequest(seg: segment).jsonData()) ?? Data())
            .mapToVoid()
    }

    public func updateSegment(device: Device, segment: Segment) -> Observable<Bool> {
        return network.postItem(device, "json/state", (try? SegmentRequest(seg: segment).jsonData()) ?? Data())
            .map({ _ in true })
    }

    public func deleteSegment(device: Device, segment: Segment) -> Observable<Void> {
        return network.postItem(device, "json/state", (try? SegmentRequest(seg: segment).jsonData()) ?? Data())
            .mapToVoid()
    }
}
