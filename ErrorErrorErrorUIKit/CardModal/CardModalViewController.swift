//
//  CardModalViewController.swift
//  WLED Hue
//
//  Created by Erik Bautista on 1/15/22.
//

import UIKit
import Then

open class CardModalViewController<T: UIView>: UIViewController {
    public enum ButtonsView {
        case primary
        case secondary
        case both
    }

    // MARK: - Properties

    public let buttonStyle: ButtonsView

    private let buttonHeight: CGFloat = 48

    // MARK: - Private Views

    private let containerView = UIView().then {
        $0.backgroundColor = .systemBackground
        $0.layer.cornerRadius = UIScreen.main.displayCornerRadius
        $0.layer.cornerCurve = .continuous
    }

    // MARK: - Public Views

    public let contentView: T

    public let titleLabel = UILabel().then {
        $0.text = ""
        $0.font = UIFont.boldSystemFont(ofSize: 26)
        $0.textColor = UIColor.label
        $0.textAlignment = .center
        $0.numberOfLines = 0
    }

    public let descriptionLabel = UILabel().then {
        $0.text = ""
        $0.font = UIFont.systemFont(ofSize: 14)
        $0.textColor = UIColor.secondaryLabel
        $0.textAlignment = .center
        $0.numberOfLines = 0
    }

    private lazy var textStackView = UIStackView(frame: .zero).then {
        $0.addArrangedSubview(titleLabel)
        $0.addArrangedSubview(descriptionLabel)
        $0.axis = .vertical
        $0.spacing = 4
    }

    public let exitButton = UIButton(type: .close)

    public lazy var secondaryButton = UIButton(type: .roundedRect).then {
        $0.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        $0.tintColor = .label
        $0.layer.cornerRadius = buttonHeight / 4
        $0.backgroundColor = .secondarySystemBackground
    }

    public lazy var primaryButton = UIButton(type: .roundedRect).then {
        $0.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        $0.tintColor = .label
        $0.layer.cornerRadius = buttonHeight / 4
        $0.backgroundColor = .secondarySystemBackground
    }

