//
//  AddNewDeviceViewController.swift
//  WLED Remote
//
//  Created by Erik Bautista on 5/15/21.
//

import UIKit
import Alamofire
import CoreData


class DiscoverDevicesViewController: UIViewController {

    var browser = NetServiceBrowser()

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
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.textColor = UIColor.label
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    private let descriptionLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.text = "Make sure your WLED device is on and connected to the same network."
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = UIColor.secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    private lazy var exitButton: UIButton = {
        let button = UIButton(type: .close, primaryAction: UIAction(handler: { [weak self] action in
            self?.dismiss(animated: true, completion: nil)
        }))
        return button
    }()

    private lazy var devicesFoundCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.dataSource = self
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
        button.tintColor = .label
        button.layer.cornerRadius = buttonHeight / 4
        button.backgroundColor = .secondarySystemBackground
        return button
    }()

    private var devices: NSMutableArray = []

    private var services: NSMutableArray = []

    override func viewDidLoad() {
        super.viewDidLoad()

        browser = NetServiceBrowser()
        browser.delegate = self

        contentView.addSubview(exitButton)
        contentView.addSubview(titleLabel)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(devicesFoundCollectionView)
        contentView.addSubview(scanningSpinner)
        contentView.addSubview(primaryButton)

        view.addSubview(contentView)

        setupContraints()
        setupListeners()

        self.startDiscovery()
        // Try to find devices for 3 seconds
        DispatchQueue.global().asyncAfter(deadline: .now() + 3 * 60) {
            if (self.devices.count == 0) {
                // notify that there was no devices found
                self.browser.stop()
                // Show no devices found controller
            }
        }
    }

    private func setupListeners() {
        primaryButton.addAction(UIAction(handler: { action in
            // Show manual controller
        }), for: .touchUpInside)
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

        devicesFoundCollectionView.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: insetSpacing + 20).isActive = true
        devicesFoundCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: outerXAxisInset).isActive = true
        devicesFoundCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -outerXAxisInset).isActive = true
        devicesFoundCollectionView.heightAnchor.constraint(equalToConstant: 100).isActive = true

        scanningSpinner.topAnchor.constraint(equalTo: devicesFoundCollectionView.topAnchor).isActive = true
        scanningSpinner.centerYAnchor.constraint(equalTo: devicesFoundCollectionView.centerYAnchor).isActive = true
        scanningSpinner.leadingAnchor.constraint(equalTo: devicesFoundCollectionView.leadingAnchor).isActive = true
        scanningSpinner.trailingAnchor.constraint(equalTo: devicesFoundCollectionView.trailingAnchor).isActive = true

        primaryButton.topAnchor.constraint(equalTo: devicesFoundCollectionView.bottomAnchor, constant: insetSpacing + 20).isActive = true
        primaryButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: outerXAxisInset).isActive = true
        primaryButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -outerXAxisInset).isActive = true
        primaryButton.heightAnchor.constraint(equalToConstant: buttonHeight).isActive = true
        primaryButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -outerYAxisInset).isActive = true
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
}

// MARK: - Discovery
extension DiscoverDevicesViewController {
    // Start finding devices
    private func startDiscovery() {
        browser.stop()
        browser.searchForServices(ofType: "_http._tcp", inDomain: "")
    }
}

// MARK: - Net Service Delegate
extension DiscoverDevicesViewController: NetServiceDelegate {

    // When a device is found, handle and parse it
    func netServiceDidResolveAddress(_ sender: NetService) {
        // Find the IPV4 address
        guard let address = sender.addresses, let ipAddress = resolveIPv4(addresses: address) else { return }
        sender.stop()   // Just need one address

        // Verify if this is a WLED device
        AF.request("http://\(ipAddress):\(sender.port)/win", method: .get).response { data in
            switch data.result {
            case .success(_):
                // Make sure this device has not been added to the database already. If it has skip it.
                guard let managedContext = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext else {
                    return
                }

                let request = CDDevice.createFetchRequest()
                request.fetchLimit = 1
                request.predicate = NSPredicate(format: "ip == %@", ipAddress)

                do {
                    let count = try managedContext.count(for: request)
                    if count > 0 {
                        print("Device already saved in database: \(ipAddress)")
                        return
                    }
                } catch {
                    print("Could not validate it's existance in the database: \(error)")
                    return
                }

                // If there is no devices with the same IP address saved, then proceed to show it's available to add
                // Do not insert into database yet
                let device = Device(name: sender.name, ip: ipAddress, port: sender.port)
                self.devices.add(device)
                DispatchQueue.main.async {
                    self.scanningSpinner.stopAnimating()
                    self.devicesFoundCollectionView.reloadData()
                }
            case .failure(let error):
                print("error: \(error)")
            }
        }
    }

    // If there was an error resolving
    func netService(_ sender: NetService, didNotResolve errorDict: [String : NSNumber]) {
        print("Resolve error:", sender, errorDict)
        services.remove(sender)
    }

    // Parse IPv4
    func resolveIPv4(addresses: [Data]) -> String? {
        var result: String?

        for addr in addresses {
            let data = addr as NSData
            var storage = sockaddr_storage()
            data.getBytes(&storage, length: MemoryLayout<sockaddr_storage>.size)
            if Int32(storage.ss_family) == AF_INET {
                let addr4 = withUnsafePointer(to: &storage) {
                    $0.withMemoryRebound(to: sockaddr_in.self, capacity: 1) {
                        $0.pointee
                    }
                }
                if let ip = String(cString: inet_ntoa(addr4.sin_addr), encoding: .ascii) {
                    result = ip
                    break
                }
            }
        }
        return result
    }

    func netServiceDidStop(_ sender: NetService) {
        services.remove(sender)
    }
}

// MARK: - Net Service Browser Delegate
extension DiscoverDevicesViewController: NetServiceBrowserDelegate {
    func netServiceBrowserWillSearch(_ browser: NetServiceBrowser) {
        print("Search about to begin")
    }

    func netServiceBrowserDidStopSearch(_ browser: NetServiceBrowser) {
        print("Search stopped")
    }

    // Founded a service
    func netServiceBrowser(_ browser: NetServiceBrowser, didFind service: NetService, moreComing: Bool) {
        print("Found a service!")
        service.delegate = self
        service.resolve(withTimeout: 10)
        services.add(service)   // Add references so we can retain the service running
    }
}

extension DiscoverDevicesViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout {
            let numberOfItemsPerRow = 3
            let totalSpace = flowLayout.sectionInset.left + flowLayout.sectionInset.right + (flowLayout.minimumInteritemSpacing * CGFloat(numberOfItemsPerRow - 1))
            let size = (collectionView.bounds.width - totalSpace) / CGFloat(numberOfItemsPerRow)
            return CGSize(width: size, height: size)
        }
        return .zero
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let device = devices.object(at: indexPath.row) as? Device {
            browser.stop()
            let addDeviceViewController = AddDeviceViewController()
            addDeviceViewController.device = device

            UIView.transition(with: self.view, duration: 0.25, options: [.transitionCrossDissolve], animations: {
                self.view.subviews.forEach { $0.removeFromSuperview() }
                self.view.addSubview(addDeviceViewController.view)
            }, completion: {_ in
                self.addChild(addDeviceViewController)
                addDeviceViewController.didMove(toParent: self)
            })
        }
    }
}

extension DiscoverDevicesViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return devices.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DeviceInfoCollectionViewCell.identifier, for: indexPath) as! DeviceInfoCollectionViewCell
        if let device = devices.object(at: indexPath.row) as? Device {
            cell.configure(device: device)
        }
        return cell
    }
}
