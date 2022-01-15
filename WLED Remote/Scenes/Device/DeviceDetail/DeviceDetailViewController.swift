//
//  DeviceDetailViewController.swift
//  WLED Remote
//
//  Created by Erik Bautista on 5/12/21.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class DeviceDetailViewController: UIViewController {

    // MARK: - Rx

    private var disposeBag = DisposeBag()

    // MARK: - View Model

    let viewModel: DeviceDetailViewModel

    // MARK: - Views

    let backgroundNavigationView = GradientView().then {
        $0.layer.shadowRadius = 8.0
        $0.layer.shadowOpacity = 0.10
        $0.layer.shadowColor = UIColor.black.cgColor
        $0.layer.shadowOffset = CGSize(width: 0, height: 5)
        $0.layer.cornerCurve = .continuous
        $0.backgroundColor = .contentOverSystemBackground
        $0.layer.cornerRadius = 14
        $0.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
    }

    let moreButton = UIButton(type: .custom).then {
        let smallConfiguration = UIImage.SymbolConfiguration(scale: .large)
        let image = UIImage(systemName: "ellipsis", withConfiguration: smallConfiguration)
        $0.setImage(image, for: .normal)
        $0.backgroundColor = UIColor(red: 90/255, green: 90/255, blue: 90/255, alpha: 0.2)
        $0.layer.cornerRadius = DeviceDetailViewController.buttonSize / 2
    }

    let onSwitch = UISwitch().then {
        $0.onTintColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.20)
        $0.tintColor = UIColor(red: 90/255, green: 90/255, blue: 90/255, alpha: 0.2)
    }

    let brightnessSlider = BrightnessSlider().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
    }

    let segmentsLabel = UILabel().then {
        $0.text = "Segments"
        $0.font = UIFont.boldSystemFont(ofSize: 12)
    }

    let commonCompositionalLayout: UICollectionViewCompositionalLayout = {
        let fraction = 1.0 / 2.0
        let insets = 4.0

        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = .init(top: insets,
                                   leading: insets,
                                   bottom: insets,
                                   trailing: insets)

        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),heightDimension: .fractionalWidth(fraction / 2))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])

        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = .init(top: insets, leading: insets, bottom: insets, trailing: insets)

        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(28))
        let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize,
                                                                 elementKind: UICollectionView.elementKindSectionHeader,
                                                                 alignment: .top)

        section.boundarySupplementaryItems = [header]
        let configutationLayout = UICollectionViewCompositionalLayout(section: section)

        return configutationLayout
    }()

    lazy var segmentsCollectionView = UICollectionView(frame: .zero, collectionViewLayout: commonCompositionalLayout).then {
        $0.register(SegmentCell.self, forCellWithReuseIdentifier: SegmentCell.identifier)
        $0.register(CollectionViewHeaderCell.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")
        $0.alwaysBounceHorizontal = false
        $0.alwaysBounceVertical = true
        $0.dataSource = nil
        $0.isScrollEnabled = true
        $0.backgroundColor = .clear
        $0.allowsSelection = true
    }

    lazy var scenesCollectionView = UICollectionView(frame: .zero, collectionViewLayout: commonCompositionalLayout).then {
        $0.register(PaletteCell.self, forCellWithReuseIdentifier: PaletteCell.identifier)
        $0.register(CollectionViewHeaderCell.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")
        $0.alwaysBounceHorizontal = true
        $0.alwaysBounceVertical = false
        $0.dataSource = nil
        $0.isScrollEnabled = true
        $0.backgroundColor = .clear
        $0.allowsSelection = true
    }

    lazy var scenesStackView = UIStackView().then {
        $0.addArrangedSubview(scenesCollectionView)
        $0.axis = .vertical
        $0.spacing = 8
    }

    // MARK: - Properties

    static let buttonSize: CGFloat = 32
    private let backgroundBrightnessHeight: CGFloat = 42

    init(viewModel: DeviceDetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Lifecycle

extension DeviceDetailViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupViewsAndConstraints()
        bindViewController()
    }
}

// MARK: - Setup

extension DeviceDetailViewController {
    private func setupNavigationBar() {
        let switchBarButton = UIBarButtonItem(customView: onSwitch)
        let moreBarButton = UIBarButtonItem(customView: moreButton).then {
            $0.customView?.translatesAutoresizingMaskIntoConstraints = false
            $0.customView?.heightAnchor.constraint(equalToConstant: onSwitch.frame.height).isActive = true
            $0.customView?.widthAnchor.constraint(equalToConstant: onSwitch.frame.height).isActive = true
        }

        navigationItem.rightBarButtonItems = [switchBarButton, moreBarButton]

        let titleAppearance = UINavigationBarAppearance().then {
            $0.configureWithTransparentBackground()
            $0.shadowImage = nil
            $0.backgroundImage = nil
        }

        navigationItem.do {
            $0.largeTitleDisplayMode = .never
            $0.standardAppearance = titleAppearance
            $0.compactAppearance = titleAppearance
            $0.scrollEdgeAppearance = titleAppearance
        }
    }

    private func setupViewsAndConstraints() {
        view.backgroundColor = .mainSystemBackground

        backgroundNavigationView.addSubview(brightnessSlider)

        view.do {
            $0.addSubview(backgroundNavigationView)
            $0.addSubview(segmentsCollectionView)
            $0.subviews.forEach({ $0.translatesAutoresizingMaskIntoConstraints = false })
        }

        backgroundNavigationView.do {
            $0.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
            $0.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
            $0.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
            $0.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: backgroundBrightnessHeight).isActive = true
        }

        brightnessSlider.do {
            $0.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor).isActive = true
            $0.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor).isActive = true
            $0.bottomAnchor.constraint(equalTo: backgroundNavigationView.bottomAnchor, constant: -12).isActive = true
        }

        segmentsCollectionView.do {
            $0.topAnchor.constraint(equalTo: backgroundNavigationView.bottomAnchor).isActive = true
            $0.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
            $0.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
            $0.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        }
    }
}