    public init(buttonView: ButtonsView, contentView: T) {
        self.buttonStyle = buttonView
        self.contentView = contentView
        super.init(nibName: nil, bundle: nil)
    }

    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    open override func viewDidLoad() {
        super.viewDidLoad()
        setupViewsAndContraints()
    }

    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)),
                                               name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)),
                                               name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self,
                                                  name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self,
                                                  name: UIResponder.keyboardWillHideNotification, object: nil)
    }
 
    open func setupViewsAndContraints() {
        containerView.do {
            $0.addSubview(exitButton)
//            $0.addSubview(titleLabel)
//            $0.addSubview(descriptionLabel)
            $0.addSubview(textStackView)
            $0.addSubview(contentView)
            if buttonStyle == .primary {
                $0.addSubview(primaryButton)
            } else if buttonStyle == .secondary {
                $0.addSubview(secondaryButton)
            } else {
                $0.addSubview(secondaryButton)
                $0.addSubview(primaryButton)
            }
            $0.subviews.forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        }

        view.addSubview(containerView)
        view.subviews.forEach { $0.translatesAutoresizingMaskIntoConstraints = false }

        containerView.do {
            $0.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 6).isActive = true
            $0.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -6).isActive = true
            $0.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -6).isActive = true
        }

        let outerYAxisInset: CGFloat = 28
        let outerXAxisInset: CGFloat = 36
        let insetSpacing: CGFloat = 8

        exitButton.do {
            $0.topAnchor.constraint(equalTo: containerView.topAnchor, constant: outerYAxisInset).isActive = true
            $0.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -outerYAxisInset).isActive = true
        }

        textStackView.do {
            $0.topAnchor.constraint(equalTo: exitButton.bottomAnchor, constant: insetSpacing).isActive = true
            $0.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: outerXAxisInset).isActive = true
            $0.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -outerXAxisInset).isActive = true
        }

        contentView.do {
            $0.topAnchor.constraint(equalTo: textStackView.bottomAnchor, constant: insetSpacing).isActive = true
            $0.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: outerXAxisInset).isActive = true
            $0.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -outerXAxisInset).isActive = true
        }

        if buttonStyle == .primary {
            primaryButton.do {
                $0.topAnchor.constraint(equalTo: contentView.bottomAnchor, constant: insetSpacing + 20).isActive = true
                $0.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: outerXAxisInset).isActive = true
                $0.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -outerXAxisInset).isActive = true
                $0.heightAnchor.constraint(equalToConstant: buttonHeight).isActive = true
                $0.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -outerYAxisInset).isActive = true
            }
        } else if buttonStyle == .secondary {
            secondaryButton.do {
                $0.topAnchor.constraint(equalTo: contentView.bottomAnchor, constant: insetSpacing + 20).isActive = true
                $0.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: outerXAxisInset).isActive = true
                $0.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -outerXAxisInset).isActive = true
                $0.heightAnchor.constraint(equalToConstant: buttonHeight).isActive = true
                $0.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -outerYAxisInset).isActive = true
            }
        } else {
            secondaryButton.do {
                $0.topAnchor.constraint(equalTo: contentView.bottomAnchor, constant: insetSpacing + 20).isActive = true
                $0.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: outerXAxisInset).isActive = true
                $0.trailingAnchor.constraint(equalTo: primaryButton.leadingAnchor, constant: -outerXAxisInset / 2).isActive = true
                $0.heightAnchor.constraint(equalToConstant: buttonHeight).isActive = true
                $0.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -outerYAxisInset).isActive = true
                $0.widthAnchor.constraint(equalTo: secondaryButton.widthAnchor).isActive = true
            }

            primaryButton.do {
                $0.topAnchor.constraint(equalTo: contentView.bottomAnchor, constant: insetSpacing + 20).isActive = true
                $0.leadingAnchor.constraint(equalTo: secondaryButton.trailingAnchor, constant: outerXAxisInset / 2).isActive = true
                $0.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -outerXAxisInset).isActive = true
                $0.heightAnchor.constraint(equalToConstant: buttonHeight).isActive = true
                $0.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -outerYAxisInset).isActive = true
                $0.widthAnchor.constraint(equalTo: secondaryButton.widthAnchor).isActive = true
            }
        }
    }

    @objc func keyboardWillShow(notification: NSNotification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            return
        }

        let firstResponders = containsFirstResponder()

        if let responderView = firstResponders.first {
            let responderMaxY = responderView.convert(responderView.bounds, to: self.view).maxY;
            let topOfKeyboard = self.view.bounds.height - keyboardSize.height

            if responderMaxY > topOfKeyboard {
                self.view.bounds.origin.y = keyboardSize.height
            }

//            let location = responderView.convert(responderView.bounds, to: view)
//
//            if keyboardSize.height < location.origin.y {
//                view.bounds.origin.y = location.height + keyboardSize.height + 8 - (view.bounds.height - location.origin.y)
//            }
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        self.view.bounds.origin.y = 0
    }

    private func containsFirstResponder() -> [UIView] {
        return view.get(all: [UITextField.self]).filter({ $0.isFirstResponder })
    }
}

private extension UIView {
    class func getAllSubviews<T: UIView>(from parenView: UIView) -> [T] {
        return parenView.subviews.flatMap { subView -> [T] in
            var result = getAllSubviews(from: subView) as [T]
            if let view = subView as? T { result.append(view) }
            return result
        }
    }

    class func getAllSubviews(from parenView: UIView, types: [UIView.Type]) -> [UIView] {
        return parenView.subviews.flatMap { subView -> [UIView] in
            var result = getAllSubviews(from: subView) as [UIView]
            for type in types {
                if subView.classForCoder == type {
                    result.append(subView)
                    return result
                }
            }
            return result
        }
    }

    func getAllSubviews<T: UIView>() -> [T] { return UIView.getAllSubviews(from: self) as [T] }
    func get<T: UIView>(all type: T.Type) -> [T] { return UIView.getAllSubviews(from: self) as [T] }
    func get(all types: [UIView.Type]) -> [UIView] { return UIView.getAllSubviews(from: self, types: types) }
}
