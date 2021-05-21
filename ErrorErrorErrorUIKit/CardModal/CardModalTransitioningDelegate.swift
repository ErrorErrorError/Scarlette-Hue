//
//  InteractiveModalTransitioningDelegate.swift
//  WLED Remote
//
//  Created by Erik Bautista on 5/15/21.
//

import UIKit

public final class CardModalTransitioningDelegate: NSObject, UIViewControllerTransitioningDelegate {
    var interactiveDismiss = true

    public init(from presented: UIViewController, to presenting: UIViewController) {
        super.init()
    }

    public func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return CardModalPresentationController(presentedViewController: presented, presenting: presenting)
    }
}
