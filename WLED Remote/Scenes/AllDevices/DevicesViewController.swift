//
//  DevicesViewController.swift
//  WLED Remote
//
//  Created by Erik Bautista on 5/12/21.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class DevicesViewController: UICollectionViewController {
    
    // MARK: Rx Stuff

    private var disposeBag = DisposeBag()

    // MARK: View Model

    var viewModel: DevicesViewModel!

    // Views
    private let addNewDevice = UIBarButtonItem(systemItem: .add)
    private let refreshControl = UIRefreshControl()

    // MARK: Constructors

    init() {
        let layout = UICollectionViewFlowLayout()
        super.init(collectionViewLayout: layout)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBar()
        setupCollectionView()
        setupConstraints()
        bindViewController()
    }

    // MARK: Setups

    private func bindViewController() {
        assert(viewModel != nil)
        let viewWillAppear = rx.sentMessage(#selector(UIViewController.viewWillAppear(_:)))
            .mapToVoid()
            .asDriverOnErrorJustComplete()
        let pull = collectionView.refreshControl!.rx.controlEvent(.valueChanged).asDriver()
        let input = DevicesViewModel.Input(trigger: Driver.merge(viewWillAppear, pull),
                                           createDeviceTrigger: addNewDevice.rx.tap.asDriver(),
                                           selection: collectionView.rx.itemSelected.asDriver())
        let output = viewModel.transform(input: input)

        let dataSource = RxCollectionViewSectionedReloadDataSource<SectionModel<String, DeviceItemViewModel>>(configureCell: { _, collectionView, indexPath, item in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DeviceCollectionViewCell.identifier, for: indexPath)
            if let cell = cell as? DeviceCollectionViewCell {
                cell.bind(item)
            }
            return cell
        })

        output.devices.compactMap({[SectionModel<String, DeviceItemViewModel>(model: "Device", items: $0)]})
            .drive(collectionView.rx.items(dataSource: dataSource)).disposed(by: disposeBag)

        output.createDevice
            .drive()
            .disposed(by: disposeBag)
        output.selectedDevice
            .drive()
            .disposed(by: disposeBag)
    }

    private func setupConstraints() {
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.estimatedItemSize = CGSize(width: collectionView.bounds.width - 32, height: 50)
        }
    }

    private func setupNavigationBar() {
        title = "Devices"
        navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.prefersLargeTitles = true

        navigationItem.setRightBarButton(addNewDevice, animated: true)
    }

    private func setupCollectionView() {
        collectionView.addSubview(refreshControl)
        collectionView.refreshControl = refreshControl
        collectionView.delegate = nil
        collectionView.dataSource = nil
        collectionView.alwaysBounceVertical = true
        collectionView.backgroundColor = .systemBackground
    }
}

// MARK: - Flow layout
extension DevicesViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
    }
}
