//
//  DevicesViewController.swift
//  WLED Remote
//
//  Created by Erik Bautista on 5/12/21.
//

import UIKit
import RxSwift
import RxCocoa
import Then

class DevicesViewController: UICollectionViewController {
    
    // MARK: - Properties

    let viewModel: DevicesViewModel
    private var disposeBag = DisposeBag()

    // MARK: - Views

    private let largeStateButtonSize: CGFloat = 30
    private let smallStateButtonSize: CGFloat = 24
    private let smallStateBottomMargin: CGFloat = 8

    // MARK: - Lifecycle

    private lazy var addNewDeviceButton = UIButton().then {
        let config = UIImage.SymbolConfiguration(pointSize: largeStateButtonSize)
        let image = UIImage(systemName: "plus.circle.fill",
                            withConfiguration: config)
        $0.setImage(image, for: .normal)
        $0.tintColor = .label
    }

    // MARK: Constructors

    init(viewModel: DevicesViewModel) {
        self.viewModel = viewModel
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
        bindViewModel()
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

    private func bindViewModel() {
        let viewWillAppear = rx
            .sentMessage(#selector(UIViewController.viewWillAppear(_:)))
            .mapToVoid()
            .asDriverOnErrorJustComplete()

        let input = DevicesViewModel.Input(
            loadTrigger: viewWillAppear,
            addDeviceTrigger: addNewDeviceButton.rx.tap.asDriver(),
            selectedDevice: collectionView.rx.itemSelected.asDriver()
        )

        let output = viewModel.transform(input: input, disposeBag: disposeBag)

        output.$deviceList
            .asDriver()
            .drive(collectionView.rx.items) { (collectionView, index, element) in
                collectionView.dequeueReusableCell(withReuseIdentifier: DeviceCell.identifier,
                                                   for: IndexPath(row: index, section: 0))
                    .then {
                        ($0 as? DeviceCell)?.bind(element)
                    }
             }
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

        guard let navigationBar = self.navigationController?.navigationBar else { return }
        navigationBar.prefersLargeTitles = true
        navigationBar.addSubview(addNewDeviceButton)

        addNewDeviceButton.do {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.rightAnchor.constraint(equalTo: navigationBar.layoutMarginsGuide.rightAnchor, constant: -8).isActive = true
            $0.bottomAnchor.constraint(equalTo: navigationBar.layoutMarginsGuide.bottomAnchor).isActive = true
            $0.widthAnchor.constraint(equalTo: $0.heightAnchor).isActive = true
        }
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

// MARK: - Add Device Button Custom

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
    func collectionView(_ collectionView: UICollectionView,
                   layout collectionViewLayout: UICollectionViewLayout,
                   sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return .zero }
        let availableWidth = collectionView.frame.width - collectionView.safeAreaInsets.left - collectionView.safeAreaInsets.right - flowLayout.sectionInset.left - flowLayout.sectionInset.right
        return CGSize(width: availableWidth, height: 80)
    }
}
