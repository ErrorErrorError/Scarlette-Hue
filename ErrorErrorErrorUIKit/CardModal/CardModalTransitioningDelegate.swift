//
//  InteractiveModalTransitioningDelegate.swift
//  WLED Remote
//
//  Created by Erik Bautista on 5/15/21.
//

import UIKit

final class CardModalTransitioningDelegate: NSObject, UIViewControllerTransitioningDelegate {
    var interactiveDismiss = true

    init(from presented: UIViewController, to presenting: UIViewController) {
        super.init()
    }

    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return CardModalPresentationController(presentedViewController: presented, presenting: presenting)
    }
}
