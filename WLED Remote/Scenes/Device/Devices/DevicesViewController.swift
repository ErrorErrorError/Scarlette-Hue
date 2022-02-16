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
import Then

class DevicesViewController: UICollectionViewController, Bindable {
    
    // MARK: - Properties

    var viewModel: DevicesViewModel!
    private var disposeBag = DisposeBag()
    private let deleteDeviceSubject = PublishSubject<IndexPath>()
    private let editDeviceSubject = PublishSubject<IndexPath>()
    private let addDeviceSubject = PublishSubject<Void>()

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
    }

    // MARK: Setups

    func bindViewModel() {
        let viewWillAppear = rx
            .sentMessage(#selector(UIViewController.viewWillAppear(_:)))
            .mapToVoid()
            .asDriverOnErrorJustComplete()

        let input = DevicesViewModel.Input(
            loadTrigger: viewWillAppear,
            addDeviceTrigger: addDeviceSubject.asDriverOnErrorJustComplete(),
            selectDevice: collectionView.rx.itemSelected.asDriver(),
            editDevice: editDeviceSubject.asDriverOnErrorJustComplete(),
            deleteDevice: deleteDeviceSubject.asDriverOnErrorJustComplete()
        )

        let output = viewModel.transform(input, disposeBag: disposeBag)

        let dataSource = RxCollectionViewSectionedAnimatedDataSource<AnimatableSectionModel<String, DeviceItemViewModel>> {  _, collectionView, indexPath, item in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DeviceCell.identifier, for: indexPath)
            if let cell = cell as? DeviceCell {
                cell.bind(item)
            }
            return cell
        }

        output.$devices
            .asDriver()
            .compactMap { [AnimatableSectionModel<String, DeviceItemViewModel>(model: "Devices", items: $0)] }
            .drive(collectionView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
    }

    private func setupConstraints() {
        collectionView.do {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor).isActive = true
            $0.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
            $0.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor).isActive = true
            $0.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        }
    }

    private func setupNavigationBar() {
        title = "Devices"
        navigationItem.largeTitleDisplayMode = .always

        let plusConfig = UIImage.SymbolConfiguration.init(pointSize: 20, weight: .semibold)
        let plusSymbol = UIImage(systemName: "plus", withConfiguration: plusConfig)
        let addButton = UIBarButtonItem(title: "", image: plusSymbol, primaryAction: UIAction(handler: { [unowned self] _ in
            self.addDeviceSubject.onNext(())
        }), menu: nil)

        addButton.tintColor = .label

        navigationItem.setRightBarButton(addButton, animated: true)
    }

    private func setupCollectionView() {
        collectionView.do {
            $0.delegate = self
            $0.dataSource = nil
            $0.alwaysBounceVertical = true
            $0.register(DeviceCell.self, forCellWithReuseIdentifier: DeviceCell.identifier)
            $0.backgroundColor = .mainSystemBackground
            if let layout = $0.collectionViewLayout as? UICollectionViewFlowLayout {
                layout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
            }
        }
    }
}

// MARK: - Flow layout
extension DevicesViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                   layout collectionViewLayout: UICollectionViewLayout,
                   sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return .zero }
        let availableWidth = collectionView.frame.width - collectionView.safeAreaInsets.left - collectionView.safeAreaInsets.right - flowLayout.sectionInset.left - flowLayout.sectionInset.right
        return CGSize(width: availableWidth, height: 80)
    }

    override func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        configureContextMenu(indexPath: indexPath)
    }

    func configureContextMenu(indexPath: IndexPath) -> UIContextMenuConfiguration {
        let context = UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { (action) -> UIMenu? in

            let edit = UIAction(title: "Edit",
                                image: .init(systemName: "square.and.pencil"),
                                identifier: nil,
                                discoverabilityTitle: nil,
                                state: .off) { [weak self] _ in
                self?.editDeviceSubject.onNext(indexPath)
            }

            let delete = UIAction(title: "Delete",
                                  image: UIImage(systemName: "trash"),
                                  identifier: nil,
                                  discoverabilityTitle: nil,
                                  attributes: .destructive,
                                  state: .off) { [weak self] _ in
                self?.deleteDeviceSubject.onNext(indexPath)
            }
            return UIMenu(title: "Options",
                          image: nil,
                          identifier: nil,
                          options: .displayInline,
                          children: [edit,delete])
        }
        return context
    }
}
