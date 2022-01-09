//
//  NetServiceBrowser+Rx.swift
//  WLED Remote
//
//  Created by Erik Bautista on 5/21/21.
//

import Foundation
import RxSwift
import RxCocoa


extension NetServiceBrowser: HasDelegate {
    public typealias Delegate = NetServiceBrowserDelegate
}

public class RxNetServiceBrowserDelegateProxy: DelegateProxy<NetServiceBrowser, NetServiceBrowserDelegate>,
                                               DelegateProxyType,
                                               NetServiceBrowserDelegate {

    public weak private(set) var netServiceBrowser: NetServiceBrowser?

    public init(netServiceBrowser: ParentObject) {
        self.netServiceBrowser = netServiceBrowser
        super.init(parentObject: netServiceBrowser, delegateProxy: RxNetServiceBrowserDelegateProxy.self)
    }

    public static func registerKnownImplementations() {
        self.register { RxNetServiceBrowserDelegateProxy(netServiceBrowser: $0) }
    }
}

public extension Reactive where Base: NetServiceBrowser {
    var delegate: DelegateProxy<NetServiceBrowser, NetServiceBrowserDelegate> {
        return RxNetServiceBrowserDelegateProxy.proxy(for: base)
    }

    func setDelegate(_ delegate: NetServiceBrowserDelegate) -> Disposable {
        return RxNetServiceBrowserDelegateProxy.installForwardDelegate(delegate, retainDelegate: false, onProxyForObject: self.base)
    }

    var serviceAdded: Observable<NetService> {
        return delegate
            .methodInvoked(#selector(NetServiceBrowserDelegate.netServiceBrowser(_:didFind:moreComing:)))
            .flatMap { (params) -> Observable<NetService> in
                let netService = params[1] as! NetService
                return netService.rx.resolve(withTimeout: 5)
            }
            .share(replay: 1)
    }
    
    var serviceRemoved: Observable<NetService> {
        return delegate
            .methodInvoked(#selector(NetServiceBrowserDelegate.netServiceBrowser(_:didRemove:moreComing:)))
            .map { params in
                return params[1] as! NetService
            }
            .share(replay: 1)
    }
}
