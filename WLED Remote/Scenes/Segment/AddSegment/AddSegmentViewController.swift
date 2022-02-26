//
//  AddSegmentViewController.swift
//  WLED Hue
//
//  Created by Erik Bautista on 1/15/22.
//

import UIKit
import ErrorErrorErrorUIKit
import RxSwift

class AddSegmentViewController: CardModalViewController<UIView>, Bindable {

    // MARK: - Rx

    private let disposeBag = DisposeBag()

    // MARK: - Properties

    var viewModel: AddSegmentViewModel!

    // MARK: - Views

    private let startLEDsLabel = UILabel().then {
        $0.font = UIFont.boldSystemFont(ofSize: 13)
        $0.textColor = .label
        $0.text = "Start LEDs"
        $0.numberOfLines = 0
    }

    private let startLEDsTextField = UITextField().then {
        $0.borderStyle = .roundedRect
        $0.placeholder = "0"
        $0.keyboardType = .numberPad
        $0.backgroundColor = .secondarySystemBackground
    }

    private let stopLEDsLabel = UILabel().then {
        $0.font = UIFont.boldSystemFont(ofSize: 13)
        $0.textColor = .label
        $0.text = "Stop LEDs"
        $0.numberOfLines = 0
    }

    private let stopLEDsTextField = UITextField().then {
        $0.borderStyle = .roundedRect
        $0.placeholder = "0"
        $0.keyboardType = .numberPad
        $0.backgroundColor = .secondarySystemBackground
    }

    init() {
        super.init(buttonView: .primary, contentView: UIView())
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func setupViewsAndContraints() {
        super.setupViewsAndContraints()

        titleLabel.text = "Add a Segment"
        descriptionLabel.text = "Set the start and stop LED for this new segment."
        primaryButton.setTitle("Add Segment", for: .normal)

        startLEDsTextField.delegate = self
        stopLEDsTextField.delegate = self

        contentView.do {
            $0.addSubview(startLEDsLabel)
            $0.addSubview(startLEDsTextField)
            $0.addSubview(stopLEDsLabel)
            $0.addSubview(stopLEDsTextField)
            $0.subviews.forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        }

        startLEDsLabel.do {
            $0.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor).isActive = true
            $0.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor).isActive = true
            $0.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor).isActive = true
        }

        startLEDsTextField.do {
            $0.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor).isActive = true
            $0.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor).isActive = true
            $0.topAnchor.constraint(equalTo: startLEDsLabel.bottomAnchor, constant: 8).isActive = true
        }

        stopLEDsLabel.do {
            $0.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor).isActive = true
            $0.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor).isActive = true
            $0.topAnchor.constraint(equalTo: startLEDsTextField.bottomAnchor, constant: 12).isActive = true
        }

        stopLEDsTextField.do {
            $0.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor).isActive = true
            $0.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor).isActive = true
            $0.topAnchor.constraint(equalTo: stopLEDsLabel.bottomAnchor, constant: 8).isActive = true
            $0.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor).isActive = true
        }
    }

    func bindViewModel() {
        let viewWillAppear = rx.sentMessage(#selector(UIViewController.viewWillAppear(_:)))
            .mapToVoid()
            .asDriverOnErrorJustComplete()

        let input = AddSegmentViewModel.Input(
            loadTrigger: viewWillAppear,
            dismissTrigger: exitButton.rx.tap.asDriver(),
            addTrigger: primaryButton.rx.tap.asDriver(),
            start: startLEDsTextField.rx.text.orEmpty.changed.asDriver(),
            stop: stopLEDsTextField.rx.text.orEmpty.changed.asDriver()
        )

        let output = viewModel.transform(input, disposeBag: disposeBag)

        output.$start
            .asDriver()
            .drive(startLEDsTextField.rx.text)
            .disposed(by: disposeBag)

        output.$stop
            .asDriver()
            .drive(stopLEDsTextField.rx.text)
            .disposed(by: disposeBag)

        output.$isValid
            .asDriver()
            .drive(primaryButton.rx.isEnabled)
            .disposed(by: disposeBag)
    }
}

extension AddSegmentViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if startLEDsTextField.isFirstResponder {
            startLEDsTextField.resignFirstResponder()
        }

        if stopLEDsTextField.isFirstResponder {
            stopLEDsTextField.resignFirstResponder()
        }

        return true
    }

    @objc private func handleTextFieldResponder(_ sender: UIGestureRecognizer) {
        if startLEDsTextField.isFirstResponder {
            startLEDsTextField.resignFirstResponder()
        }

        if stopLEDsTextField.isFirstResponder {
            stopLEDsTextField.resignFirstResponder()
        }
    }
}