// MARK: - Rx Binding

extension DeviceDetailViewController {
    private func bindViewController() {
        let input = DeviceDetailViewModel.Input(loadTrigger: Driver.just(()),
                                                moreTrigger: moreButton.rx.tap.asDriver(),
                                                on: onSwitch.rx.value.changed.asDriver(),
                                                brightness: brightnessSlider.rx.value.changed.asDriver(),
                                                selectedSegment: segmentsCollectionView.rx.itemSelected.asDriver())

        let output = viewModel.transform(input: input, disposeBag: disposeBag)

        let dataSource = RxCollectionViewSectionedReloadDataSource<SectionModel<String, SegmentItemViewModel>> {  _, collectionView, indexPath, item in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SegmentCell.identifier, for: indexPath)
            if let cell = cell as? SegmentCell {
                cell.bind(item)
            }
            return cell
        } configureSupplementaryView: { uhh, collectionView, kind, indexPath in
            let cell = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "header", for: indexPath)
            if let cell = cell as? CollectionViewHeaderCell {
                cell.bind(text: uhh.sectionModels[indexPath.row].model)
            }
            return cell
        }

        output.$deviceName
            .asDriver()
            .drive(rx.title)
            .disposed(by: disposeBag)

        output.$on
            .asDriverOnErrorJustComplete()
            .drive(onSwitch.rx.value)
            .disposed(by: disposeBag)

        output.$brightness
            .asDriverOnErrorJustComplete()
            .drive(brightnessSlider.rx.value)
            .disposed(by: disposeBag)

        output.$segments
            .asDriver()
            .compactMap { [SectionModel<String, SegmentItemViewModel>(model: "Segments", items: $0)] }
            .drive(segmentsCollectionView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)

        Driver.combineLatest(output.$segments.asDriver(), output.$on.asDriver())
            .map {
                (segments: $0.0.compactMap({ $0.segment }), on: $0.1)
            }
            .drive(animationBinding)
            .disposed(by: disposeBag)
    }

    var animationBinding: Binder<(segments: [Segment], on: Bool)> {
        Binder(self) { vc, state in
            var backgroundColors = [UIColor.clear.cgColor, UIColor.clear.cgColor]
            var deviceNameTextColor = UIColor.label

            if state.on {
                var newColors = state.segments
                    .filter { $0.on == true }
                    .compactMap { $0.colorsTuple.first }
                    .filter({ $0.reduce(0, +) != 0 })
                    .map({ UIColor(red: $0[0], green: $0[1], blue: $0[2]).cgColor })

                if newColors.count == 1 {
                    newColors.append(newColors[0])
                }

                backgroundColors = newColors

                if let first = newColors.first {
                    let color = UIColor(cgColor: first)
                    deviceNameTextColor = color.isLight ? .black : .white
                }
            }

            // Set colors to background navigation

            if let gradientLayer = vc.backgroundNavigationView.layer as? CAGradientLayer {
                gradientLayer.changeGradients(backgroundColors, animate: true)
            }

            // Animate colors on changed

            UIView.animate(withDuration: 0.2) {
                vc.setNeedsStatusBarAppearanceUpdate()

                vc.navigationItem.standardAppearance?.titleTextAttributes = [.foregroundColor: deviceNameTextColor]
                vc.navigationItem.scrollEdgeAppearance?.largeTitleTextAttributes = [.foregroundColor: deviceNameTextColor]
                vc.navigationItem.compactAppearance?.titleTextAttributes = [.foregroundColor: deviceNameTextColor]
                vc.navigationController?.navigationBar.tintColor = deviceNameTextColor
            }
        }
    }
}
