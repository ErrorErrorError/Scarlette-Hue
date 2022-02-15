//
//  SegmentSettingsViewController.swift
//  WLED Hue
//
//  Created by Erik Bautista on 1/19/22.
//

import UIKit
import ErrorErrorErrorUIKit
import RxSwift
import RxDataSources

class SegmentSettingsViewController: CardModalViewController<UITableView> {

    // MARK: - Rx

    private let disposeBag = DisposeBag()

    // MARK: - Properties

    private let viewModel: SegmentSettingsViewModel

    // MARK: - Views

    private let startLEDsTextField = UITextField().then {
        $0.placeholder = "0"
        $0.keyboardType = .numberPad
        $0.textAlignment = .right
    }

    private let stopLEDsTextField = UITextField().then {
        $0.placeholder = "0"
        $0.keyboardType = .numberPad
        $0.textAlignment = .right
    }

    private let groupingTextField = UITextField().then {
        $0.placeholder = "0"
        $0.keyboardType = .numberPad
        $0.textAlignment = .right
    }

    private let spacingTextField = UITextField().then {
        $0.placeholder = "0"
        $0.keyboardType = .numberPad
        $0.textAlignment = .right
    }

    private let reverseSwitch = UISwitch()

    private let mirrorSwitch = UISwitch()

    init(viewModel: SegmentSettingsViewModel) {
        self.viewModel = viewModel
        let tableView = UITableView(frame: .zero, style: .plain).then {
            $0.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
            $0.allowsSelection = false
            $0.separatorStyle = .none
            $0.contentInset = .zero
            $0.backgroundColor = .secondarySystemBackground
            $0.layer.cornerRadius = 20
        }
        super.init(buttonView: .primary, contentView: tableView)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        bindViewModel()
    }

    var tableViewHeightConstraint: NSLayoutConstraint?

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        contentView.reloadData()
        contentView.layoutIfNeeded()
        tableViewHeightConstraint?.constant = contentView.contentSize.height
    }

    override func setupViewsAndContraints() {
        super.setupViewsAndContraints()

        titleLabel.text = "Segment Settings"
        descriptionLabel.isHidden = false
        descriptionLabel.text = " "
        primaryButton.setTitle("Save", for: .normal)

        startLEDsTextField.delegate = self
        stopLEDsTextField.delegate = self
        groupingTextField.delegate = self
        spacingTextField.delegate = self

        contentView.delegate = self
        contentView.dataSource = self

        tableViewHeightConstraint = contentView.heightAnchor.constraint(equalToConstant: 0)
        tableViewHeightConstraint?.isActive = true
    }

    private func bindViewModel() {
        let viewWillAppear = rx.sentMessage(#selector(UIViewController.viewWillAppear(_:)))
            .mapToVoid()
            .asDriverOnErrorJustComplete()

        let input = SegmentSettingsViewModel.Input(
            loadTrigger: viewWillAppear,
            dismissTrigger: exitButton.rx.tap.asDriver(),
            saveTrigger: primaryButton.rx.tap.asDriver(),
            start: startLEDsTextField.rx.text.orEmpty.changed.asDriver(),
            stop: stopLEDsTextField.rx.text.orEmpty.changed.asDriver(),
            grouping: groupingTextField.rx.text.orEmpty.changed.asDriver(),
            spacing: spacingTextField.rx.text.orEmpty.changed.asDriver(),
            reverse: reverseSwitch.rx.value.changed.asDriver(),
            mirror: mirrorSwitch.rx.value.changed.asDriver()
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

        output.$grouping
            .asDriver()
            .drive(groupingTextField.rx.text)
            .disposed(by: disposeBag)

        output.$spacing
            .asDriver()
            .drive(spacingTextField.rx.text)
            .disposed(by: disposeBag)

        output.$reverse
            .asDriver()
            .drive(reverseSwitch.rx.value)
            .disposed(by: disposeBag)

        output.$mirror
            .asDriver()
            .drive(mirrorSwitch.rx.value)
            .disposed(by: disposeBag)

        output.$isValid
            .asDriver()
            .drive(primaryButton.rx.isEnabled)
            .disposed(by: disposeBag)
    }
}

extension SegmentSettingsViewController: UITableViewDataSource {
    enum Sections: String, CaseIterable {
        case start = "Start"
        case stop = "Stop"
        case grouping = "Grouping"
        case spacing = "Spacing"
        case reverse = "Reverse"
        case mirror = "Mirror"
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Sections.allCases.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        var config = cell.defaultContentConfiguration()
        let section = Sections.allCases[indexPath.row]
        config.text = section.rawValue
        cell.contentConfiguration = config

        var accessory: UIView?

        switch section {
        case .start:
            accessory = startLEDsTextField
        case .stop:
            accessory = stopLEDsTextField
        case .grouping:
            accessory = groupingTextField
        case .spacing:
            accessory = spacingTextField
        case .reverse:
            accessory = reverseSwitch
        case .mirror:
            accessory = mirrorSwitch
        }

        if let textField = accessory as? UITextField {
            cell.addSubview(textField)
            textField.translatesAutoresizingMaskIntoConstraints = false
            textField.do {
                $0.trailingAnchor.constraint(equalTo: cell.layoutMarginsGuide.trailingAnchor).isActive = true
                $0.topAnchor.constraint(equalTo: cell.topAnchor).isActive = true
                $0.bottomAnchor.constraint(equalTo: cell.bottomAnchor).isActive = true
            }
        } else {
            cell.accessoryView = accessory
        }

        cell.backgroundColor = .clear
//        cell.backgroundColor = .secondarySystemBackground
        return cell
    }
}

extension SegmentSettingsViewController: UITableViewDelegate {
    
}

extension SegmentSettingsViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        if startLEDsTextField.isFirstResponder {
//            startLEDsTextField.resignFirstResponder()
//        }
//
//        if stopLEDsTextField.isFirstResponder {
//            stopLEDsTextField.resignFirstResponder()
//        }
//
//        if
        textField.resignFirstResponder()
        return true
    }
}
