//
//  AddDeviceViewController.swift
//  WLED Remote
//
//  Created by Erik Bautista on 5/16/21.
//

import UIKit
import RxSwift


class AddDeviceViewController: UIViewController {

    // MARK: ViewModel

    let viewModel: AddDeviceViewModel

    // MARK: Rx

    private let disposeBag = DisposeBag()

    // MARK: Views

    private let contentView: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = UIScreen.main.displayCornerRadius
        view.layer.cornerCurve = .continuous
        return view
    }()

    private lazy var exitButton: UIButton = {
        let button = UIButton(type: .close, primaryAction: UIAction(handler: { [weak self] action in
            self?.dismiss(animated: true, completion: nil)
        }))
        return button
    }()

    private let titleLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.text = "Set WLED Information"
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()

    private let descriptionLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.text = "You can replace the name of the device now or later in settings."
        label.textColor = .secondaryLabel
        label.font = UIFont.systemFont(ofSize: 12)
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()

    private let deviceNameLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.textColor = .label
        label.text = "Device Name:"
        label.numberOfLines = 0
        return label
    }()

    private let deviceNameTextField: UITextField = {
        let textField = UITextField(frame: .zero)
        textField.borderStyle = .roundedRect
        textField.backgroundColor = .secondarySystemBackground
        return textField
    }()

    private lazy var primaryButton: UIButton = {
        let button = UIButton(type: .roundedRect)
        button.setTitle("Add Device", for: .normal)
        button.tintColor = .label
        button.layer.cornerRadius = buttonHeight / 4
        button.backgroundColor = .secondarySystemBackground
        return button
    }()

    private let buttonHeight: CGFloat = 48

    init(viewModel: AddDeviceViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        deviceNameTextField.delegate = self

        contentView.addSubview(exitButton)
        contentView.addSubview(titleLabel)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(deviceNameLabel)
        contentView.addSubview(deviceNameTextField)
        contentView.addSubview(primaryButton)

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
        assert(viewModel != nil)

        let input = AddDeviceViewModel.Input(saveTrigger: primaryButton.rx.tap.asDriver(),
                                             exitTrigger: exitButton.rx.tap.asDriver(),
                                             name: deviceNameTextField.rx.text.orEmpty.asDriver())
        let output = viewModel.transform(input: input)

        output.canSave.drive(primaryButton.rx.isEnabled).disposed(by: disposeBag)
        output.device.drive(deviceBinding).disposed(by: disposeBag)
        output.exit.drive().disposed(by: disposeBag)
        output.save.drive().disposed(by: disposeBag)
    }

    var deviceBinding: Binder<Device> {
        return Binder(self, binding: { (vc, device) in
            vc.deviceNameTextField.text = device.name
        })
    }
}

extension AddDeviceViewController: UITextFieldDelegate {
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
extension AddDeviceViewController {
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
