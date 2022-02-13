//
//  DiscoverDeviceViewController.swift
//  WLED Remote
//
//  Created by Erik Bautista on 5/15/21.
//

import UIKit
import ErrorErrorErrorUIKit
import RxSwift
import RxCocoa
import RxDataSources
import Then

class DiscoverDeviceViewController: CardModalViewController<UIView> {

    // MARK: - Rx

    private let disposeBag = DisposeBag()

    // MARK: - ViewModel

    let viewModel: DiscoverDeviceViewModel

    // MARK: - Views

    private let collectionView = UICollectionView(frame: .zero,
                                                  collectionViewLayout: UICollectionViewFlowLayout()).then {
        $0.backgroundColor = .clear
        $0.register(DeviceInfoCollectionViewCell.self, forCellWithReuseIdentifier: DeviceInfoCollectionViewCell.identifier)
    }

    private let scanningSpinner = UIActivityIndicatorView().then {
        $0.style = .large
        $0.startAnimating()
    }

    private let buttonHeight: CGFloat = 48

    init(viewModel: DiscoverDeviceViewModel) {
        self.viewModel = viewModel
        super.init(buttonView: .primary, contentView: UIView())
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        bindViewController()
    }

    override func setupViewsAndContraints() {
        super.setupViewsAndContraints()

        collectionView.delegate = self

        titleLabel.text = "Select a WLED Device to Add to Your Collection"
        descriptionLabel.text = "Make sure your WLED device is on and connected to the same network."

        primaryButton.setTitle("Manually Add Device", for: .normal)

        contentView.do {
            $0.addSubview(collectionView)
            $0.addSubview(scanningSpinner)
            $0.subviews.forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        }

        collectionView.do {
            $0.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
            $0.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
            $0.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
            $0.heightAnchor.constraint(equalToConstant: 100).isActive = true
            $0.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        }

        scanningSpinner.do {
            $0.topAnchor.constraint(equalTo: collectionView.topAnchor).isActive = true
            $0.centerYAnchor.constraint(equalTo: collectionView.centerYAnchor).isActive = true
            $0.leadingAnchor.constraint(equalTo: collectionView.leadingAnchor).isActive = true
            $0.trailingAnchor.constraint(equalTo: collectionView.trailingAnchor).isActive = true
        }
    }
}

extension DiscoverDeviceViewController {
    private func bindViewController() {
        let viewWillAppear = rx.sentMessage(#selector(UIViewController.viewWillAppear(_:)))
            .mapToVoid()
            .asDriverOnErrorJustComplete()

        let input = DiscoverDeviceViewModel.Input(scanDevicesTrigger: viewWillAppear,
                                                  manualDeviceTrigger: primaryButton.rx.tap.asDriver(),
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
