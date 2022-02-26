//
//  ConfigureDeviceViewController.swift
//  WLED Remote
//
//  Created by Erik Bautista on 5/16/21.
//

import UIKit
import ErrorErrorErrorUIKit
import RxSwift
import Then

class ConfigureDeviceViewController: CardModalViewController<UIView>, Bindable {
    // MARK: - Rx

    private let disposeBag = DisposeBag()

    // MARK: - Properties

    var viewModel: ConfigureDeviceViewModel!

    // MARK: - Views

    private let deviceNameLabel = UILabel().then {
        $0.font = UIFont.boldSystemFont(ofSize: 13)
        $0.textColor = .label
        $0.text = "Device Name"
        $0.numberOfLines = 0
    }

    private let nameTextField = UITextField().then {
        $0.borderStyle = .roundedRect
        $0.backgroundColor = .secondarySystemBackground
    }

    // MARK: - Contructor

    init() {
        super.init(buttonView: .primary, contentView: UIView())
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setListeners()
    }

    func bindViewModel() {
        let viewWillAppear = rx.sentMessage(#selector(UIViewController.viewWillAppear(_:)))
            .mapToVoid()
            .asDriverOnErrorJustComplete()

        let input = ConfigureDeviceViewModel.Input(
            loadTrigger: viewWillAppear,
            saveTrigger: primaryButton.rx.tap.asDriver(),
            exitTrigger: exitButton.rx.tap.asDriver(),
            name: nameTextField.rx.text.orEmpty.changed.asDriver()
        )

        let output = viewModel.transform(input, disposeBag: disposeBag)

        output.$canSave
            .asDriver()
            .drive(primaryButton.rx.isEnabled)
            .disposed(by: disposeBag)

        output.$name
            .asDriver()
            .drive(nameTextField.rx.text)
            .disposed(by: disposeBag)
    }

    override func setupViewsAndContraints() {
        super.setupViewsAndContraints()

        titleLabel.text = "Configure Device"
        descriptionLabel.text = "You can replace the name of the device now or later in settings."
        primaryButton.setTitle("Add Device", for: .normal)

        nameTextField.delegate = self

        contentView.do {
            $0.addSubview(deviceNameLabel)
            $0.addSubview(nameTextField)
            $0.subviews.forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        }

        deviceNameLabel.do {
            $0.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
            $0.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
            $0.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        }

        nameTextField.do {
            $0.topAnchor.constraint(equalTo: deviceNameLabel.bottomAnchor, constant: 8).isActive = true
            $0.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
            $0.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
            $0.heightAnchor.constraint(equalToConstant: 36).isActive = true
            $0.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        }
    }

    private func setListeners() {
        // Hide keyboard on clicked outside
        let tapGestureReconizer = UITapGestureRecognizer(target: self, action: #selector(handleTextFieldResponder))
        self.view.addGestureRecognizer(tapGestureReconizer)
    }
}

extension ConfigureDeviceViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let text = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !text.isEmpty else {
            return false
        }
        if nameTextField.isFirstResponder {
            nameTextField.resignFirstResponder()
        }
        return true
    }
}

// MARK: - Actions

extension ConfigureDeviceViewController {
    @objc private func handleTextFieldResponder(_ sender: UIGestureRecognizer) {
        if nameTextField.isFirstResponder {
            nameTextField.resignFirstResponder()
        }
    }
}
