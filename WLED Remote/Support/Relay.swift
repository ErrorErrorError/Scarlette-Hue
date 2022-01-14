//
//  Relay.swift
//  WLED Hue
//
//  Created by Erik Bautista on 1/10/22.
//

import UIKit
import RxSwift
import RxCocoa

@propertyWrapper
public struct Relay<Value> {

    private var subject: BehaviorRelay<Value>

    public var wrappedValue: Value {
        get {
            return subject.value
        }
        set {
            subject.accept(newValue)
        }
    }

    public var projectedValue: BehaviorRelay<Value> {
        return self.subject
    }

    public init(wrappedValue: Value) {
        subject = BehaviorRelay(value: wrappedValue)
    }
}
