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
import Then

class DiscoverDeviceViewController: UIViewController {
    // MARK: Rx

    private let disposeBag = DisposeBag()

    // MARK: ViewModel

    let viewModel: DiscoverDeviceViewModel

    private let contentView = UIView().then {
        $0.backgroundColor = .systemBackground
        $0.layer.cornerRadius = UIScreen.main.displayCornerRadius
        $0.layer.cornerCurve = .continuous
    }

    private let titleLabel = UILabel().then {
        $0.text = "Select a WLED Device to Add to Your Collection"
        $0.font = UIFont.boldSystemFont(ofSize: 26)
        $0.textColor = UIColor.label
        $0.textAlignment = .center
        $0.numberOfLines = 0
    }

    private let descriptionLabel = UILabel().then {
        $0.text = "Make sure your WLED device is on and connected to the same network."
        $0.font = UIFont.systemFont(ofSize: 14)
        $0.textColor = UIColor.secondaryLabel
        $0.textAlignment = .center
        $0.numberOfLines = 0
    }

    private let exitButton = UIButton(type: .close)

    private let collectionView = UICollectionView(frame: .zero,
                                                  collectionViewLayout: UICollectionViewFlowLayout()).then {
        $0.backgroundColor = .clear
        $0.register(DeviceInfoCollectionViewCell.self,
                    forCellWithReuseIdentifier: DeviceInfoCollectionViewCell.identifier)
    }

    private let scanningSpinner = UIActivityIndicatorView().then {
        $0.style = .large
        $0.startAnimating()
    }

    private let buttonHeight: CGFloat = 48

    private lazy var secondaryButton = UIButton(type: .roundedRect).then {
        $0.setTitle("Manually Add Device", for: .normal)
        $0.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        $0.tintColor = .label
        $0.layer.cornerRadius = buttonHeight / 4
        $0.backgroundColor = .secondarySystemBackground
    }

    init(viewModel: DiscoverDeviceViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        contentView.do {
            $0.addSubview(exitButton)
            $0.addSubview(titleLabel)
            $0.addSubview(descriptionLabel)
            $0.addSubview(collectionView)
            $0.addSubview(scanningSpinner)
            $0.addSubview(secondaryButton)
        }

        view.addSubview(contentView)

        setupContraints()
        collectionView.delegate = self
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

        secondaryButton.topAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: insetSpacing + 20).isActive = true
        secondaryButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: outerXAxisInset).isActive = true
        secondaryButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -outerXAxisInset).isActive = true
        secondaryButton.heightAnchor.constraint(equalToConstant: buttonHeight).isActive = true
        secondaryButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -outerYAxisInset).isActive = true
    }

    private func bindViewController() {
        let viewWillAppear = rx.sentMessage(#selector(UIViewController.viewWillAppear(_:)))
            .mapToVoid()
            .asDriverOnErrorJustComplete()

        let input = DiscoverDeviceViewModel.Input(scanDevicesTrigger: viewWillAppear,
                                                  manualDeviceTrigger: secondaryButton.rx.tap.asDriver(),
                                                  dismissTrigger: exitButton.rx.tap.asDriver(),
                                                  selectedDevice: collectionView.rx.itemSelected.asDriver())

        let output = viewModel.transform(input: input, disposeBag: disposeBag)

        let dataSource = RxCollectionViewSectionedReloadDataSource<SectionModel<String, DeviceInfoItemViewModel>>(configureCell: { _, collectionView, indexPath, item in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DeviceInfoCollectionViewCell.identifier, for: indexPath)
            if let cell = cell as? DeviceInfoCollectionViewCell {
                cell.bind(viewModel: item)
            }
            return cell
        })

        output.$devices
            .asDriver()
            .compactMap({[SectionModel<String, DeviceInfoItemViewModel>(model: "Device", items: $0)]})
            .drive(collectionView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)

        output.$devices
            .asDriver()
            .map({ $0.isEmpty })
            .drive(scanningSpinner.rx.isAnimating)
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
