//
//  ChromaColorPicker+Rx.swift
//  WLED Hue
//
//  Created by Erik Bautista on 1/12/22.
//

import UIKit
import RxSwift
import RxCocoa

extension ChromaColorPicker: HasDelegate {
    public typealias Delegate = ChromaColorPickerDelegate
}

public class RxChromaColorPickerProxy: DelegateProxy<ChromaColorPicker, ChromaColorPickerDelegate>, DelegateProxyType {

    public weak private(set) var chromaColorPicker: ChromaColorPicker?

    public init(chromaColorPicker: ChromaColorPicker) {
        self.chromaColorPicker = chromaColorPicker
        super.init(parentObject: chromaColorPicker, delegateProxy: RxChromaColorPickerProxy.self)
    }

        public static func registerKnownImplementations() {
        self.register { RxChromaColorPickerProxy(chromaColorPicker: $0) }
    }

    internal var colorPickerHandleDidChangePublishSubject = PublishSubject<()>()

    deinit {
        colorPickerHandleDidChangePublishSubject.on(.completed)
    }
}

extension RxChromaColorPickerProxy: ChromaColorPickerDelegate {
    public func colorPickerHandleDidChange(_ colorPicker: ChromaColorPicker, handle: ChromaColorHandle, to color: UIColor) {
        colorPickerHandleDidChangePublishSubject.onNext(())

        let forwardToDelegate = self.forwardToDelegate()
        forwardToDelegate?.colorPickerHandleDidChange(colorPicker, handle: handle, to: color)
    }
}

extension Reactive where Base: ChromaColorPicker {
    public var delegate: RxChromaColorPickerProxy {
        return RxChromaColorPickerProxy.proxy(for: base)
    }

    public var handleDidChange: ControlEvent<()> {
        let source = RxChromaColorPickerProxy.proxy(for: base).colorPickerHandleDidChangePublishSubject
        return ControlEvent(events: source)
    }
}
