//
//  CardModalPresentationController.swift
//  WLED Remote
//
//  Created by Erik Bautista on 5/15/21.
//

import UIKit

enum ModalScaleState {
    case presentation
    case interaction
}

public final class CardModalPresentationController: UIPresentationController {

    private var canDismiss = false

    private var state: ModalScaleState = .interaction

    private lazy var dimmingView: UIView! = {
        guard let container = containerView else { return nil }

        let view = UIView(frame: container.bounds)

        view.backgroundColor = UIColor.black.withAlphaComponent(0.75)
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTap(tap:))))

        return view
    }()

    override init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?) {
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)

        presentedViewController.view.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(didPan(pan:))))
    }

    @objc func didPan(pan: UIPanGestureRecognizer) {
        guard let view = pan.view,
              let superView = view.superview,
              let presented = presentedView,
              let container = containerView else {
            return
        }

        let location = pan.translation(in: superView)

        switch pan.state {
        case .began:
            presented.frame.size.height = container.frame.height
        case .changed:
            switch state {
            case .interaction:
                var verticalLimit: CGFloat = -(UIScreen.main.bounds.height / 2)
                if (location.y > 0) {
                    // add resistance if trying to drag
                    verticalLimit = (UIScreen.main.bounds.height / 2)
                }
                presented.frame.origin.y = verticalLimit * log10((location.y/verticalLimit) + 1)
            case .presentation:
                presented.frame.origin.y = location.y
            }
        case .ended:
            let maxPresentedY = container.frame.height
            switch presented.frame.origin.y {
            case 0...maxPresentedY:
                changeScale(to: .interaction)
            default:
                if canDismiss {
                    presentedViewController.dismiss(animated: true, completion: nil)
                } else {
                    changeScale(to: .interaction)
                }
            }
        default:
            break
        }
    }

    @objc func didTap(tap: UITapGestureRecognizer) {
        if canDismiss {
            presentedViewController.dismiss(animated: true, completion: nil)
        }
    }

    func changeScale(to state: ModalScaleState) {
        guard let presented = presentedView else { return }

        UIView.animate(withDuration: 0.8, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseInOut, animations: { [weak self] in
            guard let `self` = self else { return }

            presented.frame = self.frameOfPresentedViewInContainerView

        }, completion: { (isFinished) in
            self.state = state
        })
    }

    public override var frameOfPresentedViewInContainerView: CGRect {
        guard let container = containerView else { return .zero }
        return CGRect(x: 0, y: 0, width: container.bounds.width, height: container.bounds.height)
    }

    public override func presentationTransitionWillBegin() {
        guard let container = containerView, let coordinator = presentingViewController.transitionCoordinator else { return }

        dimmingView.alpha = 0
        dimmingView.addSubview(presentedViewController.view)
        container.addSubview(dimmingView)

        coordinator.animate(alongsideTransition: { [weak self] context in
            guard let `self` = self else { return }
            self.dimmingView.alpha = 1
        }, completion: nil)
    }

    public override func dismissalTransitionWillBegin() {
        guard let coordinator = presentingViewController.transitionCoordinator else { return }

        coordinator.animate(alongsideTransition: { [weak self] (context) -> Void in
            guard let `self` = self else { return }
            self.dimmingView.alpha = 0
        }, completion: nil)
    }

    public override func dismissalTransitionDidEnd(_ completed: Bool) {
        if completed {
            dimmingView.removeFromSuperview()
        }
    }
}

