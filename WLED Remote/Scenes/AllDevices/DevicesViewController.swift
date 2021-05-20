//
//  DevicesViewController.swift
//  WLED Remote
//
//  Created by Erik Bautista on 5/12/21.
//

import UIKit
import CoreData
import Alamofire
import RxSwift

class DevicesViewController: UICollectionViewController {

    enum Section {
        case main
    }

    // MARK: Type Alias

    typealias DiffableDataSource = UICollectionViewDiffableDataSource<Section, Device>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Device>

    // MARK: Data

    private lazy var dataSource = configureDataSource()
    private var devicesList: [Device] = []

    // MARK: Rx Stuff

    private var disposeBag = DisposeBag()

    // MARK: View Model

    // MARK: Views

    private let devicesLabel: UILabel = {
        let label = UILabel(frame: CGRect.zero)
        label.text = "Devices"
        return label
    }()

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

        title = "Devices"
        navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.prefersLargeTitles = true

        collectionView.delegate = self
        collectionView.dataSource = dataSource
        collectionView.register(DeviceCollectionViewCell.self, forCellWithReuseIdentifier: DeviceCollectionViewCell.identifier)
        collectionView.alwaysBounceVertical = true
        collectionView.backgroundColor = .systemBackground

        setupNavigationBar()
        setupConstraints()
        setupObservers()
        setupListeners()
        fetchDevicesFromCoreData()

        NotificationCenter.default.addObserver(self, selector: #selector(fetchDevicesFromCoreData(animation:)), name: .init("updateDevicesNotification"), object: nil)
    }

    override func viewDidAppear(_ animated: Bool) {
        requestDevicesState()
    }

    // MARK: Setups

    private func setupConstraints() {
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.estimatedItemSize = CGSize(width: collectionView.bounds.width - 32, height: 50)
        }
    }

    private func setupObservers() {
        
    }

    private func setupListeners() {}

    private func setupNavigationBar() {
        let addNewDevice = UIBarButtonItem(systemItem: .add)
        addNewDevice.target = self
        addNewDevice.action = #selector(handlePlusClicked)
        navigationItem.setRightBarButton(addNewDevice, animated: true)
    }
}

extension DevicesViewController {
    private func updateDeviceState(device: Device, state: State) {
        guard let index = devicesList.firstIndex(where: { $0.id == device.id }) else {
            return
        }

        var device = devicesList[index]
        device.state = state
        self.devicesList[index] = device
        applySnapshot(animatingDifferences: false)
    }

    private func requestDevicesState() {
        for i in devicesList.indices {
            let device = devicesList[i]
            APIClient.shared.fetchState(device: device) { [weak self] state in
                self?.updateDeviceState(device: device, state: state)
            } failure: { error in
                print("There was an error fetching device state")
            }
        }
    }

    private func clearDevices() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Device")
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedObjectContext = appDelegate.persistentContainer.viewContext
        do {
            try managedObjectContext.execute(batchDeleteRequest)
        } catch {
            print("There was an error erasing all devices.")
        }
    }

    @objc private func fetchDevicesFromCoreData(animation: Bool = true) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }

        let request = CDDevice.createFetchRequest()
        let creationSort = NSSortDescriptor(key: "created", ascending: true)
        request.sortDescriptors = [creationSort]

        let context = appDelegate.persistentContainer.viewContext

        if let fetch = try? context.fetch(request) {
            devicesList = fetch.map({ $0.asDevice() })
            requestDevicesState()
            applySnapshot()
        }
    }
}

// MARK: - Actions
extension DevicesViewController {
    @objc func handlePlusClicked() {
        let discoverDevicesViewController = DiscoverDevicesViewController()
        let cardTransitioningDelegate = CardModalTransitioningDelegate(from: self, to: discoverDevicesViewController)
        discoverDevicesViewController.modalPresentationStyle = .custom
        discoverDevicesViewController.transitioningDelegate = cardTransitioningDelegate
        present(discoverDevicesViewController, animated: true)
    }

    @objc func handleOnSwitchChanged(index: IndexPath, on: Bool) {
        if var device = dataSource.itemIdentifier(for: index),
           let arrayIndex = devicesList.firstIndex(where: { $0.id == device.id }),
           var state = device.state {
            state.on = on
            device.state = state
            devicesList[arrayIndex] = device
            applySnapshot()

            let state = State(on: on)
            APIClient.shared.updateState(device: device, state: state) {
                print("Successfully updated device")
            } failure: { error in
                print("Error updating on switch: \(String(describing: error))")
            }
        }
    }

    @objc func handleBrightnessChanged(index: IndexPath, brightness: Int) {
        if var device = dataSource.itemIdentifier(for: index),
           let arrayIndex = devicesList.firstIndex(where: { $0.id == device.id }),
           var state = device.state {
            state.bri = brightness
            device.state = state
            devicesList[arrayIndex] = device
            applySnapshot()

            let state = State(bri: brightness)
            APIClient.shared.updateState(device: device, state: state) {
                print("Successfully updated device")
            } failure: { error in
                print("Error updating brightness: \(String(describing: error))")
            }

        }
    }
}

// MARK: - UICollectionViewDelegate
extension DevicesViewController {
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let device = dataSource.itemIdentifier(for: indexPath) else {
            return
        }

        let deviceController = DeviceViewController()
        deviceController.device = device
        deviceController.modalPresentationStyle = .automatic
        navigationController?.pushViewController(deviceController, animated: true)
    }

    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        guard let device = dataSource.itemIdentifier(for: indexPath) else {
            return false
        }
        return device.state != nil
    }
}

// MARK: - UICollectionViewDiffableDataSource
extension DevicesViewController {
    func configureDataSource() -> DiffableDataSource {
        let dataSource = DiffableDataSource(collectionView: collectionView) {[weak self] collectionView, indexPath, device in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DeviceCollectionViewCell.identifier, for: indexPath) as! DeviceCollectionViewCell
            cell.configure(device)
            cell.lightSwitch.addAction(UIAction(identifier: .init("device-on-state"), handler: {[weak self] action in
                let lightSwitch = action.sender as! UISwitch
                self?.handleOnSwitchChanged(index: indexPath, on: lightSwitch.isOn)
            }), for: [.touchUpInside, .touchUpOutside])
            cell.brightnessSlider.addAction(UIAction(identifier: .init("device-brightness-state"), handler: {[weak self] action in
                let brightnessSlider = action.sender as! BrightnessSlider
                self?.handleBrightnessChanged(index: indexPath, brightness: Int(brightnessSlider.value))
            }), for: [.touchUpInside, .touchUpOutside])

            return cell
        }
        return dataSource
    }
}

// MARK: - NSDiffableSnapshot
extension DevicesViewController {
    func applySnapshot(animatingDifferences: Bool = true) {
      var snapshot = Snapshot()
      snapshot.appendSections([.main])
      snapshot.appendItems(devicesList)
      dataSource.apply(snapshot, animatingDifferences: animatingDifferences)
    }
}

// MARK: - Flow layout
extension DevicesViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
    }
}
