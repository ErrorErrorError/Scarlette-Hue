//
//  EffectSettingsViewController.swift
//  WLED Hue
//
//  Created by Erik Bautista on 2/25/22.
//

import UIKit
import RxSwift
import RxCocoa
import Then
import ErrorErrorErrorUIKit

final class EffectSettingsViewController: CardModalViewController<UITableView>, Bindable {

    // MARK: - Views

    let effectSpeedSlider = UISlider().then {
        $0.minimumValue = 0
        $0.maximumValue = 255
    }

    let effectIntensitySlider = UISlider().then {
        $0.minimumValue = 0
        $0.maximumValue = 255
    }

    // MARK: - Properties

    var viewModel: EffectSettingsViewModel!
    var disposeBag = DisposeBag()

    var tableViewHeightConstraint: NSLayoutConstraint?

    // MARK: - Constructor

    init() {
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
}

extension EffectSettingsViewController {

    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        configView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        contentView.reloadData()
        contentView.layoutIfNeeded()
        tableViewHeightConstraint?.constant = contentView.contentSize.height
    }

    // MARK: - Methods

    private func configView() {
        titleLabel.text = "Effect Settings"
        descriptionLabel.isHidden = false
        descriptionLabel.text = " "
        primaryButton.setTitle("Save", for: .normal)

        contentView.delegate = self
        contentView.dataSource = self

        tableViewHeightConstraint = contentView.heightAnchor.constraint(equalToConstant: 0)
        tableViewHeightConstraint?.isActive = true
    }

    func bindViewModel() {
        let viewWillAppear = rx.sentMessage(#selector(UIViewController.viewWillAppear(_:)))
            .mapToVoid()
            .asDriverOnErrorJustComplete()

        let input = EffectSettingsViewModel.Input(
            loadTrigger: viewWillAppear,
            exitTrigger: exitButton.rx.tap.asDriver(),
            speed: effectSpeedSlider.rx.value.changed.asDriver().compactMap({ Int($0) }),
            intensity: effectIntensitySlider.rx.value.changed.asDriver().compactMap({ Int($0) }),
            saveTrigger: primaryButton.rx.tap.asDriver()
        )

        let output = viewModel.transform(input, disposeBag: disposeBag)

        output.$speed
            .take(1)
            .map { Float($0) }
            .asDriverOnErrorJustComplete()
            .drive(effectSpeedSlider.rx.value)
            .disposed(by: disposeBag)

        output.$intensity
            .take(1)
            .map { Float($0) }
            .asDriverOnErrorJustComplete()
            .drive(effectIntensitySlider.rx.value)
            .disposed(by: disposeBag)
    }
}

// MARK: - Binders

extension EffectSettingsViewController {
    
}

// MARK: - Table View

extension EffectSettingsViewController: UITableViewDataSource {
    private enum Sections: String, CaseIterable {
        case speed = "Speed"
        case intensity = "Intensity"
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
        case .speed:
            accessory = effectSpeedSlider
        case .intensity:
            accessory = effectIntensitySlider
        }

        cell.accessoryView = accessory

        cell.backgroundColor = .clear
        return cell
    }
}

extension EffectSettingsViewController: UITableViewDelegate {
    
}
