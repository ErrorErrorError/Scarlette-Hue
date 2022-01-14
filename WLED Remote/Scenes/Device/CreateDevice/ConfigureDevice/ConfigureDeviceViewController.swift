//
//  ConfigureDeviceViewController.swift
//  WLED Remote
//
//  Created by Erik Bautista on 5/16/21.
//

import UIKit
import RxSwift
import Then

class ConfigureDeviceViewController: UIViewController {

    // MARK: ViewModel

    let viewModel: ConfigureDeviceViewModel

    // MARK: Rx

    private let disposeBag = DisposeBag()

    // MARK: Views

    private let contentView = UIView().then {
        $0.backgroundColor = .systemBackground
        $0.layer.cornerRadius = UIScreen.main.displayCornerRadius
        $0.layer.cornerCurve = .continuous
    }

    private lazy var exitButton = UIButton().then {
        $0.addAction(.init(handler: { [weak self] _ in
            self?.dismiss(animated: true, completion: nil)
        }), for: .touchUpInside)
    }

    private let titleLabel = UILabel().then {
        $0.text = "Set WLED Information"
        $0.font = UIFont.boldSystemFont(ofSize: 24)
        $0.numberOfLines = 0
        $0.textAlignment = .center
    }

    private let descriptionLabel = UILabel().then {
        $0.text = "You can replace the name of the device now or later in settings."
        $0.textColor = .secondaryLabel
        $0.font = UIFont.systemFont(ofSize: 12)
        $0.numberOfLines = 0
        $0.textAlignment = .center
    }

    private let deviceNameLabel = UILabel().then {
        $0.font = UIFont.boldSystemFont(ofSize: 14)
        $0.textColor = .label
        $0.text = "Device Name:"
        $0.numberOfLines = 0
    }

    private let deviceNameTextField = UITextField().then {
        $0.borderStyle = .roundedRect
        $0.backgroundColor = .secondarySystemBackground
    }

    private lazy var primaryButton = UIButton(type: .roundedRect).then {
        $0.setTitle("Add Device", for: .normal)
        $0.tintColor = .label
        $0.layer.cornerRadius = buttonHeight / 4
        $0.backgroundColor = .secondarySystemBackground
    }

    private let buttonHeight: CGFloat = 48

    init(viewModel: ConfigureDeviceViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        deviceNameTextField.delegate = self

        contentView.do {
            $0.addSubview(exitButton)
            $0.addSubview(titleLabel)
            $0.addSubview(descriptionLabel)
            $0.addSubview(deviceNameLabel)
            $0.addSubview(deviceNameTextField)
            $0.addSubview(primaryButton)
        }

        view.addSubview(contentView)

        setupConstraints()
        setListeners()
        bindViewController()
    }

    private func setupConstraints() {
        view.subviews.forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        contentView.subviews.forEach { $0.translatesAutoresizingMaskIntoConstraints = false }

        contentView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 6).isActive = true
        contentView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -6).isActive = true
        contentView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -6).isActive = true

        let outerYAxisInsets: CGFloat = 28
        let outerXAxisInsets: CGFloat = 36
        let insetSpacing: CGFloat = 8

        exitButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: outerYAxisInsets).isActive = true
        exitButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -outerYAxisInsets).isActive = true

        titleLabel.topAnchor.constraint(equalTo: exitButton.bottomAnchor, constant: insetSpacing).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: outerXAxisInsets).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -outerXAxisInsets).isActive = true

        descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: insetSpacing - 4).isActive = true
        descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: outerXAxisInsets).isActive = true
        descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -outerXAxisInsets).isActive = true

        deviceNameLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: insetSpacing + 20).isActive = true
        deviceNameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: outerXAxisInsets).isActive = true
        deviceNameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -outerXAxisInsets).isActive = true

        deviceNameTextField.topAnchor.constraint(greaterThanOrEqualTo: deviceNameLabel.bottomAnchor, constant: insetSpacing).isActive = true
        deviceNameTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: outerXAxisInsets).isActive = true
        deviceNameTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -outerXAxisInsets).isActive = true
        deviceNameTextField.heightAnchor.constraint(equalToConstant: 36).isActive = true

        primaryButton.topAnchor.constraint(greaterThanOrEqualTo: deviceNameTextField.bottomAnchor, constant: insetSpacing + 20).isActive = true
        primaryButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: outerXAxisInsets).isActive = true
        primaryButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -outerXAxisInsets).isActive = true
        primaryButton.heightAnchor.constraint(equalToConstant: buttonHeight).isActive = true
        primaryButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -outerYAxisInsets).isActive = true
    }

    private func setListeners() {
        let tapGestureReconizer = UITapGestureRecognizer(target: self, action: #selector(handleTextFieldResponder))
        self.view.addGestureRecognizer(tapGestureReconizer)

        // Add listeners in case the text field is low
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    private func bindViewController() {
        let viewWillAppear = rx.sentMessage(#selector(UIViewController.viewWillAppear(_:)))
            .mapToVoid()
            .asDriverOnErrorJustComplete()

        let input = ConfigureDeviceViewModel.Input(
            loadTrigger: viewWillAppear,
            saveTrigger: primaryButton.rx.tap.asDriver(),
            exitTrigger: exitButton.rx.tap.asDriver(),
            name: deviceNameTextField.rx.text.orEmpty.changed.asDriver()
        )

        let output = viewModel.transform(input: input, disposeBag: disposeBag)

        output.$canSave
            .asDriver()
            .drive(primaryButton.rx.isEnabled).disposed(by: disposeBag)

        output.$name
            .asDriver()
            .drive(deviceNameTextField.rx.text)
            .disposed(by: disposeBag)
    }
}

extension ConfigureDeviceViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let text = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !text.isEmpty else {
            return false
        }
        if deviceNameTextField.isFirstResponder {
            deviceNameTextField.resignFirstResponder()
        }
        return true
    }
}

// MARK: - Actions
extension ConfigureDeviceViewController {
    @objc private func handleTextFieldResponder(_ sender: UIGestureRecognizer) {
        if deviceNameTextField.isFirstResponder {
            deviceNameTextField.resignFirstResponder()
        }
    }

    @objc func keyboardWillShow(notification: NSNotification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            return
        }

        var shouldMoveViewUp = false

        if deviceNameTextField.isFirstResponder {
            let bottomOfTextField = deviceNameTextField.convert(deviceNameTextField.bounds, to: self.view).maxY;
            let topOfKeyboard = self.view.frame.height - keyboardSize.height

            if bottomOfTextField > topOfKeyboard {
                shouldMoveViewUp = true
            }
        }

        if(shouldMoveViewUp) {
            self.view.frame.origin.y = 0 - keyboardSize.height
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        self.view.frame.origin.y = 0
    }
}

extension Reactive where Base: UITextView {
    var isEditable: Binder<Bool> {
        return Binder(self.base, binding: { (textView, isEditable) in
            textView.isEditable = isEditable
        })
    }
}
