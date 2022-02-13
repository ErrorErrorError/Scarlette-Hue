//
//  NetService+Rx.swift
//  WLED Remote
//
//  Created by Erik Bautista on 5/21/21.
//  https://github.com/katoemba/RxNetService

import Foundation
import RxSwift
import RxCocoa

extension NetService: HasDelegate {
    public typealias Delegate = NetServiceDelegate
}

public class RxNetServiceDelegateProxy: DelegateProxy<NetService, NetServiceDelegate>, DelegateProxyType, NetServiceDelegate {

    public weak private(set) var netService: NetService?

    public init(netService: ParentObject) {
        self.netService = netService
        super.init(parentObject: netService, delegateProxy: RxNetServiceDelegateProxy.self)
    }

    public static func registerKnownImplementations() {
        self.register { RxNetServiceDelegateProxy(netService: $0) }
    }
}

public extension Reactive where Base: NetService {
    var delegate: DelegateProxy<NetService, NetServiceDelegate> {
        return RxNetServiceDelegateProxy.proxy(for: base)
    }

    func setDelegate(_ delegate: NetServiceDelegate)
        -> Disposable {
            return RxNetServiceDelegateProxy.installForwardDelegate(delegate, retainDelegate: false, onProxyForObject: self.base)
    }

    var didResolveAddress: Observable<NetService> {
        return delegate
            .methodInvoked(#selector(NetServiceDelegate.netServiceDidResolveAddress(_:)))
            .map { params in
                return params[0] as! NetService
            }
    }

    func resolve(withTimeout timeout: TimeInterval) -> Observable<NetService> {
        let netService = self.base as NetService
        netService.resolve(withTimeout: timeout)
        return didResolveAddress.filter { $0 == self.base }
    }
}

public extension NetService {
    var firstIPv4Address: String? {
        firstAddress(containing: ".")
    }

    var firstIPv6Address: String? {
        firstAddress(containing: ":")
    }

    func firstAddress(containing: String) -> String? {
        guard let addresses = addresses else { return nil }
        for address in addresses {
            let ip = address.withUnsafeBytes({ pointer -> String? in
                var hostStr = [Int8](repeating: 0, count: Int(NI_MAXHOST))
                
                let result = getnameinfo(pointer.baseAddress?.assumingMemoryBound(to: sockaddr.self),
                                         socklen_t(address.count),
                                         &hostStr,
                                         socklen_t(hostStr.count),
                                         nil,
                                         0,
                                         NI_NUMERICHOST
                )
                guard result == 0 else { return nil }
                return String(cString: hostStr)
            })
            if let ip = ip {
                if ip.contains(containing) {
                    return ip
                }
            }
        }

        return nil
    }
}
