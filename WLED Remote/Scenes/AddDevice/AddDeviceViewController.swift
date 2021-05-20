//
//  AddDeviceViewController.swift
//  WLED Remote
//
//  Created by Erik Bautista on 5/16/21.
//

import UIKit
import CoreData


class AddDeviceViewController: UIViewController {

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
        let button = UIButton(type: .roundedRect, primaryAction: UIAction(handler: { _ in self.addDevice() }))
        button.setTitle("Add Device", for: .normal)
        button.tintColor = .label
        button.layer.cornerRadius = buttonHeight / 4
        button.backgroundColor = .secondarySystemBackground
        return button
    }()

    private let buttonHeight: CGFloat = 48

    var device: Device?

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

        deviceNameTextField.text = device?.name
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

    func textFieldDidEndEditing(_ textField: UITextField) {
        if let text = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !text.isEmpty {
            primaryButton.isEnabled = true
        } else {
            primaryButton.isEnabled = false
        }
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let text = (textField.text as NSString?)?.replacingCharacters(in: range, with: string).trimmingCharacters(in: .whitespacesAndNewlines), !text.isEmpty {
            primaryButton.isEnabled = true
        } else {
            primaryButton.isEnabled = false
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

    private func addDevice() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
          return
        }

        let context = appDelegate.persistentContainer.viewContext
        if let entity = NSEntityDescription.entity(forEntityName: "CDDevice", in: context), let modelDevice = device {
            let device = CDDevice(entity: entity, insertInto: context)
            device.id = modelDevice.id
            device.name = deviceNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "WLED"
            device.ip = modelDevice.ip
            device.port = Int32(modelDevice.port)
            device.created =  Date()
            NotificationCenter.default.post(name: .init("updateDevicesNotification"), object: nil)
        }
        do {
            try context.save()
        } catch {
            print("There was an error saving context")
        }
        dismiss(animated: true)
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
