//
//  DiscoverDeviceViewController.swift
//  WLED Remote
//
//  Created by Erik Bautista on 5/15/21.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class DiscoverDeviceViewController: UIViewController {
    // MARK: Rx

    private let disposeBag = DisposeBag()

    // MARK: ViewModel

    var viewModel: DiscoverDeviceViewModel!

    private let contentView: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = UIScreen.main.displayCornerRadius
        view.layer.cornerCurve = .continuous
        return view
    }()

    private let titleLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.text = "Select a WLED Device to Add to Your Collection"
        label.font = UIFont.boldSystemFont(ofSize: 26)
        label.textColor = UIColor.label
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    private let descriptionLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.text = "Make sure your WLED device is on and connected to the same network."
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = UIColor.label
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    private lazy var exitButton: UIButton = {
        let button = UIButton(type: .close)
        return button
    }()

    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.backgroundColor = .clear
        collectionView.register(DeviceInfoCollectionViewCell.self, forCellWithReuseIdentifier: DeviceInfoCollectionViewCell.identifier)
        return collectionView
    }()

    private let scanningSpinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: .large)
        spinner.startAnimating()
        return spinner
    }()

    private let buttonHeight: CGFloat = 48

    private lazy var primaryButton: UIButton = {
        let button = UIButton(type: .roundedRect)
        button.setTitle("Manually Add Device", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.tintColor = .label
        button.layer.cornerRadius = buttonHeight / 4
        button.backgroundColor = .secondarySystemBackground
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        contentView.addSubview(exitButton)
        contentView.addSubview(titleLabel)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(collectionView)
        contentView.addSubview(scanningSpinner)
        contentView.addSubview(primaryButton)

        view.addSubview(contentView)

        setupContraints()
        bindViewController()
    }

    private func setupContraints() {
        view.subviews.forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        contentView.subviews.forEach { $0.translatesAutoresizingMaskIntoConstraints = false }

        contentView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 6).isActive = true
        contentView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -6).isActive = true
        contentView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -6).isActive = true

        let outerYAxisInset: CGFloat = 28
        let outerXAxisInset: CGFloat = 36
        let insetSpacing: CGFloat = 8

        exitButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: outerYAxisInset).isActive = true
        exitButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -outerYAxisInset).isActive = true

        titleLabel.topAnchor.constraint(equalTo: exitButton.bottomAnchor, constant: insetSpacing).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: outerXAxisInset).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -outerXAxisInset).isActive = true

        descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: insetSpacing - 4).isActive = true
        descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: outerXAxisInset).isActive = true
        descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -outerXAxisInset).isActive = true

        collectionView.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: insetSpacing + 20).isActive = true
        collectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: outerXAxisInset).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -outerXAxisInset).isActive = true
        collectionView.heightAnchor.constraint(equalToConstant: 100).isActive = true

        scanningSpinner.topAnchor.constraint(equalTo: collectionView.topAnchor).isActive = true
        scanningSpinner.centerYAnchor.constraint(equalTo: collectionView.centerYAnchor).isActive = true
        scanningSpinner.leadingAnchor.constraint(equalTo: collectionView.leadingAnchor).isActive = true
        scanningSpinner.trailingAnchor.constraint(equalTo: collectionView.trailingAnchor).isActive = true

        primaryButton.topAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: insetSpacing + 20).isActive = true
        primaryButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: outerXAxisInset).isActive = true
        primaryButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -outerXAxisInset).isActive = true
        primaryButton.heightAnchor.constraint(equalToConstant: buttonHeight).isActive = true
        primaryButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -outerYAxisInset).isActive = true
    }

    private func bindViewController() {
        assert(viewModel != nil)
        let viewWillAppear = rx.sentMessage(#selector(UIViewController.viewWillAppear(_:)))
            .mapToVoid()
            .asDriverOnErrorJustComplete()

        collectionView.delegate = self

        let input = DiscoverDeviceViewModel.Input(scanDevicesTrigger: viewWillAppear,
                                                  devicesTrigger: viewWillAppear,
                                                  dismissTrigger: exitButton.rx.tap.asDriver(),
                                                  nextTrigger: collectionView.rx.itemSelected.asDriver())

        let output = viewModel.transform(input: input)

        let dataSource = RxCollectionViewSectionedReloadDataSource<SectionModel<String, DeviceInfoItemViewModel>>(configureCell: { _, collectionView, indexPath, item in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DeviceInfoCollectionViewCell.identifier, for: indexPath)
            if let cell = cell as? DeviceInfoCollectionViewCell {
                cell.bind(viewModel: item)
            }
            return cell
        })

        output.scannedDevices.compactMap({[SectionModel<String, DeviceInfoItemViewModel>(model: "Device", items: $0)]})
            .drive(collectionView.rx.items(dataSource: dataSource)).disposed(by: disposeBag)

        output.scannedDevices.map({ $0.isEmpty }).drive(scanningSpinner.rx.isAnimating).disposed(by: disposeBag)

        output.devices.drive().disposed(by: disposeBag)

        output.dismiss.drive()
            .disposed(by: disposeBag)

        output.next.drive()
            .disposed(by: disposeBag)
    }
}

extension DiscoverDeviceViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout {
            let numberOfItemsPerRow = 3
            let totalSpace = flowLayout.sectionInset.left + flowLayout.sectionInset.right + (flowLayout.minimumInteritemSpacing * CGFloat(numberOfItemsPerRow - 1))
            let size = (collectionView.bounds.width - totalSpace) / CGFloat(numberOfItemsPerRow)
            return CGSize(width: size, height: size)
        }
        return .zero
    }
}
