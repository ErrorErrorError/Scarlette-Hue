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

    // MARK: Views

    private let largeStateButtonSize: CGFloat = 30
    private let smallStateButtonSize: CGFloat = 24
    private let smallStateBottomMargin: CGFloat = 8

    private lazy var addNewDeviceButton: UIButton = {
        let image = UIImage(systemName: "plus.circle.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: largeStateButtonSize))
        let button = UIButton()
        button.setImage(image, for: .normal)
        button.tintColor = .label
        return button
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

        setupNavigationBar()
        setupCollectionView()
        setupConstraints()
        bindViewController()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        addDeviceButtonAnimation(show: false)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        addDeviceButtonAnimation(show: true)
    }

    // MARK: Setups

    private func bindViewController() {
        assert(viewModel != nil)

        let viewWillAppear = rx.sentMessage(#selector(UIViewController.viewWillAppear(_:)))
            .mapToVoid()
            .asDriverOnErrorJustComplete()

        let input = DevicesViewModel.Input(trigger: viewWillAppear,
                                           createDeviceTrigger: addNewDeviceButton.rx.tap.asDriver(),
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
            layout.estimatedItemSize = CGSize(width: collectionView.bounds.width - 32, height: 80)
        }
    }

    private func setupNavigationBar() {
        title = "Devices"
        navigationItem.largeTitleDisplayMode = .always

        guard let navigationBar = self.navigationController?.navigationBar else { return }
        navigationBar.prefersLargeTitles = true
        navigationBar.addSubview(addNewDeviceButton)
        addNewDeviceButton.translatesAutoresizingMaskIntoConstraints = false
        addNewDeviceButton.rightAnchor.constraint(equalTo: navigationBar.layoutMarginsGuide.rightAnchor, constant: -8).isActive = true
        addNewDeviceButton.bottomAnchor.constraint(equalTo: navigationBar.layoutMarginsGuide.bottomAnchor).isActive = true
        addNewDeviceButton.widthAnchor.constraint(equalTo: addNewDeviceButton.heightAnchor).isActive = true
    }

    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = nil
        collectionView.alwaysBounceVertical = true
        collectionView.register(DeviceCollectionViewCell.self, forCellWithReuseIdentifier: DeviceCollectionViewCell.identifier)
        collectionView.backgroundColor = .mainSystemBackground
    }
}

extension DevicesViewController {
    private func addDeviceButtonAnimation(show: Bool) {
        UIView.animate(withDuration: 0.2) {
            self.addNewDeviceButton.alpha = show ? 1.0 : 0.0
        }
    }

    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let height = navigationController?.navigationBar.frame.height else { return }
        resizeButtonOnScroll(for: height)
    }

    private func resizeButtonOnScroll(for height: CGFloat) {
        let smallNavHeight: CGFloat = 44.0
        let largeNavHeight: CGFloat = 96.0
        let coeff: CGFloat = {
            let delta = height - smallNavHeight
            let heightDifferenceBetweenStates = (largeNavHeight - smallNavHeight)
            return delta / heightDifferenceBetweenStates
        }()

        let factor = smallStateButtonSize / largeStateButtonSize

        let scale: CGFloat = {
            let sizeAddendumFactor = coeff * (1.0 - factor)
            return min(1.0, sizeAddendumFactor + factor)
        }()

        let sizeDiff = largeStateButtonSize * (1.0 - factor) // 8.0
        let yTranslation: CGFloat = {
            let maxYTranslation = navigationController!.navigationBar.layoutMargins.bottom - smallStateBottomMargin + sizeDiff
            return max(0, min(maxYTranslation, (maxYTranslation - coeff * (6 + sizeDiff))))
        }()

        let xTranslation = max(0, sizeDiff - coeff * sizeDiff)

        addNewDeviceButton.transform = CGAffineTransform.identity
            .scaledBy(x: scale, y: scale)
            .translatedBy(x: xTranslation, y: yTranslation)

    }
}

// MARK: - Flow layout
extension DevicesViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
    }
}
